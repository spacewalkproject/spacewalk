#!/usr/bin/python
#
# Summary: Support function for Debian Spacewalk Clients Tests
# License: GNU GPLv2
#

import sys
import re
import xmlrpclib
import xml.dom.minidom

sys.path.append("/usr/share/rhn/")
import up2date_client.config as up2dateConfig

class sw_deb:
    def __init__(self, fqdn, user, passwd):
        self.uri = 'https://' + fqdn + '/rpc/api'
        self.client = xmlrpclib.Server(self.uri, verbose=0)
        self.key = self.client.auth.login(user, passwd)

    def create_channel(self, params):
        name = params[0]
        arch = 'channel-' + params[1] + '-deb'
        try:
            parent = params[2]
        except IndexError:
            parent = ''
        return self.client.channel.software.create(self.key, name, name, name, arch, parent)

    def remove_channel(self, params):
        return self.client.channel.software.delete(self.key, params[0]) == 1

    def create_activationkey(self, params):
        channel = params[0]
        ak = self.client.activationkey.create(self.key, channel, '', channel, [], False)
        print ak
        if params[1:]:
            return self.client.activationkey.addChildChannels(self.key, ak, params[1:])
        return ak.endswith(channel)

    def remove_activationkey(self, params):
        ak = params[0]
        return self.client.activationkey.delete(self.key, ak) == 1

    def channel_package_list(self, params):
        channel = params[0]
        for pkg in self.client.channel.software.listAllPackages(self.key, channel):
            print pkg['id']
        return True

    def system_package_list(self, params=None):
        systemid = self.__get_systemid()
        for pkg in self.client.system.listPackages(self.key, systemid):
            print '%s-%s' % (pkg['name'], pkg['version'])
        return True

    def package_install(self, params):
        systemid = self.__get_systemid()
        for i in range(len(params)):
            params[i] = int(params[i])
        time = self.client.system.searchByName(self.key,'\w')[0]['last_checkin']
        return self.client.system.schedulePackageInstall(self.key, systemid, params, time) == 1

    def unregister(self, params=None):
        systemid = self.__get_systemid()
        return self.client.system.deleteSystems(self.key, (systemid,)) == 1

    def dispatch(self, func, param):
        method = getattr(self, func)
        result = method(param)
        print "Running %s ..." % func,
        if result:
            print 'Pass'
        else:
            print 'Fail'
        return not result

    def __get_systemid(self):
        cfg = up2dateConfig.initUp2dateConfig()
        doc = xml.dom.minidom.parse(cfg['systemIdPath'])
        for membernode in doc.getElementsByTagName("member"):
            found = False
            for node in membernode.childNodes:
                if node.nodeName == "name":
                    data = node.firstChild.data
                    if data == "system_id": found = True
                if node.nodeName == "value" and found:
                    system_id_raw = (node.firstChild.firstChild).data
                    system_id = re.match('ID-([0-9]*).*', system_id_raw).group(1)
                    return int(system_id)


if __name__ == '__main__':
    fqdn = sys.argv[1]
    user = sys.argv[2]
    passwd = sys.argv[3]
    func = sys.argv[4]
    params = sys.argv[5:]

    s = sw_deb(fqdn, user, passwd)
    sys.exit(s.dispatch(func, params))
