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
# Config file handler (base class)
#

import base64
import os
try:
    #  python 2
    import xmlrpclib
except ImportError:
    #  python3
    import xmlrpc.client as xmlrpclib
import sys
import hashlib

from spacewalk.common.usix import raise_with_tb
from spacewalk.common import rhnFlags
from spacewalk.common.rhnLog import log_debug
from spacewalk.common.rhnConfig import CFG
from spacewalk.common.checksum import getStringChecksum
from spacewalk.common.rhnException import rhnFault, rhnException

from spacewalk.server import rhnSQL, rhnUser, rhnCapability
from spacewalk.server.rhnHandler import rhnHandler

from spacewalk.server.config_common.templated_document import ServerTemplatedDocument, var_interp_prep


import rhnSession

# Exceptions


class BaseConfigFileError(Exception):

    def __init__(self, args):
        Exception.__init__(self, *args)


class ConfigFileError(BaseConfigFileError):

    def __init__(self, file, *args):
        BaseConfigFileError.__init__(self, args)
        self.file = file


class ConfigFileExistsError(ConfigFileError):
    pass


class ConfigFileVersionMismatchError(ConfigFileError):
    pass


class ConfigFileMissingDelimError(ConfigFileError):
    pass


class ConfigFileMissingInfoError(ConfigFileError):
    pass


class ConfigFileMissingContentError(ConfigFileError):
    pass


class ConfigFileTooLargeError(ConfigFileError):
    pass


class ConfigFileExceedsQuota(ConfigFileError):
    pass


class ConfigFilePathIncomplete(ConfigFileError):
    pass

# Base handler class


