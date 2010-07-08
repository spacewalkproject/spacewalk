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
#
# This file contains classes and functions that save and retrieve virtual
# instance information.
#


import string
import time

from common import log_debug, log_error
from server import rhnSQL
from server.rhnServer import server_lib
from server.rhnSQL import procedure

###############################################################################
# Constants
###############################################################################

##
# Ugh... These types should be the same as on the client.  We should consider
# finding a way to share this code.  Possibly move to rhnlib?  I dunno.
#

class ListenerEvent:
    GUEST_DISCOVERED = "guest_discovered"
    GUEST_MIGRATED   = "guest_migrated"

    GUEST_REGISTERED = "guest_registered"


class ClientStateType:
    NOSTATE     = 'nostate'
    RUNNING     = 'running'
    BLOCKED     = 'blocked'
    PAUSED      = 'paused'
    SHUTDOWN    = 'shutdown'
    SHUTOFF     = 'shutoff'
    CRASHED     = 'crashed'

class ServerStateType:
    UNKNOWN     = 'unknown'
    STOPPED     = 'stopped'
    RUNNING     = 'running'
    CRASHED     = 'crashed'
    PAUSED      = 'paused'

class VirtualizationType:
    PARA        = 'para_virtualized'
    FULLY       = 'fully_virtualized'
    QEMU        = 'qemu'
    HYPERV      = 'hyperv'
    VMWARE      = 'vmware'
    VIRTAGE     = 'virtage'

class IdentityType:
    HOST        = 'host'
    GUEST       = 'guest'

class EventType:
    EXISTS      = 'exists'
    REMOVED     = 'removed'
    CRAWL_BEGAN = 'crawl_began'
    CRAWL_ENDED = 'crawl_ended'

class TargetType:
    SYSTEM      = 'system'
    DOMAIN      = 'domain'
    LOG_MSG     = 'log_message'

class PropertyType:
    NAME        = 'name'
    UUID        = 'uuid'
    TYPE        = 'virt_type'
    MEMORY      = 'memory_size'
    VCPUS       = 'vcpus'
    STATE       = 'state'
    IDENTITY    = 'identity'
    ID          = 'id'
    MESSAGE     = 'message'

CLIENT_SERVER_STATE_MAP = { 
    ClientStateType.NOSTATE  : ServerStateType.RUNNING,
    ClientStateType.RUNNING  : ServerStateType.RUNNING,
    ClientStateType.BLOCKED  : ServerStateType.RUNNING,
    ClientStateType.PAUSED   : ServerStateType.PAUSED,
    ClientStateType.SHUTDOWN : ServerStateType.STOPPED,
    ClientStateType.SHUTOFF  : ServerStateType.STOPPED,
    ClientStateType.CRASHED  : ServerStateType.CRASHED
}

###############################################################################
# VirtualizationEventError Class
###############################################################################

class VirtualizationListenerError(Exception): pass
class VirtualizationEventError(Exception): pass

###############################################################################
# Listener Interface
###############################################################################

# Abusing python to get a singleton behavior.
class Listeners:
    listeners = []

def add_listener(listener):
    """
    Allows other components of the server to listen for virtualization
    related events.
    """
    log_debug(3, "Virt listener added: %s" % str(listener))

    # Don't add the listener if it's already there.
    if not listener in Listeners.listeners:
        Listeners.listeners.append(listener)

def remove_listener(listener):
    """
    Removes a virt event listener.
    """
    log_debug(3, "Virt listener removed: %s" % str(listener))
    
    if listener in Listeners.listeners:
        Listeners.listeners.remove(listener)


###############################################################################
# VirtualizationEventHandler Class
###############################################################################

