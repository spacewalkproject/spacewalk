#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
# Implements the errata.* functions for XMLRPC
#

# common modules imports
from common.rhnTranslate import _
from common import rhnFault, rhnFlags, log_debug, log_error

# server modules imports
from server.rhnLib import parseRPMName
from server import rhnSQL, rhnHandler, rhnCapability

class Errata(rhnHandler):
    """ Errata class --- retrieve (via xmlrpc) package errata. """
    def __init__(self):
        rhnHandler.__init__(self)
        # Exposed Errata functions:
        self.functions = []
        self.functions.append('GetByPackage')      # Clients v1-
        self.functions.append('getPackageErratum') # Clients v2+
        self.functions.append('getErrataInfo')     # clients v2+
        
    def GetByPackage(self, pkg, osRel):
        """ Clients v1- Get errata for a package given "n-v-r" format
            IN:  pkg:   "n-v-r" (old client call)
                        or [n,v,r]
                 osRel: OS release
            RET: a hash by errata that applies to this package
                 (ie, newer packages are available). We also limit the scope
                 for a particular osRel.
        """
        if type(pkg) == type(''): # Old client support.
            pkg = parseRPMName(pkg)
        log_debug(1, pkg, osRel)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'GetByPackage'

        # now look up the errata
        if type(pkg[0]) != type(''):
            log_error("Invalid package name: %s %s" % (type(pkg[0]), pkg[0]))
            raise rhnFault(30, _("Expected a package name, not: %s") % pkg[0])
        #bug#186996:adding synopsis field to advisory info
        #client side changes are needed to access this data.
        h = rhnSQL.prepare("""
            select distinct
                    e.id            errata_id,
                    e.advisory_type errata_type,
                    e.advisory      advisory,
                    e.topic         topic,
                    e.description   description,
                    e.synopsis      synopsis
            from
                    rhnErrata e,
                    rhnPublicChannelFamily pcf,
                    rhnChannelFamilyMembers cfm,
                    rhnErrataPackage ep,
                    rhnChannelPackage cp,
                    rhnChannelErrata ce,
                    rhnDistChannelMap dcm,
                    rhnPackage p
            where    1=1
                and p.name_id = LOOKUP_PACKAGE_NAME(:name)
                -- map to a channel
                and p.id = cp.package_id
                and cp.channel_id = dcm.channel_id
                and dcm.release = :dist
                -- map to an errata as well
                and p.id = ep.package_id
                and ep.errata_id = e.id
                -- the errata and the channel have to be linked
                and ce.channel_id = cp.channel_id
                -- and the channel has to be public
                and cp.channel_id = cfm.channel_id
                and cfm.channel_family_id = pcf.channel_family_id
                -- and get the erratum
                and e.id = ce.errata_id
        """)
        h.execute(name = pkg[0], dist = str(osRel))
        ret = []
        # sanitize the results for display in the clients
        while 1:
            row = h.fetchone_dict()
            if row is None:
                break
            for k in row.keys():
                if row[k] is None:
                    row[k] = "N/A"
            ret.append(row)
        return ret

    def getPackageErratum(self, system_id, pkg):
        """ Clients v2+ - Get errata for a package given [n,v,r,e,a,...] format

            Sing-along: You say erratum(sing), I say errata(pl)! :)
            IN:  pkg:   [n,v,r,e,s,a,ch,...]
            RET: a hash by errata that applies to this package
        """
        log_debug(5, system_id, pkg)
        if type(pkg) != type([]) or len(pkg) < 7:
            log_error("Got invalid package specification: %s" % str(pkg))
            raise rhnFault(30, _("Expected a package, not: %s") % pkg)
        # Authenticate and decode server id.
        self.auth_system(system_id)
        # log the entry
        log_debug(1, self.server_id, pkg)
        # Stuff the action in the headers:
        transport = rhnFlags.get('outputTransportOptions')
        transport['X-RHN-Action'] = 'getPackageErratum'

        name, ver, rel, epoch, arch, size, channel = pkg[:7]
        if epoch in ['', 'none', 'None']:
            epoch = None
            
        # XXX: also, should arch/size/channel ever be used?
        #bug#186996:adding synopsis field to errata info
        #client side changes are needed to access this data.
        h = rhnSQL.prepare("""
        select distinct
            e.id            errata_id,
            e.advisory_type errata_type,
            e.advisory      advisory,
            e.topic         topic,
            e.description   description,
            e.synopsis      synopsis
        from
            rhnServerChannel sc,
            rhnChannelPackage cp,
            rhnChannelErrata ce,
            rhnErrata e,
            rhnErrataPackage ep,
            rhnPackage p
        where
            p.name_id = LOOKUP_PACKAGE_NAME(:name)
        and p.evr_id = LOOKUP_EVR(:epoch, :ver, :rel)
        -- map to a channel
        and p.id = cp.package_id
        -- map to an errata as well
        and p.id = ep.package_id
        and ep.errata_id = e.id
        -- the errata and the channel have to be linked
        and e.id = ce.errata_id
        and ce.channel_id = cp.channel_id
        -- and the server has to be subscribed to the channel
        and cp.channel_id = sc.channel_id
        and sc.server_id = :server_id
        """) # " emacs sucks
        h.execute(name = name, ver = ver, rel = rel, epoch = epoch, 
                  server_id = str(self.server_id))
        ret = []
        # sanitize the results for display in the clients
        while 1:
            row = h.fetchone_dict()
            if row is None:
                break
            for k in row.keys():
                if row[k] is None:
                    row[k] = "N/A"
            ret.append(row)

        return ret

    # I don't trust this errata_id business, but chip says "trust me"
    def getErrataInfo(self, system_id, errata_id):
        log_debug(5, system_id, errata_id)
        # Authenticate the server certificate
        self.auth_system(system_id)
        # log this thing
        log_debug(1, self.server_id, errata_id)

        client_caps = rhnCapability.get_client_capabilities()
        log_debug(3,"Client Capabilities", client_caps)
        multiarch = 0
        cap_info = None
        if client_caps and client_caps.has_key('packages.update'):
            cap_info =  client_caps['packages.update']
        if cap_info and cap_info['version'] > 1:
            multiarch = 1
 
        statement = """
        select distinct
               pn.name,
               pe.epoch,
               pe.version, 
               pe.release,
               pa.label arch
        from
               rhnPackageName pn,
               rhnPackageEVR pe, 
               rhnPackage p,
               rhnPackageArch pa, 
               rhnChannelPackage cp, 
               rhnServerChannel sc,
               rhnErrataPackage ep
        where
                   ep.errata_id = :errata_id
               and ep.package_id = p.id
               and p.name_id = pn.id
               and p.evr_id = pe.id
               and p.package_arch_id = pa.id 
               and sc.server_id = :server_id
               and sc.channel_id = cp.channel_id
               and cp.package_id = p.id
        """

        h = rhnSQL.prepare(statement)
        h.execute(errata_id = errata_id, server_id = self.server_id)

        packages = h.fetchall_dict()
        ret = []
        if not packages:
            return []
        
        for package in packages:
            if package['name'] is not None:
		if package['epoch'] is None:
		   package['epoch'] = ""

                pkg_arch = ''
                if multiarch:
                    pkg_arch = package['arch'] or ''
                ret.append([package['name'], 
                            package['version'],
                            package['release'],
                            package['epoch'],
                            pkg_arch])
        return ret


#-----------------------------------------------------------------------------
if __name__ == "__main__":
    print "You can not run this module by itself"
    import sys; sys.exit(-1)
#-----------------------------------------------------------------------------

