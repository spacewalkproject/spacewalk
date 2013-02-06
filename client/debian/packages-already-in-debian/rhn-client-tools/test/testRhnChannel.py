#!/usr/bin/python

import sys

import settestpath

from up2date_client import rhnChannel
# lots of useful util methods for building/tearing down
# test enviroments...
import testutils

import unittest


def write(blip):
    sys.stdout.write("\n|%s|\n" % blip)


class testRhnChannel(unittest.TestCase):
    def setUp(self):
        self.__setupData()
        testutils.setupConfig("channelTest1")

    def tearDown(self):
        testutils.restoreConfig()

    def __setupData(self):
        self.channelListDetails = [
            {'last_modified': '20030502050933',
             'description': '',
             'name': 'Red Hat Linux 9 i386',
             'local_channel': '0',
             'arch': 'channel-ia32',
             'parent_channel': '',
             'summary': 'Red Hat Linux 9 (Shrike) i386',
             'org_id': '',
             'id': '63',
             'label': 'redhat-linux-i386-9'}]
    
    def testGetChannelDetails(self):
        "rhnChannel.GetChannelDetails"
        res = rhnChannel.getChannelDetails()
        # the last modified will change a lot, so
        # dont bother checking it...
        write(res)
        write(self.channelListDetails)
        for i in res[0].keys():
            if i == "last_modified":
                continue
            self.assertEqual(res[0][i], self.channelListDetails[0][i])


    def testGetChannels(self):
        "Test rhnChannel.getChannels()"
        res = rhnChannel.getChannels()
        
        write(res)

    def testUpdateChannels(self):
        "Test rhnChannel.updateChannels"
        channels = rhnChannel.getChannels()
        res = rhnChannel.updateChannels(channels)

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(testRhnChannel))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest="suite")
