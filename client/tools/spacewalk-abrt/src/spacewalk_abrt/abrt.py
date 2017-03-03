#!/usr/bin/python
#
# Copyright (c) 2013--2016 Red Hat, Inc.
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

import base64
import os
import sys
import errno
from rhn.i18n import bstr

RHNROOT = '/usr/share/rhn'
if RHNROOT not in sys.path:
    sys.path.append(RHNROOT)

import gettext
t = gettext.translation('spacewalk-abrt', fallback=True)
_ = t.ugettext

from up2date_client import config
from up2date_client import up2dateAuth
from up2date_client import rhnserver
from up2date_client import up2dateLog


def _readline(filepath):
    firstline = None
    try:
        f = open(filepath, 'r')
        firstline = f.readline().strip()
        f.close()
    except IOError:
        e = sys.exc_info()[1]
        if e.errno == errno.ENOENT:
            pass
        else:
            raise
    return firstline


def _get_abrt_dir():
    abrt_dir = '/var/tmp/abrt'
    for directory in ['/var/tmp/abrt', '/var/spool/abrt']:
        if os.path.exists(directory) and os.path.isdir(directory):
            abrt_dir = directory

    cf = config.ConfigFile('/etc/abrt/abrt.conf')
    return cf['DumpLocation'] or abrt_dir


def report(problem_dir):
    problem_dir = os.path.normpath(os.path.abspath(problem_dir))
    basename = os.path.basename(problem_dir)
    log = up2dateLog.initLog()
    if not (os.path.exists(problem_dir) and os.path.isdir(problem_dir)):
        log.log_me("The specified path [%s] is not a valid directory." % problem_dir)
        return -1

    crash_items = ['analyzer', 'cmdline', 'reason']
    if os.path.exists(os.path.join(problem_dir, 'vmcore')):
        crash_items = ['analyzer', 'vmcore-dmesg.txt']

    for item in crash_items:
        item_path = os.path.join(problem_dir, item)
        if not os.path.exists(item_path):
            log.log_me("Crash directory [%s] is incomplete or invalid" % problem_dir)
            return -1

    server = rhnserver.RhnServer()
    if not server.capabilities.hasCapability('abrt'):
        return -1

    systemid = up2dateAuth.getSystemId()

    # Package information
    pkg_data = {}
    for item in ['package', 'pkg_name', 'pkg_epoch', 'pkg_version', 'pkg_release', 'pkg_arch']:
        pkg_item_path = os.path.join(problem_dir, item)
        if os.path.exists(pkg_item_path):
            filecontent = _readline(pkg_item_path)

            if filecontent:
                pkg_data[item] = filecontent

    # Crash information
    crash_data = {'crash': basename, 'path': problem_dir}
    # Crash count
    crash_count = _readline(os.path.join(problem_dir, 'count'))
    if crash_count:
        crash_data['count'] = crash_count

    # Create record about the crash
    r = server.abrt.create_crash(systemid, crash_data, pkg_data)

    if (r < 0):  # Error creating new crash report
        log.log_me("Error creating new crash report.")
        return -1

    # Upload every particular file in the problem directory to the server
    for i in os.listdir(problem_dir):
        path = os.path.join(problem_dir, i)
        if not os.path.isfile(path):
            continue

        filesize = os.stat(path).st_size

        crash_file_data = {'filename': os.path.basename(i),
                           'path': path,
                           'filesize': filesize,
                           'filecontent': base64.encodestring(bstr("")),
                           'content-encoding': 'base64'}
        if server.abrt.is_crashfile_upload_enabled(systemid) and filesize <= server.abrt.get_crashfile_uploadlimit(systemid):
            f = open(path, 'r')
            try:
                crash_file_data['filecontent'] = base64.encodestring(bstr(f.read()))
            finally:
                f.close()

        server.abrt.upload_crash_file(systemid, basename, crash_file_data)

    return 1


def update_count(problem_dir):
    problem_dir = os.path.normpath(os.path.abspath(problem_dir))
    basename = os.path.basename(problem_dir)
    log = up2dateLog.initLog()
    if not (os.path.exists(problem_dir) and os.path.isdir(problem_dir)):
        log.log_me("The specified path [%s] is not a valid directory." % problem_dir)
        return -1

    server = rhnserver.RhnServer()
    if not server.capabilities.hasCapability('abrt'):
        return -1

    systemid = up2dateAuth.getSystemId()
    crash_count_path = os.path.join(problem_dir, 'count')
    if not (os.path.exists(crash_count_path) and os.path.isfile(crash_count_path)):
        log.log_me("The problem directory [%s] does not contain any crash count information." % problem_dir)
        return 0

    crash_count = _readline(crash_count_path)
    server.abrt.update_crash_count(systemid, basename, crash_count)

    return 1


def sync():
    abrt_dir = os.path.normpath(_get_abrt_dir())
    if not (os.path.exists(abrt_dir) and os.path.isdir(abrt_dir)):
        log.log_me("The specified path [%s] is not a valid directory." % abrt_dir)
        return -1

    for i in os.listdir(abrt_dir):
        problem_dir = os.path.join(abrt_dir, i)
        if not os.path.isdir(problem_dir):
            continue

        report(problem_dir)

    return 1