##
# This class handles virtualization events.
#
class VirtualizationEventHandler:

    ##
    # This map defines how to route each event to the appropriate handler.
    #
    HANDLERS = { 
( EventType.EXISTS,      TargetType.SYSTEM )  : '_handle_system_exists',
( EventType.EXISTS,      TargetType.DOMAIN )  : '_handle_domain_exists',
( EventType.REMOVED,     TargetType.DOMAIN )  : '_handle_domain_removed',
( EventType.CRAWL_BEGAN, TargetType.SYSTEM )  : '_handle_system_crawl_began',
( EventType.CRAWL_ENDED, TargetType.SYSTEM )  : '_handle_system_crawl_ended',
( EventType.EXISTS,      TargetType.LOG_MSG ) : '_handle_log_msg_exists'
    }

    ##
    # This map defines the absolute required properties for each event type.
    #
    REQUIRED_PROPERTIES = {
        ( EventType.EXISTS, TargetType.SYSTEM )  : ( PropertyType.IDENTITY,
                                                     PropertyType.UUID, ),
        ( EventType.EXISTS, TargetType.DOMAIN )  : ( PropertyType.UUID, ),
        ( EventType.EXISTS, TargetType.LOG_MSG ) : ( PropertyType.MESSAGE, 
                                                     PropertyType.ID, )
    }

    ###########################################################################
    # Public Methods
    ###########################################################################

    def __init__(self):
        pass

    def handle(self, system_id, notification):

        log_debug(5, "Handling notification:", system_id, notification)

        # First, validate that the notification is in the correct format.  If it
        # is not, we'll bail out.
        if len(notification) != 4:
            raise VirtualizationEventError(
                "Received invalid notification length:", notification,
                "; len=", len(notification))

        # Now we are ready to field the notification.  Begin by parsing it.
        ( timestamp, action, target, properties ) = notification

        event = (action, target)

        # Fetch the appropriate handler.
        handler = None
        try:
            handler = getattr(self, self.HANDLERS[event])
        except KeyError, ke:
            raise VirtualizationEventError(
                "Don't know how to handle virt event:", event)

        # Ensure that the event has any required properties before calling the
        # handler.
        if self.REQUIRED_PROPERTIES.has_key(event):
            required_properties = self.REQUIRED_PROPERTIES[event]
            for required_property in required_properties:
                if not properties.has_key(required_property):
                    raise VirtualizationEventError(
                        "Event does not have required property:", 
                        required_property,
                        event)

        # Some properties need to be preprocessed before we can actually
        # handle the notification.
        self.__convert_properties(properties)

        # Call the handler.
        handler(system_id, timestamp, properties)

    ###########################################################################
    # Protected Methods
    ###########################################################################

    def _handle_system_exists(self, system_id, timestamp, properties):
        uuid      = properties[PropertyType.UUID]
        identity  = properties[PropertyType.IDENTITY]
        virt_type = None

        if properties.has_key(PropertyType.TYPE):
            virt_type = properties[PropertyType.TYPE]
        else:
            # presume paravirt if not specified, probably a host
            virt_type = VirtualizationType.PARA

        row = self.__db_get_system(identity, system_id, uuid)
        if not row:
            self.__db_insert_system(identity, system_id, uuid, virt_type)
        else:
            self.__db_update_system(identity, system_id, row)
            
            self.__notify_listeners(ListenerEvent.GUEST_REGISTERED,
                    row['host_system_id'],
                    system_id)

    def _handle_domain_exists(self, system_id, timestamp, properties):
        uuid = properties[PropertyType.UUID]

        row = self.__db_get_domain(system_id, uuid)
        if not row:
            self.__db_insert_domain(system_id, uuid, properties)

            # We've noticed a new guest; send a notification down the pipeline.
            self.__notify_listeners(ListenerEvent.GUEST_DISCOVERED, 
                                    system_id, 
                                    uuid)
        else:
            self.__db_update_domain(system_id, uuid, properties, row)

            # We'll attempt to detect migration by checking if the host system 
            # ID has changed.
            if row.has_key('host_system_id') and \
                row['host_system_id'] != system_id:
            
                self.__notify_listeners(ListenerEvent.GUEST_MIGRATED,
                                        row['host_system_id'],
                                        system_id,
                                        row['virtual_system_id'],
                                        uuid)
                                       
    ##
    # Handle a domain removal.  Since we are dealing with virtual domains, we
    # can't really tell whether physical removal took place, so we'll just mark
    # the domain as 'stopped'.
    #
    def _handle_domain_removed(self, system_id, timestamp, properties):
        uuid = properties[PropertyType.UUID]

        row = self.__db_get_domain(system_id, uuid)
        if len(row.keys()) == 0:
            log_debug(1, "Guest already deleted in satellite: ", properties)
            return
        new_properties = { PropertyType.STATE : ServerStateType.STOPPED }
        self.__db_update_domain(system_id, uuid, new_properties, row)

    def _handle_system_crawl_began(self, system_id, timestamp, properties):
        self.__unconfirm_domains(system_id)

    def _handle_system_crawl_ended(self, system_id, timestamp, properties):
        self.__remove_unconfirmed_domains(system_id)
        self.__confirm_domains(system_id)

    def _handle_log_msg_exists(self, system_id, timestamp, properties):
        kickstart_session_id = properties[PropertyType.ID]
        log_message          = properties[PropertyType.MESSAGE]

        self.__db_insert_log_message(kickstart_session_id, log_message)

    ###########################################################################
    # Helper Methods
    ###########################################################################

    ##
    # This returns a row from the database that represents a virtual system.
    # If no system could be found, None is returned
    #
    def __db_get_system(self, identity, system_id, uuid):

        condition = None

        # The SELECT condition is different, depending on whether this system 
        # is a host or a guest.  A guest will always have a UUID, while a host 
        # will never have one.  Instead, a host should be identified by its 
        # sysid only.
        #
        # When IdentityType.GUEST, need to worry about cross-org issues...
        # 3 states to worry about:
        # - no prior entry in the VI table; we return nothing, insert happens
        # - prior entry, same org; we return that one, update happens
        # - prior entry, different org; we return nothing, insert happens sans host sid
        if identity == IdentityType.HOST:
            condition = """
                vi.uuid is null
                and vi.host_system_id=:sysid
            """
        elif identity == IdentityType.GUEST:
            condition = """
                vi.uuid=:uuid
                AND (vi.virtual_system_id is null or
                     vi.virtual_system_id = :sysid)
                and exists (
                    select 1
                    from
                        rhnServer sguest,
                        rhnServer shost
                    where
                        shost.id is not null
                        and shost.id = vi.host_system_id
                        and sguest.id = :system_id
                        and shost.org_id = sguest.org_id )
            """ 
        else:
            raise VirtualizationEventError(
                "Unknown identity:", identity)

        select_sql = """
            SELECT
                vi.id                id,
                vi.host_system_id    host_system_id,
                vi.virtual_system_id virtual_system_id,
                vi.uuid              uuid,
                vi.confirmed         confirmed
            FROM
                rhnVirtualInstance vi
            WHERE
                %s
        """ % (condition)
        query = rhnSQL.prepare(select_sql)
        query.execute(sysid = system_id, uuid = uuid,
                system_id = system_id)
 
        row = query.fetchone_dict() or {}

        return row

    ##
    # Inserts a new system into the database.
    #
    def __db_insert_system(self, identity, system_id, uuid, virt_type):

        # If this system is a host, it's sysid goes into the host_system_id
        # column.  Otherwise, it's sysid goes into the virtual_system_id
        # column.
        host_id  = None
        guest_id = None
        if   identity == IdentityType.HOST:  host_id  = system_id
        elif identity == IdentityType.GUEST: 
            guest_id = system_id

            # Check to see if this uuid has already been registered to a
            # host in the same org and is confirmed.
            check_sql = """
                select 
                    vi.id,
                    vi.host_system_id,
                    vi.confirmed
                from 
                    rhnServer sguest,
                    rhnServer shost,
                    rhnVirtualInstance vi
                where 
                    vi.uuid = :uuid
                    and confirmed = 1
                    and vi.host_system_id is not null
                    and vi.host_system_id = shost.id
                    and :system_id = sguest.id
                    and shost.org_id = sguest.org_id
            """

            query = rhnSQL.prepare(check_sql)
            query.execute(uuid = uuid, system_id = system_id)

            row = query.fetchone_dict()

            if row:
                # We found a host for this guest, we'll save the value
                # to use when we create the row in rhnVirtualInstance.
                host_id = row['host_system_id']
            else:
                # We didn't find a host, this guest will just end up with
                # no host, and consuming physical entitlements.
                pass

        else:
            raise VirtualizationEventError(
                "Unknown identity:", identity)

        get_id_sql = "SELECT sequence_nextval('rhn_vi_id_seq') as id FROM dual"
        query = rhnSQL.prepare(get_id_sql)
        query.execute()
        row = query.fetchone_dict() or {}

        if not row or not row.has_key('id'):
            raise VirtualizationEventError('unable to get virt instance id')
        
        insert_sql = """
            INSERT INTO rhnVirtualInstance
                (id, host_system_id, virtual_system_id, uuid, confirmed)
            VALUES
                (:id, :host_id, :guest_id, :uuid, 1)
        """
        query = rhnSQL.prepare(insert_sql)
        query.execute(id = row['id'],
                      host_id = host_id,
                      guest_id = guest_id,
                      uuid = uuid)

        # Initialize a dummy info record for this system.
        insert_sql = """
            INSERT INTO rhnVirtualInstanceInfo
                (instance_id, state, instance_type)
            VALUES
                (:id,
                 (
                     SELECT rvis.id
                     FROM rhnVirtualInstanceState rvis
                     WHERE rvis.label = :state
                 ),
                 (
                     SELECT rvit.id
                     FROM rhnVirtualInstanceType rvit
                     WHERE rvit.label = :virt_type
                 ))
        """
        query = rhnSQL.prepare(insert_sql)
        query.execute(id=row['id'],
                      state = ServerStateType.UNKNOWN, 
                      virt_type = virt_type)

    ##
    # Updates a system in the database.
    #
    def __db_update_system(self, identity, system_id, existing_row):

        # since __db_get_system protects us against crossing the org
        # boundary, we really don't need to worry much about existing_row's
        # values...

        new_values_array = []
        bindings = {}
        if not existing_row.get('confirmed'): 
            new_values_array.append("confirmed=1")

        # Some guests may have been unregistered before, and therefore did not
        # have sysid's.  If we got an EXISTS for a guest system, then a guest
        # must have been registered.  Make sure that we update the 
        # virtual_system_id column in the DB to reflect that this guest is now 
        # registered.
        if identity == IdentityType.GUEST:
            if existing_row['virtual_system_id'] != system_id:
                new_values_array.append("virtual_system_id=:sysid")
                bindings['sysid'] = system_id
                # note, at this point, it's still possible to have
                # an entry in rhnVirtualInstance for this uuid w/out
                # a virtual_system_id; it'd be for a different org

        # Only touch the database if something changed.
        if new_values_array:
            new_values = string.join(new_values_array, ', ')
        
            bindings['row_id'] = existing_row['id']

            update_sql = """
                UPDATE rhnVirtualInstance SET %s WHERE id=:row_id
            """ % (new_values)
            query = rhnSQL.prepare(update_sql)
            query.execute(**bindings)


    def __db_get_domain(self, host_id, uuid):
        select_sql = """
            SELECT
                rvi.id                rvi_id,
                rvi.host_system_id    host_system_id,
                rvi.virtual_system_id virtual_system_id,
                rvi.confirmed         confirmed,
                rvii.name             name,
                rvit.label            instance_type,
                rvii.memory_size_k    memory_size_k,
                rvii.instance_id      instance_id,
                rvii.vcpus            vcpus,
                rvis.label            state
            FROM
                rhnVirtualInstanceInfo rvii,
                rhnVirtualInstanceType rvit,
                rhnVirtualInstanceState rvis,
                rhnVirtualInstance rvi
            WHERE
                ((rvi.uuid=:uuid and
                  NOT EXISTS (SELECT 1
                                FROM rhnServer host_system,
                                     rhnServer matching_uuid_system
                               WHERE matching_uuid_system.id = rvi.virtual_system_id
                                 AND host_system.id = :host_id
                                 AND host_system.org_id != matching_uuid_system.org_id)) or
                 (:uuid is null and 
                      rvi.uuid is null and 
                      rvi.host_system_id=:host_id)) and
                rvi.id = rvii.instance_id and
                rvit.id = rvii.instance_type and
                rvis.id = rvii.state
        """
        query = rhnSQL.prepare(select_sql)
        query.execute(host_id = host_id, uuid = uuid)
 
        row = query.fetchone_dict() or {}

        return row

    def __db_insert_domain(self, host_id, uuid, properties):

        # To create a new domain, we must modify both the rhnVirtualInstance 
        # and the rhnVirtualInstanceInfo tables.  We'll do rhnVirtualInstance
        # first.

        get_id_sql = "SELECT sequence_nextval('rhn_vi_id_seq') as id FROM dual"
        query = rhnSQL.prepare(get_id_sql)
        query.execute()
        row = query.fetchone_dict() or {}

        if not row or not row.has_key('id'):
            raise VirtualizationEventError('unable to get virt instance id')
        id = row['id']

        insert_sql = """
            INSERT INTO rhnVirtualInstance
                (id, host_system_id, virtual_system_id, uuid, confirmed)
            VALUES
                (:id, :host_id, null, :uuid, 1)
        """
        query = rhnSQL.prepare(insert_sql)
        query.execute(id = id, host_id = host_id, uuid = uuid)

        # Now we'll insert into the rhnVirtualInstanceInfo table.

        insert_sql = """
            INSERT INTO rhnVirtualInstanceInfo
                (instance_id,
                 name,
                 vcpus,
                 memory_size_k,
                 instance_type,
                 state)
            SELECT
                :id,
                :name, 
                :vcpus,
                :memory,
                rvit.id, 
                rvis.id
            FROM
                rhnVirtualInstanceType rvit,
                rhnVirtualInstanceState rvis
            WHERE
                rvit.label=:virt_type and
                rvis.label=:state
        """
        name      = properties[PropertyType.NAME]
        vcpus     = properties[PropertyType.VCPUS]
        memory    = properties[PropertyType.MEMORY]
        virt_type = properties[PropertyType.TYPE]
        state     = properties[PropertyType.STATE]

        query = rhnSQL.prepare(insert_sql)
        query.execute(id = id,
                      name = name,
                      vcpus = vcpus,
                      memory = memory,
                      virt_type = virt_type,
                      state = state)

    def __db_update_domain(self, host_id, uuid, properties, existing_row):

        # First, update the rhnVirtualInstance table.  If a guest domain was 
        # registered but its host was not, it is possible that the 
        # rhnVirtualInstance table's host_system_id column is null.  We'll
        # update that now, if need be.

        # __db_get_domain is responsible for ensuring that the org for any
        # existing_row matches the org for host_id
        
        new_values_array = []
        bindings = {}

        if not existing_row.get('confirmed'): 
            new_values_array.append('confirmed=1')

        if existing_row['host_system_id'] != host_id:
            new_values_array.append('host_system_id=:host_id')
            bindings['host_id'] = host_id

        # Only touch the database if something changed.
        if new_values_array:
            new_values = string.join(new_values_array, ', ')
        
            bindings['row_id'] = existing_row['rvi_id']

            update_sql = """
                UPDATE rhnVirtualInstance SET %s WHERE id=:row_id
            """ % (new_values)
            query = rhnSQL.prepare(update_sql)

            try:
                query.execute(**bindings)
            except rhnSQL.SQLError, e:
                log_error(str(e))
                raise VirtualizationEventError, str(e)

        # Now update the rhnVirtualInstanceInfo table.
 
        new_values_array = []
        bindings = {}

        if properties.has_key(PropertyType.NAME) and \
           existing_row['name'] != properties[PropertyType.NAME]:
            new_values_array.append('name=:name')
            bindings['name'] = properties[PropertyType.NAME]

        if properties.has_key(PropertyType.VCPUS) and \
           existing_row['vcpus'] != properties[PropertyType.VCPUS]:
            new_values_array.append('vcpus=:vcpus')
            bindings['vcpus'] = properties[PropertyType.VCPUS]

        if properties.has_key(PropertyType.MEMORY) and \
           existing_row['memory_size_k'] != properties[PropertyType.MEMORY]:
            new_values_array.append('memory_size_k=:memory')
            bindings['memory'] = properties[PropertyType.MEMORY]

        if properties.has_key(PropertyType.TYPE) and \
           existing_row['instance_type'] != properties[PropertyType.TYPE]:
            new_values_array.append("""
                instance_type = (
                    select rvit.id
                    from rhnVirtualInstanceType rvit
                    where rvit.label = :virt_type)
            """)
            bindings['virt_type'] = properties[PropertyType.TYPE]

        if properties.has_key(PropertyType.STATE) and \
           existing_row['state'] != properties[PropertyType.STATE]:
            new_values_array.append("""
                state = (
                    SELECT rvis.id 
                    FROM rhnVirtualInstanceState rvis 
                    WHERE rvis.label = :state)
            """)
            bindings['state'] = properties[PropertyType.STATE]

        # Only touch the database if something changed.
        if new_values_array:
            new_values = string.join(new_values_array, ', ')
        
            bindings['row_id'] = existing_row['instance_id']

            update_sql = """
                UPDATE rhnVirtualInstanceInfo SET %s WHERE instance_id=:row_id
            """ % (new_values)
            query = rhnSQL.prepare(update_sql)
            query.execute(**bindings)

    def __unconfirm_domains(self, system_id):
        update_sql = """
            UPDATE rhnVirtualInstance
            SET confirmed=0
            WHERE host_system_id=:sysid
        """
        query = rhnSQL.prepare(update_sql)
        query.execute(sysid=system_id)

    def __confirm_domains(self, system_id):
        update_sql = """
            UPDATE rhnVirtualInstance
            SET confirmed=1
            WHERE host_system_id=:sysid
        """
        query = rhnSQL.prepare(update_sql)
        query.execute(sysid=system_id)

    def __remove_unconfirmed_domains(self, system_id):
        # Mark the unconfirmed entries in the RVII table as stopped, since it 
        # appears they are no longer running.
     
        update_sql = """
            UPDATE rhnVirtualInstanceInfo rvii
            SET rvii.state=(
                SELECT rvis.id 
                FROM rhnVirtualInstanceState rvis
                WHERE rvis.label=:state
            )
            WHERE
                rvii.instance_id IN (
                    SELECT rvi.id
                    FROM rhnVirtualInstance rvi
                    WHERE rvi.confirmed=0)
        """
        query = rhnSQL.prepare(update_sql)
        query.execute(state = ServerStateType.STOPPED)

    def __db_insert_log_message(self, kickstart_session_id, log_message):
        """
        Insert a new installation log message into the database.
        """

        # log_message must be 4000 chars or shorter, db constraint
        log_message = log_message[:4000]

        insert_sql = """
            INSERT INTO rhnVirtualInstanceInstallLog
                (id, log_message, ks_session_id)
            VALUES
                (sequence_nextval('rhn_viil_id_seq'), :log_message, :kickstart_session_id)
        """
        query = rhnSQL.prepare(insert_sql)
        query.execute(log_message          = log_message, 
                      kickstart_session_id = kickstart_session_id)

    ##
    # This function normalizes and converts the values of some properties to 
    # format consumable by the server.
    #
    def __convert_properties(self, properties):

        # Attempt to normalize the UUID.
        if properties.has_key(PropertyType.UUID):
            uuid = properties[PropertyType.UUID]
            if uuid:
                uuid_as_number = string.atol(uuid, 16)

                if uuid_as_number == 0:
                    # If the UUID is a bunch of null bytes, we will convert it 
                    # to None.  This will allow us to interact with the 
                    # database properly, since the database assumes a null UUID
                    # when the system is a host.
                    properties[PropertyType.UUID] = None
                else:
                    # Normalize the UUID.  We don't know how it will appear 
                    # when it comes from the client, so we'll convert it to a 
                    # normal form.
                    # if UUID had leading 0, we must pad 0 again #429192
                    properties[PropertyType.UUID] = "%032x" % uuid_as_number

        # The server only cares about certain types of states.
        if properties.has_key(PropertyType.STATE):
            state = properties[PropertyType.STATE]
            properties[PropertyType.STATE] = CLIENT_SERVER_STATE_MAP[state]

        # We must send the memory across as a string because XMLRPC can only
        # handle up to 32 bit numbers.  RAM can easily exceed that limit these
        # days.
        if properties.has_key(PropertyType.MEMORY):
            memory = properties[PropertyType.MEMORY]
            properties[PropertyType.MEMORY] = long(memory)

    def __notify_listeners(self, *args):
        for listener in Listeners.listeners:
            listener._notify(*args)

