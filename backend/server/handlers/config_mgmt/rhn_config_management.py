#
# Copyright (c) 2008--2016 Red Hat, Inc.
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
# Config file handler (management tool)
#

import sys
import difflib
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.usix import raise_with_tb, next
from spacewalk.common.rhnException import rhnFault
from spacewalk.server import rhnSQL, configFilesHandler
from spacewalk.common.fileutils import f_date, ostr_to_sym


class ConfigManagement(configFilesHandler.ConfigFilesHandler):

    def __init__(self):
        log_debug(3)
        configFilesHandler.ConfigFilesHandler.__init__(self)
        self.functions.update({
            'management.get_file': 'management_get_file',
            'management.list_config_channels': 'management_list_channels',
            'management.create_config_channel': 'management_create_channel',
            'management.remove_config_channel': 'management_remove_channel',
            'management.list_file_revisions': 'management_list_file_revisions',
            'management.list_files': 'management_list_files',
            'management.has_file': 'management_has_file',
            'management.put_file': 'management_put_file',
            'management.remove_file': 'management_remove_file',
            'management.diff': 'management_diff',
            'management.get_default_delimiters': 'management_get_delimiters',
            'management.get_maximum_file_size': 'management_get_maximum_file_size',
        })
        self.user = None
        self.default_delimiter = '@'

    _query_list_config_channels = rhnSQL.Statement("""
        select cc.name,
               cc.label,
               cct.label channel_type
          from rhnConfigChannelType cct,
               rhnConfigChannel cc
         where cc.org_id = :org_id
           and cc.confchan_type_id = cct.id
           and cct.label = 'normal'
         order by cc.label, cc.name
    """)

    def _get_and_validate_session(self, dict):
        session = dict.get('session')
        self._validate_session(session)

    def management_list_channels(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)
        return [x['label'] for x in rhnSQL.fetchall_dict(self._query_list_config_channels,
                                        org_id=self.org_id) or []]

    _query_lookup_config_channel = rhnSQL.Statement("""
        select id
          from rhnConfigChannel
         where org_id = :org_id
           and label = :config_channel
    """)

    def management_create_channel(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace

        config_channel_name = dict.get('config_channel_name') or config_channel
        config_channel_description = dict.get('description') or config_channel

        row = rhnSQL.fetchone_dict(self._query_lookup_config_channel,
                                   org_id=self.org_id, config_channel=config_channel)
        if row:
            raise rhnFault(4010, "Configuration channel %s already exists" %
                           config_channel, explain=0)

        insert_call = rhnSQL.Function('rhn_config.insert_channel',
                                      rhnSQL.types.NUMBER())
        config_channel_id = insert_call(self.org_id,
                                        'normal',
                                        config_channel_name,
                                        config_channel,
                                        config_channel_description)

        rhnSQL.commit()
        return {}

    _query_config_channel_by_label = rhnSQL.Statement("""
    select id
      from rhnConfigChannel
     where org_id = :org_id
       and label = :label
    """)

    def management_remove_channel(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace

        row = rhnSQL.fetchone_dict(self._query_config_channel_by_label,
                                   org_id=self.org_id, label=config_channel)

        if not row:
            raise rhnFault(4009, "Channel not found")

        delete_call = rhnSQL.Procedure('rhn_config.delete_channel')

        try:
            delete_call(row['id'])
        except rhnSQL.SQLError:
            e = sys.exc_info()[1]
            errno = e.args[0]
            if errno == 2292:
                raise_with_tb(rhnFault(4005, "Cannot remove non-empty channel %s" %
                               config_channel, explain=0), sys.exc_info()[2])
            raise

        log_debug(5, "Removed:", config_channel)
        rhnSQL.commit()
        return ""

    _query_management_list_files = rhnSQL.Statement("""
        select cc.label config_channel,
               cfn.path
          from rhnConfigFileName cfn,
               rhnConfigFileState cfs,
               rhnConfigFile cf,
               rhnConfigChannel cc
         where cc.org_id = :org_id
           and cc.label = :config_channel
           and cc.id = cf.config_channel_id
           and cf.state_id = cfs.id
           and cfs.label = 'alive'
           and cf.config_file_name_id = cfn.id
    """)

    def management_list_files(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the config channel

        log_debug(3, "Org id", self.org_id, "Config channel", config_channel)

        h = rhnSQL.prepare(self._query_management_list_files)
        h.execute(org_id=self.org_id, config_channel=config_channel)

        retval = []
        while 1:
            row = h.fetchone_dict()
            if not row:
                break
            val = {}
            # Only copy a subset of the keys
            for f in ['config_channel', 'path']:
                val[f] = row[f]

            retval.append(val)
        log_debug(4, "pre sort", retval)
        retval.sort(lambda x, y: cmp(x['path'], y['path']))
        log_debug(4, "Return value", retval)
        return retval

    def management_get_file(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace
        path = dict.get('path')
        revision = dict.get('revision')

        row = self._get_file(config_channel, path, revision=revision)
        if not row:
            raise rhnFault(4011, "File %s does not exist in channel %s" %
                           (path, config_channel), explain=0)

        return self._format_file_results(row)

    _query_list_file_revisions = rhnSQL.Statement("""
        select cr.revision
          from rhnConfigChannel cc,
               rhnConfigRevision cr,
               rhnConfigFile cf
         where cf.config_channel_id = cc.id
           and cc.label = :config_channel
           and cc.org_id = :org_id
           and cf.config_file_name_id = lookup_config_filename(:path)
           and cr.config_file_id = cf.id
         order by revision desc
    """)

    def management_list_file_revisions(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace
        path = dict.get('path')

        retval = [x['revision'] for x in rhnSQL.fetchall_dict(self._query_list_file_revisions,
                                          org_id=self.org_id, config_channel=config_channel, path=path) or []]
        if not retval:
            raise rhnFault(4011, "File %s does not exist in channel %s" %
                           (path, config_channel), explain=0)

        return retval

    def management_has_file(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace
        path = dict.get('path')
        row = self._get_file(config_channel, path)
        if not row:
            return {}
        return {
            'revision': row['revision'],
        }

    _query_get_file = """
        select :path path,
               cc.label config_channel,
               ccont.contents file_contents,
               ccont.is_binary,
               c.checksum_type,
               c.checksum,
               ccont.delim_start, ccont.delim_end,
               cr.revision,
               cf.modified,
               ci.username,
               ci.groupname,
               ci.filemode,
               cft.label,
               ci.selinux_ctx,
           case
                when cft.label='symlink' then (select path from rhnConfigFileName where id = ci.SYMLINK_TARGET_FILENAME_ID)
                else ''
            end as symlink
          from rhnConfigChannel cc,
               rhnConfigInfo ci,
               rhnConfigRevision cr
          left join rhnConfigContent ccont
            on cr.config_content_id = ccont.id
          left join rhnChecksumView c
            on ccont.checksum_id = c.id,
               rhnConfigFile cf,
               rhnConfigFileType cft
         where cf.config_channel_id = cc.id
           and cc.label = :config_channel
           and cc.org_id = :org_id
           and cf.config_file_name_id = lookup_config_filename(:path)
           and cr.config_file_id = cf.id
           and cr.config_info_id = ci.id
           and cr.config_file_type_id = cft.id
    """
    _query_get_file_latest = rhnSQL.Statement(_query_get_file + """
           and cf.latest_config_revision_id = cr.id
           """)
    _query_get_file_revision = rhnSQL.Statement(_query_get_file + """
           and cr.revision = :revision
           """)

    def _get_file(self, config_channel, path, revision=None):
        log_debug(2, config_channel, path)
        params = {
            'org_id': self.org_id,
            'config_channel': config_channel,
            'path': path,
        }
        if revision is None:
            # Fetch the latest
            q = self._query_get_file_latest
        else:
            params['revision'] = revision
            q = self._query_get_file_revision
        log_debug(4, params)
        return rhnSQL.fetchone_dict(q, **params)

    _query_lookup_config_file_by_channel = rhnSQL.Statement("""
        select cf.id,
               cf.state_id
          from rhnConfigFile cf,
               rhnConfigChannel cc
         where cc.org_id = :org_id
           and cf.config_channel_id = cc.id
           and cc.label = :config_channel
           and cf.config_file_name_id = lookup_config_filename(:path)
    """)

    def management_remove_file(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace
        path = dict.get('path')

        row = rhnSQL.fetchone_dict(self._query_lookup_config_file_by_channel,
                                   org_id=self.org_id, config_channel=config_channel, path=path)
        if not row:
            raise rhnFault(4011, "File %s does not exist in channel %s" %
                           (path, config_channel), explain=0)

        config_file_id = row['id']

        delete_call = rhnSQL.Procedure("rhn_config.delete_file")
        delete_call(config_file_id)

        rhnSQL.commit()

        return {}

    _query_update_file_state = rhnSQL.Statement("""
        update rhnConfigFile
           set state_id = :state_id
         where id = :config_file_id
    """)

    def management_disable_file(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        # XXX Validate the namespace
        path = dict.get('path')

        t = rhnSQL.Table('rhnConfigFileState', 'label')
        state_id_dead = t['dead']['id']

        row = rhnSQL.fetchone_dict(self._query_lookup_config_file_by_channel,
                                   config_channel=config_channel, path=path)
        if not row or row['state_id'] == state_id_dead:
            raise rhnFault(4011, "File %s does not exist in channel %s" %
                           (path, config_channel), explain=0)

        rhnSQL.execute(self._query_update_file_state,
                       config_file_id=row['id'], state_id=state_id_dead)
        rhnSQL.commit()
        return {}

    def management_put_file(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        config_channel = dict.get('config_channel')
        row = self.lookup_org_config_channel_by_name(config_channel)
        conf_channel_id = row['id']

        file_path = dict.get('path')
        result = self.push_file(conf_channel_id, dict)

        file_too_large = result.get('file_too_large')
        if file_too_large:
            raise rhnFault(4003, "File %s is too large (%s bytes)" %
                           (dict['path'], dict['size']), explain=0)

        rhnSQL.commit()
        return {}

    def management_get_delimiters(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        return self._get_delimiters()

    def management_get_maximum_file_size(self, dict={}):
        log_debug(1)
        self._get_and_validate_session(dict)

        return self._get_maximum_file_size()

    def __attributes_differ(self, fsrc, fdst):
        """ Returns true if acl, ownership, type or selinux context differ. """
        return (fsrc['filemode'] != fdst['filemode']) or (fsrc['label'] != fdst['label']) or \
               (fsrc['username'] != fdst['username']) or (fsrc['groupname'] != fdst['groupname']) or \
               (fsrc['selinux_ctx'] != fdst['selinux_ctx'])

    def __header(self, path, fsrc, config_channel_src, fdst, config_channel_dst):
        """ Returns diff like header for this two files. """
        template = "--- %s\t%s\tattributes: %s %s %s %s\tconfig channel: %s\trevision: %s"
        first_row = template % (path, f_date(fsrc['modified']), ostr_to_sym(fsrc['filemode'], fsrc['label']),
                                fsrc['username'], fsrc['groupname'], fsrc['selinux_ctx'], config_channel_src,
                                fsrc['revision'],
                                )
        second_row = template % (path, f_date(fdst['modified']), ostr_to_sym(fdst['filemode'], fdst['label']),
                                 fdst['username'], fdst['groupname'], fdst['selinux_ctx'], config_channel_dst,
                                 fdst['revision'],
                                 )
        return (first_row, second_row)

    def management_diff(self, dict):
        log_debug(1)
        self._get_and_validate_session(dict)

        param_names = ['config_channel_src', 'revision_src', 'path', ]
        for p in param_names:
            val = dict.get(p)
            if val is None:
                raise rhnFault(4007, "No content sent for `%s'" % p)

        log_debug(4, "Params sent", dict)
        path = dict['path']

        config_channel_src = dict['config_channel_src']
        revision_src = dict.get('revision_src')
        fsrc = self._get_file_revision(config_channel_src, revision_src, path)

        config_channel_dst = dict.get('config_channel_dst')
        if config_channel_dst is None:
            config_channel_dst = config_channel_src
        revision_dst = dict.get('revision_dst')
        fdst = self._get_file_revision(config_channel_dst, revision_dst, path)

        if fsrc['label'] != fdst['label']:
            raise rhnFault(4017,
                           "Path %s  is a %s in channel %s while it is a %s in channel %s"
                           % (path, fsrc['label'],
                              config_channel_src, fdst['label'], config_channel_dst),
                           explain=0)

        if fsrc['label'] == 'symlink':
            if (fsrc["symlink"] != fdst['symlink']) or self.__attributes_differ(fsrc, fdst):
                (first_row, second_row) = self.__header(path, fsrc, config_channel_src, fdst, config_channel_dst)
                first_row += ' target: %s' % fsrc["symlink"]
                second_row += ' target: %s' % fdst["symlink"]
                return first_row + "\n" + second_row + "\n"
            return ""

        diff = difflib.unified_diff(
            fsrc['file_content'], fdst['file_content'], path, path, fsrc['modified'], fdst['modified'], lineterm='')
        try:
            first_row = next(diff)
        except StopIteration:
            return ""

        if not first_row.startswith('---'):
            # Hmm, weird
            return first_row + '\n'.join(list(diff))

        try:
            second_row = next(diff)
        except StopIteration:
            second_row = ''

        if not second_row.startswith('+++'):
            # Hmm, weird
            return second_row + '\n'.join(list(diff))

        (first_row, second_row) = self.__header(path, fsrc, config_channel_src, fdst, config_channel_dst)
        return first_row + "\n" + second_row + '\n' + '\n'.join(list(diff))

    def _get_file_revision(self, config_channel, revision, path):
        if revision and not revision.isdigit():
            raise rhnFault(4016, "Invalid revision number '%s' specified for path %s "
                           "in channel %s" % (revision, path, config_channel),
                           explain=0)

        f = self._get_file(config_channel, path, revision=revision)
        if not f:
            raise rhnFault(4011, "File %s (revision %s) does not exist "
                           "in channel %s" % (path, revision, config_channel),
                           explain=0)
        if f['label'] == 'file' and f['is_binary'] == 'Y':
            raise rhnFault(4004, "File %s (revision %s) seems to contain "
                           "binary data" % (path, revision),
                           explain=0)

        # We have to read the contents of the first file here, because the LOB
        # object is tied to a cursor; if we re-execute the cursor, the LOB
        # seems to be invalid (bug 151220)

        # Empty files or directories may have NULL instead of lobs
        fc_lob = f.get('file_contents')
        if fc_lob:
            f['file_content'] = rhnSQL.read_lob(fc_lob).splitlines()
        else:
            f['file_content'] = ''
        return f

    # Helper functions
    _query_org_config_channels = rhnSQL.Statement("""
        select cc.id, cc.label, cc.name, cct.label channel_type
          from rhnConfigChannelType cct, rhnConfigChannel cc
         where cc.label = :config_channel
           and cc.org_id = :org_id
           and cc.confchan_type_id = cct.id
    """)

    def lookup_org_config_channel_by_name(self, config_channel):
        row = rhnSQL.fetchone_dict(self._query_org_config_channels,
                                   config_channel=config_channel, org_id=self.org_id)
        if not row:
            raise rhnFault(4009, "Configuration channel %s does not exist" %
                           config_channel, explain=0)
        return row

    def _check_user_role(self):
        user_roles = self.user.get_roles()
        if 'config_admin' in user_roles or 'org_admin' in user_roles:
            # All good
            return

        raise rhnFault(4006,
                       "User is not a allowed to manage config files")
