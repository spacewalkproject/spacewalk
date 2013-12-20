#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
# Kickstart a system using koan.
#

import traceback
import stat
import string
import shutil
import sys
import types
import os
import os.path
import tempfile
import xmlrpclib
import pprint
from koan.app import Koan

SHADOW      = "/tmp/ks-tree-shadow"

def execute(cmd):
    tmp = tempfile.mktemp()
    status = os.system(cmd + " > " + tmp)
    data = open(tmp).readlines()
    ret = []
    for l in data:
        ret.append(string.strip(l))
    if status == 0:
        return ret
    msg = """Error executing command:\n %s\noutput:\n%s"""
    raise Exception(msg % (cmd, string.join(response,"\n")))

def find_host_name():
    return execute("hostname")[0]

def find_netmask(device):
    nm = execute("LANG=C ipcalc -4ms $(ip -4 -o addr show dev %s | awk '{print $4}')|awk -F= '{print $2}'" % device)
    if nm:
        return nm[0]
    else:
        return ""

def find_netmask6(device):
    nm6 = execute("LANG=C ip -6 -o addr show dev %s | perl -lne 'print $1 if m!/(.+) scope global!'" % device)
    if nm6:
        return nm6[0]
    else:
        return ""

def find_ip(device):
    ip = execute("LANG=C ip -4 -o addr show dev %s | perl -lne 'print $1 if m!.+\s(.+)/.+ scope global!'" % device)
    if ip:
        return ip[0]
    else:
        return ""

def find_ip6(device):
    ip6 = execute("LANG=C ip -6 -o addr show dev %s | perl -lne 'print $1 if m!.+\s(.+)/.+ scope global!'" % device)
    if ip6:
        return ip6[0]
    else:
        return ""

def find_name_servers():
    servers = execute("cat /etc/resolv.conf | perl -lne '/^nameserver\s+(\S+)/ and print $1'")
    ret = []
    for s in servers:
        if s not in ("127.0.0.1", "::1"):
            ret.append(s)
    return ret

def find_gateway(device):
    response = execute("ip -f inet route list dev %s|awk '/^default/ {print $3}'" % device)
    if response:
        return response[0]
    else:
        return ""

def find_gateway6(device):
    response = execute("ip -f inet6 route list dev %s|awk '/^default/ {print $3}'" % device)
    if response:
        return response[0]
    else:
        return ""

def getSystemId():
    path = "/etc/sysconfig/rhn/systemid"
    if not os.access(path, os.R_OK):
        return None
    return open(path, "r").read()

def update_static_device_records(kickstart_host, static_device):
    client = xmlrpclib.Server("https://" + kickstart_host + "/rpc/api")
    data = {"gateway" : find_gateway(static_device),\
            "nameservers": find_name_servers(),\
            "hostname" : find_host_name(),\
            "device" :  static_device,\
            "ip": find_ip(static_device),\
            "netmask" : find_netmask(static_device)}

    data6 = {"gateway" : find_gateway6(static_device), \
             "device" : static_device, \
             "ip" : find_ip6(static_device), \
             "netmask" : find_netmask6(static_device)}

    api_version = client.api.get_version()

    # Since api_version >= 11.1 we support setup_static_network with IPv6 data
    if float(api_version) <= 11.00:
        client.system.setup_static_network(getSystemId(), data)
    else:
        client.system.setup_static_network(getSystemId(), data, data6)

def initiate(kickstart_host, base, extra_append, static_device=None, system_record="", preserve_files=[]):

    error_messages = {}
    success = 0

    # cleanup previous attempt
    rm_rf(SHADOW)
    os.mkdir(SHADOW)

    print "Preserve files! : %s"  % preserve_files

    try:
        if static_device:
            update_static_device_records(kickstart_host, static_device)

        k = Koan()
        k.list_items          = 0
        k.server              = kickstart_host
        k.is_virt             = 0
        k.is_replace          = 1
        k.is_display          = 0
        k.profile             = None

        if system_record != "":
           k.system          = system_record
        else:
           k.system          = None
        k.port                = 443
        k.image               = None
        k.live_cd             = None
        k.virt_path           = None
        k.virt_type           = None
        k.virt_bridge         = None
        k.no_gfx              = 1
        k.add_reinstall_entry = None
        k.kopts_override      = None
        k.use_kexec           = None
        k.embed_kickstart     =  None
        if hasattr(k, 'no_copy_default'):
            k.no_copy_default = 1
        else: # older koan
            k.grubby_copy_default = 0
        if static_device:
            k.embed_kickstart = 1
        k.run()

    except Exception, e:
        (xa, xb, tb) = sys.exc_info()
        try:
            getattr(e,"from_koan")
            error_messages['koan'] = str(e)[1:-1]
            print str(e)[1:-1] # nice exception, no traceback needed
        except:
            print xa
            print xb
            print string.join(traceback.format_list(traceback.extract_tb(tb)))
            error_messages['koan'] = string.join(traceback.format_list(traceback.extract_tb(tb)))
        return (1, "Kickstart failed. Koan error.", error_messages)

    # Now process preserve_files if there are any
    initrd = '/boot/initrd.img'
    if preserve_files:
        ret = create_new_rd(initrd, preserve_files)
        if ret:
            # Error
            return ret
        initrd = initrd + ".merged"



    return (0, "Kickstart initiate succeeded", error_messages)


