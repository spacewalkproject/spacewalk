#
# Copyright (c) 2008--2016 Red Hat, Inc.
#
# Authors: Pradeep Kilambi
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

import sys
import os
import shutil

from optparse import Option, OptionParser
from spacewalk.common.rhnLog import initLOG, rhnLog
from spacewalk.common.rhnConfig import CFG, initCFG
from spacewalk.common import rhn_rpm
from spacewalk.server.rhnLib import parseRPMFilename, get_package_path
from spacewalk.server import rhnSQL, rhnPackageUpload
from spacewalk.server.rhnServer import server_packages
from spacewalk.satellite_tools.progress_bar import ProgressBar
from spacewalk.common.checksum import getFileChecksum
from spacewalk.server.importlib import mpmSource

initCFG('server.satellite')
initLOG(CFG.LOG_FILE, CFG.DEBUG)

OPTIONS = None
debug = 0
verbose = 0

options_table = [
    Option("--update-package-files", action="store_true",
           help="Update package files (bugs #659348, #652852)"),
    Option("--update-sha256", action="store_true",
           help="Update SHA-256 capable packages"),
    Option("--update-filer", action="store_true",
           help="Convert filer structure"),
    Option("--update-kstrees", action="store_true",
           help="Fix kickstart trees permissions"),
    Option("--update-changelog", action="store_true",
           help="Fix incorrectly encoded package changelog data"),
    Option("-v", "--verbose", action="count",
           help="Increase verbosity"),
    Option("--debug", action="store_true",
           help="Log the debug information to a log file"),
]


def main():
    global debug, verbose
    parser = OptionParser(option_list=options_table)

    (options, args) = parser.parse_args()

    if args:
        for arg in args:
            sys.stderr.write("Not a valid option ('%s'), try --help\n" % arg)
        sys.exit(-1)

    if options.verbose:
        initLOG("stdout", options.verbose or 0)
        verbose = 1

    if options.debug:
        initLOG(CFG.LOG_FILE, options.debug or 0)
        debug = 1

    rhnSQL.initDB()

    if options.update_filer:
        process_package_data()

    if options.update_sha256:
        process_sha256_packages()

    if options.update_kstrees:
        process_kickstart_trees()

    if options.update_package_files:
        process_package_files()

    if options.update_changelog:
        process_changelog()

_get_path_query = """
        select id, checksum_type, checksum, path, epoch, new_path
        from (
                select rhnPackage.id,
                       rhnChecksumView.checksum_type,
                       rhnChecksumView.checksum,
                       rhnPackage.path,
                       rhnPackageEvr.epoch,
                        case when rhnPackage.org_id is null then 'NULL'
                             else rhnPackage.org_id || '' end
                        || '/' || substr(rhnChecksumView.checksum, 1, 3)
                        || '/' || rhnPackageName.name
                        || '/' || case when rhnPackageEvr.epoch is null then ''
                                       else rhnPackageEvr.epoch || ':' end
                        || rhnPackageEvr.version || '-' || rhnPackageEvr.release
                        || '/' || rhnPackageArch.label
                        || '/' || rhnChecksumView.checksum
                        || substr(rhnPackage.path, instr(rhnPackage.path, '/', -1))
                        as new_path
                from rhnPackage, rhnPackagename, rhnPackageEvr, rhnPackageArch, rhnChecksumView
                where rhnPackage.name_id = rhnPackageName.id
                        and rhnPackage.evr_id = rhnPackageEvr.id
                        and rhnPackage.package_arch_id = rhnPackageArch.id
                        and rhnPackage.checksum_id = rhnChecksumView.id
                ) X
        where '/' || new_path <> nvl(substr(path, -length(new_path) - 1), 'x')
"""

_update_pkg_path_query = """
    update rhnPackage
       set path = :new_path
    where id = :the_id
"""


