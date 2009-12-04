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

# system module imports
import string
from rhn.rpclib import xmlrpclib
import random

# common modules imports
from common import rhnCache, rhnFlags, log_debug, CFG, rhnFault
from common.rhnTranslate import _
from rhn.common import rhn_rpm

# server modules imports
from server import rhnChannel, rhnSQL, rhnHandler, rhnLib

# Applet class --- retrieve (via xmlrpc) date required for applet
# functionality
class Applet(rhnHandler):
    def __init__(self):
        rhnHandler.__init__(self)
        # Exposed Errata functions:
        self.functions = []
        self.functions.append("poll_status")
        self.functions.append("poll_packages")
        self.functions.append("tie_uuid")
        self.functions.append("has_base_channel")

    _query_lookup_server = rhnSQL.Statement("""
        select s.id
          from rhnServer s,
               rhnServerUuid su
         where su.uuid = :uuid
           and su.server_id = s.id
         order by modified desc
    """)
    _query_lookup_base_channel = rhnSQL.Statement("""
        select c.label
          from rhnChannel c,
               rhnServerChannel sc
         where sc.server_id = :server_id
           and sc.channel_id = c.id
           and c.parent_channel is null
    """)
    def has_base_channel(self, uuid):
        log_debug(1, uuid)
        # Verifies if a system has a base channel
        h = rhnSQL.prepare(self._query_lookup_server)
        h.execute(uuid=uuid)
        row = h.fetchone_dict()
        if not row:
            raise rhnFault(140, 
                _("Your system was not found in the RHN database"), 
                explain=0)
        server_id = row['id']

        h = rhnSQL.prepare(self._query_lookup_base_channel)
        h.execute(server_id=server_id)
        row = h.fetchone_dict()
        if row:
            return 1
        return 0


    # ties a uuid to an rhnServer.id
    def tie_uuid(self, systemid, uuid):
        log_debug(1, uuid)
        systemid = str(systemid)
        uuid = str(uuid)
        
        server = self.auth_system(systemid)
        if not uuid:
            # Nothing to do
            return

        server.update_uuid(uuid)
        return 1
            
    # return our sttaus - for now a dummy function
    def poll_status(self):
        checkin_interval = (CFG.CHECKIN_INTERVAL + 
            random.random() * CFG.CHECKIN_INTERVAL_MAX_OFFSET)
        return { 
            'checkin_interval'  : int(checkin_interval), 
            'server_status'     : 'normal' 
        }
    
    # poll for latest packages for the RHN Applet
    def poll_packages(self, release, server_arch, timestamp = 0, uuid = None):
        log_debug(1, release, server_arch, timestamp, uuid)

        # make sure we're dealing with strings here
        release = str(release)
        server_arch = rhnLib.normalize_server_arch(server_arch)
        timestamp = str(timestamp)
        uuid = str(uuid)
        
        # get a list of acceptable channels
        channel_list = []
        
        channel_list = rhnChannel.applet_channels_for_uuid(uuid)

        # it's possible the tie between uuid and rhnServer.id wasn't yet
        # made, default to normal behavior
        if not channel_list:
            channel_list = rhnChannel.get_channel_for_release_arch(release, 
                                                                   server_arch)
            channel_list = [channel_list]
        # bork if no channels returned
        if not channel_list:
            log_debug(8, "No channels for release = '%s', arch = '%s', uuid = '%s'" % (
                release, server_arch, uuid))
            return { 'last_modified' : 0, 'contents' : [] }
        
        last_channel_changed_ts = max(map(lambda a: a["last_modified"], channel_list))

        # make satellite content override a cache caused by hosted
        last_channel_changed_ts = str(long(last_channel_changed_ts) + 1)

        # gotta be careful about channel unsubscriptions...
        client_cache_invalidated = None

        # we return rhnServer.channels_changed for each row
        # in the satellite case, pluck it off the first...
        if channel_list[0].has_key("server_channels_changed"):
           sc_ts = channel_list[0]["server_channels_changed"]

           if sc_ts and (sc_ts >= last_channel_changed_ts):
               client_cache_invalidated = 1
               
        
        if (last_channel_changed_ts <= timestamp) and (not client_cache_invalidated):
            # XXX: I hate these freaking return codes that return
            # different members in the dictinary depending on what
            # sort of data you get
            log_debug(3, "Client has current data")
            return { 'use_cached_copy' : 1 }

        # we'll have to return something big - compress
        rhnFlags.set("compress_response", 1)                        
        
        # Mark the response as being already XMLRPC-encoded
        rhnFlags.set("XMLRPC-Encoded-Response", 1)

        # next, check the cache if we have something with this timestamp
        label_list = map(lambda a: str(a["id"]), channel_list)
        label_list.sort()
        log_debug(4, "label_list", label_list)
        cache_key = "applet-poll-%s" % string.join(label_list, "-")
        
        ret = rhnCache.get(cache_key, last_channel_changed_ts)
        if ret: # we have a good entry with matching timestamp
            log_debug(3, "Cache HIT for", cache_key)
            return ret

        # damn, need to do some real work from chip's requirements:
        # The package list should be an array of hashes with the keys
        # nvre, name, version, release, epoch, errata_advisory,
        # errata_id, with the errata fields being empty strings if the
        # package isn't from an errata.
        ret = { 'last_modified' : last_channel_changed_ts, 'contents' : [] }

        # we search for packages only in the allowed channels - build
        # the SQL helper string and dictionary to make the foo IN (
        # list ) constructs use bind variables
        qlist = []
        qdict = {}
        for c in channel_list:
            v = c["id"]
            k = "channel_%s" % v
            qlist.append(":%s" % k)
            qdict[k] = v
        qlist = string.join(qlist, ", ")

        # This query is kind of big. One of these days I'm gonna start
        # pulling them out and transforming them into views. We can
        # also simulate this using several functions exposed out of
        # rhnChannel, but there is no difference in speed because we
        # need to do more than one query; besides, we cache the hell
        # out of it
        h = rhnSQL.prepare("""
        select distinct
            pn.name name,
            pe.version version,
            pe.release release,
            pe.epoch epoch,
            e_sq.errata_advisory errata_advisory,
            e_sq.errata_synopsis errata_synopsis,
            e_sq.errata_id errata_id
        from
            rhnPackageName pn,
            rhnPackageEVR pe,
	    (	select	sq_e.id errata_id,
			sq_e.synopsis errata_synopsis,
			sq_e.advisory errata_advisory,
			sq_ep.package_id
		from	
			rhnErrata sq_e,
			rhnErrataPackage sq_ep,
			rhnChannelErrata sq_ce
		where	sq_ce.errata_id = sq_ep.errata_id
			and sq_ce.errata_id = sq_e.id
			and sq_ce.channel_id in ( %s )
	    ) e_sq,
            rhnChannelNewestPackage cnp
        where
            cnp.channel_id in ( %s )
        and cnp.name_id = pn.id
        and cnp.evr_id = pe.id
	and cnp.package_id = e_sq.package_id(+)
        """ % (qlist, qlist))
        apply(h.execute, (), qdict)
        
        plist = h.fetchall_dict()
        
        if not plist:
            # We've set XMLRPC-Encoded-Response above
            ret = xmlrpclib.dumps((ret, ), methodresponse=1)
            return ret

        contents = {}
        
        for p in plist:
            for k in p.keys():
                if p[k] is None:
                    p[k] = ""            
            p["nevr"] = "%s-%s-%s:%s" % (
                 p["name"], p["version"], p["release"], p["epoch"])
            p["nvr"] = "%s-%s-%s" % (p["name"], p["version"], p["release"])

            pkg_name = p["name"]
            
            if contents.has_key(pkg_name):
                stored_pkg = contents[pkg_name]

                s = [ stored_pkg["name"],
                      stored_pkg["version"],
                      stored_pkg["release"],
                      stored_pkg["epoch"] ]

                n = [ p["name"],
                      p["version"],
                      p["release"],
                      p["epoch"] ]

                log_debug(7, "comparing vres", s, n)
                if rhn_rpm.nvre_compare(s, n) < 0:
                    log_debug(7, "replacing %s with %s" % (pkg_name, p))
                    contents[pkg_name] = p
                else:
                    # already have a higher vre stored...
                    pass
            else:
                log_debug(7, "initial store for %s" % pkg_name)
                contents[pkg_name] = p
            
        ret["contents"] = contents.values()
        
        # save it in the cache
        # We've set XMLRPC-Encoded-Response above
        ret = xmlrpclib.dumps((ret, ), methodresponse=1)
        rhnCache.set(cache_key, ret, last_channel_changed_ts)
        
        return ret
