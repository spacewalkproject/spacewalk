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

import sys
import time
import xmlrpclib
from types import ListType, TupleType, DictType
import gzip
import cStringIO

from spacewalk.common import rhn_rpm, rhn_mpm

def main():
    packages = sys.argv[1:]
    if not packages:
        return

    for pkgfile in packages:
        # Try to open the package as a patch first
        try:
            f = open(pkgfile)

            header = rhn_rpm.get_package_header(file=f)
            p = rpm_to_mpm(header, f)
            dest_filename = _compute_filename(p.header)
            print "Writing out the package to %s" % dest_filename
            dest_file = open(dest_filename, "w+")
            p.write(dest_file)
            dest_file.close()
            f.close()
        except:
            raise

def _compute_filename(dict):
    return '%s-%s.%s.mpm' % (dict['name'], dict['version'], dict['arch'])

def rpm_to_mpm(header, file_stream):
    tag_map = {
        'package_group' : 'group',
        'rpm_version'   : 'rpmversion',
        'payload_size'  : 'archivesize',
        'payload_format': 'payloadformat',
        'build_host'    : 'buildhost',
        'build_time'    : 'buildtime',
        'source_rpm'    : 'sourcerpm',
    }
    
    tags = [
        'name',
        'epoch',
        'version',
        'release',
        'arch',
        'description',
        'summary',
        'license',
        'package_group',
        'rpm_version',
        'payload_size',
        'payload_format',
        'build_host',
        'build_time',
        'cookie',
        'vendor',
        'source_rpm',
        'sigmd5',
        'sigpgp',
        'siggpg',
        'sigsize',
    ]
    
    result = {}
    for t in tags:
        tt = tag_map.get(t, t)
        result[t] = header[tt]

    # Add files
    result['files'] = _extract_files(header)

    # Dependency
    result['provides'] = _extract_rpm_requires(header)
    result['requires'] = _extract_rpm_provides(header)
    result['conflicts'] = _extract_rpm_conflicts(header)
    result['obsoletes'] = _extract_rpm_obsoletes(header)

    result['changelog'] = _extract_rpm_changelog(header)

    # md5sum, package_size
    file_stream.seek(0, 2)
    file_size = file_stream.tell() 
    result['package_size'] = file_size

    is_source = 0
    if header.is_source:
        is_source = 1
    result['is_source'] = is_source

    result['package_type'] = 'rpm'

    h = rhn_mpm.MPM_Header(result)
    p = rhn_mpm.MPM_Package()
    p.header = h
    p.payload_stream = file_stream
    
    return p

def _extract_files(header):
    tag_maps = {
        'name'      : 'filenames',
        'device'    : 'filedevices',
        'inode'     : 'fileinodes',
        'file_mode' : 'filemodes',
        'username'  : 'fileusername',
        'groupname' : 'filegroupname',
        'rdev'      : 'filerdevs',
        'file_size' : 'filesizes',
        'mtime'     : 'filemtimes',
        'md5'       : 'filemd5s',
        'linkto'    : 'filelinktos',
        'flags'     : 'fileflags',
        'verifyflags' : 'fileverifyflags',
        'lang'      : 'filelangs',
    }
    files = _extract_array_fields(header, tag_maps)
    # Munge the mtime
    for f in files:
        f['mtime'] = gmtime(f['mtime'])
    return files

def _extract_rpm_provides(header):
    tag_maps = {
        'name'      : 'provides',
        'version'   : 'provideversion',
        'flags'     : 'provideflags',
    }
    return _extract_array_fields(header, tag_maps)

def _extract_rpm_requires(header):
    tag_maps = {
        'name'      : 'requirename',
        'version'   : 'requireversion',
        'flags'     : 'requireflags',
    }
    return _extract_array_fields(header, tag_maps)

def _extract_rpm_conflicts(header):
    tag_maps = {
        'name'      : 'conflictname',
        'version'   : 'conflictversion',
        'flags'     : 'conflictflags',
    }
    return _extract_array_fields(header, tag_maps)

def _extract_rpm_obsoletes(header):
    tag_maps = {
        'name'      : 'obsoletename',
        'version'   : 'obsoleteversion',
        'flags'     : 'obsoleteflags',
    }
    return _extract_array_fields(header, tag_maps)

def _extract_rpm_changelog(header):
    tag_maps = {
        'name'      : 'changelogname',
        'text'      : 'changelogtext',
        'time'      : 'changelogtime',
    }
    cl = _extract_array_fields(header, tag_maps)
    # Munge the changelog time
    for c in cl:
        c['time'] = gmtime(c['time'])
    return cl

def _extract_array_fields(header, tag_maps):
    # First determine the number of entries
    key = tag_maps.keys()[0]
    rpmtag = tag_maps.get(key)
    arr = header[rpmtag]
    if arr is None:
        # nothing to do
        return []
    count = len(arr)

    result = []
    for i in range(count):
        dict = {}
        for key, rpmtag in tag_maps.items():
            arr = header[rpmtag]
            if type(arr) not in (ListType, TupleType):
                arr = [arr]
            dict[key] = arr[i]
        result.append(dict)
    return result

def _replace_null(obj):
    if obj is None:
        return ''
    if isinstance(obj, ListType):
        return map(_replace_null, obj)
    if isinstance(obj, TupleType):
        return tuple(_replace_null(list(obj)))
    if isinstance(obj, DictType):
        dict = {}
        for k, v in obj.items():
            dict[_replace_null(k)] = _replace_null(v)
        return dict
    return obj

def _encode(package):
    stream = cStringIO.StringIO()
    data = xmlrpclib.dumps((_replace_null(package), ))
    f = gzip.GzipFile(None, "wb", 9, stream)
    f.write('<?xml version="1.0"?>\n')
    f.write(data)
    f.close()
    stream.seek(0, 0)
    return stream.getvalue()
    

def gmtime(timestamp):
    ttuple = time.gmtime(timestamp)
    return "%d-%02d-%02d %02d:%02d:%02d" % ttuple[:6]

if __name__ == '__main__':
    sys.exit(main() or 0)
