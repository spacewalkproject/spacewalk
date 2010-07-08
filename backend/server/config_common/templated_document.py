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
# $Id$

from base_templated_document import TemplatedDocument

from common import log_debug

from server.rhnServer.server_hardware import NetworkInformation
from server.rhnServer.server_hardware import NetIfaceInformation

RHN_PREFIX = 'rhn.system.'

def var_interp_prep(server):
    # make sure we have the necessary data in the server obj
    server.reload_hardware_byid(server.getid())
    server.load_custom_info()
    return server


class ServerTemplatedDocument(TemplatedDocument):

    def __init__(self, server, start_delim=None, end_delim=None):
        TemplatedDocument.__init__(self, start_delim=start_delim, end_delim=end_delim)
        
        self.server = server

    def fallback_call(self, fname, params, defval):
        # Re-compose the macro if we don't know the function
        return self.null_call(fname, params, defval)
    
    def set_functions(self):
        self.functions.clear()
        self.functions.update({
            RHN_PREFIX + 'sid'            : self.sid,
            RHN_PREFIX + 'profile_name'   : self.profile_name,
            RHN_PREFIX + 'description'    : self.description,            
            RHN_PREFIX + 'hostname'       : self.hostname,
            RHN_PREFIX + 'ip_address'     : self.ipaddr,
            RHN_PREFIX + 'custom_info'    : self.custom_info,
            RHN_PREFIX + 'net_interface.ip_address'         : self.net_intf_ipaddr,
            RHN_PREFIX + 'net_interface.netmask'            : self.net_intf_netmask,
            RHN_PREFIX + 'net_interface.broadcast'          : self.net_intf_broadcast,
            RHN_PREFIX + 'net_interface.hardware_address'   : self.net_intf_hwaddr,
            RHN_PREFIX + 'net_interface.driver_module'      : self.net_intf_module,
        })

    #######################
    # HANDLER FUNCTIONS
    #
    # If any of these can't come up w/ a good value, they should return None
    # If None is returned, the default value will be used if provided
    # Otherwise, the empty string '' will be substituted
    def sid(self):
        return self.server.server['id']

    def profile_name(self):
        return self.server.server['name']

    def description(self):
        return self.server.server['description']

    def hostname(self):
        network_infos = self.server.hardware_by_class(NetworkInformation)
        if network_infos:
            return network_infos[0].data['hostname']
        else:
            return None

    def ipaddr(self):
        network_infos = self.server.hardware_by_class(NetworkInformation)

        if network_infos:
            return network_infos[0].data['ipaddr']
        else:
            return None

    def custom_info(self, key):
        if self.server.custom_info == None:
            log_debug(4, "no custom info", self.server)
            raise "didn't load custom info"

        if self.server.custom_info.has_key(key):
            return self.server.custom_info[key]

        return None


    def _interface_info(self, interface_name):
        infos = self.server.hardware_by_class(NetIfaceInformation)
        if infos:
            network_interfaces = infos[0].db_ifaces
        else:
            return None

        for iface in network_interfaces:
            if iface['name'] == interface_name:
                return iface
        return None
        


    def net_intf_ipaddr(self, interface_name):
        iface = self._interface_info(interface_name)

        if not iface:
            return None
        return iface['ip_addr']


    def net_intf_netmask(self, interface_name):
        iface = self._interface_info(interface_name)

        if not iface:
            return None

        return iface['netmask']


    def net_intf_broadcast(self, interface_name):
        iface = self._interface_info(interface_name)

        if not iface:
            return None

        return iface['broadcast']

    def net_intf_hwaddr(self, interface_name):
        iface = self._interface_info(interface_name)

        if not iface:
            return None

        return iface['hw_addr']


    def net_intf_module(self, interface_name):
        iface = self._interface_info(interface_name)

        if not iface:
            return None

        return iface['module']
