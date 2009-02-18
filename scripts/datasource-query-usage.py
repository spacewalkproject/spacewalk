#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.

"""
Scan for unused datasource queries. Run from web or java with:

    ../scripts/datasource-query-usage.py **/*_queries.xml

Writes out used_queries and unused_queries files.

Be sure to remove the used_queries and unused_queries files in the directory
before re-running.
"""

import os
import os.path
import sys
import xml.parsers.expat
import commands

def start_element(name, attrs, filename):
    if name == "mode":
        query_name = attrs['name']
        grep_for_hits(filename, query_name)

def dummy_element(name):
    pass

def grep_for_hits(filename, query_name):
    cmd = "grep -r %s * | grep -v '.xml' | wc -l" \
            % query_name
    (status, output) = commands.getstatusoutput(cmd)
    hits = int(output)
    used = open("used_queries", "a")
    unused = open("unused_queries", "a")
    if hits == 0:
        print("  Unused query: %s" % query_name)
        unused.write(filename + "." + query_name + "\n")
    else:
        used.write(filename + "." + query_name + "\n")
    used.close()
    unused.close()

if __name__ == "__main__":
    cwd = os.getcwd()
    files = sys.argv[1:]
    for filename in files:
        print("Scanning %s" % filename)
        f = open(filename, 'r')
        p = xml.parsers.expat.ParserCreate()

        p.StartElementHandler = lambda x, y: start_element(x, y, os.path.basename(filename))
        p.EndElementHandler = dummy_element
        p.CharacterDataHandler = dummy_element

        p.Parse(f.read())
