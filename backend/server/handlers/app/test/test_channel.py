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

import sys
import unittest
sys.path.append('/usr/share/rhn/')
from server import rhnSQL
from common import rhnFault
from server.handlers.app import channel

#setup
db = 'webdev'
username = 'praddb'
password = 'password'
channel = channel.Channel()
commit = True
options = {'verbose': None, 'family': 'prad-channel', 'manage': None,
           'dist_release': '1.0', 'update_only': None, 'subscribe': None,
           'summary': 'none', 'create': True, 'end_of_life': None, 'label': 'yy',
           'csv': None, 'username': 'praddb', 'description': None, 'parent': None,
           'revoke_manage': None, 'update': None, 'password': 'password',
           'arch': 'channel-ia32', 'gpg_key_id': None, 'gpg_key_url': None,
           'name': 'xx', 'gpg_key_fp': None, 'list': None,
           'server': 'rhnxml.back-webdev.redhat.com', 'orgId': None,
           'revoke_subscribe': None, 'delete': None}

version = options['dist_release']

kargs = {
    'channel_id'      : 217,
    'channel_arch_id' : 500,
    'release'         : version
    }

def init_db(username, password, dbhost):
    db = "%s/%s@%s" % (username, password, dbhost)
    rhnSQL.initDB(db)

