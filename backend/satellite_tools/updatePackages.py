#!/usr/bin/python
#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import time
import shutil

sys.path.append('/usr/share/rhn')

from optparse import Option, OptionParser
from common import rhnLib, rhnLog, initLOG, CFG, initCFG
from spacewalk.common import rhn_rpm
from server.rhnLib import parseRPMFilename, get_package_path
from server import rhnSQL, rhnPackageUpload
from server.rhnServer import server_packages
from satellite_tools.progress_bar import ProgressBar
from spacewalk.common.checksum import getFileChecksum

initCFG('server.satellite')
initLOG(CFG.LOG_FILE, CFG.DEBUG)

OPTIONS = None
debug = 0
verbose = 0

options_table = [
    Option("--update-sha256", action="store_true",
        help="Update SHA-256 capable packages"),
    Option("--update-filer", action="store_true",
        help="Convert filer structure"),
    Option("--update-kstrees", action="store_true",
        help="Fix kickstart trees permissions"),
    Option("-d", "--db", action="store", help="DB string to connect to"),
    Option("-v", "--verbose", action="count",
        help="Increase verbosity"),
    Option("--debug", action="store_true",
        help="Log the debug information to a log file"),
]


def main():
    global options_table, debug, verbose
    parser = OptionParser(option_list=options_table)

    (options, args) = parser.parse_args()

    if args:
        for arg in args:
            sys.stderr.write("Not a valid option ('%s'), try --help\n" % arg)
        sys.exit(-1)

    if options.verbose:
        verbose = 1

    if options.debug:
        debug = 1

    if not options.db:
        sys.stderr.write("--db not specified\n")
        sys.exit(1)

    print "Connecting to %s" % options.db
    rhnSQL.initDB(options.db)

    if options.update_filer:
        process_package_data()

    if options.update_sha256:
        process_sha256_packages()

    if options.update_kstrees:
        process_kickstart_trees()

_get_path_query = """
	select id, checksum_type, checksum, path, epoch, new_path
	from (
		select rhnPackage.id,
                       rhnChecksumView.checksum_type,
                       rhnChecksumView.checksum,
                       rhnPackage.path,
                       rhnPackageEvr.epoch,
			decode(rhnPackage.org_id, null, 'NULL', rhnPackage.org_id) || '/' || substr(rhnChecksumView.checksum, 1, 3)
			|| '/' || rhnPackageName.name
			|| '/' || decode(rhnPackageEvr.epoch, null, '', rhnPackageEvr.epoch || ':')
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
		)
	where '/' || new_path <> nvl(substr(path, -length(new_path) - 1), 'x')
"""

_update_pkg_path_query = """
    update rhnPackage
       set path =: new_path
    where id = :the_id
"""

