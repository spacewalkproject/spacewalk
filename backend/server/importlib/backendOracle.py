#!/usr/bin/python -v
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
# Oracle-specific stuff
#
# FIXME: need more documentation
#

from backend import Backend
from backendLib import DBint, DBstring, DBdateTime, DBblob, Table, \
        TableCollection
from server import rhnSQL

class OracleBackend(Backend):
    tables = TableCollection(
        # NOTE: pk = primary keys
        #       attribute = attribute this table links back to
        #       map = mapping from database fields to generic attribute names
        Table('rhnPackageProvides',
            fields      = {
                'package_id'    : DBint(),
                'capability_id' : DBint(),
                'sense'         : DBint(),
                },
            pk          = ['package_id', 'capability_id', 'sense'],
            attribute   = 'provides',
            map         = { 'sense' : 'flags', },
        ),
        Table('rhnPackageRequires', 
            fields      = {
                'package_id'    : DBint(),
                'capability_id' : DBint(),
                'sense'         : DBint(),
            },
            pk          = ['package_id', 'capability_id', 'sense'],
            attribute   = 'requires',
            map         = { 'sense' : 'flags', },
        ),
        Table('rhnPackageConflicts',
            fields      = {
                'package_id'    : DBint(),
                'capability_id' : DBint(),
                'sense'         : DBint(),
            },
            pk          = ['package_id', 'capability_id', 'sense'],
            attribute   = 'conflicts',
            map         = { 'sense' : 'flags', },
        ),
        Table('rhnPackageObsoletes',
            fields      = {
                'package_id'    : DBint(),
                'capability_id' : DBint(),
                'sense'         : DBint(),
            },
            pk          = ['package_id', 'capability_id', 'sense'],
            attribute   = 'obsoletes',
            map         = { 'sense' : 'flags', },
        ),
        Table('rhnPackageChangeLog',
            fields      = {
                'package_id'    : DBint(),
                'name'          : DBstring(128),
                'text'          : DBstring(3000),
                'time'          : DBdateTime()
            },
            pk          = ['package_id', 'name', 'text', 'time'],
            attribute   = 'changelog',
        ),
        Table('rhnPackageFile',
            fields      = {
                'package_id'    : DBint(),
                'capability_id' : DBint(),
                'device'        : DBint(),
                'inode'         : DBint(),
                'file_mode'     : DBint(),
                'username'      : DBstring(32),
                'groupname'     : DBstring(32),
                'rdev'          : DBint(),
                'file_size'     : DBint(),
                'mtime'         : DBdateTime(),
                'checksum_id'   : DBint(),
                'linkto'        : DBstring(256),
                'flags'         : DBint(),
                'verifyflags'   : DBint(),
                'lang'          : DBstring(32),
            },
            pk          = ['package_id', 'capability_id', 'checksum_id'],
            attribute   = 'files',
            severityHash = {
                'mtime'         : 0,
                'file_size'     : 4,
            },
        ),
        Table('rhnPackage',
            fields      = {
                'id'            : DBint(), 
                'org_id'        : DBint(), 
                'name_id'       : DBint(), 
                'evr_id'        : DBint(), 
                'package_arch_id': DBint(), 
                'package_group' : DBint(), 
                'rpm_version'   : DBstring(16),
                'description'   : DBstring(4000),
                'summary'       : DBstring(4000),
                'package_size'  : DBint(), 
                'payload_size'  : DBint(),
                'build_host'    : DBstring(256), 
                'build_time'    : DBdateTime(),
                'source_rpm_id' : DBint(),
                'checksum_id'   : DBint(),
                'vendor'        : DBstring(64), 
                'payload_format': DBstring(32), 
                'path'          : DBstring(1000), 
                'copyright'     : DBstring(64),
                'cookie'        : DBstring(128),
                'header_start'  : DBint(),
                'header_end'    : DBint(),
                'last_modified' : DBdateTime(),
            },
            pk          = ['org_id', 'name_id', 'evr_id', 'package_arch_id',
                           'checksum_id'],
            nullable    = ['org_id'],
            severityHash = {
                'path'          : 1,
                'package_size'  : 2,
                'build_time'    : 3,
                'build_host'    : 3,
                'last_modified' : 0.5,
                # rpm got it wrong so now we have to ignore it
                'payload_size'  : 0,
            },
        ),
        Table('rhnChannelPackage',
            fields      = {
                'package_id'    : DBint(),
                'channel_id'    : DBint(),
            },
            pk          = ['channel_id', 'package_id'],
        ),
        Table('rhnErrata',
            fields      = {
                'id'            : DBint(),
                'advisory'      : DBstring(32),
                'advisory_type' : DBstring(32),
                'advisory_name' : DBstring(32),
                'advisory_rel'  : DBint(),
                'product'       : DBstring(64),
                'description'   : DBstring(4000),
                'synopsis'      : DBstring(4000),
                'topic'         : DBstring(4000),
                'solution'      : DBstring(4000),
                'notes'         : DBstring(4000),
                'refers_to'     : DBstring(4000),
                'org_id'        : DBint(),
		'locally_modified' : DBstring(1),
                'severity_id'   : DBint(),
                # We will treat issue_date and update_date as regular dates
                # with times instead of DBdate types, otherwise we'd have 
                # issues with timezones
                'issue_date'    : DBdateTime(),
                'update_date'   : DBdateTime(),
                'last_modified' : DBdateTime(),
            },
            pk          = ['advisory_name', ],
            defaultSeverity = 4,
        ),
        Table('rhnErrataBugList',
            fields      = {
                'errata_id'     : DBint(),
                'bug_id'        : DBint(),
                'summary'       : DBstring(4000),
            },
            pk          = ['errata_id', 'bug_id'],
            attribute   = 'bugs',
            defaultSeverity = 4,
        ),
        Table('rhnCVE',
            fields      = {
                'id'            : DBint(),
                'name'          : DBstring(13),
            },
            pk          = ['name'],
        ),
        Table('rhnErrataCVE',
            fields      = {
                'errata_id'     : DBint(),
                'cve_id'        : DBint(),
            },
            pk          = ['errata_id', 'cve_id'],
            attribute   = 'cve',
            defaultSeverity = 4,
        ),
        Table('rhnErrataFile',
            fields      = {
                'id'            : DBint(),
                'errata_id'     : DBint(),
                'type'          : DBint(),
                'checksum_id'   : DBint(),
                'filename'      : DBstring(1024),
            },
            pk          = ['errata_id', 'filename', 'checksum_id'],
            attribute   = 'files',
            defaultSeverity = 4,
            sequenceColumn = 'id',
        ),
        Table('rhnErrataFilePackage',
            fields      = {
                'errata_file_id'    : DBint(),
                'package_id'        : DBint(),
            },
            pk          = ['errata_file_id', 'package_id'],
        ),
        Table('rhnErrataFilePackageSource',
            fields      = {
                'errata_file_id'    : DBint(),
                'package_id'        : DBint(),
            },
            pk          = ['errata_file_id', 'package_id'],
        ),
        Table('rhnErrataFileChannel',
            fields      = {
                'errata_file_id'    : DBint(),
                'channel_id'        : DBint(),
            },
            pk          = ['errata_file_id', 'channel_id'],
        ),
        Table('rhnErrataKeyword',
            fields      = {
                'errata_id'     : DBint(),
                'keyword'       : DBstring(64),
            },
            pk          = ['errata_id', 'keyword'],
            attribute   = 'keywords',
            defaultSeverity = 4,
        ),
        Table('rhnErrataPackage',
            fields      = {
                'errata_id'     : DBint(),
                'package_id'    : DBint(),
            },
            pk          = ['errata_id', 'package_id'],
            attribute   = 'packages',
            defaultSeverity = 4,
        ),
        Table('rhnChannelErrata',
            fields      = {
                'errata_id'     : DBint(),
                'channel_id'    : DBint(),
            },
            pk          = ['errata_id', 'channel_id'],
            attribute   = 'channels',
            defaultSeverity = 4,
        ),
        Table('rhnChannel',
            fields      = {
                'id'            : DBint(),
                'parent_channel' : DBint(),
                'org_id'        : DBint(),
                'channel_arch_id': DBint(),
                'label'         : DBstring(128),
                'basedir'       : DBstring(256),
                'name'          : DBstring(64),
                'summary'       : DBstring(500),
                'description'   : DBstring(4000),
                'product_name_id' : DBint(),
                'gpg_key_url'   : DBstring(256),
                'gpg_key_id'    : DBstring(14),
                'gpg_key_fp'    : DBstring(50),
                'end_of_life'   : DBdateTime(),
                'receiving_updates' : DBstring(1),
                'last_modified' : DBdateTime(),
                'channel_product_id' : DBint(),
                'checksum_type_id' : DBint(),
            },
            pk          = ['label'],
        ),
        Table('rhnChannelFamily',
            fields      = {
                'id'            : DBint(),
                'name'          : DBstring(128),
                'label'         : DBstring(128),
                'product_url'   : DBstring(128),
            },
            pk          = ['label'],
            defaultSeverity = 4,
        ),
        Table('rhnDistChannelMap',
            fields      = {
                'os'            : DBstring(64),
                'release'       : DBstring(64),
                'channel_arch_id': DBint(),
                'channel_id'    : DBint(),
            },
            pk          = ['os', 'release', 'channel_arch_id', 'channel_id'],
            attribute   = 'dists',
            defaultSeverity = 4,
        ),
        Table('rhnReleaseChannelMap',
            fields      = {
                'product'       : DBstring(64),
                'version'       : DBstring(64),
                'release'       : DBstring(64),
                'channel_arch_id': DBint(),
                'channel_id'    : DBint()
            },
            pk          = ['product', 'version', 'release', 'channel_arch_id', 'channel_id'],
            attribute   = 'release',
            defaultSeverity = 4,
        ),
        Table('rhnChannelFamilyMembers',
            fields      = {
                'channel_id'        : DBint(),
                'channel_family_id' : DBint(),
            },
            pk          = ['channel_id', 'channel_family_id'],
            attribute   = 'families',
            defaultSeverity = 4,
        ),
        Table('rhnPackageSource',
            fields      = {
                'id'            : DBint(),
                'org_id'        : DBint(),
                'source_rpm_id' : DBint(),
                'package_group' : DBint(), 
                'rpm_version'   : DBstring(16),
                'payload_size'  : DBint(),
                'build_host'    : DBstring(256), 
                'build_time'    : DBdateTime(),
                'path'          : DBstring(1000),
                'package_size'  : DBint(),
                'checksum_id'   : DBint(),
                'sigchecksum_id' : DBint(),
                'vendor'        : DBstring(64), 
                'cookie'        : DBstring(128),
                'last_modified' : DBdateTime(),
            },
            pk          = ['source_rpm_id', 'org_id',
                           'sigchecksum_id', 'checksum_id'],
            nullable    = ['org_id'],
            severityHash = {
                'path'          : 1,
                'file_size'     : 2,
                'build_host'    : 3,
                'build_time'    : 3,
                # rpm got it wrong so now we have to ignore it
                'payload_size'  : 0,
                'last_modified' : 0.5,
            },
        ),
        Table('rhnServerArch',
            fields      = {
                'id'            : DBint(),
                'label'         : DBstring(64),
                'name'          : DBstring(64),
                'arch_type_id'  : DBint(),
            },
            pk          = ['label'],
        ),
        Table('rhnPackageArch',
            fields      = {
                'id'            : DBint(),
                'label'         : DBstring(64),
                'name'          : DBstring(64),
                'arch_type_id'  : DBint(),
            },
            pk          = ['label'],
        ),
        Table('rhnChannelArch',
            fields      = {
                'id'            : DBint(),
                'label'         : DBstring(64),
                'name'          : DBstring(64),
                'arch_type_id'  : DBint(),
            },
            pk          = ['label'],
        ),
        Table('rhnCPUArch',
            fields      = {
                'id'            : DBint(),
                'label'         : DBstring(64),
                'name'          : DBstring(64),
            },
            pk          = ['label'],
        ),
        Table('rhnServerPackageArchCompat',
            fields      = {
                'server_arch_id'    : DBint(),
                'package_arch_id'   : DBint(),
                'preference'        : DBint(),
            },
            pk          = ['server_arch_id', 'package_arch_id', 'preference'],
        ),
        Table('rhnServerChannelArchCompat',
            fields      = {
                'server_arch_id'    : DBint(),
                'channel_arch_id'   : DBint(),
            },
            pk          = ['server_arch_id', 'channel_arch_id'],
        ),
        Table('rhnChannelPackageArchCompat',
            fields      = {
                'channel_arch_id'   : DBint(),
                'package_arch_id'   : DBint(),
            },
            pk          = ['channel_arch_id', 'package_arch_id'],
        ),
        Table('rhnServerServerGroupArchCompat',
            fields      = {
                'server_arch_id'    : DBint(),
                'server_group_type' : DBint(),
            },
            pk          = ['server_arch_id', 'server_group_type'],
        ),
        Table('rhnBlacklistObsoletes',
            fields      = {
                'name_id'           : DBint(),
                'evr_id'            : DBint(),
                'package_arch_id'   : DBint(),
                'ignore_name_id'    : DBint(),
            },
            pk          = ['name_id', 'evr_id', 'package_arch_id',
                           'ignore_name_id'],
        ),
        Table('rhnKickstartableTree',
            fields      = {
                'id'                : DBint(),
                'org_id'            : DBint(), 
                'base_path'         : DBstring(256),
                'channel_id'        : DBint(),
                'label'             : DBstring(64),
                'boot_image'        : DBstring(128),
                'kstree_type'       : DBint(),
                'install_type'      : DBint(),
            },
            pk          = ['label', 'org_id'],
            nullable    = ['org_id'],
        ),
        Table('rhnKSTreeType',
            # not used at the moment
            fields      = {
                'id'                : DBint(),
                'label'             : DBstring(32),
                'name'              : DBstring(64),
            },
            pk          = ['label'],
        ),
        Table('rhnKSInstallType',
            # not used at the moment
            fields      = {
                'id'                : DBint(),
                'label'             : DBstring(32),
                'name'              : DBstring(64),
            },
            pk          = ['label'],
        ),
        Table('rhnKSTreeFile',
            fields      = {
                'kstree_id'         : DBint(),
                'relative_filename' : DBstring(256),
                'checksum_id'       : DBint(),
                'file_size'         : DBint(),
                'last_modified'     : DBdateTime()
            },
            pk          = ['kstree_id', 'relative_filename', 'checksum_id'],
            attribute   = 'files',
            map         = {
                'relative_filename' : 'relative_path',
            },
        ),
        
        Table('rhnProductName',
            fields      = {
                'id'                : DBint(),
                'label'             : DBstring(128),
                'name'              : DBstring(128),
            },
            pk          = ['id', 'label', 'name'],
        ),
        # tables needed for virt ----------------------------------------

        Table('rhnVirtSubLevel',
            fields      = {
                'id'                : DBint(),
                'label'             : DBstring(32),
                'name'              : DBstring(128),
            },
            pk          = ['id', 'label', 'name'],
        ),

        # tables needed for solaris --------------------------------------
        
        Table('rhnSolarisPatch',
            # Table column -> Column type mapping
            fields      = {
                'package_id'        : DBint(),
                'solaris_release'   : DBstring(64),
                'sunos_release'     : DBstring(64),
                'patch_type'        : DBint(),
                'readme'            : DBblob(),
                'patchinfo'         : DBstring(4000),
            },
            pk          = ['package_id',],
            nullable    = ['solaris_release', 'sunos_release', 'patchinfo'],
            # Object attribute -> Sub-table mapping
            attribute   = 'solaris_patch',
        ),
        Table('rhnSolarisPatchPackages',
            fields      = {
                'patch_id'          : DBint(),
                'package_nevra_id'  : DBint(),
            },
            pk          = ['patch_id', 'package_nevra_id'],
            attribute   = 'solaris_patch_packages',
        ),
        Table('rhnSolarisPatchSet',
            fields      = {
                'package_id'        : DBint(),
                'readme'            : DBblob(),
                'set_date'          : DBdateTime(),
            },
            pk          = ['package_id',],
            nullable    = ['readme'],
            attribute   = 'solaris_patch_set',
        ),
        Table('rhnSolarisPatchSetMembers',
            fields      = {
                'patch_id'          : DBint(),
                'patch_set_id'      : DBint(),
                'patch_order'       : DBint(),
            },
            pk          = ['patch_set_id', 'patch_id'],
            nullable    = ['patch_order'],
            attribute   = 'solaris_patch_set_members',
        ),
        Table('rhnSolarisPackage',
            fields      = {
                'package_id'        : DBint(),
                'category'          : DBstring(2048),
                'pkginfo'           : DBstring(4000),
                'pkgmap'            : DBblob(),
                'intonly'           : DBstring(1),
            },
            pk          = ['package_id'],
            nullable    = ['category', 'pkginfo', 'pkgmap'],
            attribute   = 'solaris_package',
        ),
    )

    def __init__(self):
        Backend.__init__(self, rhnSQL)

    def init(self):
        """
        Override parent to do explicit setting of the date format. (Oracle
        specific)
        """
        # Set date format
        self.setDateFormat("YYYY-MM-DD HH24:MI:SS")
        return Backend.init(self)

class PostgresqlBackend(OracleBackend):
    """
    PostgresqlBackend specific implementation. The bulk of the OracleBackend
    is not actually Oracle specific, so we'll re-use as much as we can and just
    avoid the few bits that are.
    """

    def init(self):
        """
        Avoid the Oracle specific stuff here in parent method.
        """
        return Backend.init(self)

