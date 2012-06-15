#   rhn-client-tools
#
#   Copyright (C) 2006 Red Hat, Inc.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; version 2 of the License.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
#   02110-1301  USA

import settestpath

import unittest

from up2date_client import haltree


class HalDeviceTests(unittest.TestCase):

    def test_no_parent(self):
        properties = { 'info.udi' : 'foo/bar/disk/3' }
        device = haltree.HalDevice(properties)
        
        self.assertEquals(None, device.parent_udi)

    def test_with_parent(self):
        parent_udi = 'foo/bar/parent/1'
        properties = { 'info.udi' : 'foo/bar/disk/3',
            'info.parent' : parent_udi }
        device = haltree.HalDevice(properties)
        
        self.assertEquals(parent_udi, device.parent_udi)


class HalTreeTests(unittest.TestCase):

    def setUp(self):
        properties = { 'info.udi' : 'foo/bar/computer' }
        self.head = haltree.HalDevice(properties)

        properties = { 'info.udi' : 'foo/bar/disk/3', 
            'info.parent' : 'foo/bar/computer' }
        self.child = haltree.HalDevice(properties)


    def test_add_head(self):
        tree = haltree.HalTree()
        tree.add(self.head)
        
        self.assertEquals(self.head, tree.head)

    def test_add_device_no_head(self):
        tree = haltree.HalTree()
        tree.add(self.child)
        
        self.assertEquals(None, tree.head)

    def test_add_head_single_child_child_first(self):
        tree = haltree.HalTree()
        tree.add(self.child)
        tree.add(self.head)

        self.assertEquals(self.head, tree.head)
        self.assertEquals(self.head, self.child.parent)

        self.assertEquals(1, len(self.head.children))
        self.assertEquals(self.child, self.head.children[0])

    def test_add_head_single_child_head_first(self):
        tree = haltree.HalTree()
        tree.add(self.head)
        tree.add(self.child)

        self.assertEquals(self.head, tree.head)
        self.assertEquals(self.head, self.child.parent)

        self.assertEquals(1, len(self.head.children))
        self.assertEquals(self.child, self.head.children[0])


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(HalDeviceTests))
    suite.addTest(unittest.makeSuite(HalTreeTests))
    return suite
       
if __name__ == "__main__":
    unittest.main(defaultTest="suite")
