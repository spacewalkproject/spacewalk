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
Test module for blob updates.
To create the table for this test run:

drop table test_blob_update;

create table test_blob_update 
    (id1 int not null, id2 int, val1 blob, val2 blob, nval int not null);
"""

import sys
sys.path.insert(0, "/usr/share/rhn")
from common.rhnConfig import CFG, initCFG
from server import rhnSQL
from server.importlib.backendLib import Table, DBblob, DBint, TableUpdate, \
    TableInsert
from pprint import pprint
from os.path import isabs

def setupDb():
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
    setupDb()
    q = """select cr.id as rev_id, 
                    ccon.id as content_id,
                    ccon.contents,
                    cr.CONFIG_INFO_ID as info_id,
                    cf.id as file_id,
                    cc.org_id,
                    wc.name as org_name,
                    ci.SELINUX_CTX as selinux, 
                    cfn.path as path,
                    ci.SYMLINK_TARGET_FILENAME_ID as info_target,
                    nvl( (select path from rhnCOnfigFileName where id = ci.SYMLINK_TARGET_FILENAME_ID), 'None') as name_target
           from rhnConfigContent ccon 
            inner join rhnConfigRevision cr on cr.config_content_id = ccon.id
            inner join rhnConfigFile cf on cr.CONFIG_FILE_ID  = cf.id
            inner join rhnConfigFileName cfn on cfn.id = cf.config_file_name_id
            inner join rhnConfigInfo ci on ci.id = cr.CONFIG_INFO_ID
            inner join rhnConfigChannel cc on cf.CONFIG_CHANNEL_ID = cc.id
            inner join web_customer wc on cc.org_id = wc.id
            where 
            cr.CONFIG_FILE_TYPE_ID in (select id from rhnConfigFileType where label='symlink')"""
    h = rhnSQL.prepare(q)
    h.execute()
    results = h.fetchall_dict()
    if not results:
        return
    contents = []
    for row in results:
        contents.append( dict(revision_id = row["rev_id"],
                    file_id = row ["file_id"],
                   info_id = row ["info_id"],
                   content_id = row ["content_id"],
                   path = row['path'],
                   info_target = row['info_target'],
                   name_target = row['name_target'],
                   selinux = row['selinux'],
                   org_id = row['org_id'],
                   org_name = row['org_name'],
                   symlink_target = rhnSQL.read_lob(row["contents"])))


    update_query = """update rhnConfigRevision set config_info_id =                            
        lookup_config_info(null, null, null, :selinux, lookup_config_filename(:symlink_target)) where id = :revision_id"""

    null_symlink_update_query = """update rhnConfigRevision set config_info_id =                            
        lookup_config_info(null, null, null, :selinux, null) where id = :revision_id"""

    update_cr = """ update rhnConfigRevision set config_content_id = null where id = :revision_id"""
    delete_content = """ delete from rhnConfigContent where id = :content_id"""
    bad_items = list()
    for item in contents:
        if item['symlink_target'] is None:
            bad_items.append(item)
            rhnSQL.prepare(null_symlink_update_query).execute(**item)
        else:
            if not isabs(item['symlink_target']) or len(item['symlink_target']) >= 1024:
                bad_items.append(item)
                item['symlink_target'] = item['symlink_target'][:1024]
            rhnSQL.prepare(update_query).execute(**item)
        rhnSQL.prepare(update_cr).execute(**item)
        rhnSQL.prepare(delete_content).execute(**item)

    rhnSQL.commit()
    rhnSQL.closeDB()

    msg = """ 
    The following symbolic link paths are either null or not absolute or above 1024 characters in length. 
    While entries have been added in the DB, the values have to be updated for them in the Web UI. 
    Please go to the provided url, logging in as a user with config admin/org admin role in the specified organization 
    and update the target path value accordingly.
    """
    format = """
    Path: [%(path)s]
    Symbolic link:[%(symlink_target)s]
    Update URL: https://<FQDN>/rhn/configuration/file/FileDetails.do?cfid=%(file_id)d&crid=%(revision_id)d
    Organization Id : [%(org_id)d]
    Organization Name : [%(org_name)s]
    """
    if bad_items:
        print msg
        for item in bad_items:
            print format % item

if __name__ == '__main__':
    sys.exit(main() or 0)
