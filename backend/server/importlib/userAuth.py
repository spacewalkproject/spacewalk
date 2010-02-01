#!/usr/bin/python
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
# Authentication
#

from common import CFG, rhnFault, log_debug, add_to_seclist
from common.rhnTranslate import _

from server import rhnSQL, rhnUser

class UserAuth:
    def __init__(self):
        self.org_id = None
        self.user_id = None
        self.groups = []

    def auth(self, login, password):
        add_to_seclist(password)
        self.groups, self.org_id, self.user_id = getUserGroups(login, password)
        log_debug(4, "Groups: %s; org_id: %s; user_id: %s" % (
            self.groups, self.org_id, self.user_id))

    def auth_session(self, session_string):
        user_instance = rhnUser.session_reload(session_string)
        self.groups, self.org_id, self.user_id = getUserGroupsFromUserInstance(user_instance)
        log_debug(4, "Groups: %s; org_id: %s; user_id: %s" % (
            self.groups, self.org_id, self.user_id))

    def isSuperuser(self):
        if 'rhn_superuser' in self.groups:
            log_debug(4, "Is superuser")
            return 1
        log_debug(4, "Is NOT superuser")
        return 0

    def isOrgAdmin(self):
        if self.isSuperuser():
            log_debug(4, "Is org admin because isa superuser")
            # Superusers can do anything
            return 1
        if 'org_admin' in self.groups:
            log_debug(4, "Is org admin")
            return 1
        log_debug(4, "Is NOT org admin")
        return 0

    def isChannelAdmin(self):
        if self.isSuperuser():
            # Superusers can do anything
            log_debug(4, "Is channel admin because isa superuser")
            return 1
        if 'org_admin' in self.groups:
            log_debug(4, "Is channel admin because isa org admin")
            return 1
        if 'channel_admin' in self.groups:
            log_debug(4, "Is channel admin")
            return 1
        log_debug(4, "Is NOT channel admin")
        return 0

    def authzOrg(self, info):
        # This function is a lot more complicated than it should be; the
        # corner case is pushes without a channel; we have to deny regular
        # users the ability to push to their org.
        
        # If the org id is not specified, default to the user's org id
        if not info.has_key('orgId'):
            info['orgId'] = self.org_id
        log_debug(4, "info[orgId]", info['orgId'], "org id", self.org_id)
            
        org_id = info['orgId']

        if org_id == '':
            # Satellites are not allowwd to push in the null org
            raise rhnFault(4, 
                _("You are not authorized to manage packages in the null org"))
            if not self.isSuperuser():
                # Nope
                raise rhnFault(4, 
                    _("You are not authorized to manage packages in the null org"))

            org_id = None

        if org_id and self.org_id != org_id:
            # Not so fast...
            raise rhnFault(32, 
                _("You are not allowed to manage packages in the %s org") %
                    org_id)
            
        # Org admins and channel admins have full privileges; we could use
        # user_manages_channes, except for the case where there are no chanels
        
        if self.isOrgAdmin() or self.isChannelAdmin():
            log_debug(4, "Org authorized (org_admin or channel_admin)")
            return
            
        # regular user at this point... check if the user manages any channels
        if user_manages_channels(self.user_id):
            log_debug(4, "Org authorized (user manages a channel)")
            return

        # ok, you're a regular user who doesn't manage any channels.
        # take a hike.
        raise rhnFault(32, 
            _("You are not allowed to perform administrative tasks"))


    def authzChannels(self, channels):
        log_debug(4, channels)
        if not channels:
            return
        if 'rhn_superuser' in self.groups:
            log_debug(4, "Is superuser")
            return None

        # rhn_channel.user_role_check checks for the ownership of the channel
        # by this user's org

        h = rhnSQL.prepare("""
            select rhn_channel.user_role_check(id, :user_id, 'manage') manage
              from rhnChannel
             where label = :channel
        """)

        for channel in channels:
            h.execute(channel=channel, user_id=self.user_id)

            row = h.fetchone_dict()
            # Either the channel doesn't exist, or not allowed to manage it
            if not row or not row['manage']:
                raise rhnFault(32,
                    _("You are not allowed to manage channel %s, or that "
                    "channel does not exist") % channel)

            log_debug(4, "User %s allowed to manage channel %s" %
                (self.user_id, channel))

        return None


#wregglej 12/21/05 This should only be used when the user instance has already been reloaded from
#a session.
def getUserGroupsFromUserInstance(user_instance):
    log_debug(4, user_instance.getid())
    user = user_instance

    if not user:
        log_debug("null user")
        raise rhnFault(2)

    #Don't need to check the password, the session should have already been checked.
    
    # Get the org id
    org_id = user.contact['org_id']
    user_id = user.getid()
    h = rhnSQL.prepare("""
        select ugt.label
          from rhnUserGroupType ugt,
               rhnUserGroup ug,
               rhnUserGroupMembers ugm
         where ugm.user_id = :user_id
               and ugm.user_group_id = ug.id
               and ug.group_type = ugt.id
    """)
    h.execute(user_id=user_id)
    groups = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        groups.append(row['label'])
    return groups, org_id, user_id 
    

def getUserGroups(login, password):
    # Authenticates a user and returns the list of groups it belongs
    # to, and the org id
    add_to_seclist(password)
    log_debug(4, login)
    user = rhnUser.search(login)

    if not user:
        log_debug("rhnUser.search failed")
        raise rhnFault(2)

    # Check the user's password
    if not user.check_password(password):
        log_debug("user.check_password failed")
        raise rhnFault(2)

    # Get the org id
    org_id = user.contact['org_id']
    user_id = user.getid()
    h = rhnSQL.prepare("""
        select ugt.label
          from rhnUserGroupType ugt,
               rhnUserGroup ug,
               rhnUserGroupMembers ugm
         where ugm.user_id = :user_id
               and ugm.user_group_id = ug.id
               and ug.group_type = ugt.id
    """)
    h.execute(user_id=user_id)
    groups = []
    while 1:
        row = h.fetchone_dict()
        if not row:
            break
        groups.append(row['label'])
    return groups, org_id, user_id


def user_manages_channels(user_id):
    h = rhnSQL.prepare("""
        select distinct 1 
          from rhnChannel
         where rhn_channel.user_role_check(id, :user_id, 'manage') = 1
    """)

    h.execute(user_id=user_id)
    row = h.fetchone_dict()

    return (row is not None)
