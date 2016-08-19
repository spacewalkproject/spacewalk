#!/usr/bin/python
#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
from rhn import rpclib


class Test:

    def __init__(self):
        self._server_url = 'http://rhnblade4.rhndev.redhat.com/XMLRPC'
        self._getserver_url = None
        self._systemid = None
        self._username = None
        self._channel_data = None
        self._package_data = None
        self._server = None
        self._getserver = None
        self._login = None
        self._header_data = None
        self._package = None

    def _get_sysid(self):
        if self._systemid is None:
            self._systemid = open("/etc/sysconfig/rhn/systemid").read()
        return self._systemid

    def _connect(self):
        if self._server is None:
            self._server = rpclib.Server(self._server_url)
        return self._server

    def login(self):
        if self._login is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._login = LoginInfo(s.up2date.login(sysid))
        return self._login

    def list_channels(self):
        if self._channel_data is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._channel_data = ChannelList(s.up2date.listChannels(sysid))
        return self._channel_data

    def list_packages(self):
        if self._package_data is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._package_data = PackagesList(s.up2date.listall(sysid))
        return self._package_data

    def list_packages_size(self):
        if self._package_data is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._package_data = s.up2date.listall_size(sysid)
        return self._package_data

    def header(self, pkglist):
        if pkglist is None:
            return None
        if self._header_data is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._package_data = s.up2date.header(sysid, pkglist)
        return self._header_data

    def package(self, package):
        if package is None:
            return None
        if self._package is None:
            s = self._connect()
            sysid = self._get_sysid()
            self._package = s.up2date.package(sysid, package)
        return self._package

    def reserve_user(self, username, password):
        ret = None
        if username is not None and password is not None:
            s = self._connect()
            sysid = self._get_sysid()
            ret = s.registration.reserve_user(username, password)
        return ret

    def new_user(self, username, password, email=None, org_id=None, org_password=None):
        if email is None or username is None or password is None:
            return None
        s = self._connect()
        ret = s.registration.new_user(username, password, email, org_id, org_password)
        return ret


class PackagesList:

    def __init__(self, packagelist):
        if packagelist is None:
            self.packagelist = None
        else:
            self.packagelist = packagelist
        self._num_packages = None
        self._name = 0
        self._version = 1
        self._release = 2
        self._epoch = 3

    def get_num_packages(self):
        if self._num_packages is None:
            self._num_packages = len(self.packagelist)
        return self._num_packages

    def _get_field(self, pack_index, field):
        if pack_index is None or field is None:
            return None
        if self.packagelist[pack_index] is None:
            return None
        return self.packagelist[pack_index][field]

    def get_name(self, pack_index):
        return self._get_field(pack_index, self._name)

    def get_version(self, pack_index):
        return self._get_field(pack_index, self._version)

    def get_release(self, pack_index):
        return self._get_field(pack_index, self._release)

    def get_epoch(self, pack_index):
        return self._get_field(pack_index, self._epoch)


class ChannelList:

    def __init__(self, channeldata=None):
        if channeldata is None:
            self.channel_list = None
        else:
            self.channel_list = channeldata

        self._last_modified = 'last_modified'
        self._description = 'description'
        self._name = 'name'
        self._local_channel = 'local_channel'
        self._arch = 'arch'
        self._parent_channel = 'parent_channel'
        self._summary = 'summary'
        self._org_id = 'org_id'
        self._id = 'id'
        self._label = 'label'
        self._num_channels = None

    def set_channel_data(self, channeldata):
        if channeldata is None:
            self.channel_list = None
        else:
            self.channel_list = channeldata

    def get_num_channels(self):
        if self._num_channels is None:
            self._num_channels = len(self.channel_list)
        return self._num_channels

    def get_last_modified(self, ch_index):
        if self.channel_list[ch_index].has_key(self._last_modified):
            return self.channel_list[ch_index][self._last_modified]
        return None

    def get_description(self, ch_index):
        if self.channel_list[ch_index].has_key(self._description):
            return self.channel_list[ch_index][self._description]
        return None

    def get_name(self, ch_index):
        if self.channel_list[ch_index].has_key(self._name):
            return self.channel_list[ch_index][self._name]
        return None

    def get_local_channel(self, ch_index):
        if self.channel_list[ch_index].has_key(self._local_channel):
            return self.channel_list[ch_index][self._local_channel]
        return None

    def get_arch(self, ch_index):
        if self.channel_list[ch_index].has_key(self._arch):
            return self.channel_list[ch_index][self._arch]
        return None

    def get_parent_channel(self, ch_index):
        if self.channel_list[ch_index].has_key(self._parent_channel):
            return self.channel_list[ch_index][self._parent_channel]
        return None

    def get_summary(self, ch_index):
        if self.channel_list[ch_index].has_key(self._summary):
            return self.channel_list[ch_index][self._summary]
        return None

    def get_org_id(self, ch_index):
        if self.channel_list[ch_index].has_key(self._org_id):
            return self.channel_list[ch_index][self._org_id]
        return None

    def get_id(self, ch_index):
        if self.channel_list[ch_index].has_key(self._id):
            return self.channel_list[ch_index][self._id]
        return None

    def get_label(self, ch_index):
        if self.channel_list[ch_index].has_key(self._label):
            return self.channel_list[ch_index][self._label]
        return None