class ConfigFilesHandler(rhnHandler):

    def __init__(self):
        log_debug(3)
        rhnHandler.__init__(self)
        self.functions = {
            'rhn_login': 'login',
            'test_session': 'test_session',
            'max_upload_fsize': 'max_upload_file_size',
        }
        self.org_id = None

    # Returns a reference to a callable method
    def get_function(self, function):
        if function not in self.functions:
            return None

        # Turn compression on by default
        rhnFlags.set('compress_response', 1)
        return getattr(self, self.functions[function])

    # returns max filesize that will be uploaded
    def max_upload_file_size(self):
        return self._get_maximum_file_size()

    # Generic login function
    def login(self, dict):
        log_debug(1)
        username = dict.get('username')
        password = dict.get('password')
        self.user = rhnUser.search(username)
        if not self.user or not (self.user.check_password(password)):
            raise rhnFault(2)

        # Good to go
        session = self.user.create_session()
        return session.get_session()

    def test_session(self, dict):
        log_debug(3)

        try:
            self._validate_session(dict.get('session'))
        except (rhnSession.InvalidSessionError, rhnSession.ExpiredSessionError):
            return 0

        return 1

    # Helper functions
    def _get_delimiters(self):
        return {
            'delim_start': CFG.config_delim_start,
            'delim_end': CFG.config_delim_end,
        }

    def _validate_session(self, session):
        # session_reload will toss an exception if the session
        # token is invalid... I guess we're letting it percolate
        # up...
        # --bretm
        self.user = rhnUser.session_reload(session)
        self.org_id = self.user.contact['org_id']
        self._check_user_role()

    def _check_user_role(self):
        pass

    def _is_file(self, file):
        return str(file['config_file_type_id']) == '1'

    def _is_link(self, file):
        return str(file['config_file_type_id']) == '3'

    _query_current_selinux_lookup = rhnSQL.Statement("""
       select ci.selinux_ctx from rhnConfigInfo ci, rhnConfigRevision cr, rhnConfigFile cf
       where ci.id = cr.config_info_id
         and cf.id = cr.config_file_id
         and cf.config_file_name_id = lookup_config_filename(:path)
         and cr.revision = (
           select max(mcr.revision) from rhnConfigRevision mcr, rhnConfigFile mcf
           where mcf.id = mcr.config_file_id
             and mcf.config_file_name_id = cf.config_file_name_id
      )
    """)

    def _push_file(self, config_channel_id, file):
        if not file:
            # Nothing to do
            return {}

        # Check for full path on the file
        path = file.get('path')
        if not (path[0] == os.sep):
            raise ConfigFilePathIncomplete(file)

        if 'config_file_type_id' not in file:
            log_debug(4, "Client does not support config directories, so set file_type_id to 1")
            file['config_file_type_id'] = '1'
        # Check if delimiters are present
        if self._is_file(file) and \
           not (file.get('delim_start') and file.get('delim_end')):
            # Need delimiters
            raise ConfigFileMissingDelimError(file)

        if not (file.get('user') and file.get('group') and
                file.get('mode') is not None) and not self._is_link(file):
            raise ConfigFileMissingInfoError(file)

        # Oracle doesn't like certain binding variables
        file['username'] = file.get('user', '')
        file['groupname'] = file.get('group', '')
        file['file_mode'] = str(file.get('mode', ''))
        # if the selinux flag is not sent by the client it is set to the last file
        # revision (or to None (i.e. NULL) in case of first revision) - see the bug
        # 644985 - SELinux context cleared from RHEL4 rhncfg-client
        file['selinux_ctx'] = file.get('selinux_ctx', None)
        if not file['selinux_ctx']:
            # RHEL4 or RHEL5+ with disabled selinux - set from the last revision
            h = rhnSQL.prepare(self._query_current_selinux_lookup)
            h.execute(**file)
            row = h.fetchone_dict()
            if row:
                file['selinux_ctx'] = row['selinux_ctx']
            else:
                file['selinux_ctx'] = None
        result = {}

        try:

            if self._is_file(file):
                self._push_contents(file)
            elif self._is_link(file):
                file['symlink'] = file.get('symlink') or ''
        except ConfigFileTooLargeError:
            result['file_too_large'] = 1

        t = rhnSQL.Table('rhnConfigFileState', 'label')
        state_id_alive = t['alive']['id']

        file['state_id'] = state_id_alive
        file['config_channel_id'] = config_channel_id

        try:
            self._push_config_file(file)
            self._push_revision(file)
        except rhnSQL.SQLSchemaError:
            e = sys.exc_info()[1]
            log_debug(4, "schema error", e)
            rhnSQL.rollback()  # blow away the contents that got inserted
            if e.errno == 20267:
                # ORA-20267: (not_enough_quota) - Insufficient available quota
                # for the specified action
                raise ConfigFileExceedsQuota(file)
            raise

        return {}

    # A wrapper around _push_file, that also catches exceptions
    def push_file(self, config_channel_id, file):
        try:
            result = self._push_file(config_channel_id, file)
        except ConfigFilePathIncomplete:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4015, "Full path of file '%s' must be specified" % e.file.get('path'),
                          explain=0), sys.exc_info()[2])

        except ConfigFileExistsError:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4013, "File %s already uploaded" % e.file.get('path'),
                          explain=0), sys.exc_info()[2])
        except ConfigFileVersionMismatchError:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4012, "File %s uploaded with a different "
                           "version" % e.file.get('path'), explain=0), sys.exc_info()[2])
        except ConfigFileMissingDelimError:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4008, "Delimiter not specified for file %s" %
                           e.file.get('path'), explain=0), sys.exc_info()[2])
        except ConfigFileMissingContentError:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4007, "No content sent for file %s" %
                           e.file.get('path'), explain=0), sys.exc_info()[2])
        except ConfigFileExceedsQuota:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4014, "File size of %s exceeds free quota space" %
                           e.file.get('path'), explain=0), sys.exc_info()[2])
        except ConfigFileTooLargeError:
            e = sys.exc_info()[1]
            raise_with_tb(rhnFault(4003, "File size of %s larger than %s bytes" %
                                         (e.file.get('path'), self._get_maximum_file_size()),
                                   explain=0), sys.exc_info()[2])

        rhnSQL.commit()
        return result

    _query_content_lookup = rhnSQL.Statement("""
        select cc.id, cv.checksum_type, cv.checksum, file_size, contents, is_binary, delim_start, delim_end
          from rhnConfigContent cc, rhnChecksumView cv
         where cv.checksum = :checksum
           and cv.checksum_type = :checksum_type
           and file_size = :file_size
           and checksum_id = cv.id
    """)

    _query_insert_content = rhnSQL.Statement("""
        insert into rhnConfigContent
               (id, checksum_id, file_size, contents, is_binary, delim_start, delim_end)
        values (:config_content_id, lookup_checksum(:checksum_type, :checksum),
                :file_size, :contents, :is_binary, :delim_start, :delim_end)
    """)

    def _push_contents(self, file):

        checksum_type = 'sha256'  # FIXME: this should be configuration option

        file['file_size'] = 0
        file['is_binary'] = 'N'

        file_path = file.get('path')
        file_contents = file.get('file_contents') or ''

        if 'enc64' in file and file_contents:
            file_contents = base64.decodestring(file_contents)

        if 'config_file_type_id' not in file:
            log_debug(4, "Client does not support config directories, so set file_type_id to 1")
            file['config_file_type_id'] = '1'

        file['checksum_type'] = checksum_type
        file['checksum'] = getStringChecksum(checksum_type, file_contents or '')

        if file_contents:
            file['file_size'] = len(file_contents)

            if file['file_size'] > self._get_maximum_file_size():
                raise ConfigFileTooLargeError(file_path, file['file_size'])

            # Is the content binary data?
            # XXX We may need a heuristic; this is what the web site does, and we
            # have to be consistent
            # XXX Yes this is iterating over a string
            try:
                file_contents.decode('UTF-8')
            except UnicodeDecodeError:
                file['is_binary'] = 'Y'

        h = rhnSQL.prepare(self._query_content_lookup)
        h.execute(**file)
        row = h.fetchone_dict()

        if row:
            db_contents = rhnSQL.read_lob(row['contents']) or ''
            if file_contents == db_contents:
                # Same content
                file['config_content_id'] = row['id']
                log_debug(5, "same content")
                return

        # We have to insert a new file now
        content_seq = rhnSQL.Sequence('rhn_confcontent_id_seq')
        config_content_id = content_seq.next()
        file['config_content_id'] = config_content_id
        file['contents'] = file_contents

        h = rhnSQL.prepare(self._query_insert_content,
                           blob_map={'contents': 'contents'})
        h.execute(**file)

    _query_lookup_symlink_config_info = rhnSQL.Statement("""
        select lookup_config_info(null, null, null, :selinux_ctx, lookup_config_filename(:symlink)) id
          from dual
    """)

    _query_lookup_non_symlink_config_info = rhnSQL.Statement("""
        select lookup_config_info(:username, :groupname, :file_mode, :selinux_ctx, null) id
          from dual
    """)

    _query_lookup_config_file = rhnSQL.Statement("""
        select id
          from rhnConfigFile
         where config_channel_id = :config_channel_id
           and config_file_name_id = lookup_config_filename(:path)
    """)

    def _push_config_file(self, file):
        config_info_query = self._query_lookup_non_symlink_config_info
        if self._is_link(file) and file.get("symlink"):
            config_info_query = self._query_lookup_symlink_config_info

        # Look up the config info first
        h = rhnSQL.prepare(config_info_query)
        h.execute(**file)
        row = h.fetchone_dict()
        if not row:
            # Hmm
            raise rhnException("This query should always return a row")
        config_info_id = row['id']
        file['config_info_id'] = config_info_id

        # Look up the config file itself
        h = rhnSQL.prepare(self._query_lookup_config_file)
        h.execute(**file)
        row = h.fetchone_dict()
        if row:
            # Yay we already have this file
            # Later down the road, we're going to update modified for this
            # table
            file['config_file_id'] = row['id']
            return

        # Have to insert this config file, gotta use the api to keep quotas up2date...
        insert_call = rhnSQL.Function("rhn_config.insert_file",
                                      rhnSQL.types.NUMBER())
        file['config_file_id'] = insert_call(file['config_channel_id'], file['path'])

    _query_lookup_revision = rhnSQL.Statement("""
        select id, revision, config_content_id, config_info_id,
               config_file_type_id
          from rhnConfigRevision
         where config_file_id = :config_file_id
         order by revision desc
    """)

    def _push_revision(self, file):
        # Assume we don't have any revision for now
        file['revision'] = 1
        h = rhnSQL.prepare(self._query_lookup_revision)
        h.execute(**file)
        row = h.fetchone_dict()
        if row:
            # Is it the same revision as this one?

            fields = ['config_content_id', 'config_info_id', 'config_file_type_id']

            if 'config_file_type_id' not in file:
                log_debug(4, "Client does not support config directories, so set file_type_id to 1")
                file['config_file_type_id'] = '1'

            for f in fields:
                if file.get(f) != row.get(f):
                    break
            else:  # for
                # All fields are equal
                file['config_revision_id'] = row['id']
                self._update_revision(file)
                self._update_config_file(file)
                return

            # A revision already exists, but it's different. Just update the
            # revision number

            revision = row['revision'] + 1
            file['revision'] = revision

        # If we got here, we need a new revision
        self._insert_revision(file)

        if self.user and hasattr(self.user, 'getid'):
            self._add_author(file, self.user)
        self._update_config_file(file)

    _query_update_revision = rhnSQL.Statement("""
        update rhnConfigRevision
           set modified = current_timestamp
         where id = :config_revision_id
    """)

    def _update_revision(self, file):
        h = rhnSQL.prepare(self._query_update_revision)
        h.execute(**file)

    def _insert_revision(self, file):
        insert_call = rhnSQL.Function("rhn_config.insert_revision",
                                      rhnSQL.types.NUMBER())
        file['config_revision_id'] = insert_call(file['revision'],
                                                 file['config_file_id'],
                                                 file.get('config_content_id', None),
                                                 file['config_info_id'],
                                                 file['config_file_type_id'])

    _query_update_revision_add_author = rhnSQL.Statement("""
        update rhnConfigRevision
            set changed_by_id = :user_id
        where id = :rev_id
    """)

    def _add_author(self, file, author):
        h = rhnSQL.prepare(self._query_update_revision_add_author)
        h.execute(user_id=author.getid(), rev_id=file['config_revision_id'])

    _query_update_config_file = rhnSQL.Statement("""
        update rhnConfigFile
           set latest_config_revision_id = :config_revision_id,
               state_id = :state_id
         where config_channel_id = :config_channel_id
           and config_file_name_id = lookup_config_filename(:path)
    """)

    def _update_config_file(self, file):
        h = rhnSQL.prepare(self._query_update_config_file)
        h.execute(**file)

    def _format_file_results(self, row):
        server = None
        if self.server:
            server = var_interp_prep(self.server)

        return format_file_results(row, server=server)

    def _get_maximum_file_size(self):
        return CFG.maximum_config_file_size

    def new_config_channel_id(self):
        return rhnSQL.Sequence('rhn_confchan_id_seq').next()


