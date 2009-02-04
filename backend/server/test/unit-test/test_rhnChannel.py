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
#
#
# $Id$

import sys
import time
import unittest
from server import rhnSQL, rhnChannel

DB = 'rhnuser/rhnuser@webdev'
    

class Tests(unittest.TestCase):

    def setUp(self):
        rhnSQL.initDB(DB)

    def tearDown(self):
        # Roll back any unsaved data
        rhnSQL.rollback()

    def test_new_channel_1(self):
        """Tests new channel creation"""
        cf = rhnChannel.ChannelFamily()
        cf.load_from_dict(self._new_channel_family_dict())
        cf.save()
        
        label = cf.get_label()
        vdict = self._new_channel_dict(label=label, channel_family=label)

        c = rhnChannel.Channel()
        for k, v in vdict.items():
            method = getattr(c, "set_" + k)
            method(v)
        c.save()
        channel_id = c.get_id()

        c = rhnChannel.Channel()
        c.load_by_label(label)
        for k, v in vdict.items():
            method = getattr(c, "get_" + k)
            dbv = method()
            self.assertEqual(v, dbv)
        rhnSQL.commit()
        return c
    
    def test_new_channel_2(self):
        """Tests new channel creation from dictionary"""
        cf = rhnChannel.ChannelFamily()
        cf.load_from_dict(self._new_channel_family_dict())
        cf.save()
        
        label = cf.get_label()
        vdict = self._new_channel_dict(label=label, channel_family=label)

        c = rhnChannel.Channel()
        c.load_from_dict(vdict)
        c.save()
        channel_id = c.get_id()

        c = rhnChannel.Channel()
        c.load_by_label(label)
        for k, v in vdict.items():
            method = getattr(c, "get_" + k)
            dbv = method()
            self.assertEqual(v, dbv)
        rhnSQL.commit()
        return c

    def test_new_channel_family_1(self):
        """Tests new channel family creation"""
        vdict = self._new_channel_family_dict()
        label = vdict['label']

        c = rhnChannel.ChannelFamily()
        for k, v in vdict.items():
            method = getattr(c, "set_" + k)
            method(v)
        c.save()
        channel_id = c.get_id()

        c = rhnChannel.ChannelFamily()
        c.load_by_label(label)
        for k, v in vdict.items():
            method = getattr(c, "get_" + k)
            dbv = method()
            self.assertEqual(v, dbv)
        rhnSQL.commit()
        return c

    def test_new_channel_family_2(self):
        """Tests new channel family creation from a dict"""
        vdict = self._new_channel_family_dict()
        label = vdict['label']

        c = rhnChannel.ChannelFamily()
        c.load_from_dict(vdict)
        c.save()
        channel_id = c.get_id()

        c = rhnChannel.ChannelFamily()
        c.load_by_label(label)
        for k, v in vdict.items():
            method = getattr(c, "get_" + k)
            dbv = method()
            self.assertEqual(v, dbv)
        rhnSQL.commit()
        return c

    def test_create_channels_1(self):
        """Tests rhnChannel.create_channels"""
        vdict = self._new_channel_family_dict()
        cf = rhnChannel.ChannelFamily()
        cf.load_from_dict(vdict)
        cf.save()

        cf_label = cf.get_label()

        entries = []
        for i in range(5):
            vdict = self._new_channel_dict(channel_family=cf_label)
            entries.append(vdict)

        rhnChannel.create_channels(entries)
        rhnSQL.commit()
        return entries

    def test_create_channel_families_1(self):
        """Tests rhnChannel.create_channel_families"""
        entries = []
        for i in range(5):
            vdict = self._new_channel_family_dict()
            entries.append(vdict)

        rhnChannel.create_channel_families(entries)
        rhnSQL.commit()
        for entry in entries:
            label = entry['label']
            c = rhnChannel.Channel().load_by_label(label)
            self.failIf(c.exists())
        return entries

    def test_delete_channels_1(self):
        """Tests rhnChannel.delete_channels"""
        entries = self.test_create_channels_1()
        messages = rhnChannel.delete_channels(entries)
        self.assertEqual(messages, [])
        rhnSQL.commit()
        return entries

    def test_delete_channel_families_1(self):
        """Tests rhnChannel.delete_channel_families"""
        entries = self.test_create_channel_families_1()
        messages = rhnChannel.delete_channel_families(entries)
        self.assertEqual(messages, [])
        rhnSQL.commit()
        for entry in entries:
            label = entry['label']
            c = rhnChannel.ChannelFamily().load_by_label(label)
            self.failIf(c.exists())
        return entries

    def test_delete_channel_families_2(self):
        """Tests the removal of a channel family that has a child associated"""
        c = self.test_new_channel_1()
        cf_label = c.get_channel_families()[0]

        vdict = {'label' : cf_label}
        entries = [ vdict ]
        messages = rhnChannel.delete_channel_families(entries)
        self.assertNotEqual(messages, [])
        rhnSQL.commit()
        # Just to be sure
        c = rhnChannel.ChannelFamily().load_by_label(cf_label)
        self.failUnless(c.exists())
        return entries

    def test_list_channel_families_1(self):
        """Tests rhnChannel.list_channel_families"""
        channel_families =  rhnChannel.list_channel_families()
        self.failUnless(len(channel_families) > 0)

    def test_list_channels_1(self):
        """Tests rhnChannel.list_channels"""
        channels =  rhnChannel.list_channels(pattern="redhat-%")
        self.failUnless(len(channels) > 0)

    def _new_channel_dict(self, **kwargs):
        if not hasattr(self, '_counter'):
            self._counter = 0
            
        label = kwargs.get('label')
        if label is None:
            label = 'rhn-unittest-%.3f-%s' % (time.time(), self._counter)
            self._counter = self._counter + 1

        release = kwargs.get('release') or 'release-' + label
        os = kwargs.get('os') or 'Unittest Distro'
        if kwargs.has_key('org_id'):
            org_id = kwargs['org_id']
        else:
            org_id = 'rhn-noc'

        vdict = {
            'label'             : label,
            'name'              : kwargs.get('name') or label,
            'summary'           : kwargs.get('summary') or label,
            'description'       : kwargs.get('description') or label,
            'basedir'           : kwargs.get('basedir') or '/',
            'channel_arch'      : kwargs.get('channel_arch') or 'channel-x86_64',
            'channel_families'  : [ kwargs.get('channel_family') or label ],
            'org_id'            : org_id,
            'gpg_key_url'       : kwargs.get('gpg_key_url'),
            'gpg_key_id'        : kwargs.get('gpg_key_id'),
            'gpg_key_fp'        : kwargs.get('gpg_key_fp'),
            'end_of_life'       : kwargs.get('end_of_life'),
            'dists'             : [{
                                    'release'   : release,
                                    'os'        : os,
                                }],
        }
        return vdict

    def _new_channel_family_dict(self, **kwargs):
        if not hasattr(self, '_counter'):
            self._counter = 0
            
        label = kwargs.get('label')
        if label is None:
            label = 'rhn-unittest-%.3f-%s' % (time.time(), self._counter)
            self._counter = self._counter + 1

        product_url = kwargs.get('product_url') or 'http://rhn.redhat.com'
        
        vdict = {
            'label'             : label,
            'name'              : kwargs.get('name') or label,
            'product_url'       : product_url,
        }
        return vdict

if __name__ == '__main__':
    sys.exit(unittest.main() or 0)