class LoginInfo:

    def __init__(self, logininfo=None):
        if logininfo is None:
            self.login_dict = None
        else:
            self.login_dict = logininfo

        self._server_key = 'X-RHN-Server-Id'
        self._user_key = 'X-RHN-Auth-User-Id'
        self._sig_key = 'X-RHN-Auth'
        self._time_key = 'X-RHN-Auth-Server-Time'
        self._expire_key = 'X-RHN-Auth-Expire-Offset'
        self._channel_key = 'X-RHN-Auth-Channels'

    def set_login_dict(self, login_dict):
        self.login_dict = login_dict

    def get_server_id(self):
        if self.login_dict.has_key(self._server_key):
            return str(self.login_dict[self._server_key])
        return None

    def get_user_id(self):
        if self.login_dict.has_key(self._user_key):
            return self.login_dict[self._user_key]
        return None

    def get_signature(self):
        if self.login_dict.has_key(self._sig_key):
            return self.login_dict[self._sig_key]
        return None

    def get_server_time(self):
        if self.login_dict.has_key(self._time_key):
            return self.login_dict[self._time_key]
        return None

    def get_expire_offset(self):
        if self.login_dict.has_key(self._expire_key):
            return self.login_dict[self._expire_key]
        return None

    def get_auth_channels(self):
        if self.login_dict.has_key(self._channel_key):
            return self.login_dict.has_key[self._channel_key]
        return None

if __name__ == "__main__":
    t = Test()
    lg = t.login()
    print("Server ID: " + lg.get_server_id())
    print("User ID: " + lg.get_user_id())
    print("Server Time: " + lg.get_server_time())
    print("Auth: " + lg.get_signature())
    print("Expire Offset: " + lg.get_expire_offset())

    list = t.list_channels()
    print("\n")
    for i in range(list.get_num_channels()):
        print("Channel Name: " + list.get_name(i))
        print("Channel Last Modified: " + list.get_last_modified(i))
        print("Channel Description: " + list.get_description(i))
        print("Channel Local Channel: " + list.get_local_channel(i))
        print("Channel Arch: " + list.get_arch(i))
        print("Channel Parent Channel: " + list.get_parent_channel(i))
        print("Channel Summary: " + list.get_summary(i))
        print("Channel org_id: " + list.get_org_id(i))
        print("Channel id: " + list.get_id(i))
        print("Channel label: " + list.get_label(i))

    print("")
    plist = t.list_packages()
    for j in range(plist.get_num_packages()):
        print("Package Name: " + plist.get_name(j))
        print("Package Version: " + plist.get_version(j))
        print("Package Release: " + plist.get_release(j))
        print("Package Epoch: " + plist.get_epoch(j))
        print("")

    #package = t.package([plist.get_name(0), plist.get_version(0), plist.get_release(0), plist.get_epoch(j)])
    # print package
    if sys.version_info[0] == 3:
        raw_input = input
    uname = raw_input("username:")
    password = raw_input("password:")
    email = raw_input("email:")
    org_id = raw_input("ord_id:")
    org_password = raw_input("org_password:")

    print(t.reserve_user(uname, password))
    print(t.new_user(uname, password, email, org_id, org_password))