###############################################################################
# Module level functions
###############################################################################
def _handle_virt_guest_params(system_certificate, params):
    # Get the uuid, if there is one.
    if params.has_key('virt_uuid'):
        virt_uuid = params['virt_uuid']
        if virt_uuid is not None and not is_host_uuid(virt_uuid):
            # If we don't have a virt_type key, we'll assume PARA.
            virt_type = None
            if params.has_key('virt_type'):
                virt_type = params['virt_type']
                if virt_type == 'para':
                    virt_type = VirtualizationType.PARA
                elif virt_type == 'fully':
                    virt_type = VirtualizationType.FULLY
                else:
                    raise Exception(
                        "Unknown virtualization type: %s" % virt_type)
            else:
                raise Exception("Virtualization type not provided")

            _notify_guest(system_certificate, virt_uuid, virt_type)

# Notifies the virtualization backend that there is a guest with a
# specific
# uuid and type, then associates it with the provided system id.
#
# New for RHEL 5.
#
# Args are:
# * system_id   - a string representation of the system's system id.
# * uuid        - a string representation of the system's uuid.
# * virt_type   - a string representation of the system's virt type
# 
# No return value.
def _notify_guest(server_id, uuid, virt_type):
    identity = IdentityType.GUEST
    event = EventType.EXISTS
    target = TargetType.SYSTEM
    properties = {
                    PropertyType.IDENTITY   :   identity,
                    PropertyType.UUID       :   uuid,
                    PropertyType.TYPE       :   virt_type,
                 }

    virt_action = _make_virt_action(event, target, properties)
    _virt_notify(server_id, [virt_action])

