#!/usr/bin/python

import xmlrpclib
import unittest

from random import randint
from datetime import datetime, timedelta, date

from config import *

# Should have at least 100 free slots to run these tests, which *should*
# return all of those back to the default satellite org once finished.
CHANNEL_LABEL = "channel-apitest"
CHANNEL_NAME = "channel-apitest"
CHANNEL_SUMMARY = "dummy channel"
ARCH_LABEL = "channel-ia32"
PARENT_LABEL = ""

# ERRATA_BUGS: array of structs...(optional)
ERRATA_BUGS=[]
# ERRATA_KEYWORDS: array of strings...(optional)
ERRATA_KEYWORDS=[]
# ERRATA_PACKAGES: array of integers...(optional)
ERRATA_PACKAGES=[]
# ERRATA_CHANNELS: array of strings...(optional)
ERRATA_CHANNELS=[]

class ChannelSoftware(RhnTestCase):

    def setUp(self):
        RhnTestCase.setUp(self)

        # create a channel that will be used by various tests
        self.channel_result = client.channel.software.create(self.session_key, CHANNEL_LABEL, CHANNEL_NAME, CHANNEL_SUMMARY, ARCH_LABEL, PARENT_LABEL)

        # create an errata of each type (security, bug, enhancement) and
        # associate them with the new channel
        self.random_int = randint(1, 1000000)
        self.advisory_name = "apitest %s" % self.random_int
        SEC_ERRATA_INFO = {'synopsis' : 'test security errata',
                       'advisory_name' : self.advisory_name,
                       'advisory_release' : 1,
                       'advisory_type' : 'Security Advisory',
                       'product' : 'test product',
                       'topic' : 'test topic',
                       'description' : 'test description',
                       'references' : 'test references',
                       'notes' : 'test notes',
                       '' : '',
                       'solution' : 'test solution'}
        client.errata.create(self.session_key, SEC_ERRATA_INFO, ERRATA_BUGS, ERRATA_KEYWORDS, ERRATA_PACKAGES, True, [CHANNEL_LABEL])

        self.random_int = randint(1, 1000000)
        self.advisory_name = "apitest %s" % self.random_int
        BUG_ERRATA_INFO = {'synopsis' : 'test bug errata',
                       'advisory_name' : self.advisory_name,
                       'advisory_release' : 1,
                       'advisory_type' : 'Bug Fix Advisory',
                       'product' : 'test product',
                       'topic' : 'test topic',
                       'description' : 'test description',
                       'references' : 'test references',
                       'notes' : 'test notes',
                       '' : '',
                       'solution' : 'test solution'}
        client.errata.create(self.session_key, BUG_ERRATA_INFO, ERRATA_BUGS, ERRATA_KEYWORDS, ERRATA_PACKAGES, True, [CHANNEL_LABEL])

        self.random_int = randint(1, 1000000)
        self.advisory_name = "apitest %s" % self.random_int
        ENH_ERRATA_INFO = {'synopsis' : 'test enhancement errata',
                       'advisory_name' : self.advisory_name,
                       'advisory_release' : 1,
                       'advisory_type' : 'Product Enhancement Advisory',
                       'product' : 'test product',
                       'topic' : 'test topic',
                       'description' : 'test description',
                       'references' : 'test references',
                       'notes' : 'test notes',
                       '' : '',
                       'solution' : 'test solution'}
        client.errata.create(self.session_key, ENH_ERRATA_INFO, ERRATA_BUGS, ERRATA_KEYWORDS, ERRATA_PACKAGES, True, [CHANNEL_LABEL])

    def tearDown(self):
        result = client.channel.software.delete(self.session_key, CHANNEL_LABEL)
        RhnTestCase.tearDown(self)

    def test_list_errata_by_type(self):
        # list errata based upon type
        result = client.channel.software.listErrataByType(self.session_key, CHANNEL_LABEL, "Security Advisory")
        #print "test_list_errata_by_type: channel.software.listErrataByType: Security=", result

        for entry in result:
            self.assertTrue(entry.has_key('advisory'))
            self.assertTrue(entry.has_key('issue_date'))
            self.assertTrue(entry.has_key('update_date'))
            self.assertTrue(entry.has_key('synopsis'))
            self.assertTrue(entry.has_key('advisory_type'))
            self.assertTrue(entry.has_key('last_modified_date'))
            self.assertEquals(entry['advisory_type'], 'Security Advisory')

        result = client.channel.software.listErrataByType(self.session_key, CHANNEL_LABEL, "Bug Fix Advisory")
        #print "test_list_errata_by_type: channel.software.listErrataByType: Bug=", result

        for entry in result:
            self.assertTrue(entry.has_key('advisory'))
            self.assertTrue(entry.has_key('issue_date'))
            self.assertTrue(entry.has_key('update_date'))
            self.assertTrue(entry.has_key('synopsis'))
            self.assertTrue(entry.has_key('advisory_type'))
            self.assertTrue(entry.has_key('last_modified_date'))
            self.assertEquals(entry['advisory_type'], 'Bug Fix Advisory')

        result = client.channel.software.listErrataByType(self.session_key, CHANNEL_LABEL, "Product Enhancement Advisory")
        #print "test_list_errata_by_type: channel.software.listErrataByType: Enhancement=", result

        for entry in result:
            self.assertTrue(entry.has_key('advisory'))
            self.assertTrue(entry.has_key('issue_date'))
            self.assertTrue(entry.has_key('update_date'))
            self.assertTrue(entry.has_key('synopsis'))
            self.assertTrue(entry.has_key('advisory_type'))
            self.assertTrue(entry.has_key('last_modified_date'))
            self.assertEquals(entry['advisory_type'], 'Product Enhancement Advisory')

    def test_merge_errata_all(self):
        # merge the errata from the channel created on setup in to a new
        # channel created by this test.

        toChannelLabel = "testmergeerrataall"
        toChannelName = "test merge errata all"

        self.channel_result = client.channel.software.create(self.session_key, toChannelLabel, toChannelName, CHANNEL_SUMMARY, ARCH_LABEL, PARENT_LABEL)

        mergeResult = client.channel.software.mergeErrata(self.session_key, CHANNEL_LABEL, toChannelLabel)

        fromErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        toErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        #print "test_merge_errata_all: fromErrata list=", fromErrata
        #print "test_merge_errata_all: toErrata list=", toErrata


        # if the initial channel did not have any errata, this isn't really
        # a valid test...
        self.assertTrue(len(fromErrata) > 0)

        self.assertTrue(len(mergeResult) == len(fromErrata))
        self.assertTrue(len(fromErrata) == len(toErrata))
        self.assertTrue(fromErrata == toErrata)

        # attempt a second merge of the same errata and confirm that 
        # there is no change to the errata in the 'to channel'...
        # there shouldn't be since the channel already had those errata...
        mergeResult = client.channel.software.mergeErrata(self.session_key, CHANNEL_LABEL, toChannelLabel)
        newToErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        self.assertTrue(len(mergeResult) == 0)
        self.assertTrue(len(fromErrata) == len(toErrata))
        self.assertTrue(fromErrata == toErrata)

        # clean up from test
        client.channel.software.delete(self.session_key, toChannelLabel)

    def test_list_all_packages(self):
        results = client.channel.software.list_all_packages(self.session_key, 'centos-5.2-i386')
        for r in results:
            print r

    def test_merge_errata_by_date(self):
        # merge the errata from the channel created on setup in to a new
        # channel created by this test.

        toChannelLabel = "testmergeerratabydate"
        toChannelName = "test merge errata by date"

        self.channel_result = client.channel.software.create(self.session_key, toChannelLabel, toChannelName, CHANNEL_SUMMARY, ARCH_LABEL, PARENT_LABEL)

        yesterday = datetime.now() - timedelta(1)
        yesterday = yesterday.strftime("%Y-%m-%d")
        tomorrow = datetime.now() + timedelta(1)
        tomorrow = tomorrow.strftime("%Y-%m-%d")

        mergeResult = client.channel.software.mergeErrata(self.session_key, CHANNEL_LABEL, toChannelLabel, yesterday, tomorrow)

        fromErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        toErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        #print "test_merge_errata_by_date: fromErrata list=", fromErrata
        #print "test_merge_errata_by_date: toErrata list=", toErrata


        # if the initial channel did not have any errata, this isn't really
        # a valid test...
        self.assertTrue(len(fromErrata) > 0)

        self.assertTrue(len(mergeResult) == len(fromErrata))
        self.assertTrue(len(fromErrata) == len(toErrata))
        self.assertTrue(fromErrata == toErrata)

        # attempt a second merge where we try to merge errata for an
        # interval where we don't have any errata to merge...
        before_yesterday = datetime.now() - timedelta(5)
        before_yesterday = before_yesterday.strftime("%Y-%m-%d")

        mergeResult = client.channel.software.mergeErrata(self.session_key, CHANNEL_LABEL, toChannelLabel, before_yesterday, yesterday)
        newToErrata = client.channel.software.listErrata(self.session_key, CHANNEL_LABEL)
        self.assertTrue(len(mergeResult) == 0)
        self.assertTrue(len(fromErrata) == len(newToErrata))
        self.assertTrue(fromErrata == newToErrata)

        # clean up from test
        client.channel.software.delete(self.session_key, toChannelLabel)

if __name__ == "__main__":
    unittest.main()


