#!/usr/bin/python
#
# Script to parse the files in a directory for all sql statements in
# those files, and output their explain plans.
#
# Author: James Slagle
#
# Stuff to fix:
#     o ???
#
# $Id:$

import sys
import os
import string
import fileinput

# optparse is 2.3, optik is old 2.2 style
try:
    from optparse import OptionParser, Option
except ImportError:
    from optik import OptionParser, Option

from server import rhnSQL

options_table = [
    Option("-v", "--verbose",
        action="count",
        help="Increase verbosity"),
    Option("-d","--db",
        action="store",
        help="db for execution and gathering of the explain plan"),
    Option("-q", "--querydir",
        action="store",
        help="harvest queries from files in this directory\n" \
             "(defaults to current directory)"),
    Option("-e","--excludefiles",
        action="append",
        help="exclude processing files of this name from query directory\n" \
             "(can be specified multiple times)"),
    Option("-p","--planfile",
        action="store",
        help="write the explain plan results to file instead of standard out"),
    Option("--debug",
        action="count",
        help="extra debugging info")
]

# starting work here
def main():

    global options_table
    parser = OptionParser(option_list=options_table)

    (options, args) = parser.parse_args()

    global verbose
    verbose = options.verbose

    global debug
    debug = options.debug

    if debug:
        print options.excludefiles

    if check_options(options):
        return 0

    if verbose:
        print "Connecting to %s " % options.db
    sys.stdout.flush()
    rhnSQL.initDB(options.db)

    if not confirm_plan_table(options.db):
        return 0  

    # get list of files in query-dir
    # for each file, 
    #   find a line that contains 'select...'
    #   read from 'select...' to end of query

    if options.querydir:
        working_dir = options.querydir
    else:
        working_dir = '.'

    if os.path.isdir(working_dir):
        for root, dirs, files in os.walk(working_dir):
            for filename in files:
                if root.find('.') >= 0 or filename[0:1] == '.':
                    continue
                else:
                    process_file(os.path.join(root,filename))
    else:
        process_file(working_dir)

    # execute explain plan for query
    # write results of explain plan to stdout/file

# harvest queries from a file and explain plan them
def process_file(filename):
    print "\n\nQueries for file:\n %s" % filename

    found_query = 0

    for line in fileinput.input(filename):
        lowerline = line.lower()
        if debug:
            print "lowerline is" + lowerline + "and found_query is" 
            print found_query

        if found_query:
            if debug:
                print "query is " + query

            query_terminator = end_of_query(0,lowerline)
            if len(query_terminator) > 0:
                if debug:
                    print "found the end of the query"
                lowerline = cleanse_query(lowerline)
                query = query + lowerline[0:lowerline.find(query_terminator)]
                found_query = 0
                if debug:
                    print "about to call ep on: \n" + query
                if explain_plan(query):
                    print "-----------------------------"
                    print query
                    get_explain_plan()
                # if debug:
                    # sys.exit()
                continue
            else:
                if debug:
                    print "adding " + lowerline + " to query"

                lowerline = cleanse_query(lowerline)

                query = query + lowerline
                continue

        start = start_of_query(lowerline)
        if len(start) > 0 and lowerline.find('mode name') < 0 and lowerline.find('query name') < 0:
            if debug:
                print "found starter of " + start
                print "found first line at " + lowerline
            found_query = 1
            lowerline = cleanse_query(lowerline)

            # see if the query is all on one line
            query_terminator = end_of_query(lowerline.find(start), lowerline)
            if len(query_terminator) > 0:
                query = lowerline[lowerline.find(start):lowerline.find(query_terminator,lowerline.find(start))]

                # want to do something special here, but for now drop the query
                found_query = 0
            else:
                query = lowerline[lowerline.find(start):len(lowerline)]

    return 1

def cleanse_query(line):

    # do some cleansing for datasource queries
    line = line.replace('%',':')
    line = line.replace('&gt;','>')
    line = line.replace('&lt;','<')
    line = line.replace('<!--','--')
    line = line.replace('?',':cleansed')

    return line

def start_of_query(line):
    starters = (
                # 'update ',
                # 'delete ',
                'select ',
                'select\n',
                'select\t',
                'adfsfasfaf '
               )

    for starter in starters:
        if line.find(starter) >= 0:
            return starter

    return ''     


