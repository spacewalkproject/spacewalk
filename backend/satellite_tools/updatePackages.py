#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
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
from common import rhnLib, rhnLog, rhn_rpm, initLOG, CFG, initCFG
from server.rhnLib import parseRPMFilename
from server import rhnSQL
from server.rhnServer import server_packages
from satellite_tools.progress_bar import ProgressBar

initCFG('server.satellite')
initLOG(CFG.LOG_FILE, CFG.DEBUG)

OPTIONS = None
debug = 0
verbose = 0

options_table = [
    Option("-v", "--verbose",       action="count",
        help="Increase verbosity"),
    Option("-d", "--db",            action="store",
        help="DB string to connect to"),
    Option(   "--debug",            action="store_true",
        help="logs the debug information to a log file"),
]


def main():
    global options_table, debug
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

    process_package_data()

    process_kickstart_trees()

def get_new_pkg_path(nvrea, org_id, prepend="", omit_epoch=None,
        package_type='rpm', md5sum=None):
    name = nvrea[0]
    release = nvrea[2]

    # dirarch and pkgarch are special-cased for source rpms
    dirarch = pkgarch = nvrea[4]

    if org_id in ['', None]:
        org = "NULL"
    else:
        org = org_id

    version = nvrea[1]
    if not omit_epoch:
        epoch = nvrea[3]
        if epoch not in [None, '']:
            version = str(epoch) + ':' + version
    # normpath sanitizes the path (removing duplicated / and such)
    template = os.path.normpath(prepend +
                               "/%s/%s/%s/%s-%s/%s/%s/%s-%s-%s.%s.%s")
    return template % (org, md5sum[:3], name, version, release, dirarch, md5sum,
        name, nvrea[1], release, pkgarch, package_type)


_get_path_query = """
	select rhnPackage.md5sum, rhnPackage.path, rhnPackageEvr.epoch
	from rhnPackage, rhnPackageEvr
	where rhnPackage.path not like '%'||rhnPackage.MD5SUM||'%'
		and rhnPackage.evr_id = rhnPackageEvr.id
"""

_update_pkg_path_query = """
    update rhnPackage
       set path =: new_path
    where path =: old_path
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
    i = 0
    for path in paths:
        pb.addTo(1)
        time.sleep(0.005)
        pb.printIncrement()
        old_path_nvrea = path['path'].split('/')
        org_id = old_path_nvrea[1]
        try:
            nvrea = parseRPMFilename(old_path_nvrea[-1])
            if nvrea[3] in [ None, '']:
                nvrea[3] = path['epoch']
        except:
            # probably not qan rpm skip
            if debug:
                Log.writeMessage("Skipping: %s Not a valid rpm" \
                                  % old_path_nvrea[-1])
            continue
        old_abs_path = os.path.join(CFG.MOUNT_POINT, path['path'])

        if not os.path.exists(old_abs_path):
            skip_list.append(old_abs_path)
            if debug: Log.writeMessage("Missing Path: %s" % old_abs_path)
            continue
        md5sum = path['md5sum']

        try:
            #hdr = get_package_info(old_abs_path)
            hdr = rhn_rpm.get_package_header(filename=old_abs_path)
        except IOError:
            raise
        new_path = get_new_pkg_path(nvrea, org_id, old_path_nvrea[0], \
                                    md5sum=md5sum)
        new_abs_path = os.path.join(CFG.MOUNT_POINT, new_path)
        new_abs_dir = os.path.dirname(new_abs_path)
        # relocate the package on the filer
        if not os.path.isdir(new_abs_dir):
            os.makedirs(new_abs_dir)
        shutil.move(old_abs_path, new_abs_path)
        # Clean up left overs
        os.removedirs(os.path.dirname(old_abs_path))
        # make the path readable
        os.chmod(new_abs_path, 0644)
        if debug: Log.writeMessage("Relocated %s to %s on filer" \
                           % (old_abs_path, new_abs_path))
        # Update the db paths
        _update_package_path.execute(old_path= path['path'], \
                             new_path = new_path )
        if debug: Log.writeMessage("query Executed: %s" \
                               %  _update_pkg_path_query )
        # Process gpg key ids
        server_packages.processPackageKeyAssociations(hdr, md5sum)
        if debug: Log.writeMessage("gpg key info updated" )
        i = i + 1
        # we need to break the transaction to smaller pieces
        if i % 1000 == 0:
            rhnSQL.commit()
    pb.printComplete()
    # All done, final commit
    rhnSQL.commit()
    sys.stderr.write("Transaction Committed! \n")
    if verbose: print " Skipping %s packages, paths not found" % len(skip_list)
    return

def process_kickstart_trees():
    for root,dirs,files in os.walk(CFG.MOUNT_POINT + "/rhn/"):
        for name in files:
            os.chmod(root + '/' + name, 0644)


if __name__ == '__main__':
    main()

