#!/usr/bin/python
#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

import time
from rhn.UserDictCase import UserDictCase
from spacewalk.server import rhnSQL, rhnServer, rhnAction
from spacewalk.common import rhnConfig, rhnFlags
import server.xmlrpc.up2date
from misc_functions import create_activation_key
import misc_functions

# The Test Server class is a singleton. This allows us to avoid the long setup times between each test.


class TestServer:

    # The actual implementation
    class TestServerImplementation:

        def __init__(self):
            #start_init = time.time()

            self.filesuploaded = False

            self.options = rhnConfig.initCFG('server')
            print self.options

            mytime = time.time()
            self.test_username = username or ("test_username_%.3f" % mytime)
            self.test_password = password or ("test_password_%.3f" % mytime)
            self.test_email = email or ("%s@test_domain.com" % self.test_username)
            self.channel_arch = 'unittestarch'

            self.roles = ['org_admin']
            rhnFlags.set('outputTransportOptions', UserDictCase())

            self._init_db()
            self._init_org()
            self._init_user(self.roles)
            self._init_server()
            self._init_channels()
            self._init_up2date()

        # Sets up database connection
        def _init_db(self):
            rhnSQL.initDB()

        # creates an org
        def _init_org(self):
            self.org_id, self.org_name, self.org_password = misc_functions.create_new_org()

        # create a user. Must have called _init_client first.
        def _init_user(self, roles):
            self.testuser = misc_functions.create_new_user(username=self.test_username,
                                                           password=self.test_password,
                                                           #email = self.test_email,
                                                           org_id=self.org_id,
                                                           #org_password = self.org_password,
                                                           roles=roles)

        # create a server. Must have called _init_client and _init_user.
        def _init_server(self):
            self.testserver = misc_functions.new_server(self.testuser, self.org_id)

        # createa a new channel family and a channel associated with the channel
        # family, and add it to the server's channels.
        def _init_channels(self):
            # create a channel family.
            self.cf = misc_functions.create_channel_family()
            self.label = self.cf.get_label()

            # Create a new channel using the channel family info
            self.channel = misc_functions.create_channel(self.label, self.label, org_id=self.org_id)

            # Associate the channel family with the organization
            _insert_channel_family = """
            INSERT INTO rhnPrivateChannelFamily( channel_family_id, org_id )
            VALUES ( :channel_family_id, :org_id )"""
            insert_channel_family = rhnSQL.prepare(_insert_channel_family)
            insert_channel_family.execute(channel_family_id=self.cf.get_id(), org_id=self.org_id)
            rhnSQL.commit()

            # Associate the channel with the server
            _insert_channel = "INSERT INTO rhnServerChannel( server_id, channel_id ) VALUES ( :server_id, :channel_id )"
            insert = rhnSQL.prepare(_insert_channel)
            insert.execute(server_id=self.testserver.getid(), channel_id=self.channel.get_id())
            rhnSQL.commit()

        # instantiate an up2date object and make sure that entitlements aren't checked, which avoids some nastiness
        # that isn't needed for testing purposes...yet. Also, make sure the the server_id of the Up2date object is set
        # correctly. Violates encapsulation horribly.
        def _init_up2date(self):
            self.up2date = server.xmlrpc.up2date.Up2date()
            self.up2date.check_entitlement = 0
            self.up2date.server_id = self.testserver.getid()

        def getUp2date(self):
            return self.up2date

        # Uploads packages from directory.
        def upload_packages(self,
                            directory,
                            channel_label=None,
                            username=None,
                            password=None,
                            org_id=None,
                            force=False,
                            source=0):

            upload_label = channel_label or self.label
            upload_username = username or self.test_username
            upload_password = password or self.test_password
            upload_org_id = org_id or self.org_id

            #start_upload = time.time()
            if not self.filesuploaded or force:
                misc_functions.upload_packages(upload_label,
                                               directory,
                                               org_id=upload_org_id,
                                               username=upload_username,
                                               password=upload_password,
                                               source=source)
                self.filesuploaded = True
            #fin_upload = time.time()
            # print "Upload time: %s" % ( str( fin_upload - start_upload )

        def getServerId(self):
            return self.testserver.getid()

        def getUsername(self):
            return self.test_username

        def getPassword(self):
            return self.test_password

        def getChannel(self):
            return self.channel

        def getChannelFamily(self):
            return self.cf

        def getSystemId(self):
            return self.testserver.system_id()

    # Will contain the reference to a TestServerImplementation object
    __instance = None

    def __init__(self):
        if TestServer.__instance is None:
            TestServer.__instance = TestServer.TestServerImplementation()

        self.__dict__['_TestServer__instance'] = TestServer.__instance

    def __getattr__(self, attr):
        return getattr(TestServer.__instance, attr)

    def __setattr__(self, attr, value):
        return setattr(TestServer.__instance, attr, value)


_query_action_lookup = rhnSQL.Statement("""
    select *
      from rhnServerAction
     where server_id = :server_id
""")


def look_at_actions(server_id):
    h = rhnSQL.prepare(_query_action_lookup)
    h.execute(server_id=server_id)
    return h.fetchall_dict()


if __name__ == "__main__":
    myserver = TestServer()
    # myserver.upload_packages('/home/devel/wregglej/rpmtest')
    #handler = rhnHandler()
    # print handler.auth_system( myserver.getSystemId() )
    #up2date = myserver.getUp2date()
    #id = myserver.getSystemId()
    # print up2date.solvedep( id, ['libcaps.so'] )
    # print "Done!"
    #rhnserver = rhnServer.Server(myserver.testuser, org_id=myserver.org_id)

    fake_key = create_activation_key(
        org_id=myserver.org_id, user_id=myserver.testuser.getid(), channels=[myserver.label], server_id=myserver.getServerId())
    fake_action = rhnAction.schedule_server_action(
        myserver.getServerId(), "packages.update", action_name="Testing", delta_time=9999, org_id=myserver.org_id)
    fake_token = rhnServer.search_token(fake_key._token)

    print look_at_actions(myserver.getServerId())

    rhnFlags.set("registration_token", fake_token)
    myserver.testserver.use_token()

    print look_at_actions(myserver.getServerId())

    rhnAction.invalidate_action(myserver.getServerId(), fake_action)
    rhnSQL.rollback()
