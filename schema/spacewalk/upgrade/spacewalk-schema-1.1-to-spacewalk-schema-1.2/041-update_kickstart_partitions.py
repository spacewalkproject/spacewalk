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
#
#
# Test for blob updates
#
# $Id$

"""
This script is meant to be used by spacewalk users upgrading from  Satellite 530 to 540
or spacewalk 1.1 to 1.2. 
The schema storing the Kickstart Partition informatino was updated between spacewalk 1.1 to 1.2 
from a  bunch of commands holding the partition info to one blob holding the partition info in rhnKsData

This script extracts partitioning specific commands and arguments from kickstart commands and merges them onto one blob
for the kickstart data.

It acquires the database information from rhn.conf

"""

import sys
sys.path.insert(0, "/usr/share/rhn")
from common.rhnConfig import CFG, initCFG
from server import rhnSQL
from server.importlib.backendLib import Table, DBblob, DBint, TableUpdate, \
    TableInsert
from pprint import pprint
from os.path import isabs
import sys 

def gen_part_line(cname, arg):
    tokens = list(arg.split())
    if not tokens:
        return ""
    if tokens[0][:4] == "swap":
        tokens[0] = "swap"
    cmds = dict ( partitions = "part",
                raids = "raid",
                volgroups = "volgroup",
                logvols = "logvol",
                include = "%include",
                custom_partition = "")
    return ("%s %s" % (cmds[cname], " ".join(tokens))).strip()

def generate_partition_snippet(kickstart):
    lines = [gen_part_line(row['name'], row['arguments']) for row in kickstart["commands"]]
    return "\n".join(lines)

def setup_db():
    initCFG('server.satellite')
    db_backend = CFG.DB_BACKEND
    db_host = CFG.DB_HOST
    db_port = CFG.DB_PORT
    db_user = CFG.DB_user
    db_password = CFG.DB_PASSWORD
    database = CFG.DB_NAME
    rhnSQL.initDB(backend=db_backend, host=db_host, port=db_port, 
                        username=db_user, password=db_password, database=database)

def main():
    setup_db()
    print "================="
    print "Updating Kickstart Commands"
    q = """select distinct ks.id, ks.org_id
            from rhnksData ks 
                     inner join rhnKickstartCommand kc on kc.KICKSTART_ID = ks.id
                     inner join rhnKickstartCommandName kcn on kcn.id = kc.KS_COMMAND_NAME_ID
            where 
                kcn.name in ('partitions','raids', 
                    'volgroups','logvols','include','custom_partition')
            order by ks.org_id
         """
    h = rhnSQL.prepare(q)
    h.execute()
    results = h.fetchall_dict()
    if results:
        kickstarts = []

        for row in results:
            kickstart = dict(id = row["id"])
            kickstarts.append(kickstart)


        q_commands = rhnSQL.prepare("""
                select kcn.name, kc.arguments 
                from rhnKickstartCommand kc 
                        inner join rhnKickstartCommandName kcn on kcn.id = kc.KS_COMMAND_NAME_ID
                where 
                    kcn.name in ('partitions','raids', 'volgroups','logvols','include','custom_partition')
                    and kc.kickstart_id=:id
                order by kcn.sort_order""")

        for kickstart in kickstarts:
            q_commands.execute(**kickstart)
            kickstart ['commands'] = q_commands.fetchall_dict()
            kickstart ['partition'] = generate_partition_snippet(kickstart)

        q_add_empty_blob =  rhnSQL.prepare ("""update rhnKSData set partition_data = empty_blob() where id = :id """)
        q_update_ksdata = rhnSQL.prepare ("""select partition_data from rhnKsData where id = :id for update """)
        for kickstart in kickstarts:
            q_add_empty_blob.execute(id = kickstart['id'])
            q_update_ksdata.execute(id = kickstart['id'])
            data = q_update_ksdata.fetchone_dict()['partition_data']
            data.write(kickstart ['partition'])

        q_delete_old_commands = rhnSQL.prepare("""delete from rhnKickstartCommand 
                            where KS_COMMAND_NAME_ID in 
                            (select id from rhnKickstartCommandName where name in ('partitions','raids', 'volgroups','logvols','include','custom_partition'))""")
        q_delete_old_commands.execute()

    q_delete_old_command_names = rhnSQL.prepare("""delete from rhnKickstartCommandName where name in ('partitions','raids', 'volgroups','logvols','include','custom_partition')""")
    q_delete_old_command_names.execute()

    rhnSQL.commit()
    rhnSQL.closeDB()
    print "Update completed."
    print "================="

if __name__ == '__main__':
    sys.exit(main() or 0)