class VirtDiskPathExistsError(Exception):
    def __init__(self, disk_path):
        self.value = disk_path
    def __str__(self):
        return "Virt Disk Path %s already exists on the host system. Please provide another disk path for the virt guest and reschedule your guest kickstart." % self.value


class BlockDeviceNonexistentError(Exception):
    def __init__(self, device_path):
        self.value = device_path
    def __str__(self):
        return "Block Device Path %s does not exist on the host system. Please create the device for the virtual guest and reschedule your guest kickstart." % self.value


def initiate_guest(kickstart_host, cobbler_system_name, virt_type, name, mem_kb,
                   vcpus, disk_gb, virt_bridge, disk_path, extra_append, log_notify_handler=None):

    error_messages = {}
    success = 0
    try:
        if disk_path.startswith('/dev/'):
            if not os.path.exists(disk_path):
               raise BlockDeviceNonexistentError(disk_path)
        else:
            if os.path.exists(disk_path):
                raise VirtDiskPathExistsError(disk_path)
        k = Koan()
        k.list_items          = 0
        k.server              = kickstart_host
        k.is_virt             = 1
        k.is_replace          = 0
        k.is_display          = 0
        k.port                = 443
        k.profile             = None
        k.system              = cobbler_system_name
        k.should_poll         = 1
        k.image               = None
        k.live_cd             = None
        k.virt_name           = name
        k.virt_path           = disk_path
        k.virt_type           = virt_type
        k.virt_bridge         = virt_bridge
        k.no_gfx              = 1
        k.add_reinstall_entry = None
        k.kopts_override      = None
        k.virt_auto_boot      = None
        if hasattr(k, 'no_copy_default'):
            k.no_copy_default = 1
        else: # older koan
            k.grubby_copy_default = 0
        k.run()

        # refresh current virtualization state on the server
        import virtualization.support
        virtualization.support.refresh()
    except Exception, e:
        (xa, xb, tb) = sys.exc_info()
        if str(xb).startswith("The MAC address you entered is already in use"):
            # I really wish there was a better way to check for this
            error_messages['koan'] = str(xb)
            print str(xb)
        elif  hasattr(e,"from_koan") and len(str(e)) > 1:
            error_messages['koan'] = str(e)[1:-1]
            print str(e)[1:-1] # nice exception, no traceback needed
        else:
            print xa
            print xb
            print string.join(traceback.format_list(traceback.extract_tb(tb)))
            error_messages['koan'] = str(xb) + ' ' + string.join(traceback.format_list(traceback.extract_tb(tb)))
        return (1, "Virtual kickstart failed. Koan error.", error_messages)

    return (0, "Virtual kickstart initiate succeeded", error_messages)

def create_new_rd(initrd, preserve_files=[]):
    """
    Returns None if everything went well, or a tuple
    (err_code, err_string, dict) if problems were found
    """
    if not initrd:
        return (3, "Kickstart create new init failed: initrd not found: %s" %
            initrd, {})

    # quota should be configurable from the UI
    quota = 1000000
    # lame naming below to use /tmp/ks-tres-shadow 2X
    # but needed to get it here the ks.cfg expects it
    preserve_shadow = SHADOW + SHADOW
    # new FileCopier class handles the dirty work of getting the
    # preserved file set copied w/ all permissions, owners, etc
    # kept intact and in the correct location
    c = FileCopier(preserve_files, preserve_shadow, quota=quota)
    try:
        c.copy()
    except QuotaExceeded:
        return (3, "Quota of %s bytes exceeded" % quota, {})

    (status, stdout, stderr) = my_popen([
        "/usr/sbin/merge-rd.sh", initrd, initrd, SHADOW])
    if status:
        return (status, 'Error creating the new RAM disk',
            _build_error(status, stdout, stderr))

    return None


def rm_rf(path):
    "Equivalent of rm -rf"
    # We need to make sure path exists
    if os.path.islink(path):
        # Broken links will be reported as non-existent
        os.unlink(path)
        return
    # Now make sure path exists before we call the recursive function
    if os.path.exists(path):
        return _remove_func(path)


