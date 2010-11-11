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
# channel mgmt functions
# This is the XML-RPC response handler for manage-channel tool


from spacewalk.common import RPC_Base, rhnFault, log_debug
from spacewalk.server import rhnSQL, rhnKickstart
from spacewalk.server.importlib.userAuth import UserAuth

import string

rhnChannel_fields = (
        'id', 'label', 'parent_channel', 'orgid', 'basedir', 'name', 
        'summary', 'description', 'gpg_key_url', 'gpg_key_id', 'gpg_key_fp',
        'channel_arch_id', 'end_of_life',
    )

class Channel(RPC_Base):
    def __init__(self):
        log_debug(3)
	RPC_Base.__init__(self)        
        self.functions = [
            'addKSTree',
            'createChannel',
            'listChannel',
            'deleteChannel',
            'delKSTree',
            'updateChannel',
            'listChannelForOrg',
            'lookupChannel',
            'lookupChannelFamily',
            'lookupChannelArch',
            'lookupOrgId',
            'updateChannelMembership',
            'channelCreateTransaction',
            'moveChannelDownloads',
            'deleteDist',
            'updateDist',
            'checkChannelAuthPermission',
            'channelManagePermission',
            'revokeChannelPermission',
        ]
        
    def _auth(self, username, password):

        if not (username and password):
            raise rhnFault(50, "Missing username/password arguments",
                explain=0)

        authobj = auth(username, password)

        if not authobj:
            raise rhnFault(50, "Invalid username/password arguments",
                                           explain=0)
        return authobj

    
    def addKSTree(self, username, password, channel_label, ks_label, path,
                  install_type, tree_type, clear, files, pkgs, ignore_lint_errors, commit):

        log_debug(3)
        self._auth(username, password)

        # channel = rhnChannel.channel_info(channel_label)

        # if channel is '':
            # raise rhnFault(40, 'Could not lookup channel ' + channel_label)
