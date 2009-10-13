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
# Config file handler (client side)
#

from common import rhnFault, log_debug

from server import rhnSQL, configFilesHandler
from server.rhnHandler import rhnHandler

class ConfigManagement(configFilesHandler.ConfigFilesHandler):
    def __init__(self):
        log_debug(3)
	configFilesHandler.ConfigFilesHandler.__init__(self)        
        self.functions.update({
            'client.list_config_channels'   : 'client_list_channels',
            # XXX1
            'client.set_namespaces'     : 'client_set_namespaces',
            'client.list_files'         : 'client_list_files',
            'client.get_file'           : 'client_get_file',
            'client.get_default_delimiters'     : 'client_get_delimiters',
            'client.upload_file'       : 'client_upload_file',
            'client.get_maximum_file_size'  : 'client_get_maximum_file_size',
            'client.upload'             : 'client_upload_to_server_import',
        })
        self.org_id = None

    # We need the org id too
    def auth_system(self, systemid):
        rhnHandler.auth_system(self, systemid)
        self.org_id = self.server.server['org_id']
        
    def client_get_maximum_file_size(self, systemid):
        log_debug(1)
        self.auth_system(systemid)

        return self._get_maximum_file_size()

    def client_get_delimiters(self, systemid):
        log_debug(1)
        self.auth_system(systemid)

        return self._get_delimiters()
                
    def client_list_channels(self, systemid):
        self.auth_system(systemid)
        return self._get_client_config_channels(self.server_id)

    # XXX1
    def client_set_namespaces(self, systemid, namespaces):
        self.auth_system(systemid)

        server_id = self.server.getid()
        org_id = self.server.server['org_id']

        h = rhnSQL.prepare("""
            delete from rhnServerConfigChannel where server_id = :server_id
        """)
        h.execute(server_id=server_id)

        h = rhnSQL.prepare("""
            insert into rhnServerConfigChannel (server_id, config_channel_id, position)
            select :server_id, id, :position
              from rhnConfigChannel
             where name = :config_channel
               and org_id = :org_id
        """)

        position = 0
        for config_channel in namespaces:
            rowcount = h.execute(server_id=server_id, position=position,
                config_channel=config_channel, org_id=org_id)
            if not rowcount:
                raise rhnFault(4009, "Unable to find config channel %s" %
                    config_channel, explain=0)
            position = position + 1

        rhnSQL.commit()
        return 0
            
    _query_client_list_files = rhnSQL.Statement("""
        select cfn.path, cr.config_file_type_id
          from rhnConfigChannelType cct,
               rhnConfigChannel cc,
               rhnConfigFileState cfs,
               rhnConfigFileName cfn,
               rhnConfigRevision cr,
               rhnConfigFile cf
         where cc.org_id = :org_id
           and cc.label = :config_channel
           and cc.confchan_type_id = cct.id
           and cct.label in ('normal', 'local_override')
           and cf.config_channel_id = cc.id
           and cf.latest_config_revision_id = cr.id
           and cr.config_file_id = cf.id
           and cf.state_id = cfs.id
           and cfs.label = 'alive'
           and cf.config_file_name_id = cfn.id
           order by cfn.path
    """)

    def client_list_files(self, systemid, config_channel=None):
        log_debug(1)
        self.auth_system(systemid)

        if config_channel:
            config_channels = [ config_channel ]
        else:
            config_channels = self._get_client_config_channels(self.server.getid())
            config_channels = map(lambda x: x['label'], config_channels)

        if not config_channels:
            # No config channels
            return []

        h = rhnSQL.prepare(self._query_client_list_files)
        
        result_hash = {}
        # We're storing the config files in a dictionary, keyed by path; this
        # way, the most important channel (with the lowest preference) will
        # override the less important oness
        for config_channel in config_channels:
            log_debug(4, "Checking config channel", config_channel)
        
            h.execute(org_id=self.org_id, config_channel=config_channel)
            while 1:
                row = h.fetchone_dict()
                if not row:
                    break

                path = row['path']
                result_hash[path] = (config_channel, path, row['config_file_type_id'])

        result = result_hash.values()
        # Sort by path first since that's what the web site does
        result.sort(lambda x, y: cmp(x[1], y[1]))
        return result
        
    def client_get_file(self, systemid, filename):
        self.auth_system(systemid)
        server_id = self.server.getid()

        return self._client_get_file(server_id, filename)

    _query_client_get_file = rhnSQL.Statement("""
        select :path path,
               cc.label config_channel, 
               ccont.contents file_contents,
               ccont.is_binary is_binary,
               c.checksum,
               cr.delim_start, cr.delim_end,
               cr.revision,
               cf.modified,
               ci.username,
               ci.groupname,
               ci.filemode,
	       cft.label,
	       cct.priority,
	       ci.selinux_ctx
          from rhnConfigChannel cc,
               rhnConfigInfo ci,
               rhnConfigRevision cr,
               rhnConfigContent ccont,
               rhnChecksum c,
               rhnServerConfigChannel scc,
               rhnConfigFile cf,
	       rhnConfigFileType cft,
	       rhnConfigChannelType cct
         where scc.server_id = :server_id
           and scc.config_channel_id = cc.id
           and cf.config_channel_id = cc.id
           and cf.config_file_name_id = lookup_config_filename(:path)
           and cr.config_file_id = cf.id
           and cr.config_info_id = ci.id
           and cf.latest_config_revision_id = cr.id
           and cr.config_content_id = ccont.id
	   and cr.config_file_type_id = cft.id
	   and cct.id = cc.confchan_type_id
           and ccont.checksum_id = c.id
         order by cct.priority, scc.position 
    """)

    def _client_get_file(self, server_id, filename):
        h = rhnSQL.prepare(self._query_client_get_file)

        h.execute(server_id=server_id, path=filename)
        row = h.fetchone_dict()
        if not row:
            # XXX Return something other than a dict?
            return {'missing' : 1}

        return self._format_file_results(row)

    _query_client_config_channels = rhnSQL.Statement("""
        select cc.label,
               cc.name
          from rhnConfigChannelType cct,
               rhnConfigChannel cc, 
               rhnServerConfigChannel scc
         where scc.server_id = :server_id
           and scc.config_channel_id = cc.id
           and cc.confchan_type_id = cct.id
           and cct.label in ('normal', 'local_override')
         order by scc.position nulls last, cc.name desc
    """)
    
    def _get_client_config_channels(self, server_id):
        h = rhnSQL.prepare(self._query_client_config_channels)
        h.execute(server_id=server_id)
        return h.fetchall_dict() or []

    _query_client_upload_files = rhnSQL.Statement("""
        select acc.config_channel_id, ast.name action_status
          from rhnServerAction sa,
               rhnActionStatus ast,
               rhnActionConfigChannel acc
         where acc.server_id = :server_id
           and acc.action_id = :action_id
           and sa.server_id = :server_id
           and sa.action_id = :action_id
           and sa.status = ast.id
    """)

    def client_upload_file(self, systemid, action_id, file):
        self.auth_system(systemid)
        log_debug(1, self.server_id, action_id)

        # Validate that the action indeed applies
        h = rhnSQL.prepare(self._query_client_upload_files)
        h.execute(server_id=self.server_id, action_id=action_id)
        row = h.fetchone_dict()
        if not row:
            raise rhnFault(4002, "Action not available for this server")
        if row['action_status'] != 'Picked Up':
            raise rhnFault(4002, "Improper action for this server")

        config_channel_id = row['config_channel_id']

        return self.push_file(config_channel_id, file)

    _query_lookup_import_channel = rhnSQL.Statement("""
        select cc.id
          from rhnConfigChannelType cct,
               rhnConfigChannel cc,
               rhnServerConfigChannel scc
         where scc.server_id = :server_id
           and scc.config_channel_id = cc.id
           and cc.confchan_type_id = cct.id
           and cct.label = 'server_import'
    """)
        
    # Almost identical to client_upload_files
    def client_upload_to_server_import(self, systemid, file):
        self.auth_system(systemid)
        log_debug(1, self.server_id)

        h = rhnSQL.prepare(self._query_lookup_import_channel)
        h.execute(server_id=self.server_id)
        row = h.fetchone_dict()
        if not row:
            config_channel_id = self._create_server_import_channel(self.server_id)
        else:
            config_channel_id = row['id']
        
        return self.push_file(config_channel_id, file)

    _query_create_server_import_channel = rhnSQL.Statement("""
        insert into rhnServerConfigChannel
               (server_id, config_channel_id, position)
        values (:server_id, :config_channel_id, :position)
    """)

    def _create_server_import_channel(self, server_id):        
        name = "server_import Config Channel for system %d" % server_id
        description = "XXX"

        # server_import and local_override channels that
        # get created need to conform to this label formula:
        # {rhnConfigChannelType.label}-{sid}
        label = "server_import-%d" % server_id
        
        insert_call = rhnSQL.Function('rhn_config.insert_channel', 
            rhnSQL.types.NUMBER())
        config_channel_id = insert_call(self.org_id,
                                        'server_import',
                                        name,
                                        label,
                                        description)

        h = rhnSQL.prepare(self._query_create_server_import_channel)
        h.execute(server_id=server_id, config_channel_id=config_channel_id,
                  position=None)

        return config_channel_id