def _remove_func(path):
    "Recursive function for rm -rf; will fail if path doesn't exist"
    if not os.path.isdir(path):
        # Attempt to remove the file/link/etc
        os.unlink(path)
        return

    # It's a directory!
    files = os.listdir(path)
    # We need to add the path since listdir only returns a relative path
    files = map(lambda x, p=path: os.path.join(p, x), files)
    # Recursive call
    map(_remove_func, files)
    # After we remove everything from this directory we can also remove
    # the directory
    os.rmdir(path)
    return

def my_popen(cmd):
    print "CMD: %s " % cmd

    subproc = 1
    try:
        import subprocess
    except ImportError:
        #RHEL 4 (python 2.3) doesn't have subprocess
        import popen2
        subproc = 0

    if subproc:
        c = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                 stderr=subprocess.PIPE, close_fds=True, bufsize=-1)
        c.stdin.close()
        while 1:
            status = c.poll()
            if status is not None:
                # Save the exit code, we still have to read from
                # the pipes
                return status, c.stdout, c.stderr
    else:
        c = popen2.Popen3(cmd, capturestderr=1, bufsize=-1)
        c.tochild.close()

        while 1:
            status = c.poll()
            if os.WIFEXITED(status):
                # Save the exit code, we still have to read from
                # the pipes
                return os.WEXITSTATUS(status), c.fromchild, c.childerr

def _build_error(status, stdout, stderr):
    params = {
        'status'    : status,
        'stdout'    : stdout.read(),
        'stderr'    : stderr.read(),
    }
    return params


class FileCopier:
    """A class that copies a list of files/directories to the specified
    destination
    """
    def __init__(self, files, dest, quota=None):
        self.files = files
        self.dest = dest
        self.quota = quota
        self.current_quota = 0


    def copy(self):
        return self._copy(self.files)


    def _copy(self, files):
        assert(isinstance(files, types.ListType))
        for f in files:
            try:
                st = os.lstat(f)
            except OSError:
                # Ignore it
                continue

            st_mode = st[stat.ST_MODE]

            if stat.S_ISLNK(st_mode):
                self._copy_link(f, st)
            elif stat.S_ISDIR(st_mode):
                self._copy_dir(f, st)
            elif stat.S_ISREG(st_mode):
                self._copy_file(f, st)


    def _copy_file(self, f, st):
        # Check quota first
        file_size = st[stat.ST_SIZE]
        self._check_quota(f, file_size)
        self._create_dirs(f)

        # Now copy the file
        dest = self._build_dest(f)
        shutil.copy2(f, dest)
        self._copy_perms(dest, st)
        # Update space usage
        self._update_quota(f, file_size)


    def _check_quota(self, f, file_size):
        if not self.quota:
            return
        # Quota enabled
        if self.current_quota + file_size > self.quota:
            raise QuotaExceeded(f)


    def _update_quota(self, f, file_size):
        self.current_quota = self.current_quota + file_size


    def _create_dirs(self, f):
        dirname = os.path.dirname(f)
        self._copy_dir_modes(dirname, self.dest)


    def _copy_perms(self, dest, st):
        os.chmod(dest, st[stat.ST_MODE])
        os.chown(dest, st[stat.ST_UID], st[stat.ST_GID])
        os.utime(dest, (st[stat.ST_ATIME], st[stat.ST_MTIME]))


    def _copy_dir(self, f, st):
        files = map(lambda x, d=f: os.path.join(d, x), os.listdir(f))
        # Create this directory since it may be empty
        self._copy_dir_modes(f, self.dest)
        return self._copy(files)


    def _copy_link(self, f, st):
        file_size = st[stat.ST_SIZE]
        self._check_quota(f, file_size)
        deref_link = os.readlink(f)
        self._create_dirs(f)

        # Create the symlink
        dest = self._build_dest(f)
        os.symlink(deref_link, dest)

        self._update_quota(f, file_size)


    def _build_dest(self, f):
        return os.path.normpath(self.dest + f)


    def _copy_dir_modes(self, srcdir, dest):
        if not os.path.exists(dest):
            os.makedirs(dest)
        l = []
        srcdir = os.path.normpath(srcdir)
        while 1:
            h, t = os.path.split(srcdir)
            if not t:
                break
            l.append(t)
            srcdir = h

        l.reverse()
        dest_dir = dest
        src_dir = os.sep
        for d in l:
            src_dir = os.path.join(src_dir, d)
            src_st = os.lstat(src_dir)
            dest_dir = os.path.join(dest_dir, d)
            if not os.path.exists(dest_dir):
                os.mkdir(dest_dir)
            os.chmod(dest_dir, src_st[stat.ST_MODE])
            os.chown(dest_dir, src_st[stat.ST_UID], src_st[stat.ST_GID])

class QuotaExceeded(Exception):
    pass