def format_file_results(row, server=None):
    encoding = ''
    contents = None
    contents = rhnSQL.read_lob(row['file_contents']) or ''
    checksum = row['checksum'] or ''

    if server and (row['is_binary'] == 'N') and contents:

        interpolator = ServerTemplatedDocument(server,
                                               start_delim=row['delim_start'],
                                               end_delim=row['delim_end'])
        contents = interpolator.interpolate(contents)
        if row['checksum_type']:
            checksummer = hashlib.new(row['checksum_type'])
            checksummer.update(contents)
            checksum = checksummer.hexdigest()

    if contents:
        client_caps = rhnCapability.get_client_capabilities()
        if client_caps and 'configfiles.base64_enc' in client_caps:
            encoding = 'base64'
            contents = base64.encodestring(contents)
    if row.get('modified', False):
        m_date = xmlrpclib.DateTime(str(row['modified']))
    else:
        m_date = ''

    return {
        'path': row['path'],
        'config_channel': row['config_channel'],
        'file_contents': contents,
        'symlink': row['symlink'] or '',
        'checksum_type': row['checksum_type'] or '',
        'checksum': checksum,
        'verify_contents': True,
        'delim_start': row['delim_start'] or '',
        'delim_end': row['delim_end'] or '',
        'revision': row['revision'] or '',
        'username': row['username'] or '',
        'groupname': row['groupname'] or '',
        'filemode': row['filemode'] or '',
        'encoding': encoding or '',
        'filetype': row['label'],
        'selinux_ctx': row['selinux_ctx'] or '',
        'modified': m_date,
        'is_binary': row['is_binary'] or '',
    }
