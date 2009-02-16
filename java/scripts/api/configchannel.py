#!/usr/bin/python

import xmlrpclib
import unittest

from random import randint

from config import *

class ConfigChannel(RhnTestCase):

    def setUp(self):
        RhnTestCase.setUp(self)

    def tearDown(self):
        RhnTestCase.tearDown(self)

    def test_schedule_file_comparisons(self):

        random_int = randint(1, 1000000)
        channel_label = "apitest_channel%s" % random_int
        channel_name = "apitest channel%s" % random_int
        channel_description = "channel description"

        channel_details = client.configchannel.create(self.session_key, channel_label, channel_name, channel_description)
#        print channel_details

        path = "/tmp/test_file.sh"
        path_info = {'contents' : 'echo hello',
                    'owner' : 'root',
                    'group' : 'root',
                    'permissions' : '644',
                    'macro-start-delimiter' : '{|',
                    'macro-end-delimiter' : '|}'}
        client.configchannel.createOrUpdatePath(self.session_key, channel_label, path, False, path_info)

        actionId = client.configchannel.scheduleFileComparisons(self.session_key, channel_label, path, [SERVER_ID])

        action_details = client.schedule.listInProgressSystems(self.session_key, actionId)
#        print action_details

        self.assertTrue(len(action_details) > 0)

        # clean up from test
        client.configchannel.deleteChannels(self.session_key, [channel_label])

if __name__ == "__main__":
    unittest.main()


