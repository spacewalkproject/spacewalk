#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
# Stuff for handling Servers
#

# system modules
import time
import string

# Global Modules
from common import rhnException, rhnFault, log_debug, log_error, CFG
from common import rhnFlags
from common.rhnTranslate import _
from spacewalk.common import rhn_rpm

# from the server stuff...
from server import rhnChannel, rhnUser, rhnSQL, rhnLib, rhnAction, \
                   rhnVirtualization
# from server import rhnChannel, rhnUser, rhnSQL, rhnLib, rhnAction
from search_notify import SearchNotify

# Local Modules
import server_kickstart
import server_lib
import server_token
from server_certificate import Certificate, gen_secret
from server_wrapper import ServerWrapper
from satellite_cert import SatelliteCert

class Server(ServerWrapper):
    """ Main Server class """
    def __init__(self, user, arch = None, org_id = None):
        ServerWrapper.__init__(self)
        self.user = user
        # Use the handy TableRow
        self.server = rhnSQL.Row("rhnServer", "id")
        self.server["release"] = ""
        self.server["os"] = "Red Hat Linux"
        self.is_rpm_managed = 0
        self.set_arch(arch)
        # We only get this passed in when we create a new
        # entry. Usually a reload will create a dummy entry first and
        # then call self.loadcert()
        if user:
            self.server["org_id"] = user.customer["id"]
        elif org_id:
            self.server["org_id"] = org_id
        self.cert = None
        # Also, at this point we know that this is a real server
        self.type = "REAL"
        self.default_description()
        # Satellite certificate associated to this server 
        self.satellite_cert = None

        # custom info values
        self.custom_info = None

        # uuid
        self.uuid = None
        self.registration_number = None

    _query_lookup_arch = rhnSQL.Statement("""
        select sa.id, 
               decode(at.label, 'rpm', 1, 0) is_rpm_managed
          from rhnServerArch sa,
               rhnArchType at
         where sa.label = :archname
           and sa.arch_type_id = at.id
    """)

    def set_arch(self, arch):
        self.archname = arch
        # try to detect the archid
        if arch is None:
            return

        arch = rhnLib.normalize_server_arch(arch)
        h = rhnSQL.prepare(self._query_lookup_arch)
        h.execute(archname = arch)
        data = h.fetchone_dict()
        if not data:
            # Log it to disk, it may show interesting things
            log_error("Attempt to create server with invalid arch `%s'" %
                arch)
            raise rhnFault(24, 
                _("Architecture `%s' is not supported") % arch)
        self.server["server_arch_id"] = data["id"]
        self.is_rpm_managed = data['is_rpm_managed']
        
    # set the default description...    
    def default_description(self):
        self.server["description"] = "Initial Registration Parameters:\n"\
                                     "OS: %s\n"\
                                     "Release: %s\n"\
                                     "CPU Arch: %s" % (
            self.server["os"], self.server["release"],
            self.archname)

    def __repr__(self):
        # misa: looks like id can return negative numbers, so use %d
        # instead of %x
        # For the gory details,
        # http://mail.python.org/pipermail/python-dev/2005-February/051559.html
        return "<Server Class at %d: %s>\n" % (
            id(self), {
            "self.cert" : self.cert,
            "self.server" : self.server.data,
            })
    __str__ = __repr__
    
    # Return a Digital Certificate that can be placed in a file on the
    # client side.
    def system_id(self):       
        log_debug(3, self.server, self.cert)
        if self.cert is None:
            # need to instantiate it
            cert = Certificate()
            cert["system_id"]        = self.server["digital_server_id"]
            cert["os_release"]       = self.server["release"]
            cert["operating_system"] = self.server["os"]
            cert["architecture"]     = self.archname
            cert["profile_name"]     = self.server["name"]
            cert["description"]      = self.server["description"]
            if self.user:
                cert["username"]         = self.user.contact["login"]
            cert["type"]             = self.type
            cert.set_secret(self.server["secret"])
            self.cert = cert
        return self.cert.certificate()

    # return the id of this system
    def getid(self):
        if not self.server.has_key("id"):            
            sysid = rhnSQL.Sequence("rhn_server_id_seq")()
            self.server["digital_server_id"] = "ID-%09d" % sysid           
            # we can't reset the id column, so we need to poke into
            # internals. kind of illegal, but it works...
            self.server.data["id"] = (sysid, 0)
        else:
            sysid = self.server["id"]
        return sysid


    # change the base channel of a server
    def change_base_channel(self, new_rel):
        log_debug(3, self.server["id"], new_rel)
        old_rel = self.server["release"]       
        # test noops
        if old_rel == new_rel:
            return 1        
        current_channels = rhnChannel.channels_for_server(self.server["id"])
        # Extract the base channel off of 
        old_base = filter(lambda x: not x['parent_channel'], 
            current_channels)

        # Quick sanity check
        base_channels_count = len(old_base)
        if base_channels_count == 1:
            old_base = old_base[0]
        elif base_channels_count == 0:
            old_base = None
        else:
            raise rhnException("Server %s subscribed to multiple base channels"
                % (self.server["id"], ))
       
        #bz 442355
        #Leave custom base channels alone, don't alter any of the channel subscriptions
        if not CFG.RESET_BASE_CHANNEL and rhnChannel.isCustomChannel(old_base["id"]):
            log_debug(3, 
                    "Custom base channel detected, will not alter channel subscriptions")
            self.server["release"] = new_rel
            self.server.save()
            msg = """The Red Hat Network Update Agent has detected a 
            change in the base version of the operating system running 
            on your system, additionaly you are subscribed to a custom
            channel as your base channel.  Due to this configuration 
            your channel subscriptions will not be altered.
            """
            self.add_history("Updated system release from %s to %s" % (
                old_rel, new_rel), msg)
            self.save_history_byid(self.server["id"])
            return 1

        
        s = rhnChannel.LiteServer().init_from_server(self)
        s.release = new_rel
        s.arch = self.archname
        # Let get_server_channels deal with the errors and raise rhnFault
        target_channels = rhnChannel.guess_channels_for_server(s)
        target_base = filter(lambda x: not x['parent_channel'],
            target_channels)[0]

        channels_to_subscribe = []
        channels_to_unsubscribe = []
        if old_base and old_base['id'] == target_base['id']:
            # Same base channel. Preserve the currently subscribed child
            # channels, just add the ones that are missing
            hash = {}
            for c in current_channels:
                hash[c['id']] = c

            for c in target_channels:
                channel_id = c['id']
                if hash.has_key(channel_id):
                    # Already subscribed to this one
                    del hash[channel_id]
                    continue
                # Have to subscribe to this one
                channels_to_subscribe.append(c)

            # We don't want to lose subscriptions to prior channels, so don't
            # do anything with hash.values()
        else:
            # Different base channel
            channels_to_unsubscribe = current_channels
            channels_to_subscribe = target_channels

        rhnSQL.transaction("change_base_channel")
        self.server["release"] = new_rel
        self.server.save()
        if not (channels_to_subscribe or channels_to_unsubscribe):
            # Nothing to do, just add the history entry
            self.add_history("Updated system release from %s to %s" % (
                old_rel, new_rel))
            self.save_history_byid(self.server["id"])
            return 1

        # XXX: need a way to preserve existing subscriptions to
        # families so we can restore access to non-public ones.

        rhnChannel.unsubscribe_channels(self.server["id"],
            channels_to_unsubscribe)
        rhnChannel.subscribe_channels(self.server["id"],
            channels_to_subscribe)
        # now that we changed, recompute the errata cache for this one
        rhnSQL.Procedure("queue_server")(self.server["id"])
        # Make a history note
        sub_channels = rhnChannel.channels_for_server(self.server["id"])
        if sub_channels:
            channel_list = map(lambda a: a["name"], sub_channels)
            msg = """The Red Hat Network Update Agent has detected a 
            change in the base version of the operating system running 
            on your system and has updated your channel subscriptions
            to reflect that.
            Your server has been automatically subscribed to the following
            channels:\n%s\n""" % (string.join(channel_list, "\n"),)
        else:
            msg = """*** ERROR: ***
            While trying to subscribe this server to software channels:
            There are no channels serving release %s""" % new_rel
        self.add_history("Updated system release from %s to %s" % (
            old_rel, new_rel), msg)
        self.save_history_byid(self.server["id"])
        return 1

    def take_snapshot(self, reason):
        return server_lib.snapshot_server(self.server['id'], reason)

    # returns true iff the base channel assigned to this system
    # has been end-of-life'd
    def base_channel_is_eol(self):
        h = rhnSQL.prepare("""
        select 1
        from rhnChannel c, rhnServerChannel sc
        where sc.server_id = :server_id
          and sc.channel_id = c.id
          and c.parent_channel IS NULL
          and sysdate - c.end_of_life > 0
        """)
        h.execute(server_id = self.getid())
        ret = h.fetchone_dict()
        if ret:
            return 1

        return None


    _query_server_custom_info = rhnSQL.Statement("""
    select cdk.label,
           scdv.value
      from rhnCustomDataKey cdk,
           rhnServerCustomDataValue scdv
     where scdv.server_id = :server_id
       and scdv.key_id = cdk.id
    """)
    def load_custom_info(self):
        self.custom_info = {}
        
        h = rhnSQL.prepare(self._query_server_custom_info)
        h.execute(server_id = self.getid())
        rows = h.fetchall_dict()

        if not rows:
            log_debug(4, "no custom info values")
            return
        
        for row in rows:
            self.custom_info[row['label']] = row['value']
    
    # load additional server information from the token definition
    def load_token(self):
        # Fetch token
        tokens_obj = rhnFlags.get("registration_token")
        if not tokens_obj:
            # No tokens present
            return 0

        # make sure we have reserved a server_id. most likely if this
        # is a new server object (just created from
        # registration.new_system) then we have no associated a
        # server["id"] yet -- and getid() will reserve that for us.
        self.getid()
        # pull in the extra information needed to fill in the
        # required registration fields using tokens

        user_id = tokens_obj.get_user_id()
        org_id = tokens_obj.get_org_id()

        self.user = rhnUser.User("", "")
        if user_id is not None:
            self.user.reload(user_id)
        self.server["creator_id"] = user_id
        self.server["org_id"] = org_id
        return 0
    
    # perform the actions required by the token (subscribing to
    # channels, server groups, etc)
    def use_token(self):
        # Fetch token
        tokens_obj = rhnFlags.get("registration_token")
        if not tokens_obj:
            # No token present
            return 0

        is_rereg_token = tokens_obj.is_rereg_token

        # We get back a history of what is being done in the
        # registration process
        history = server_token.process_token(self.server, self.archname, 
            tokens_obj, self.virt_type)

        if is_rereg_token:
            event_name = "Reactivation via Token"
            event_text = "System reactivated"
        else:
            event_name = "Subscription via Token"
            event_text = "System created"
        
        token_name = tokens_obj.get_names()
        # now record that history nicely
        self.add_history(event_name, 
            "%s with token <strong>%s</strong><br />\n%s" % 
                (event_text, token_name, history))
        self.save_history_byid(self.server["id"])
        
        #6/23/05 wregglej 157262, use get_kickstart session_id() to see if we're in the middle of a kickstart.
        ks_id = tokens_obj.get_kickstart_session_id()

        #4/5/05 wregglej, Added for bugzilla: 149932. Actions need to be flushed on reregistration.
        #6/23/05 wregglej 157262, don't call flush_actions() if we're in the middle of a kickstart.
        #   It would cause all of the remaining kickstart actions to get flushed, which is bad.
        if is_rereg_token and ks_id is None:
            self.flush_actions() 

        # XXX: will need to call self.save() later to commit all that
        return 0

    def disable_token(self):
        tokens_obj = rhnFlags.get('registration_token')
        if not tokens_obj:
            # Nothing to do
            return
        if not tokens_obj.is_rereg_token:
            # Not a re-registration token - nothing to do
            return

        # Re-registration token - we know for sure there is only one
        token_server_id = tokens_obj.get_server_id()
        if token_server_id != self.getid():
            # Token is not associated with this server (it may actually not be
            # associated with any server)
            return
        server_token.disable_token(tokens_obj)
        # save() will commit this

    # Auto-entitlement: attempt to entitle this server to the highest
    # entitlement that is available
    def autoentitle(self):
        # misa: as of 2005-05-27 nonlinux does not get a special treatment
        # anymore (this is in connection to feature 145440 - entitlement model
        # changes
        entitlement_hierarchy = ['enterprise_entitled', 'sw_mgr_entitled']

        any_base_entitlements = 0
        
        for entitlement in entitlement_hierarchy:
            try:
                self._entitle(entitlement)
                any_base_entitlements = 1
            except rhnSQL.SQLSchemaError, e:
                if e.errno == 20220:
                    # ORA-20220: (servergroup_max_members) - Server group 
                    # membership cannot excede maximum membership
                    #
                    # ignore for now, since any_base_entitlements will throw
                    # an error at the end if not set
                    continue
                
                if e.errno == 20287:
                    # ORA-20287: (invalid_entitlement) - The server can not be
                    # entitled to the specified level
                    #
                    # ignore for now, since any_base_entitlements will throw
                    # an error at the end if not set
                    continue


                # Should not normally happen
                log_error("Failed to entitle", self.server["id"], entitlement,
                    e.errmsg)
                raise server_lib.rhnSystemEntitlementException("Unable to entitle")
            except rhnSQL.SQLError, e:
                log_error("Failed to entitle", self.server["id"], entitlement,
                    str(e))
                raise server_lib.rhnSystemEntitlementException("Unable to entitle")
            else:
                if any_base_entitlements:
                    # All is fine
                    return
                else:
                    raise server_lib.rhnNoSystemEntitlementsException

    def _entitle(self, entitlement):
        entitle_server = rhnSQL.Procedure("rhn_entitlements.entitle_server")
        entitle_server(self.server['id'], entitlement)

    def create_perm_cache(self):
        log_debug(4)
        create_perms = rhnSQL.Procedure("rhn_cache.update_perms_for_server")
        create_perms(self.server['id'])

    def gen_secret(self):
        # Running this invalidates the cert
        self.cert = None
        self.server["secret"] = gen_secret()

    _query_update_uuid = rhnSQL.Statement("""
        update rhnServerUuid set uuid = :uuid
         where server_id = :server_id
    """)
    _query_insert_uuid = rhnSQL.Statement("""
        insert into rhnServerUuid (server_id, uuid)
        values (:server_id, :uuid)
    """)
    def update_uuid(self, uuid, commit=1):
        log_debug(3, uuid)
        # XXX Should determine a way to do this dinamically
        uuid_col_length = 36
        if uuid is not None:
            uuid = str(uuid)
        if not uuid:
            log_debug('Nothing to do')
            return
        
        uuid = uuid[:uuid_col_length]
        server_id = self.server['id']
        log_debug(4, "Trimmed uuid", uuid, server_id)

        # Update this server's UUID (unique client identifier)
        h = rhnSQL.prepare(self._query_update_uuid)
        ret = h.execute(server_id=server_id, uuid=uuid)
        log_debug(4, "execute returned", ret)

        if ret != 1:
            # Row does not exist, have to create it
            h = rhnSQL.prepare(self._query_insert_uuid)
            h.execute(server_id=server_id, uuid=uuid)

        if commit:
            rhnSQL.commit()

       # Save this record in the database
    def __save(self, channel, pre_commit = 0):
        if self.server.real:
            server_id = self.server["id"]
            self.server.save()
        else: # create new entry
            self.gen_secret()
            server_id = self.getid()
            org_id = self.server["org_id"]

            if self.user:
                user_id = self.user.getid()
            else:
                user_id = None
            
            # some more default values
            self.server["auto_deliver"] = "N"
            self.server["auto_update"] = "N"
            if self.user and not self.server.has_key("creator_id"):
                # save the link to the user that created it if we have
                # that information
                self.server["creator_id"] = self.user.getid()
            # and create the server entry
            self.server.create(server_id)
            server_lib.create_server_setup(server_id, org_id)

            have_reg_token = rhnFlags.test("registration_token")

            # Handle virtualization specific bits
            if self.virt_uuid is not None and \
               self.virt_type is not None:
                rhnVirtualization._notify_guest(self.getid(),
                                                self.virt_uuid, self.virt_type)

            # if we're using a token, then the following channel
            # subscription request can allow no matches since the
            # token code will fix up or fail miserably later.
            # subscribe the server to applicable channels

            # bretm 02/17/2007 -- TODO:  refactor activation key codepaths
            # to allow us to not have to pass in none_ok=1 in any case
            #
            # This can now throw exceptions which will be caught at a higher level
            if pre_commit:
                rhnSQL.commit()
            
            if channel is not None:
                channel_info = dict(rhnChannel.channel_info(channel))
                log_debug(4, "eus channel id %s" % str(channel_info))
                rhnChannel._subscribe_sql(server_id, channel_info['id'])
            else:
                rhnChannel.subscribe_server_channels(self, 
                               none_ok=have_reg_token,
                               user_id=user_id)

            if not have_reg_token:
                # Attempt to auto-entitle, can throw the following exceptions:
                #   rhnSystemEntitlementException
                #   rhnNoSystemEntitlementsException
                self.autoentitle()
            
                # If a new server that was registered by an user (i.e. not
                # with a registration token), look for this user's default 
                # groups
                self.join_groups()
            
            server_lib.join_rhn(org_id)
        # Update the uuid - but don't commit yet
        self.update_uuid(self.uuid, commit=0)

        self.create_perm_cache()
        # And save the extra profile data...
        self.save_packages_byid(server_id, schedule=1)
        self.save_hardware_byid(server_id)
        self.save_history_byid(server_id)
        return 0

    # This is a wrapper for the above class that allows us to rollback
    # any changes in case we don't succeed completely
    def save(self, commit = 1, channel = None, pre_commit = 0):
        log_debug(3)
        # attempt to preserve pending changes before we were called,
        # so we set up our own transaction checkpoint
        rhnSQL.transaction("save_server")
        try:
            self.__save(channel, pre_commit = pre_commit)
        except: # roll back to what we have before and raise again           
            rhnSQL.rollback("save_server")
            # shoot the exception up the chain
            raise
        else: # if we want to commit, commit all pending changes
            if commit:
                rhnSQL.commit()
                try:
                    search = SearchNotify()
                    search.notify()
                except Exception, e:
                    log_error("Exception caught from SearchNotify.notify().", e)
        return 0

    # Reload the current configuration from database using a server id.
    def reload(self, server, reload_all = 0):
        log_debug(4, server, "reload_all = %d" % reload_all)
        
        if not self.server.load(int(server)):
            log_error("Could not find server record for reload", server)
            raise rhnFault(29, "Could not find server record in the database")
        self.cert = None
        # it is lame that we have to do this
        h = rhnSQL.prepare("""
        select label from rhnServerArch where id = :archid
        """)
        h.execute(archid = self.server["server_arch_id"])
        data = h.fetchone_dict()
        if not data:
            raise rhnException("Found server with invalid numeric "
                               "architecture reference",
                               self.server.data)
        self.archname = data['label']
        # we don't know this one anymore (well, we could look for, but
        # why would we do that?)
        self.user = None
        
        # XXX: Fix me
        if reload_all:
            if not self.reload_packages_byid(self.server["id"]) == 0:
                return -1
            if not self.reload_hardware_byid(self.server["id"]) == 0:
                return -1       
        return 0
    
    # Use the values we find in the cert to cause a reload of this
    # server from the database.
    def loadcert(self, cert, load_user = 1):
        log_debug(4, cert)
        # certificate is presumed to be already verified
        if not isinstance(cert, Certificate):
            return -1
        # reload the whole thing based on the cert data
        server = cert["system_id"]
        row = server_lib.getServerID(server)
        if row is None:
            return -1
        sid = row["id"]
        # standard reload based on an ID
        ret = self.reload(sid)
        if not ret == 0:
            return ret

        # the reload() will never be able to fill in the username.  It
        # would require from the database standpoint insuring that for
        # a given server we can have only one owner at any given time.
        # cert includes it and it's valid because it has been verified
        # through checksuming before we got here
        
        self.user = None

        #Load the user if at all possible. If it's not possible,
        #self.user will be None, which should be a handled case wherever
        #self.user is used.
        if load_user:
            # Load up the username associated with this profile
            self.user = rhnUser.search(cert["username"])

        ##4/27/05 wregglej - Commented out this block because it was causing problems
        ##with rhn_check/up2date when the user that registered the system was deleted.
        #    if not self.user:
        #        log_error("Invalid username for server id",
        #                  cert["username"], server, cert["profile_name"])
        #        raise rhnFault(9, "Invalid username '%s' for server id %s" %(
        #            cert["username"], server))

        # XXX: make sure that the database thinks that the server
        # registrnt is the same as this certificate thinks. The
        # certificate passed checksum checks, but it never hurts to be
        # too careful now with satellites and all.        
        return 0
        
    # Is this server entitled?
    def check_entitlement(self):
        if not self.server.has_key("id"):
            return None
        log_debug(3, self.server["id"])

        return server_lib.check_entitlement(self.server['id'])
    

    # Given a dbiDate object, returns the UNIX representation (seconds since
    # epoch)
    def dbiDate2timestamp(self, dateobj):
        timeString = '%s %s %s %s %s %s' % (dateobj.year, dateobj.month,
            dateobj.day, dateobj.hour, dateobj.minute, dateobj.second)
        return time.mktime(time.strptime(timeString, '%Y %m %d %H %M %S'))
 
    def validateSatCert(self):
        # make sure the cert is still valid
        
        h = rhnSQL.prepare("""
        select TO_CHAR(expires, 'YYYY-MM-DD HH24:MI:SS') expires
          from rhnSatelliteCert
         where label = 'rhn-satellite-cert'
         order by version desc nulls last
        """)
        # Fetching just the first row will get the max version, null
        # included
        h.execute()
        ret = h.fetchone_dict()
        if not ret:
            log_debug(2, "Satellite certificate not found")
            return 0
        expire_string = ret['expires']
        expire_time = time.mktime(time.strptime(expire_string, 
            "%Y-%m-%d %H:%M:%S"))

        now = time.time()
        log_debug(3, "Certificate expiration: %s; now: time: %s (%s)" % (
            expire_string, time.ctime(now), now))

        # We will allow for a grace period of 8 days after the cert expires to 
        # give the user some time renew the certificate before we disable.
        grace_period_seconds = 60 * 60 * 24 * 8

        if (now > expire_time + grace_period_seconds):
            log_debug(1, "Satellite certificate expired on %s" % expire_string)
            return 0
        return 1

    def checkSatEntitlement(self):
        """Check serverId against DB to see if it maps to an entitled
           RHN Satellite Server.
        """
        h = rhnSQL.prepare("""
            select cert
            from rhnsatelliteinfo si
            where si.server_id = :serverId
        """)
        h.execute(serverId=self.server["id"])
        row = h.fetchone_dict()
        if not row:
            return 0

        cert = row['cert']
        if not cert:
            return 0

        # Bugzilla #219625
        # Cert is now a blob, so convert it to a string
        cert = cert.read()

        self.satellite_cert = SatelliteCert()
        self.satellite_cert.load(cert)
        # Some sanity checking
        #if self.satellite_cert.expires:
        #    if time.time() > self.satellite_cert.expires:
        #        # Expired satellite
        #        return 0

        return 1

    def checkin(self, commit = 1, check_for_abuse = 1):
        """ convenient wrapper for these thing until we clean the code up """
        if not self.server.has_key("id"):
            return 0 # meaningless if rhnFault not raised
        return server_lib.checkin(self.server["id"], commit,
                       check_for_abuse=check_for_abuse)
    def throttle(self):
        """ convenient wrapper for these thing until we clean the code up """
        if not self.server.has_key("id"):
            return 1 # meaningless if rhnFault not raised
        return server_lib.throttle(self.server)

    def set_qos(self):
        """ convenient wrapper for these thing until we clean the code up """
        if not self.server.has_key("id"):
            return 1 # meaningless if rhnFault not raised
        return server_lib.set_qos(self.server["id"])

    def join_groups(self):
        """ For a new server, join server groups """

        # Sanity check - we should always have a user
        if not self.user:
            raise rhnException("User not specified")

        server_id = self.getid()
        user_id = self.user.getid()

        h = rhnSQL.prepare("""
            select system_group_id
            from rhnUserDefaultSystemGroups
            where user_id = :user_id
        """)
        h.execute(user_id=user_id)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            server_group_id = row['system_group_id']
            log_debug(5, "Subscribing server to group %s" % server_group_id)

            server_lib.join_server_group(server_id, server_group_id)

    def fetch_registration_message(self):
        return rhnChannel.system_reg_message(self)

    def process_kickstart_info(self):
        log_debug(4)
        tokens_obj = rhnFlags.get("registration_token")
        if not tokens_obj:
            log_debug(4, "no registration token found")
            # Nothing to do here
            return

        # If there are kickstart sessions associated with this system (other
        # than, possibly, the current one), mark them as failed
        history = server_kickstart.terminate_kickstart_sessions(self.getid())
        for k, v in history:
            self.add_history(k, v)
        
        kickstart_session_id = tokens_obj.get_kickstart_session_id()
        if kickstart_session_id is None:
            log_debug(4, "No kickstart_session_id associated with token %s (%s)"
                % (tokens_obj.get_names(), tokens_obj.tokens))
                
            # Nothing to do here
            return

        # Flush server actions
        self.flush_actions()

        server_id = self.getid()
        action_id = server_kickstart.schedule_kickstart_sync(server_id, 
            kickstart_session_id)

        server_kickstart.subscribe_to_tools_channel(server_id,
            kickstart_session_id)

        server_kickstart.schedule_virt_pkg_install(server_id,
            kickstart_session_id)

        # Update the next action to the newly inserted one
        server_kickstart.update_ks_session_table(kickstart_session_id, 
            'registered', action_id, server_id)

    def flush_actions(self):
        server_id = self.getid()
        h = rhnSQL.prepare("""
            select action_id
              from rhnServerAction
             where server_id = :server_id
               and status in (0, 1) -- Queued or Picked Up
        """)
        h.execute(server_id=server_id)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            action_id = row['action_id']
            rhnAction.update_server_action(server_id=server_id,
                action_id=action_id, status=3, result_code=-100,
                result_message="Action canceled: system kickstarted or reregistered") #4/6/05 wregglej, added the "or reregistered" part.

    def server_locked(self):
        """ Returns true is the server is locked (for actions that are blocked) """
        server_id = self.getid()
        h = rhnSQL.prepare("""
            select 1
              from rhnServerLock
             where server_id = :server_id
        """)
        h.execute(server_id=server_id)
        row = h.fetchone_dict()
        if row:
            return 1
        return 0

    def register_push_client(self):
        """ insert or update rhnPushClient for this server_id """
        server_id = self.getid()
        ret = server_lib.update_push_client_registration(server_id)
        return ret

    def register_push_client_jid(self, jid):
        """ update the JID in the corresponing entry from rhnPushClient """
        server_id = self.getid()
        ret = server_lib.update_push_client_jid(server_id, jid)
        return ret
        