def _virt_notify(server_id, actions):
        # Instantiate the event handler.
        handler = VirtualizationEventHandler()

        # Handle each of the actions, in turn.
        for action in actions:
            log_debug(5, "Processing action:", action)

            try:
                handler.handle(server_id, action)
            except VirtualizationEventError, vee:
                log_error(
                    "An error occurred while handling a virtualization event:",
                    vee,
                    "Ignoring event...")

        # rhnSQL.commit()
        return 0


def _make_virt_action(event, target, properties):
    """
    Construct a tuple representing a virtualization action.
    
    New for RHEL 5. 
    
    Args are:
    * event       - one of EventType.EXISTS, EventType.REMOVED, 
                    EventType.CRAWL_BEGAN, EventType.CRAWL_ENDED
    * target      - one of TargetType.SYSTEM, TargetType.DOMAIN, 
                    TargetType.LOG_MSG
    * properties  - a dictionary that associates a PropertyType with
                    a value (typically a string).
    
    Return a tuple consisting of (timestamp, event, target, properties).
    """

    current_time = int(time.time())
    return (current_time, event, target, properties)


def is_host_uuid(uuid):
    uuid = eval('0x%s' % uuid)
    return long(uuid) == 0L
    

###############################################################################
# Testing
###############################################################################

if __name__ == '__main__':

    rhnSQL.initDB("rhnsat/rhnsat@rhnsat")

    host_sysid  = 1000010001
    guest_sysid = 1000010010
    handler = VirtualizationEventHandler()

    # Create some fake actions.

    host_exists  = ( int(time.time()), 
                     EventType.EXISTS, 
                     TargetType.SYSTEM, 
                     { PropertyType.UUID     : None,
                       PropertyType.IDENTITY : IdentityType.HOST   })

    guest_exists = ( int(time.time()), 
                     EventType.EXISTS, 
                     TargetType.SYSTEM, 
                     { PropertyType.UUID     : '2e2e2e2e2e2e2e2e',
                       PropertyType.IDENTITY : IdentityType.GUEST  })

    crawl_began  = ( int(time.time()),
                     EventType.CRAWL_BEGAN,
                     TargetType.SYSTEM,
                     {} )

    dom0_exists  = ( int(time.time()),
                     EventType.EXISTS,
                     TargetType.DOMAIN,
                     { PropertyType.UUID     : None,
                       PropertyType.NAME     : 'DOM0_TEST',
                       PropertyType.TYPE     : VirtualizationType.PARA,
                       PropertyType.STATE    : ClientStateType.RUNNING,
                       PropertyType.VCPUS    : 5,
                       PropertyType.MEMORY   : 1111111 } )

    domU1_exists = ( int(time.time()),
                     EventType.EXISTS,
                     TargetType.DOMAIN,
                     { PropertyType.UUID     : '1f1f1f1f1f1f1f1f',
                       PropertyType.NAME     : 'DOMU1_TEST',
                       PropertyType.TYPE     : VirtualizationType.PARA,
                       PropertyType.STATE    : ClientStateType.BLOCKED,
                       PropertyType.VCPUS    : 1,
                       PropertyType.MEMORY   : 22222 } )

    domU2_exists = ( int(time.time()),
                     EventType.EXISTS,
                     TargetType.DOMAIN,
                     { PropertyType.UUID     : '2e2e2e2e2e2e2e2e',
                       PropertyType.NAME     : 'DOMU2_TEST',
                       PropertyType.TYPE     : VirtualizationType.PARA,
                       PropertyType.STATE    : ClientStateType.PAUSED,
                       PropertyType.VCPUS    : 2,
                       PropertyType.MEMORY   : 44444 } )

    crawl_ended  = ( int(time.time()),
                     EventType.CRAWL_ENDED,
                     TargetType.SYSTEM,
                     {} )

    # Host reg'd, guest reg'd, crawl.

    handler.handle(host_sysid,  host_exists)
    handler.handle(guest_sysid, guest_exists)
    handler.handle(guest_sysid, crawl_began)
    handler.handle(guest_sysid, crawl_ended)
    handler.handle(host_sysid,  crawl_began)
    handler.handle(host_sysid,  dom0_exists)
    handler.handle(host_sysid,  domU1_exists)
    handler.handle(host_sysid,  domU2_exists)
    handler.handle(host_sysid,  crawl_ended)
    # rhnSQL.commit()

    # Clear out the database for this sysid.
    handler.handle(host_sysid,  crawl_began)
    handler.handle(host_sysid,  crawl_ended)
    # rhnSQL.commit()

    # Host reg'd, crawl, guest reg'd.

    handler.handle(host_sysid,  host_exists)
    handler.handle(host_sysid,  crawl_began)
    handler.handle(host_sysid,  dom0_exists)
    handler.handle(host_sysid,  domU1_exists)
    handler.handle(host_sysid,  domU2_exists)
    handler.handle(host_sysid,  crawl_ended)
    handler.handle(guest_sysid, guest_exists)
    handler.handle(guest_sysid, crawl_began)
    handler.handle(guest_sysid, crawl_ended)
    # rhnSQL.commit()

    # Now do some dynamic updates.

    domU2_changed = ( int(time.time()),
                      EventType.EXISTS,
                      TargetType.DOMAIN,
                      { PropertyType.UUID  : '2e2e2e2e2e2e2e2e',
                        PropertyType.NAME  : 'CHANGED_DOMU2_TEST',
                        PropertyType.STATE : ClientStateType.RUNNING } )

    handler.handle(host_sysid, domU2_changed)
    # rhnSQL.commit()