def end_of_query(start, line):
    terminators = list()

    # a list of all possible query terminators to search for
    terminators = (
                   '</query>',
                   '</elaborator>',
                   # '/',
                   'eoq',
                   'eos',
                   '"',
                   ';'
                  )

    for term in terminators:
        if line.find(term,start) >= 0:

            if term == ';':
                
                if debug:
                    print 'found a semi-colon'

                # this is not robust at all, but i'll wait until the
                # corner case pops up to fix it
                if line.find('&gt;',start) >= 0 or line.find('&lt;',start) >= 0:
                    continue
                else:
                    comment = line.find('--',start)
                    if comment < 0 or (comment >= 0 and line.find(term,start) < comment):
                        if debug:
                            print 'found a query terminator of %s' % term
                        return term
                    else:
                        continue

            comment = line.find('--',start)
            if comment < 0 or (comment >= 0 and line.find(term,start) < comment):
                if debug:
                    print 'found a query terminator of %s' % term
                return term

    return ''

def explain_plan(query):
    
    q = rhnSQL.prepare("""
        delete from plan_table where statement_id = 'query_explain'
                       """)
    q.execute()

    plan = """explain plan set statement_id = 'query_explain' for """
    q = rhnSQL.prepare(plan+query)

    try:
        q.execute()
    except rhnSQL.SQLError, e:
        print "-----------------------------"
        print query + "must not be a well formed SQL query "
        print "error message was %s\n" % e
        return 0

    return 1

def get_explain_plan():


    q = rhnSQL.prepare("""
        select
            to_char(parent_id) explain_parent_id,
            to_char(id) explain_id,
            lpad(' ',2*(LEVEL-1)) || operation || '  ' || options || '  ' ||
        object_name
            explain_operation
        from
            plan_table
        start with id = 1 and statement_id = 'query_explain'
        connect by prior id = parent_id and statement_id = 'query_explain'
        order by id
    """)

    q.execute()
    
    for row in q.fetchall_dict():
        print row['explain_parent_id'] + "    " + row['explain_id'] + "    " + row['explain_operation']

    return 1


# return 1 if options aren't valid
def check_options(options):
    if not options.db:
        print "Missing --db"
        return 0
    
def confirm_plan_table(db):
    if verbose:
        print "Confirming existence of plan_table..."
    q = rhnSQL.prepare("select 1 from all_tables where table_name = 'PLAN_TABLE'")
    q.execute()
    row = q.fetchall_dict()
    if row:
        if verbose:
            print "plan_table exists"
        return 1
    else:
        if verbose:
            print "plan_table doesn't exist, creating..."
        h = rhnSQL.prepare("""
        CREATE TABLE PLAN_TABLE
        (
          STATEMENT_ID     VARCHAR2(30 BYTE),
          TIMESTAMP        DATE,
          REMARKS          VARCHAR2(80 BYTE),
          OPERATION        VARCHAR2(30 BYTE),
          OPTIONS          VARCHAR2(30 BYTE),
          OBJECT_NODE      VARCHAR2(128 BYTE),
          OBJECT_OWNER     VARCHAR2(30 BYTE),
          OBJECT_NAME      VARCHAR2(30 BYTE),
          OBJECT_INSTANCE  INTEGER,
          OBJECT_TYPE      VARCHAR2(30 BYTE),
          OPTIMIZER        VARCHAR2(255 BYTE),
          SEARCH_COLUMNS   NUMBER,
          ID               INTEGER,
          PARENT_ID        INTEGER,
          POSITION         INTEGER,
          COST             INTEGER,
          CARDINALITY      INTEGER,
          BYTES            INTEGER,
          OTHER_TAG        VARCHAR2(255 BYTE),
          PARTITION_START  VARCHAR2(255 BYTE),
          PARTITION_STOP   VARCHAR2(255 BYTE),
          PARTITION_ID     INTEGER,
          OTHER            LONG,
          DISTRIBUTION     VARCHAR2(30 BYTE)
        )
        """)
        try:
            h.execute()
        except Error:
            return 0
        return 1


if __name__ == '__main__':
    sys.exit(main() or 0)