def process_package_data():
    if debug:
        log = rhnLog('/var/log/rhn/update-packages.log', 5)

    _get_path_sql = rhnSQL.prepare(_get_path_query)
    _update_package_path = rhnSQL.prepare(_update_pkg_path_query)

    _get_path_sql.execute()
    paths = _get_path_sql.fetchall_dict()

    if not paths:
        # Nothing to change
        return
    if verbose:
        print("Processing %s packages" % len(paths))
    pb = ProgressBar(prompt='standby: ', endTag=' - Complete!',
                     finalSize=len(paths), finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)
    skip_list = []
    new_ok_list = []
    i = 0
    for path in paths:
        pb.addTo(1)
        pb.printIncrement()
        old_path_nvrea = path['path'].split('/')
        org_id = old_path_nvrea[1]
        # pylint: disable=W0703
        try:
            nevra = parseRPMFilename(old_path_nvrea[-1])
            if nevra[1] in [None, '']:
                nevra[1] = path['epoch']
        except Exception:
            # probably not an rpm skip
            if debug:
                log.writeMessage("Skipping: %s Not a valid rpm"
                                 % old_path_nvrea[-1])
            continue
        old_abs_path = os.path.join(CFG.MOUNT_POINT, path['path'])

        checksum_type = path['checksum_type']
        checksum = path['checksum']
        new_path = get_package_path(nevra, org_id, prepend=old_path_nvrea[0],
                                    checksum=checksum)
        new_abs_path = os.path.join(CFG.MOUNT_POINT, new_path)

        bad_abs_path = os.path.join(CFG.MOUNT_POINT,
                                    get_package_path(nevra, org_id, prepend=old_path_nvrea[0],
                                                     omit_epoch=True, checksum=checksum))

        if not os.path.exists(old_abs_path):
            if os.path.exists(new_abs_path):
                new_ok_list.append(new_abs_path)
                if debug:
                    log.writeMessage("File %s already on final path %s" % (path['path'], new_abs_path))
                old_abs_path = new_abs_path
            elif os.path.exists(bad_abs_path):
                log.writeMessage("File %s found on %s" % (path['path'], bad_abs_path))
                old_abs_path = bad_abs_path
            else:
                skip_list.append(old_abs_path)
                if debug:
                    log.writeMessage("Missing path %s for package %d" % (old_abs_path, path['id']))
                continue

        # pylint: disable=W0703
        try:
            hdr = rhn_rpm.get_package_header(filename=old_abs_path)
        except Exception:
            e = sys.exc_info()[1]
            msg = "Exception occurred when reading package header %s: %s" % \
                (old_abs_path, str(e))
            print(msg)
            if debug:
                log.writeMessage(msg)
            rhnSQL.commit()
            sys.exit(1)

        if old_abs_path != new_abs_path:
            new_abs_dir = os.path.dirname(new_abs_path)
            # relocate the package on the filer
            if debug:
                log.writeMessage("Relocating %s to %s on filer"
                                 % (old_abs_path, new_abs_path))
            if not os.path.isdir(new_abs_dir):
                os.makedirs(new_abs_dir)
            shutil.move(old_abs_path, new_abs_path)
            # Clean up left overs
            os.removedirs(os.path.dirname(old_abs_path))
            # make the path readable
            os.chmod(new_abs_path, int('0644', 8))

        # Update the db paths
        _update_package_path.execute(the_id=path['id'],
                                     new_path=new_path)
        if debug:
            log.writeMessage("query Executed: update rhnPackage %d to %s"
                             % (path['id'], new_path))
        # Process gpg key ids
        server_packages.processPackageKeyAssociations(hdr, checksum_type, checksum)
        if debug:
            log.writeMessage("gpg key info updated from %s" % new_abs_path)
        i = i + 1
        # we need to break the transaction to smaller pieces
        if i % 1000 == 0:
            rhnSQL.commit()
    pb.printComplete()
    # All done, final commit
    rhnSQL.commit()
    sys.stderr.write("Transaction Committed! \n")
    if verbose:
        print(" Skipping %s packages, paths not found" % len(skip_list))
    if len(new_ok_list) > 0 and verbose:
        print(" There were %s packages found in the correct location" % len(new_ok_list))
    return


def process_kickstart_trees():
    for root, _dirs, files in os.walk(CFG.MOUNT_POINT + "/rhn/"):
        for name in files:
            os.chmod(root + '/' + name, int('0644', 8))

_get_sha256_packages_query = """
select p.id, p.path
from rhnPackage p,
     rhnPackageRequires pr,
     rhnPackageCapability pc,
     rhnChecksumView cv
where pr.package_id = p.id and
      pr.capability_id = pc.id and
      pc.name = 'rpmlib(FileDigests)' and
      pc.version = '4.6.0-1' and
      cv.id = p.checksum_id and
      cv.checksum_type = 'md5'
"""

_update_sha256_package = """
update rhnPackage
set checksum_id = lookup_checksum(:ctype, :csum),
    path = :path
where id = :id
"""

_select_checksum_type_id = """
select id from rhnChecksumType where label = :ctype
"""