# XXX: put this somewhere better
###############################################################################
# VirtualizationListener Class
###############################################################################

class VirtualizationListener:
    
    def __init__(self):
        pass

    def guest_migrated(self, old_host_sid, new_host_sid, guest_sid, guest_uuid):
        """
        This function is called if we infer that the guest has been migrated
        to a different host system.

            old_host_sid - The server id for the old host.
            new_host_sid - The server id for the new host.
            guest_sid    - The server id for the guest, if it is registered.
            guest_uuid   - The UUID of the guest that has been migrated.
        """
        pass

    def guest_discovered(self, host_sid, guest_uuid, guest_sid = None):
        """
        This function is called if we detect a new guest.
        """
        pass

    def guest_registered(self, host_sid, guest_sid):
        pass

    ###########################################################################
    # Protected Interface
    ###########################################################################

    def _notify(self, event, *args):
        if event == ListenerEvent.GUEST_MIGRATED:
            self.guest_migrated(*args)
        elif event == ListenerEvent.GUEST_DISCOVERED:
            self.guest_discovered(*args)
        elif event == ListenerEvent.GUEST_REGISTERED:
            self.guest_registered(*args)

class EntitlementVirtualizationListener(VirtualizationListener):

    def guest_migrated(self, old_host_sid, new_host_sid, guest_sid, guest_uuid):
        try:
            procedure.rhn_entitlements.repoll_virt_guest_entitlements(new_host_sid)
        except rhnSQL.SQLError, e:
            log_error("Error adding entitlement: %s" %str(e))
            # rhnSQL.rollback()
            return

        # rhnSQL.commit()

    def guest_registered(self, host_sid, guest_sid):
        host_system_slots = server_lib.check_entitlement(host_sid)
        host_system_slots = host_system_slots.keys()

        try:
            host_system_slots.remove("virtualization_host")
        except ValueError:
            pass
        try:
            host_system_slots.remove("virtualization_host_platform")
        except ValueError:
            pass

        guest_system_slots = server_lib.check_entitlement(guest_sid)
        guest_system_slots = guest_system_slots.keys()

        for entitlement in host_system_slots:
            if entitlement not in guest_system_slots:
                try:
                    procedure.rhn_entitlements.entitle_server(guest_sid,
                            entitlement)
                except rhnSQL.SQLError, e:
                    log_error("Error adding entitlement %s: %s"
                            % (entitlement, str(e)))
                    # rhnSQL.rollback()
                    return

        # rhnSQL.commit()



# This file provides an interface that allows components of the RHN server to
# listen for virtualization events.

###############################################################################
# Constants
###############################################################################


add_listener(EntitlementVirtualizationListener())