def process_package_data():
    global verbose, debug

    if debug:
        Log = rhnLog.rhnLog('/var/log/rhn/update-packages.log', 5)

    _get_path_sql = rhnSQL.prepare(_get_path_query)
    _update_package_path = rhnSQL.prepare(_update_pkg_path_query)

    _get_path_sql.execute()
    paths = _get_path_sql.fetchall_dict()

    if not paths:
        # Nothing to change
        return
    if verbose: print "Processing %s packages" % len(paths)
    pb = ProgressBar(prompt='standby: ', endTag=' - Complete!', \
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
        try:
            nevra = parseRPMFilename(old_path_nvrea[-1])
            if nevra[1] in [ None, '']:
                nevra[1] = path['epoch']
        except:
            # probably not an rpm skip
            if debug:
                Log.writeMessage("Skipping: %s Not a valid rpm" \
                                  % old_path_nvrea[-1])
            continue
        old_abs_path = os.path.join(CFG.MOUNT_POINT, path['path'])

        checksum_type = path['checksum_type']
        checksum = path['checksum']
        new_path = get_package_path(nevra, org_id, prepend=old_path_nvrea[0],
                                    checksum=checksum)
        new_abs_path = os.path.join(CFG.MOUNT_POINT, new_path)

        bad_abs_path = os.path.join(CFG.MOUNT_POINT, \
                   get_package_path(nevra, org_id, prepend=old_path_nvrea[0],
                             omit_epoch = True, checksum=checksum))

        if not os.path.exists(old_abs_path):
            if os.path.exists(new_abs_path):
                new_ok_list.append(new_abs_path)
                if debug: Log.writeMessage("File %s already on final path %s" % (path['path'], new_abs_path))
                old_abs_path = new_abs_path
            elif os.path.exists(bad_abs_path):
                Log.writeMessage("File %s found on %s" % (path['path'], bad_abs_path))
                old_abs_path = bad_abs_path
            else:
                skip_list.append(old_abs_path)
                if debug: Log.writeMessage("Missing path %s for package %d" % ( old_abs_path, path['id']))
                continue

        try:
            hdr = rhn_rpm.get_package_header(filename=old_abs_path)
        except:
            rhnSQL.commit()
            raise

        if old_abs_path != new_abs_path:
            new_abs_dir = os.path.dirname(new_abs_path)
            # relocate the package on the filer
            if debug: Log.writeMessage("Relocating %s to %s on filer" \
                           % (old_abs_path, new_abs_path))
            if not os.path.isdir(new_abs_dir):
                os.makedirs(new_abs_dir)
            shutil.move(old_abs_path, new_abs_path)
            # Clean up left overs
            os.removedirs(os.path.dirname(old_abs_path))
            # make the path readable
            os.chmod(new_abs_path, 0644)

        # Update the db paths
        _update_package_path.execute(the_id= path['id'], \
                             new_path = new_path )
        if debug: Log.writeMessage("query Executed: update rhnPackage %d to %s" \
                               % ( path['id'], new_path ))
        # Process gpg key ids
        server_packages.processPackageKeyAssociations(hdr, checksum_type, checksum)
        if debug: Log.writeMessage("gpg key info updated from %s" % new_abs_path )
        i = i + 1
        # we need to break the transaction to smaller pieces
        if i % 1000 == 0:
            rhnSQL.commit()
    pb.printComplete()
    # All done, final commit
    rhnSQL.commit()
    sys.stderr.write("Transaction Committed! \n")
    if verbose: print " Skipping %s packages, paths not found" % len(skip_list)
    if len(new_ok_list) > 0 and verbose: print " There were %s packages found in the correct location" % len(new_ok_list)
    return

def process_kickstart_trees():
    for root,dirs,files in os.walk(CFG.MOUNT_POINT + "/rhn/"):
        for name in files:
            os.chmod(root + '/' + name, 0644)

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
            rhnChecksum_seq.nextval,
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
    global verbose, debug

    if debug:
        Log = rhnLog.rhnLog('/var/log/rhn/update-packages.log', 5)

    _get_sha256_packages_sql = rhnSQL.prepare(_get_sha256_packages_query)
    _get_sha256_packages_sql.execute()
    packages = _get_sha256_packages_sql.fetchall_dict()

    if not packages:
        print "No SHA256 capable packages to process."
        if debug:
            Log.writeMessage("No SHA256 capable packages to process.")

        return

    if verbose:
        print "Processing %s SHA256 capable packages" % len(packages)

    pb = ProgressBar(prompt='standby: ', endTag=' - Complete!', \
                     finalSize=len(packages), finalBarLength=40, stream=sys.stdout)
    pb.printAll(1)

    _update_sha256_package_sql = rhnSQL.prepare(_update_sha256_package)
    _update_package_files_sql = rhnSQL.prepare(_update_package_files)

    for package in packages:
        pb.addTo(1)
        pb.printIncrement()

        old_abs_path = os.path.join(CFG.MOUNT_POINT, package['path'])
        temp_file = open(old_abs_path, 'rb')
        header, payload_stream, header_start, header_end = \
                rhnPackageUpload.load_package(temp_file)
        checksum_type = header.checksum_type()
        checksum = getFileChecksum(checksum_type, file=temp_file)

        old_path = package['path'].split('/')
        nevra = parseRPMFilename(old_path[-1])
        org_id = old_path[1]
        new_path = get_package_path(nevra, org_id, prepend=old_path[0], checksum=checksum)
        new_abs_path = os.path.join(CFG.MOUNT_POINT, new_path)

        # Filer content relocation
        try:
            if old_abs_path != new_abs_path:
                if debug:
                    Log.writeMessage("Relocating %s to %s on filer" % (old_abs_path, new_abs_path))

                new_abs_dir = os.path.dirname(new_abs_path)
                if not os.path.isdir(new_abs_dir):
                    os.makedirs(new_abs_dir)

                # link() the old path to the new path
                if not os.path.exists(new_abs_path):
                    os.link(old_abs_path, new_abs_path)
                elif debug:
                    Log.writeMessage("File %s already exists" % new_abs_path)

                # Make the new path readable
                os.chmod(new_abs_path, 0644)
        except OSError, e:
            message = "Error when relocating %s to %s on filer: %s" % \
                      (old_abs_path, new_abs_path, str(e))
            print message
            if debug:
                Log.writeMessage(message)
            sys.exit(1)

        # Update package checksum in the database
        _update_sha256_package_sql.execute(ctype=checksum_type, csum=checksum,
                                           path=new_path, id=package['id'])

        _select_checksum_type_id_sql = rhnSQL.prepare(_select_checksum_type_id)
        _select_checksum_type_id_sql.execute(ctype=checksum_type)
        checksum_type_id =_select_checksum_type_id_sql.fetchone()[0]

        # Update checksum of every single file in a package
        for i, file in enumerate(header['filenames']):
            csum  = header['filemd5s'][i]

            # Do not update checksums for directories & links
            if not csum:
                continue

            _update_package_files_sql.execute(ctype_id=checksum_type_id, csum=csum,
                                              pid=package['id'], filename=file)

        rhnSQL.commit()

        try:
            if os.path.exists(old_abs_path):
                os.unlink(old_abs_path)
            if os.path.exists(os.path.dirname(old_abs_path)):
                os.removedirs(os.path.dirname(old_abs_path))
        except OSError, e:
            message = "Error when removing %s: %s" % (old_abs_path, str(e))
            print message
            if debug:
                Log.writeMessage(message)

            sys.exit(1)

    pb.printComplete()

if __name__ == '__main__':
    main()