_update_package_files = """
declare
    checksum_id number;
begin
    begin
        insert into rhnChecksum values (
            sequence_nextval('rhnChecksum_seq'),
            :ctype_id,
            :csum ) returning id into checksum_id;
    exception when dup_val_on_index then
        select c.id
        into checksum_id
        from rhnChecksum c
        where c.checksum = :csum and
              c.checksum_type_id = :ctype_id;
    end;

    update rhnPackageFile p
    set p.checksum_id = checksum_id
    where p.capability_id = (
        select c.id
        from rhnPackageCapability c
        where p.package_id = :pid and
              c.name = :filename
    ) and p.package_id = :pid;
end;
"""


def process_sha256_packages():
    if debug:
        log = rhnLog('/var/log/rhn/update-packages.log', 5)

    _get_sha256_packages_sql = rhnSQL.prepare(_get_sha256_packages_query)
    _get_sha256_packages_sql.execute()
    packages = _get_sha256_packages_sql.fetchall_dict()

    if not packages:
        print("No SHA256 capable packages to process.")
        if debug:
            log.writeMessage("No SHA256 capable packages to process.")

        return

    if verbose:
        print("Processing %s SHA256 capable packages" % len(packages))

    pb = ProgressBar(prompt='standby: ', endTag=' - Complete!',
                     finalSize=len(packages), finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)

    _update_sha256_package_sql = rhnSQL.prepare(_update_sha256_package)
    _update_package_files_sql = rhnSQL.prepare(_update_package_files)

    for package in packages:
        pb.addTo(1)
        pb.printIncrement()

        old_abs_path = os.path.join(CFG.MOUNT_POINT, package['path'])
        if debug and verbose:
            log.writeMessage("Processing package: %s" % old_abs_path)
        temp_file = open(old_abs_path, 'rb')
        header, _payload_stream, _header_start, _header_end = \
            rhnPackageUpload.load_package(temp_file)
        checksum_type = header.checksum_type()
        checksum = getFileChecksum(checksum_type, file_obj=temp_file)

        old_path = package['path'].split('/')
        nevra = parseRPMFilename(old_path[-1])
        org_id = old_path[1]
        new_path = get_package_path(nevra, org_id, prepend=old_path[0], checksum=checksum)
        new_abs_path = os.path.join(CFG.MOUNT_POINT, new_path)

        # Filer content relocation
        try:
            if old_abs_path != new_abs_path:
                if debug:
                    log.writeMessage("Relocating %s to %s on filer" % (old_abs_path, new_abs_path))

                new_abs_dir = os.path.dirname(new_abs_path)
                if not os.path.isdir(new_abs_dir):
                    os.makedirs(new_abs_dir)

                # link() the old path to the new path
                if not os.path.exists(new_abs_path):
                    os.link(old_abs_path, new_abs_path)
                elif debug:
                    log.writeMessage("File %s already exists" % new_abs_path)

                # Make the new path readable
                os.chmod(new_abs_path, int('0644', 8))
        except OSError:
            e = sys.exc_info()[1]
            message = "Error when relocating %s to %s on filer: %s" % \
                      (old_abs_path, new_abs_path, str(e))
            print(message)
            if debug:
                log.writeMessage(message)
            sys.exit(1)

        # Update package checksum in the database
        _update_sha256_package_sql.execute(ctype=checksum_type, csum=checksum,
                                           path=new_path, id=package['id'])

        _select_checksum_type_id_sql = rhnSQL.prepare(_select_checksum_type_id)
        _select_checksum_type_id_sql.execute(ctype=checksum_type)
        checksum_type_id = _select_checksum_type_id_sql.fetchone()[0]

        # Update checksum of every single file in a package
        for i, f in enumerate(header['filenames']):
            csum = header['filemd5s'][i]

            # Do not update checksums for directories & links
            if not csum:
                continue

            _update_package_files_sql.execute(ctype_id=checksum_type_id, csum=csum,
                                              pid=package['id'], filename=f)

        rhnSQL.commit()

        try:
            if os.path.exists(old_abs_path):
                os.unlink(old_abs_path)
            if os.path.exists(os.path.dirname(old_abs_path)):
                os.removedirs(os.path.dirname(old_abs_path))
        except OSError:
            e = sys.exc_info()[1]
            message = "Error when removing %s: %s" % (old_abs_path, str(e))
            print(message)
            if debug:
                log.writeMessage(message)

            sys.exit(1)

    pb.printComplete()

package_query = """
    select p.id as id,
           p.path as path,
           count(pf.capability_id) as filecount,
           count(pf.checksum_id) as nonnullcsums
      from rhnPackage p left outer join rhnPackageFile pf
        on p.id = pf.package_id
     where path is not null
  group by id, path
"""