# 
        # channel_id = channel['id']            
       
        kstree = rhnKickstart.lookup_tree(ks_label, pkgs)

        if kstree != None and clear:
            kstree.delete_tree()
            kstree = None

        if kstree == None:
            boot_image = ks_label
            kstree = rhnKickstart.create_tree(ks_label, channel_label, path, boot_image,
                                              tree_type, install_type, pkgs)

        # Firstly, we should lint the tree, and if we're not set to ignore linting errors
        # we error.
        lint_results =  kstree.lint_tree()

        if lint_results != None and not ignore_lint_errors:
            rhnSQL.rollback()
            raise rhnFault (2102, """
            The following packages in the kickstart tree were not found in the
            channel:
            %s
            """ % lint_results, explain=0)
        
        kstree.clear_files()

        for file in files:
            if kstree.has_file(file):
                continue
            else:

                log_debug(3, 'trying to insert ' + file['last_modified'] + ' as last_modified')

                kstree.add_file(file)

        if commit:
            rhnSQL.commit()
            message = 'Success. Committing transaction.'
        else:
            rhnSQL.rollback()
            message = 'Success. Rolling back transaction.  --commit not specified'

        return message

    def delKSTree(self, username, password, ks_label, commit):

        log_debug(3)
        self._auth(username, password)

        kstree = rhnKickstart.lookup_tree(ks_label)

        if not isinstance(kstree, rhnKickstart.Kickstart):
            message = 'Kickstart tree not found'
            return message
        else:
            kstree.delete_tree()

        if commit:
            rhnSQL.commit()
            message = 'Success. Committing transaction.'
        else:
            rhnSQL.rollback()
            message = 'Success. Rolling back transaction.  --commit not specified'

        return message


    def createChannel(self, params, commit, username, password):       
        log_debug(3)
        self._auth(username, password)
        
        params['id'] = rhnSQL.Sequence("rhn_channel_id_seq").next()
        fields = []
        for f in rhnChannel_fields:
            if params.has_key(f):
                fields.append(f)
        
        field_names = string.join(fields, ", ")
        bind_vars = string.join(map(lambda x: ':' + x, fields), ', ')
        try:
            rhnSQL.execute("insert into rhnChannel (%s) values (%s)" %
                                 (field_names, bind_vars),
                                 **params)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )

        if commit:
            rhnSQL.commit()
        else:
            rhnSQL.rollback()
            return 1
        return params['id']

    def updateChannel(self, params, channel_id, old_channel_family_id,
                      new_channel_family_id, commit, username, password):
        log_debug(3)
        global rhnChannel_fields
        
        authobj = self._auth(username, password)
        authobj.isChannelAdmin()
        
        fields = []
        for f in rhnChannel_fields:
            if params.has_key(f):
                fields.append(f)
        
        set_clause = string.join(
            map(lambda x: "%s = :%s" % (x, x), fields), ', ')
        
        try:
            rhnSQL.execute("update rhnChannel set %s where id = :id" % set_clause,
                           **params)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )

        self.deleteDist(channel_id, username, password)
        
        self.moveChannelDownloads(channel_id, old_channel_family_id,
                               new_channel_family_id, username, password)
        if commit:
            rhnSQL.commit()
        else:
            rhnSQL.rollback()
            return 1
        
        return 0
        
    # All channels.
    def listChannel(self, username, password):
        log_debug(3)
        self._auth(username, password)
        ret = rhnSQL.fetchall_dict("select label from rhnChannel") or []
        return map(lambda x: x['label'], ret)


    # A specific orgs channels.
    def listChannelForOrg(self, orgId, username, password):
        log_debug(3)
        self._auth(username, password)
        
        # Red Hat only:
        if not orgId:
            orgId = 1
        ret = rhnSQL.fetchall_dict("""select label from rhnChannel
                                       where org_id = :orgId""",
                                       orgId=int(orgId)) or []
        return map(lambda x: x['label'], ret)

    def _insert_channel_family(self, channel_id):
        log_debug(3)
        
        # get channel family info for this channel
        # A channel can currently be in at most one channel family
        row = rhnSQL.fetchone_dict("""
        select cfm.channel_family_id, cf.label channel_family
          from rhnChannelFamilyMembers cfm,
               rhnChannelFamily cf
         where cfm.channel_id = :channel_id
           and cfm.channel_family_id = cf.id
        """, channel_id=channel_id)
        if row:
            return removeNone(row)
        
        return { 'channel_family_id' :'', 'channel_family' : ''}

    def lookupChannel(self, name, username, password):
        log_debug(3)
        authobj = self._auth(username, password)
        authobj.isChannelAdmin()

        row = rhnSQL.fetchone_dict("select * from rhnChannel where label = :label",
                                   label=name)
        if row:
            row.update(self._insert_channel_family(row['id']))
            row['last_modified'] = str(row['last_modified'])
            row['modified'] = str(row['modified'])
            row['created'] = str(row['created'])
            return removeNone(row)

        # Look the channel up by id
        try:
            name = int(name)
        except ValueError:
            return ''

        row = rhnSQL.fetchone_dict("select * from rhnChannel where id = :channel_id",
                                    channel_id = name)
        if row:
            row.update(self._insert_channel_family(row['id']))
            return removeNone(row)

        return ''
    
    def lookupChannelFamily(self, name, username, password):
        log_debug(3)
        
        authobj = self._auth(username, password)
        if not authobj.isChannelAdmin():
            raise rhnFault(50, "Invalid user permissions",
                           explain=0)
        
        row = rhnSQL.fetchone_dict("select * from rhnChannelFamily where label = :label",
                                    label=name)
        if not row:
            return 0
        row = removeNone(row)

        row['modified'] = str(row['modified'])
        row['created'] = str(row['created'])        
        return row


    def lookupChannelArch(self, label, username, password):
        log_debug(3)
        self._auth(username, password)

        row = rhnSQL.fetchone_dict("select id from rhnChannelArch where label = :label",
                                    label=label)
        if not row:
            return 0
        return row['id']

    def lookupOrgId(self, org_id, username, password):
        log_debug(3)
        self._auth(username, password)
        
        if not org_id:
            return ''
        row = rhnSQL.fetchone_dict("""select org_id from web_contact
                                        where login_uc = UPPER(:org_id)""",
                                        org_id=org_id)
        if row:
            return row['org_id']
        
        try:
            org_id = int(org_id)
        except ValueError:
            raise rhnFault(42, "Invalid org_id ",explain=0)

        row = rhnSQL.fetchone_dict("""select id from web_customer where id = :org_id""",
                                   org_id=org_id)
        if row:
            return row['id']
        
        return ''
        
        
    def deleteChannel(self, channel_id, commit, username, password):
        log_debug(3)
        authobj = self._auth(username, password)
        authobj.isChannelAdmin()
        
        try:
            p = rhnSQL.Procedure("delete_channel")
            p(channel_id)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )

        if commit:
            rhnSQL.commit()
        else:
            rhnSQL.rollback()
            return 1
        return 0

    def updateChannelMembership(self, channel_id, channel_family_id,
                                kargs, commit, username, password):
        log_debug(3)
        authobj = self._auth(username, password)
        authobj.isChannelAdmin()

        rhnSQL.execute("""
            delete from rhnChannelFamilyMembers where channel_id = :channel_id""",
            channel_id=channel_id)
        
        try:
            rhnSQL.execute("""
            insert into rhnChannelFamilyMembers (channel_id, channel_family_id )
            values (:channel_id, :channel_family_id)
            """, channel_id=channel_id, channel_family_id=channel_family_id)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )

        self.updateDist( kargs, username, password)
        
        if commit:
            rhnSQL.commit()
        else:
            rhnSQL.rollback()
            return 1
        return 0

    def moveChannelDownloads(self, channel_id, old_channel_family_id,
                               new_channel_family_id, username, password):
        log_debug(3)
        self._auth(username, password)
        
        if old_channel_family_id is None or \
               old_channel_family_id == new_channel_family_id:
            # Nothing to be done here, same channel family
            return 0
        log_debug(3, "  Migrating downloads")
        
        try:
            rhnSQL.execute("""
            update rhnDownloads
               set channel_family_id = :new_channel_family_id
             where channel_family_id = :old_channel_family_id
               and id in (
                   select downloads_id
                     from rhnChannelDownloads
                    where channel_id = :channel_id)
                """,
                channel_id=channel_id,
                old_channel_family_id=old_channel_family_id,
                new_channel_family_id=new_channel_family_id,
                )
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )
        
        return 0

        
    def updateDist(self, kwargs, username, password):
        log_debug(3)
        self._auth(username, password)
        
        if not kwargs.get('release'):
            raise rhnFault(23, "Insufficient data, release missing to update dist", explain=0)
                     
        if not kwargs.get('os'):
            kwargs['os'] = 'Red Hat Linux'

        if kwargs.get('channel_id') is None:
            # Missing stuff
            raise rhnFault(23, "Insufficient data, channel_id missing to update dist", explain=0)

        if kwargs.get('channel_arch_id') is None:
            # Missing stuff
            raise rhnFault(23, "Insufficient data, channel arch id missing to update dist", explain=0)
            
        try:
            rhnSQL.execute("""
            insert into rhnDistChannelMap 
                (channel_id, channel_arch_id, os, release)
            values
                (:channel_id, :channel_arch_id, :os, :release)
            """, kwargs)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )

        return 0

        
    def deleteDist(self, channel_id, username, password):
        log_debug(3)
        self._auth(username, password)
        
        try:
            rhnSQL.execute("""
            delete from rhnDistChannelMap where channel_id = :channel_id
            """, channel_id=channel_id)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )
        
        return 0
    
    # Build a checkpoint transaction so we can roll back just this channel
    #transaction_name = "t-%s" % dict['label']
    def channelCreateTransaction(self, username, password, transaction_name):
        log_debug(3)
        self._auth(username, password)
        
        rhnSQL.transaction(transaction_name)

    def checkChannelAuthPermission(self, label, username, password):
        log_debug(3)
        authobj = self._auth(username, password)
        return authobj.isChannelAdmin()

    def channelManagePermission(self, label, role, commit, username, password):
        query = """
            insert into rhnChannelPermission
               (channel_id, role_id, user_id)
            (select c.id, cpr.id, wc.id
               from rhnchannelpermissionrole cpr,
                    rhnchannel c,
                    web_contact wc
               where wc.login    = :username 
                 and c.label     = :label
                 and cpr.label   = :role_label)
        """
        return self._channelPermission(label, role, commit, username, password, query)

    def revokeChannelPermission(self, label, role, commit, username, password):
        query = """
            delete from rhnchannelpermission
              where (channel_id, role_id, user_id) in
             (select c.id, cpr.id, wc.id
               from rhnchannelpermissionrole cpr,
                    rhnchannel c,
                    web_contact wc
               where wc.login    = :username
                 and c.label     = :label
                 and cpr.label   = :role_label)
        """
        return self._channelPermission(label, role, commit, username, password, query)

    def _channelPermission(self, label, role, commit, username, password, query):
        log_debug(3)
        self._auth(username, password)
        try:
            rhnSQL.execute(query, username = username, label = label, role_label = role)
        except rhnSQL.SQLError, e:
            rhnSQL.rollback()
            raise rhnFault(23, str(e.args[1]), explain=0 )
        if commit:
            rhnSQL.commit()
        else:
            rhnSQL.rollback()
            return 1
        return 0

def removeNone(data):
    for key in data.keys():
        if data[key] is None:
            data[key] = ''
    return data

def auth(login, password):
    # Authorize this user
    authobj = UserAuth()
    authobj.auth(login, password)
    return authobj