class ChannelTestCase(unittest.TestCase):
    
    def setUp(self):
        #init_db('rhnuser', 'rhnuser', db)
        rhnSQL.initDB('rhnuser/rhnuser@webdev')
        
    def tearDown(self):
        rhnSQL.rollback()

    def testauth(self):
        try:
            channel._auth(username, password)
        except rhnFault, f:
            None
            
    def testcreatechannel(self):
        params = {'gpg_key_url': '', 'channel_arch_id': 500, 'name': 'xx',
                  'gpg_key_fp': '', 'basedir': '/', 'org_id': '',
                  'end_of_life': '', 'label': 'yy', 'parent_channel': '',
                  'summary': 'none', 'id': 255, 'gpg_key_id': '', 'description': ''}
        
        ret = channel.createChannel(params, commit, username, password)
        # PGPORT_1:NO Change # 
        h = rhnSQL.prepare("""select * from rhnChannel where label = : label""")
        h.execute(label = params['label'])

        ret = h.fetchone_dict() or []

        self.assertEqual(ret, [])
        
        
    def testlistchannel(self):
        ret = channel.listChannel(username, password)

        self.assertNotEqual(ret, [])

        assert type(ret) == type([])

    def testupdatechannel(self):
        params = {'gpg_key_url': '', 'channel_arch_id': 500, 'name': 'xx-update', 'gpg_key_fp': '',
                  'basedir': '/', 'org_id': '', 'end_of_life': '', 'label': 'yy',
                  'parent_channel': '', 'summary': 'none', 'id': 255, 'gpg_key_id': '',
                  'description': ''}
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select id from rhnChannel where label = : label""")
        h.execute(label = params['label'])

        ret = h.fetchone_dict() or []

        channel_id = ret['id']
        
        old_channel_family_id = 107
        new_channel_family_id = 109
        
        ret = channel.updateChannel(params, channel_id, old_channel_family_id,
                      new_channel_family_id, commit, username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select name from rhnChannel where label = : label""")
        h.execute(label = params['label'])

        ret = h.fetchone_dict() or []
        #Errors if the name field is not updated.
        self.assertEqual(ret['name'], params['name'])
        

    def testdeletechannel(self):
        channel_id = 5294
        ret = channel.deleteChannel( channel_id, commit, username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select * from rhnChannel where id = : cid""")
        h.execute(cid = channel_id)

        ret = h.fetchone_dict() or []
        
        self.assertEqual(ret, [])
        
        
    def testlistchannelfororg(self):
        orgId = 1
        ret = channel.listChannelForOrg(orgId, username, password)
        
        assert type(ret) == type([])

    def testlookupchannel(self):
        label = 'aa'
        ret = channel.lookupChannel( label, username, password)
        if ret:
            assert type(ret) == type([])
        
    def testlookupchannelarch(self):
        label = 'aa'
        test_arch = channel.lookupChannelArch(label, username, password)
        assert type(test_arch) == type(1)
        
    def testlookuporgId(self):
        org_id =1
        ret = channel.lookupOrgId(org_id, username, password)
        if ret:
            assert type(ret) == type(1)
        
    def testupdateChannelMembership(self):
        channel_id = 5497
        channel_family_id = 109
        ret = channel.updateChannelMembership(channel_id, channel_family_id, kargs, commit,
                                              username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select * from rhnChannelFamilyMembers where channel_id = : cid """)

        h.execute(cid = channel_id)

        ret = h.fetchone_dict() or []

        self.assertNotEqual(ret, [])
        
        
    def testmoveChannelDownloads(self):
        channel_id = 5497
        old_channel_family_id = 107
        new_channel_family_id = 109
        ret = channel.moveChannelDownloads(channel_id, old_channel_family_id,
                                           new_channel_family_id, username, password)

        self.assertEqual(ret, 1)
        
    def testdeleteDist(self):
        channel_id = 505
        ret = channel.deleteDist(channel_id, username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select *
                                from rhnDistChannelMap
                               where channel_id = : cid """)

        h.execute(cid = channel_id)
        
        ret = h.fetchone_dict() or []

        self.assertEqual(ret, [])
        
    def testupdateDist(self):
        version = options['dist_release']
        kargs = {
            'channel_id'      : 217,
            'channel_arch_id' : 500,
            'release'         : version
            }
        # PGPORT_1:NO Change #
        ret = channel.updateDist(kargs, username, password)
        h = rhnSQL.prepare("""select *
                                from rhnDistChannelMap
                               where channel_id = : cid """)

        h.execute(cid = kargs['channel_id'])

        ret = h.fetchone_dict() or []
        self.assertNotEqual(ret, [])
        
    def testchannelManagePermission(self):
        ret1 = channel.channelManagePermission(options['label'], 'manage', commit,
                                               username, password)
        
        ret2 = channel.channelManagePermission(options['label'], 'subscribe', commit,
                                               username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select id from rhnchannel where label = :label""")
        h.execute(label = options['label'])

        ret = h.fetchone_dict() or []
        # PGPORT_1:NO Change #
        h2 = rhnSQL.prepare("""
             select cpr.label
               from rhnchannelpermission cp,
                    rhnchannelpermissionrole cpr
              where cp.channel_id = :cid
                and cpr.id = cp.role_id
        """)
        h2.execute(cid = ret['id'])

        ret2 = h2.fetchone_dict() or []
        if ret2:
            assert ret2['label'] in ['manage', 'subscribe']
        
    def testrevokemanageChannelPermission(self):
        ret = channel.revokeChannelPermission(options['label'], 'manage', commit,
                                              username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select id from rhnchannel where label = :label""")
        h.execute(label = options['label'])
        
        ret = h.fetchone_dict() or [] 
        # PGPORT_1:NO Change #
        h2 = rhnSQL.prepare("""
             select cpr.label
               from rhnchannelpermission cp,
                    rhnchannelpermissionrole cpr
              where cp.channel_id = :cid
                and cpr.id = cp.role_id
        """)
        h2.execute(cid = ret['id'])

        ret2 = h2.fetchone_dict() or []
        if ret2:
            assert ret2['label'] != 'manage'
        
        
    def testrevokesubscribeChannelPermission(self):
        ret = channel.revokeChannelPermission(options['label'], 'subscribe', commit,
                                              username, password)
        # PGPORT_1:NO Change #
        h = rhnSQL.prepare("""select id from rhnchannel where label = :label""")
        h.execute(label = options['label'])
        
        ret = h.fetchone_dict() or []
        # PGPORT_1:NO Change #
        h2 = rhnSQL.prepare("""
             select cpr.label
               from rhnchannelpermission cp,
                    rhnchannelpermissionrole cpr
              where cpr.id = cp.role_id
                and cp.channel_id = :cid
        """)
        h2.execute(cid = ret['id'])

        ret2 = h2.fetchone_dict() or []
        if ret2:
            assert ret2['label'] != 'subscribe'
    

if __name__ == "__main__":
    unittest.main()
    rhnSQL.rollback()