package_capabilities = """
    select PC.name,
           PF.package_id,
           PF.capability_id,
           C.checksum,
           C.checksum_type
      from rhnPackageFile PF left outer join rhnChecksumView C
        on PF.checksum_id = C.id,
           rhnPackageCapability PC
     where PC.id = PF.capability_id and
           PF.package_id = :pid
"""

update_packagefile_checksum = """
    update rhnPackageFile
       set checksum_id = lookup_checksum(:ctype, :csum)
     where package_id = :pid and
           capability_id = :cid
"""

insert_packagefile = """
    insert into rhnPackageFile (
            package_id, capability_id, device, inode, file_mode, username,
            groupname, rdev, file_size, mtime, linkto, flags, verifyflags,
            lang, checksum_id
           )
    values (
            :pid, lookup_package_capability(:name, null),
            :device, :inode, :file_mode, :username, :groupname,
            :rdev, :file_size, to_timestamp(:mtime, 'YYYY-MM-DD HH24:MI:SS'), :linkto,
            :flags, :verifyflags, :lang, lookup_checksum(:ctype, :csum)
           )
"""

package_name_query = """
    select pn.name as name,
           evr_t_as_vre_simple(pevr.evr) as vre,
           pa.label as arch
      from rhnPackage p,
           rhnPackageName pn,
           rhnPackageEVR pevr,
           rhnPackageArch pa
     where p.id = :pid and
           p.name_id = pn.id and
           p.evr_id = pevr.id and
           p.package_arch_id = pa.id
"""

package_repodata_delete = """
    delete
          from rhnPackageRepoData
         where package_id = :pid
"""


def process_package_files():
    def parse_header(header):
        checksum_type = rhn_rpm.RPM_Header(header).checksum_type()
        return mpmSource.create_package(header, size=0,
                                        checksum_type=checksum_type, checksum=None, relpath=None,
                                        org_id=None, header_start=None, header_end=None, channels=[])

    package_name_h = rhnSQL.prepare(package_name_query)

    def package_name(pid):
        package_name_h.execute(pid=pid)
        r = package_name_h.fetchall_dict()[0]
        return "%s-%s.%s" % (r['name'], r['vre'], r['arch'])

    package_repodata_h = rhnSQL.prepare(package_repodata_delete)

    def delete_package_repodata(pid):
        package_repodata_h.execute(pid=pid)

    log = rhnLog('/var/log/rhn/update-packages.log', 5)

    package_query_h = rhnSQL.prepare(package_query)
    package_query_h.execute()

    package_capabilities_h = rhnSQL.prepare(package_capabilities)
    update_packagefile_checksum_h = rhnSQL.prepare(update_packagefile_checksum)
    insert_packagefile_h = rhnSQL.prepare(insert_packagefile)

    while (True):
        row = package_query_h.fetchone_dict()
        if not row:  # No more packages in DB to process
            break

        package_path = os.path.join(CFG.MOUNT_POINT, row['path'])

        if not os.path.exists(package_path):
            if debug:
                log.writeMessage("Package path '%s' does not exist." % package_path)
            continue

        # pylint: disable=W0703
        try:
            hdr = rhn_rpm.get_package_header(filename=package_path)
        except Exception:
            e = sys.exc_info()[1]
            message = "Error when reading package %s header: %s" % (package_path, e)
            if debug:
                log.writeMessage(message)
            continue

        pkg_updates = 0
        if row['filecount'] != len(hdr['filenames']):
            # Number of package files on disk and in the DB do not match
            # (possibly a bug #652852). We have to correct them one by one.
            package_capabilities_h.execute(pid=row['id'])
            pkg_caps = {}  # file-name : capabilities dictionary
            for cap in package_capabilities_h.fetchall_dict() or []:
                pkg_caps[cap['name']] = cap

            for f in parse_header(hdr)['files']:
                if f['name'] in pkg_caps:
                    continue  # The package files exists in the DB

                # Insert the missing package file into DB
                insert_packagefile_h.execute(pid=row['id'], name=f['name'],
                                             ctype=f['checksum_type'], csum=f['checksum'], device=f['device'],
                                             inode=f['inode'], file_mode=f['file_mode'], username=f['username'],
                                             groupname=f['groupname'], rdev=f['rdev'], file_size=f['file_size'],
                                             mtime=f['mtime'], linkto=f['linkto'], flags=f['flags'],
                                             verifyflags=f['verifyflags'], lang=f['lang'])
                pkg_updates += 1

            if debug and pkg_updates:
                log.writeMessage("Package id: %s, name: %s, %s files inserted" %
                                 (row['id'], package_name(row['id']), pkg_updates))
        elif row['nonnullcsums'] == 0:
            # All package files in the DB have null checksum (possibly a bug #659348)
            package_capabilities_h.execute(pid=row['id'])
            pkg_caps = {}  # file-name : capabilities dictionary
            for cap in package_capabilities_h.fetchall_dict() or []:
                pkg_caps[cap['name']] = cap

            for f in parse_header(hdr)['files']:
                if f['checksum'] == '':  # Convert empty string (symlinks) to None to match w/ Oracle returns
                    f['checksum'] = None

                caps = pkg_caps[f['name']]

                if not caps['checksum'] == f['checksum']:
                    # Package file exists, but its checksum in the DB is incorrect
                    update_packagefile_checksum_h.execute(ctype=f['checksum_type'], csum=f['checksum'],
                                                          pid=caps['package_id'], cid=caps['capability_id'])
                    pkg_updates += 1

            if debug and pkg_updates:
                log.writeMessage("Package id: %s, name: %s, %s checksums updated" %
                                 (row['id'], package_name(row['id']), pkg_updates))

        if pkg_updates:
            log.writeMessage("Package id: %s, purging rhnPackageRepoData" % row['id'])
            delete_package_repodata(row['id'])

        rhnSQL.commit()  # End of a package


