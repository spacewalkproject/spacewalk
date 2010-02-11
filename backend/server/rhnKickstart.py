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

import string

# common module
from common import log_debug, rhnFault

# local module
import rhnSQL, rhnChannel

class Kickstart:
    
    def __init__(self, ks_dict, pkgs):
        
        self.id = ks_dict['id']
        self.label = ks_dict['label']
        self.base_path = ks_dict['base_path']
        self.channel_id = ks_dict['channel_id']
        self.boot_image = ks_dict['boot_image']
        self.pkgs = pkgs

        self.files = self._get_files(self.id)

    def _get_files(self, tree_id):

        files_query = rhnSQL.prepare("""
            SELECT 
                relative_filename, 
                file_size, 
                c.checksum_type,
                c.checksum,
                TO_CHAR(last_modified, 'YYYY-MM-DD HH24:MI:SS') AS LAST_MODIFIED 
            FROM rhnKSTreeFile, rhnChecksumViev c
           WHERE kstree_id = :tree_id
             AND checksum_id = c.id
        """)
        files_query.execute(tree_id = tree_id)

        file_list = files_query.fetchall_dict()
        if file_list:
            return file_list
        else:
            return []

    def delete_tree(self):

        delete_query = rhnSQL.prepare("""
            delete from rhnKickstartableTree
            where id = :id
        """)
        delete_query.execute(id = self.id)

        update_channel = rhnSQL.Procedure('rhn_channel.update_channel')
        invalidate_ss = 0

        update_channel(self.channel_id, invalidate_ss)

    def has_file(self, ks_file):

        for file in self.files:
            if file['relative_filename'] == ks_file['relative_path'] and \
               file['checksum_type'] == ks_file['checksum_type'] and \
               file['checksum'] == ks_file['checksum'] and \
               file['file_size'] == ks_file['file_size'] and \
               file['last_modified'] == ks_file['last_modified']:

                return 1
            
        return 0

    def clear_files(self):

        clear_files_q = rhnSQL.prepare("""
            delete from rhnKSTreeFile where kstree_id = :kstree_id
        """)

        clear_files_q.execute(kstree_id = self.id)

    def add_file(self, ks_file):
        
        h = rhnSQL.prepare("alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS'")
        h.execute()
        
        log_debug(3, 'trying to insert ' + str(self.id) + ' , ' + ks_file['relative_path'] + \
                     ' , ' + str(ks_file['checksum_type']) + ':'
                     ' , ' + str(ks_file['checksum']) + ' , ' + str(ks_file['file_size']) + \
                     ' , ' + ks_file['last_modified'])

        insert_file_q = rhnSQL.prepare("""
            insert into rhnKSTreeFile
            (kstree_id, relative_filename, checksum_id, file_size, last_modified)
            values (:kstree_id, :relative_filename, lookup_checksum(:checksum_type, :checksum),
                    :file_size, :last_modified)
        """)
        insert_file_q.execute(kstree_id = self.id,
                              relative_filename = ks_file['relative_path'],
                              checksum_type = ks_file['checksum_type'],
                              checksum = ks_file['checksum'],
                              file_size = ks_file['file_size'],
                              last_modified = ks_file['last_modified'])

        update_channel = rhnSQL.Procedure('rhn_channel.update_channel')
        invalidate_ss = 0

        update_channel(self.channel_id, invalidate_ss)

    # Verifies that all pkgs in the ks tree are actually available in the channel
    # Returns a list of packages not found.  If the list is empty, the tree linted 
    # successfully.
    def lint_tree(self):

        # Get a list of all pkgs in the channel.
        channel_pkgs = rhnChannel.list_packages_path(self.channel_id)

        log_debug(3, 'channel_pkgs is ' + str(channel_pkgs))

        pkgs_not_found = []

        # Walk over each package in the kickstart tree
        for pkg in self.pkgs:

            found = 0

            # Check the current kickstart package against each package in the channel
            for channel_pkg in channel_pkgs:

                # If we find the pkg, set found and break the loop.
                if string.find(string.lower(channel_pkg[0]), string.lower(pkg)) > 0:
                    found = 1
                    break
                                
            if found == 0:
                pkgs_not_found.append(pkg)

        return pkgs_not_found                
        
        
    def commit(self):
        pass
    

def create_tree(ks_label, channel_label, path, boot_image, kstree_type, install_type, pkgs):
    
    channel = rhnChannel.channel_info(channel_label)

    if channel is '':
        raise rhnFault(40, 'Could not lookup channel ' + channel_label)

    channel_id = channel['id']
    
    create_ks_query = rhnSQL.prepare("""
        insert into rhnKickstartableTree (
            id, org_id, label, base_path, channel_id, boot_image, kstree_type,
            install_type)
        values (
            sequence_nextval('rhn_kstree_id_seq'), :org_id, :label, :base_path, :channel_id, 
            :boot_image, 
            (select id from rhnKSTreeType where label = :kstree_type),
            (select id from rhnKSInstallType where label = :install_type))
    """)
    create_ks_query.execute(org_id = None,
                            label = ks_label,
                            base_path = path,
                            channel_id = channel_id,
                            boot_image = boot_image,
                            kstree_type = kstree_type,
                            install_type = install_type)

    return lookup_tree(ks_label, pkgs)


def lookup_tree(ks_label, pkgs):    
    
    ks_label_query = rhnSQL.prepare ("""
        SELECT KT.id, KT.label, KT.base_path, KT.channel_id, KT.boot_image,
               KT.org_id, KTT.id AS TREE_TYPE, KTT.label AS TREE_TYPE_LABEL, KTT.name AS TREE_TYPE_NAME,
               KIT.id AS install_type, KIT.label AS install_type_label, KIT.name AS install_type_name,
               C.channel_arch_id, CA.label AS CHANNEL_ARCH_LABEL, CA.name AS CHANNEL_ARCH_NAME
          FROM rhnKSTreeType KTT,
               rhnKSInstallType KIT,
               rhnChannel C,
               rhnChannelArch CA,
               rhnKickstartableTree KT
         WHERE KT.label = :ks_label
           AND KTT.id = KT.kstree_type
           AND KIT.id = KT.install_type
           AND C.id = KT.channel_id
           AND CA.id = C.channel_arch_id
    """)

    ks_label_query.execute(ks_label = ks_label)

    ks_row = ks_label_query.fetchone_dict()

    if ks_row:
        kickstart = Kickstart(ks_row, pkgs)
        return kickstart
    else:
        return None

    

