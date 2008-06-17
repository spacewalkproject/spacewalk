#!/usr/bin/python
#
# This script checks for duplicate actions in rhnAction and
# eliminates the duplicates

import sys
import getopt
import string

import DCOracle

# the almighty help
def usage():
    print sys.argv[0], "<database_connect>"

opts, args = getopt.getopt(sys.argv[1:], "hv",
                           ["help"])

if not len(args) == 1:
    usage()
    sys.exit(-1)

database = args[0]

DB = DCOracle.Connect(database)

print "Launching SQL code..."

# Get all distinct actions
h = DB.prepare("""
select distinct method,args,action,description,version
from rhnAction
""")
# Get the ids for those actions
h_id = DB.prepare("""
select id from rhnAction
where action = :action
  and method = :method
  and args = :args
  and description = :description
  and version = :version
order by id
""")
# The update query
h_upd = DB.prepare("""
update rhnServerAction
set actionid = :new_id
where actionid = :old_id
""")
h_del = DB.prepare("delete from rhnAction where id = :del_id")

print "Executing query..."
h.execute()
# Now the data storage
print "Starting to read data..."
counter = 0
data = h.fetchone_dict()
while data:
    counter = counter + 1
    if counter % 1000 == 0:
        print "Counter: %d relations read" % (counter,)
    apply(h_id.execute, (), data)
    data_id = h_id.fetchone_dict()
    if not data_id:
        continue
    actid = data_id["id"]
    print "Looking at action id = %d" % actid, data["method"]
    # now iterate over the others
    commit = 1
    while 1:
        dupdata = h_id.fetchone_dict()
        if not dupdata:
            break
        dupid = dupdata["id"]
        print "\tduplicate found: id = %d" % dupid, data["method"]
        h_upd.execute(new_id = actid, old_id = dupid)
        h_del.execute(del_id = dupid)
        commit = commit + 1
        if commit % 200 == 0:
            print "COMMIT update"
            DB.commit()
    DB.commit()
    data = h.fetchone_dict()
    