def process_changelog():
    def convert(u):
        last = ''
        while u != last:
            last = u
            try:
                u = last.encode('iso8859-1').decode('utf8')
            except (UnicodeDecodeError, UnicodeEncodeError):
                e = sys.exc_info()[1]
                if e.reason == 'unexpected end of data':
                    u = u[:-1]
                    continue
                else:
                    break
        return u

    if CFG.db_backend == 'postgresql':
        lengthb = "octet_length(%s)"
    else:
        lengthb = "lengthb(%s)"
    _non_ascii_changelog_data_count = """select count(*) as cnt from rhnpackagechangelogdata
                                          where length(name) <> %s
                                             or length(text) <> %s
        """ % (lengthb % 'name', lengthb % 'text')
    _non_ascii_changelog_data = """select * from rhnpackagechangelogdata
                                    where length(name) <> %s
                                       or length(text) <> %s
        """ % (lengthb % 'name', lengthb % 'text')
    _update_changelog_data_name = """update rhnpackagechangelogdata set name = :name
                                           where id = :id"""
    _update_changelog_data_text = """update rhnpackagechangelogdata set text = :text
                                           where id = :id"""
    if debug:
        log = rhnLog('/var/log/rhn/update-packages.log', 5)

    query_count = rhnSQL.prepare(_non_ascii_changelog_data_count)
    query_count.execute()
    nrows = query_count.fetchall_dict()[0]['cnt']

    query = rhnSQL.prepare(_non_ascii_changelog_data)
    query.execute()

    if nrows == 0:
        msg = "No non-ASCII changelog entries to process."
        print(msg)
        if debug:
            log.writeMessage(msg)
        return

    if verbose:
        print("Processing %s non-ASCII changelog entries" % nrows)

    pb = ProgressBar(prompt='standby: ', endTag=' - Complete!',
                     finalSize=nrows, finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)

    update_name = rhnSQL.prepare(_update_changelog_data_name)
    update_text = rhnSQL.prepare(_update_changelog_data_text)

    while (True):
        row = query.fetchone_dict()
        if not row:  # No more packages in DB to process
            break

        pb.addTo(1)
        pb.printIncrement()

        name_u = row['name'].decode('utf8', 'ignore')
        name_fixed = name_u
        if len(row['name']) != len(name_u):
            name_fixed = convert(name_u)
        if name_fixed != name_u:
            if debug and verbose:
                log.writeMessage("Fixing record %s: name: '%s'" % (row['id'], row['name']))
            update_name.execute(id=row['id'], name=name_fixed)

        text_u = row['text'].decode('utf8', 'ignore')
        text_fixed = text_u
        if len(row['text']) != len(text_u):
            text_fixed = convert(text_u)
        if text_fixed != text_u:
            if debug and verbose:
                log.writeMessage("Fixing record %s: text: '%s'" % (row['id'], row['text']))
            update_text.execute(id=row['id'], text=text_fixed)

        rhnSQL.commit()

    pb.printComplete()


if __name__ == '__main__':
    main()
