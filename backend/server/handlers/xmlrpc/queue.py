# Queue functions on the server side.
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

import sys
import time
from rhn.rpclib import xmlrpclib

from types import IntType, TupleType

# Global modules
from common import CFG, log_debug, log_error, Traceback
from common import rhnFlags
from common import rhnFault
from common.rhnTranslate import _

from server import rhnSQL, rhnHandler, rhnCapability, rhnAction
from server.rhnLib import InvalidAction, EmptyAction, ShadowAction
from server.rhnServer import server_kickstart

import getMethod

class Queue(rhnHandler):
    """ XMLRPC queue functions that we will provide for the outside world. """

    def __init__(self):
        """ Add a list of functions we are willing to server out. """
        rhnHandler.__init__(self)
        self.functions.append('get')
        self.functions.append('get_future_actions')
        self.functions.append('length')
        self.functions.append('submit')

        # XXX I am not proud of this. There should be a generic way to map
        # the client's error codes into success status codes
        self.action_type_completed_codes = {
            'errata.update' : {
                39  : None,
            },
        }

    def __getV1(self, action):
        """ Fetches old queued actions for the client version 1. """
        log_debug(3, self.server_id)
        actionId = action['id']
        method = action["method"]
        if method == 'packages.update':
            xml = self.__packageUpdate(actionId)
        elif method == 'errata.update':
            xml = self.__errataUpdate(actionId)
        elif method == 'hardware.refresh_list':
            xml = xmlrpclib.dumps(("hardware",), methodname="client.refresh")
        elif method == 'packages.refresh_list':
            xml = xmlrpclib.dumps(("rpmlist",), methodname="client.refresh")
        else: # Unrecognized, skip
            raise InvalidAction("Action method %s unsupported by "
                                "Update Agent Client" % method)
        # all good
        return {'id': actionId, 'version': 1, 'action': xml}

    def __getV2(self, action, dry_run=0):
        """ Fetches queued actions for the clients version 2+. """
        log_debug(3, self.server_id)
        # Get the root dir of this install
        rootDir = rhnFlags.get("RootDir")
        if not rootDir:
            raise EmptyAction("Could not figure out RootDir for "
                              "action retrieval via getMethod")
        try:
            method = getMethod.getMethod(action['method'], rootDir,
                                         'server.action')
        except getMethod.GetMethodException:
            Traceback("queue.get V2")
            raise EmptyAction("Could not get a valid method for %s" % (
                action['method'],))
        # Call the method
        result = method(self.server_id, action['id'], dry_run)
        if result is None:
            # None are mapped to the empty list
            result = ()
        elif not isinstance(result, TupleType):
            # Everything other than a tuple is wrapped in a tuple
            result = (result, )

        xmlblob = xmlrpclib.dumps(result, methodname=action['method'])
        log_debug(5, "returning xmlblob for action", xmlblob)
        return { 
            'id'        : action['id'],
            'action'    : xmlblob,
            'version'   : action['version'],
        }
    
    def __update_status(self, status):
        """ Update the runnng kernel and the last boot values for this
            server from the status dictionary passed on queue checkin.

            Record last running kernel and uptime.  Only update
            last_boot if it has changed by more than five minutes. We
            don't know the timezone the server is in. or even if its
            clock is right, but we do know it can properly track seconds
             since it rebooted, and use our own clocks to keep proper
            track of the actual time.
        """
        
        if status.has_key('uname'):
            kernelver = status['uname'][2]
            if kernelver != self.server.server["running_kernel"]:
                self.server.server["running_kernel"] = kernelver

        # XXX:We should be using Oracle's sysdate() for this management
        # In the case of multiple app servers in mutiple time zones all the
        # results are skewed.
        if status.has_key('uptime'):
            uptime = status['uptime']
            if isinstance(uptime, type([])) and len(uptime):
                # Toss the other values. For now
                uptime = uptime[0]
                try:
                    uptime = float(uptime)
                except ValueError:
                    # Wrong value passed by the client
                    pass
                else:
                    last_boot = time.time() - uptime
                    if abs(last_boot-self.server.server["last_boot"]) > 60*5:
                        self.server.server["last_boot"] = last_boot
        
        # this is smart enough to do a NOOP if nothing changed.
        self.server.server.save()

    def __should_snapshot(self):
        log_debug(4, self.server_id, "determining whether to snapshot...")

        entitlements = self.server.check_entitlement()
        if not entitlements.has_key("provisioning_entitled"):
            return 0

        # ok, take the snapshot before attempting this action
        return 1

    def _invalidate_child_actions(self, action_id):
        f_action_ids = rhnAction.invalidate_action(self.server_id, action_id)
        for f_action_id in f_action_ids:
            # Invalidate any kickstart session that depends on this action
            server_kickstart.update_kickstart_session(self.server_id, 
                f_action_id, action_status=3, kickstart_state='failed', 
                next_action_type=None)
        return f_action_ids

    def _invalidate_failed_prereq_actions(self):
        h = rhnSQL.prepare("""
            select sa.action_id, a.prerequisite
              from rhnServerAction sa, rhnAction a
             where sa.server_id = :server_id
               and sa.action_id = a.id
               and sa.status in (0, 1) -- Queued or picked up
               and a.prerequisite is not null
               and exists (
                   select 1
                     from rhnServerAction
                    where server_id = sa.server_id
                      and action_id = a.prerequisite
                      and status = 3 -- failed
               )
        """)

        h.execute(server_id=self.server_id)
        while 1:
            row = h.fetchone_dict()
            if not row:
                break

            action_id, prereq_action_id = row['action_id'], row['prerequisite']

            self._invalidate_child_actions(action_id)

    _query_queue_future = rhnSQL.Statement("""
                    select sa.action_id id, a.version,
                           sa.remaining_tries, at.label method,
                           at.unlocked_only,
                           a.prerequisite
                      from rhnServerAction sa,
                           rhnAction a,
                           rhnActionType at
                     where sa.server_id = :server_id
                       and sa.action_id = a.id
                       and a.action_type = at.id
                       and sa.status in (0, 1) -- Queued or picked up
                       and a.earliest_action <= sysdate + (:time_window/24)  -- Check earliest_action
                      order by a.earliest_action, a.prerequisite nulls first, a.id
    """)

    def get_future_actions(self, system_id, time_window):
        """ return actions which are scheduled within next /time_window/ hours """
        self.auth_system(system_id)
        log_debug(3, "Checking for future actions within %d hours" % time_window)
        h = rhnSQL.prepare(self._query_queue_future)
        h.execute(server_id=self.server_id, time_window=time_window)
        result = []
        while action = h.fetchone_dict():
            result.append(self.__getV2(action, dry_run=1))
        return result

    _query_queue_get = rhnSQL.Statement("""
                    select sa.action_id id, a.version, 
                           sa.remaining_tries, at.label method,
                           at.unlocked_only,
                           a.prerequisite
                      from rhnServerAction sa, 
                           rhnAction a, 
                           rhnActionType at
                     where sa.server_id = :server_id
                       and sa.action_id = a.id
                       and a.action_type = at.id
                       and sa.status in (0, 1) -- Queued or picked up
                       and a.earliest_action <= sysdate -- Check earliest_action
                       and not exists (
                           select 1
                             from rhnServerAction sap
                            where sap.server_id = :server_id
                              and sap.action_id = a.prerequisite
                              and sap.status != 2 -- completed
                           )
                      order by a.earliest_action, a.prerequisite nulls first, a.id
    """)

    # Probably we need to figure out if we really need to split these two.
    def get(self, system_id, version = 1, status = {}):
        # Authenticate the system certificate
        if CFG.DISABLE_CHECKINS:
            self.update_checkin = 0
        else:
            self.update_checkin = 1
        self.auth_system(system_id)
        log_debug(1, self.server_id, version,
                  "checkins %s" % ["disabled", "enabled"][self.update_checkin]) 
        if status:
            self.__update_status(status)

        # Update the capabilities list
        rhnCapability.update_client_capabilities(self.server_id)

        # Invalidate failed actions
        self._invalidate_failed_prereq_actions()

        server_locked = self.server.server_locked()
        log_debug(3, "Server locked", server_locked)
            
        ret = {}
        # get the action. Status codes are currently:
        # 0 Queued # 1 Picked Up # 2 Completed # 3 Failed       
        # XXX: we should really be using labels from rhnActionType instead of
        #      hard coded type id numbers.        
        # We fetch actions whose prerequisites have completed, and actions
        # that don't have prerequisites at all
        h = rhnSQL.prepare(self._query_queue_get)

        should_execute = 1

        # Loop to get a valid action
        # (only one valid action will be dealt with per execution of this function...)
        while 1:
            if should_execute:
                h.execute(server_id=self.server_id)
                should_execute = 0

            # Okay, got an action
            action = h.fetchone_dict()
            if not action: # No actions available; bail out           
                # Don't forget the commit at the end...
                ret = ""
                break
            action_id = action['id']
            log_debug(4, "Checking action %s" % action_id)
            # okay, now we have the action - process it.
            if action['remaining_tries'] < 1:
                log_debug(4, "Action %s picked up too many times" % action_id)
                # We've run out of pickup attempts for this action...
                self.__update_action(action_id, status=3, 
                    message="This action has been picked up multiple times "
                    "without a successful transaction; "
                    "this action is now failed for this system.")
                # Invalidate actions that depend on this one
                self._invalidate_child_actions(action_id)
                # keep looking for a good action to process...
                continue

            if server_locked and action['unlocked_only']== 'Y':
                # This action is locked
                log_debug(4, "server id %s locked for action id %s" % (
                    self.server_id, action_id))
                continue

            try:
                if version == 1:
                    ret = self.__getV1(action)
                else:
                    ret = self.__getV2(action)
            except ShadowAction, e: # Action the client should not see
                # Make sure we re-execute the query, so we pick up whatever
                # extra actions were added
                should_execute = 1
                text = e.args[0]
                log_debug(4, "Shadow Action", text)
                self.__update_action(action['id'], 2, 0, text)
                continue
            except InvalidAction, e: # This is an invalid action
                # Update its status so it won't bother us again
                text = e.args[0]
                log_debug(4, "Invalid Action", text)
                self.__update_action(action['id'], 3, -99, text)
                continue
            except EmptyAction, e:
                # this means that we have some sort of internal error
                # which gets reported in the logs. We don't touch the
                # action because this should get fixed on our side.
                log_error("Can not process action data", action, e.args)
                ret = ""
                break
            else: # all fine
                # Update the status of the action
                h = rhnSQL.prepare("""
                update rhnServerAction
                    set status = 1,
                        pickup_time = SYSDATE,
                        remaining_tries = :tries - 1
                where action_id = :action_id
                  and server_id = :server_id
                """)
                h.execute(action_id = action["id"], server_id = self.server_id,
                          tries = action["remaining_tries"])
                break                        

        # commit all changes
        rhnSQL.commit()

        return ret

    def submit(self, system_id, action_id, result, message="", data={}):
        """ Submit the results of a queue run.
            Maps old and new rhn_check behavior to new database status codes

            The new API uses 4 slightly different status codes than the
            old client does.  This function will "hopefully" sensibly
            map them.  Old methodology:
               -rhn_check retrieves an action from the top of the action queue.
               -It attempts to execute the desired action and returns either
                   (a) 0   -- presumed successful.
                   (b) rhnFault object -- presumed failed
                   (c) some other non-fault object -- *assumed* successful.
               -Regardless of result code, action is marked as "executed"

            We try to make a smarter status selection (i.e. failed||completed).

            For reference:
            New DB status codes:      Old DB status codes: 
                  0: Queued               0: queued
                  1: Picked Up            1: picked up
                  2: Completed            2: executed
                  3: Failed               3: completed
        """
        if type(action_id) is not IntType:
            # Convert it to int
            try:
                action_id = int(action_id)
            except ValueError:
                log_error("Invalid action_id", action_id)
                raise rhnFault(30, _("Invalid action value type %s (%s)") % 
                    (action_id, type(action_id)))
        # Authenticate the system certificate
        self.auth_system(system_id)
        log_debug(1, self.server_id, action_id, result)
        # check that the action is valid
        # We have a uniqueness constraint on (action_id, server_id)
        h = rhnSQL.prepare("""
            select at.label action_type,
                   at.trigger_snapshot,
                   at.name
              from rhnServerAction sa,
                   rhnAction a,
                   rhnActionType at
             where sa.server_id = :server_id 
               and sa.action_id = :action_id 
               and sa.status = 1
               and a.id = :action_id
               and a.action_type = at.id
        """)
        h.execute(server_id = self.server_id, action_id = action_id)
        row = h.fetchone_dict()
        if not row:
            log_error("Server %s does not own action %s" % (
                self.server_id, action_id))
            raise rhnFault(22, _("Action %s does not belong to server %s") % (
                action_id, self.server_id))
        
        action_type = row['action_type']
        trigger_snapshot = (row['trigger_snapshot'] == 'Y')

        if data.has_key('missing_packages'): 
            missing_packages = "Missing-Packages: %s" % str( \
                                data['missing_packages'])
            rmsg = "%s %s" % (message, missing_packages)
        elif data.has_key('koan'):
            rmsg = "%s: %s" % (message, data['koan'])
        else:
            rmsg = message

        rcode = result
        # Careful with this one, result can be a very complex thing
        # and this processing is required for compatibility with old
        # rhn_check clients
        if type(rcode) == type({}):
            if result.has_key("faultCode"):
                rcode = result["faultCode"]
            if result.has_key("faultString"):
                rmsg = result["faultString"] + str(data)
        if type(rcode) in [type({}), type(()), type([])] \
               or type(rcode) is not IntType:
            rmsg = "%s [%s]" % (str(message), str(rcode))         
            rcode = -1            
        # map to db codes.
        status = self.status_for_action_type_code(action_type, rcode)

        if status == 3:
            # Failed action - invalidate children
            self._invalidate_child_actions(action_id)
        elif status == 2 and trigger_snapshot and self.__should_snapshot():
            # if action status is 'Completed', snapshot if allowed and if needed
            self.server.take_snapshot("Scheduled action completion:  %s" % row['name'])
        
        self.__update_action(action_id, status, rcode, rmsg)

        # Store the status in a flag - easier than to complicate the action
        # plugin API by adding a status
        rhnFlags.set('action_id', action_id)
        rhnFlags.set('action_status', status)

        self.process_extra_data(self.server_id, action_id, data=data,
            action_type=action_type)

        # commit, because nobody else will
        rhnSQL.commit()
        return 0

    def status_for_action_type_code(self, action_type, rcode):
        """ Convert whatever the client sends as a result code into a status in the
            database format
            This is more complicated, since some of the client's result codes have
            to be marked as successes.
        """
        log_debug(4, action_type, rcode)
        if rcode == 0:
            # Completed
            return 2
        
        if not self.action_type_completed_codes.has_key(action_type):
            # Failed
            return 3
        
        hash = self.action_type_completed_codes[action_type]
        if not hash.has_key(rcode):
            # Failed
            return 3
            
        # Completed
        return 2

    def process_extra_data(self, server_id, action_id, data={},
            action_type=None):
        log_debug(4, server_id, action_id, action_type)

        if not action_type:
            # Shouldn't happen
            return

        rootDir = rhnFlags.get("RootDir")
        if not rootDir:
            log_error("Could not figure out RootDir")
            return

        try:
            method = getMethod.getMethod(action_type, rootDir,
                                         'server.action_extra_data')
        except getMethod.GetMethodException:
            Traceback("queue.get V2")
            raise EmptyAction("Could not get a valid method for %s" % 
                action_type)
        # Call the method
        result = method(self.server_id, action_id, data=data)
        return result

    def length(self, system_id):
        """ Return the queue length for a certain server. """
        # Authenticate the system certificate
        self.auth_system(system_id)
        log_debug(1, self.server_id)
        h = rhnSQL.prepare("""
        select
            count(action_id) id
        from
            rhnServerAction r
        where
            r.server_id = :server_id
        and r.status in (0, 1)
        """)
        h.execute(server_id = self.server_id)
        data = h.fetchone_dict()
        if data is None:
            return 0        
        return data["id"]

    ### PRIVATE methods

    def __update_action(self, action_id, status,
                           resultCode = None, message = ""):
        """ Update the status of an action. """
        log_debug(4, action_id, status, resultCode, message)
        rhnAction.update_server_action(server_id=self.server_id,
            action_id=action_id, status=status, 
            result_code=resultCode, result_message=message)
        return 0
    
    def __errataUpdate(self, actionId):
        """ Old client errata retrieval. """
        log_debug(3, self.server_id, actionId)
        # get the names of the packages associated with each errata and
        # look them up in channels subscribed to by the server and select
        # the latest version
        sql = """
        select
            pn.name name,
            pl.evr.version version,
            pl.evr.release release
        from (
            select
                p.name_id,
                max(pe.evr) evr
            from
                rhnPackageEVR pe,
                rhnChannelPackage cp,
                rhnPackage p,
                rhnServerChannel sc,
                (
                    select
                        p_name.name_id id
                    from
                        rhnActionErrataUpdate aeu,
                        rhnErrataPackage ep,
                        rhnPackage p_name
                    where
                        aeu.action_id = :action_id
                    and aeu.errata_id = ep.errata_id
                    and ep.package_id = p_name.id
                ) nids
            where
                nids.id = p.name_id
            and p.evr_id = pe.id
            and p.id = cp.package_id
            and cp.channel_id = sc.channel_id
            and sc.server_id = :server_id
            group by p.name_id
            ) pl,
            rhnPackageName pn
        where
            pn.id = pl.name_id
        """ 
        h = rhnSQL.prepare(sql)
        h.execute(action_id = actionId, server_id = self.server_id)

        packages = []
        while 1:
            ret = h.fetchone_dict()
            if not ret:
                break
            # older clients have issues with real epochs, se they are
            # kind of irrelevant
            packages.append([ret["name"], ret["version"], ret["release"], ''])
        xml = xmlrpclib.dumps((packages,), methodname='client.update_packages')
        return xml

    def __packageUpdate(self, actionId):
        """ Old client package retrieval. """
        log_debug(3, self.server_id, actionId)
        # The SQL query is a union of:
        # - packages with a specific EVR
        # - the latest packages (no EVR specified)
        # XXX Should we want to schedule the install for a specific version,
        # we'll have to modify this
        statement = """
        select distinct
            pkglist.name name,
            -- decode the evr object selected earlier
            pkglist.evr.version version,
            pkglist.evr.release release
        from (        
            -- get the max of the two possible cases
            select
                pl.name name,
                max(pl.evr) evr
            from (
                -- if the EVR is specifically requested...
                select
                    pn.name name,
                    pe.evr evr
                from    
                    rhnActionPackage ap,
                    rhnPackage p,
                    rhnPackageName pn,
                    rhnPackageEVR pe,
                    rhnServerChannel sc,
                    rhnChannelPackage cp
                where
                    ap.action_id = :action_id
                and ap.evr_id is NOT NULL
                and ap.evr_id = p.evr_id
                and ap.evr_id = pe.id
                and ap.name_id = p.name_id
                and ap.name_id = pn.id
                and p.id = cp.package_id
                and cp.channel_id = sc.channel_id
                and sc.server_id = :server_id
                UNION
                -- when no EVR requested, we need to compute the max available
                -- from the channels the server is subscribed to
                select
                    pn.name name,
                    max(pevr.evr) evr
                from
                    rhnActionPackage ap,
                    rhnServerChannel sc,
                    rhnChannelPackage cp,
                    rhnPackage p,
                    rhnPackageEVR pevr,
                    rhnPackageName pn
                where
                    ap.action_id = :action_id
                and ap.evr_id is null
                and ap.name_id = pn.id
                and ap.name_id = p.name_id
                and p.evr_id = pevr.id
                and sc.server_id = :server_id
                and sc.channel_id = cp.channel_id
                and cp.package_id = p.id
                group by pn.name
            ) pl
            group by pl.name
        ) pkglist
        """
        h = rhnSQL.prepare(statement)
        h.execute(action_id = actionId, server_id = self.server_id)
        ret = h.fetchall_dict() or []
        packages = []
        for p in ret:
            # old clients have issues dealing with real epochs, so we
            # kind of fake it for now in here
            entry = [p['name'], p['version'], p['release'], '']
            packages.append(entry)
        xml = xmlrpclib.dumps((packages,), methodname='client.update_packages')
        return xml

            
#-----------------------------------------------------------------------------
if __name__ == "__main__":
    print "You can not run this module by itself"
    q = Queue()
    sys.exit(-1)
#-----------------------------------------------------------------------------

