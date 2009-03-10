#!/usr/bin/python

import sys
sys.path.append("/usr/share/rhn")

from server import rhnSQL


DB = 'rhnsat/rhnsat@rhnsat'

from server.importlib.backendOracle import OracleBackend
from server.importlib.backendLib import DBint, DBstring, DBdateTime, DBblob

tabs = OracleBackend.tables
utabs = {}

# convert table names to uppercase
for k,v  in tabs.iteritems():
   utabs[k.upper()] = v

#PGPORT_1:NO Change
rhnSQL.initDB(DB)
h = rhnSQL.prepare("""select table_name, column_name, data_type, data_length
	from user_tab_columns""")
h.execute()
rows = h.fetchall_dict()

# 'translate' oracle type to DBtypes
ora2py = {
	'NUMBER': 	'DBint',
	'DATE': 	'DBdateTime',
	'VARCHAR2': 	'DBstring',
	'CHAR': 	'DBstring',
	'BLOB': 	'DBblob',
}

for i in rows:
    if utabs.has_key(i['table_name']):
        # table exists in backendOracle
        cols = utabs[i['table_name']]
        if cols.fields.has_key(i['column_name'].lower()):
            # column defined in backendOracle
            t = cols.fields[i['column_name'].lower()]

            # check column type
            if not isinstance(t, eval(ora2py[i['data_type']])):
                print "%s.%s:  %s vs. %s" % ( i['table_name'],
                    i['column_name'], i['data_type'], t.__class__)
            elif isinstance(t, DBstring) and t.limit <> i['data_length']:
                # for VARCHAR2/DBstring check also size
                print "%s.%s: DBstring(%d) vs. VARCHAR2(%s)" % (
                     i['table_name'], i['column_name'], t.limit, i['data_length'])
            else:
                print "%s.%s: OK" % ( i['table_name'], i['column_name'])


