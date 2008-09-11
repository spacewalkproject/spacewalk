#!/usr/bin/python
import sys
import exceptions
from pprint import pprint
sys.path.append("/home/pjones/devel/rhn/devel/backend/")
from server.rhnslib import rhns_oracle
rhns_oracle.DEBUG=0

rhns_oracle.initDB()
db = rhns_oracle.DB

class IgnoreError(exceptions.Exception):
    def __init__(self):
	pass

def getTableForConstraint(constraintName):
    sql = "select table_name from user_constraints where constraint_name = :constraint_name"
    h = db.prepare(sql)
    h.execute(constraint_name = constraintName)
    val = h.fetchone_dict()
    if not val is None:
	return val['table_name']
    raise ValueError, constraintName

def getConstraintsForTable(tableName):
    sql = "select * from user_constraints where table_name = :table_name and constraint_type = 'R'"
    h = db.prepare(sql)
    h.execute(table_name = tableName)
    vals = h.fetchall_dict()
    if vals is None:
	return []
    else:
	return vals

def getColumnsForTable(table):
    sql = "select column_name from user_tab_columns where table_name = :table_name"
    h = db.prepare(sql)
    h.execute(table_name = table)
    vals = h.fetchall_dict()
    if vals is None: 
	return []
    ret = []
    for val in vals:
	ret.append(val['column_name'])
    return ret

def removeTableFromTreeVals(tree, val):
    for table in tree.keys():
	if tree[table].has_key(val):
	    del tree[table][val]
    del tree[val]

refConstraintTree = {}
tableList = []

h = db.prepare("select table_name from user_tables")
h.execute()
tables = h.fetchall_dict()

for table in tables:
    tableName = table['table_name']
    refConstraintTree[tableName] = {}
    constraints = getConstraintsForTable(tableName)
    for constraint in constraints:
	refConstraintTable = None
        try:
	    refConstraintTable = getTableForConstraint(constraint['r_constraint_name'])
	except ValueError, cn:
	    pass
	if not refConstraintTable is None:
	    refConstraintTree[tableName][refConstraintTable] = None

while 1:
    pruneTable = None
    found = 0
    try:
        for table in refConstraintTree.keys():
	    length = len(refConstraintTree[table].items())
	    if (length == 0) or (length == 1 and refConstraintTree[table].has_key(table)):
		found = 1
		pruneTable = table
		raise IgnoreError
	else:
	    break
	if found == 0:
	    break
    except IgnoreError:
	tableList.append(pruneTable)
	removeTableFromTreeVals(refConstraintTree,pruneTable)

for table in tableList:
    sys.stderr.write("%s:\n" % table)
    columns = getColumnsForTable(table)
    for column in columns:
	sys.stderr.write("\t%s\t" % column)
	if len(column) < 8:
	    sys.stderr.write("\t")
	sys.stderr.write("%s\n" % column)
    sys.stderr.write("\n")

