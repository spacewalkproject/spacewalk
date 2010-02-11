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
# Useful kickstart functions
#
# $Id: kickstart.py 111499 2007-02-21 19:19:01Z jbowes $

import os
import stat
import time
import types
import shutil
import string
import subprocess

from rhnkickstart import lilo
from rhnkickstart import common

from rhnkickstart.kickstart_exceptions import KickstartException

PREFIX      = ""
BOOT        = "/boot"
ELILO_BOOT  = "/boot/efi"
RHN_KS_DIR  = "rhn-kickstart"
SHADOW      = "/tmp/ks-tree-shadow"
LILO_CONF   = "/etc/lilo.conf"
GRUB_CONF   = "/boot/grub/grub.conf"
ELILO_CONF  = "/boot/efi/efi/redhat/elilo.conf"
YABOOT_CONF = "/etc/yaboot.conf"
ZIPL_CONF   = "/etc/zipl.conf"

def initiate(base, extra_append, static_device=None, preserve_files=[]):
    # XXX it's bad to hardcode each special case, but this is the only one I 
    # can think of...
    if os.path.exists(ELILO_BOOT):
        base_dir = os.path.join(PREFIX, ELILO_BOOT, RHN_KS_DIR, base)
    else:
        base_dir = os.path.join(PREFIX, BOOT, RHN_KS_DIR, base)

    try:
        # First, download the kickstart file.
        kickstart_config = common.download_kickstart_file(extra_append)

        # This hack sucks, but it works around a race condition dealing with
        # the tiny url generation on the server.  Basically, if we request
        # the download images too soon after receiving the ks config file, we
        # are served a 404.  We'll remove this hack when we figure out what the
        # server-side issue is.
        time.sleep(5)

        # Download the kernel and initrd images.
        if os.path.exists(ZIPL_CONF):
            pxe_dir = "images"
        else:
            pxe_dir = "images/pxeboot"

        (kernel, initrd) = \
            common.download_install_images(kickstart_config, pxe_dir,
                base_dir)
    except KickstartException, e:
        return (15, str(e), {})

    # cleanup previous attempt
    rm_rf(SHADOW)
    os.mkdir(SHADOW)
   
    if static_device:
        extra_append, error = local_network_kickstart(extra_append,
                kickstart_config, static_device, initrd, preserve_files)
        if error is not None:
            return error
        initrd = initrd + ".merged"
    elif preserve_files:
        ret = create_new_rd(initrd, preserve_files)
        if ret:
            # Error
            return ret
        initrd = initrd + ".merged"
    
    # XXX hardcoding the ramdisk_size is potentially bad, and
    # should be dynamic based on the size of the uncompressed new initrd 
    if os.path.exists(ZIPL_CONF):
        append = ["ip=off", "root=/dev/ram0", "ramdisk_size=40000", "ro", "RUNKS=1"]
    else:
        append = ["lang=", "devfs=nomount", "ramdisk_size=16438"]
    if extra_append:
        append.append(extra_append)
    append = string.join(append)

    error_messages = {}

    success = 0

    if os.path.exists(GRUB_CONF):
        # the boolean logic marks success to '1' if function call suceeds
        success = _modify_grub_conf(base, kernel, initrd, append, error_messages) or success 

    if os.path.exists(LILO_CONF):
        success = _modify_lilo_conf(base, kernel, initrd, append, error_messages) or success 

    if os.path.exists(YABOOT_CONF):
        success = _modify_yaboot_conf(base, kernel, initrd, append, error_messages) or success

    if os.path.exists(ELILO_CONF):
        success = _modify_elilo_conf(base, kernel, initrd, append, error_messages) or success

    if os.path.exists(ZIPL_CONF):
        success = _modify_s390(base, kernel, initrd, append, error_messages) or success

    if not success:
        return (10, "Kickstart initiate failed: failed to install bootloaders", 
            error_messages)

    return (0, "Kickstart initiate succeeded", error_messages)

def _modify_grub_conf(base, vmlinuz, initrd, append, error_messages):
    """
    modify the configuration file for the grub bootloader
    returns '1' on success, '0' on failure
    """

    bootloader_args = [
        "/sbin/grubby",
        "--config-file", GRUB_CONF,
        "--add-kernel", vmlinuz,
        "--remove-kernel", vmlinuz,
        "--initrd", initrd,
        "--title", os.path.basename(base),
        "--make-default",
        "--args", append,
    ]
    exit_code, stdout, stderr = my_popen(bootloader_args)
    if exit_code:
        err = {
            'command'   : string.join(bootloader_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['grub'] = err
        return 0

    return 1

def _modify_lilo_conf(base, vmlinuz, initrd, append, error_messages):
    """
    modify the configuration file for the lilo bootloader
    returns '1' on success, '0' on failure
    """
    
    label = "kickstart"

    add_to_lilo(label=label, vmlinuz=vmlinuz, initrd=initrd, append=append, lilo_conf=LILO_CONF)
    bootloader_args = [
        "/sbin/lilo", 
        "-C", LILO_CONF, 
    ]
    exit_code, stdout, stderr = my_popen(bootloader_args)
    if exit_code:
        err = {
            'command'   : string.join(bootloader_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['lilo'] = err
        return 0

    return 1

def _modify_yaboot_conf(base, vmlinuz, initrd, append, error_messages):
    """
    modify the configuration file for the grub bootloader
    returns '1' on success, '0' on failure
    """

    bootloader_args = [
        "/sbin/grubby",
        "--yaboot",
        "--config-file", YABOOT_CONF,
        "--add-kernel", vmlinuz,
        "--initrd", initrd,
        "--title", os.path.basename(base),
        "--make-default",
        "--args", append,
    ]
    exit_code, stdout, stderr = my_popen(bootloader_args)
    if exit_code:
        err = {
            'command'   : string.join(bootloader_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['yaboot'] = err
        return 0

    return 1

def _modify_elilo_conf(base, vmlinuz, initrd, append, error_messages):
    """
    modify the configuration file for the elilo bootloader
    returns '1' on success, '0' on failure
    """

    # XXX ugly hack to work around required relative path for elilo
    e_vmlinuz = string.replace(vmlinuz, '/boot/efi', '../..', 1)
    e_initrd  = string.replace(initrd, '/boot/efi', '../..', 1)
    
    # this works for elilo as well: for rhel2.1
    # XXX the problem with this approach is that there is *no* error checking, 
    # so we won't know about a failure until it's too late
    label = "kickstart"
    add_to_lilo(label=label, vmlinuz=e_vmlinuz, initrd=e_initrd, append=append, lilo_conf=ELILO_CONF)

    return 1

def add_to_lilo(label, vmlinuz, initrd, append, lilo_conf='/etc/lilo.conf'):
    config = lilo.LiloConfigFile()
    config.read(lilo_conf)

    if label in config.listImages():
        config.delImage(label)

    sl = lilo.LiloConfigFile(imageType="image", path=vmlinuz)
    sl.addEntry("label", label)
    sl.addEntry("initrd", initrd)
    if append:
        sl.addEntry("append", '"%s"' % append)

    config.addImage(sl)
    config.addEntry("default", label)
    config.write(lilo_conf)

def _modify_s390(base, vmlinuz, initrd, append, error_messages):
    """
    prepare files for s390 install
    returns '1' on success, '0' on failure
    """

    # Buid parm file from kernel parameters in append.
    # There is a maximum of 32 parameters.
    parmfn = os.path.join(PREFIX, BOOT, RHN_KS_DIR, "user.parm")    
    if os.path.exists(parmfn):
        os.unlink(parmfn)
    parmfd = os.open(parmfn, os.O_CREAT | os.O_WRONLY)
    parmdata = string.split(append, maxsplit=31)

    # Write kernel parameters to a file.  Max 80 characters per line.
    line_position = 0
    for item in parmdata:
        if len(item) >= 80:
            continue
        elif (line_position + len(item)) >= 80:
            # Start a new line
            os.write(parmfd, "\n")
            line_position = 0
        os.write(parmfd, item)
        os.write(parmfd, " ")
        line_position += len(item) + 1
    os.write(parmfd, "\n")
    os.close(parmfd)

    # Load z/VM unit record module.  This was added to RHEL 5.2,
    # so this is a hard requirement.  This also requires that the guest
    # is running under z/VM, not natively in an LPAR.
    cmd_args = [
        "/sbin/modprobe",
        "vmur",
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Next, load vmcp, so we can run hipervisor commands directly.
    cmd_args = [
        "/sbin/modprobe",
        "vmcp",
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Bring the virtual reader and virtual punch devices online.
    cmd_args = [
        "/sbin/chccwdev",
        "-e",
        "000c", "000d",
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Clear the reader
    cmd_args = [
        "/sbin/vmur",
        "purge", "-f",
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Punch the kernel
    cmd_args = [
        "/sbin/vmur",
        "punch", "-r",
        "--name", "KERNEL.IMG",
        vmlinuz,
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Punch the parm file
    cmd_args = [
        "/sbin/vmur",
        "punch", "-t", "-r",
        "--name", "USER.PARM",
        parmfn,
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Punch the initrd
    cmd_args = [
        "/sbin/vmur",
        "punch", "-r",
        "--name", "INITRD.IMG",
        initrd,
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Set all files to "keep" on reader
    cmd_args = [
        "/sbin/vmcp",
        "change", "reader",
        "all", "keep",
    ]
    exit_code, stdout, stderr = my_popen(cmd_args)
    if exit_code:
        err = {
            'command'   : string.join(cmd_args),
            'exit_code' : exit_code,
            'stdout'    : stdout.read(),
            'stderr'    : stderr.read(),
        }
        error_messages['s390'] = err
        return 0

    # Set system to reboot from virtual reader (address 000c)
    reiplfd = os.open("/sys/firmware/reipl/reipl_type", os.O_WRONLY)
    os.write(reiplfd, "ccw")
    os.close(reiplfd)

    reiplfd_ccw = os.open("/sys/firmware/reipl/ccw/device", os.O_WRONLY)
    os.write(reiplfd_ccw, "0.0.000c")
    os.close(reiplfd_ccw)

    return 1


def my_popen(cmd):
    c = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, close_fds=True,
                         bufsize=-1)
    c.stdin.close()
    while 1:
        status = c.poll()
        if status is not None:
            # Save the exit code, we still have to read from
            # the pipes
            return status, c.stdout, c.stderr

def local_network_kickstart(extra_append, ks_data, static_device, initrd, preserve_files=[]):
    """
    Returns  a tuple (append_string, error)
    where error is a tuple (error_code, error_string, dict)
    """
    match = common.extract_kickstart_url(extra_append)
    if not match:
        return None, (15, "Error extracting kickstart url", {})

    if not os.access(SHADOW, os.F_OK):
        os.mkdir(SHADOW, 0700)
    
    ks_file = SHADOW + "/" + "ks.cfg"
    f = open(ks_file, "w")
    f.write(ks_data)
    f.close()

    if static_device:
        (status, stdout, stderr) = my_popen([
            "/usr/sbin/mangle-kickstart-network.sh",
            ks_file, static_device])
        if status:
            return None, (15, "Unable to create network kickstart",
                _build_error(status, stdout, stderr))
    
    ret = create_new_rd(initrd, preserve_files)
    if ret:
        # Error
        return None, ret
        
    extra_append = "%s%s%s" % (extra_append[:match.start(1)], "ks=file:/ks.cfg", extra_append[match.end(1):])
    
    return extra_append, None


def create_new_rd(initrd, preserve_files=[]):
    """
    Returns None if everything went well, or a tuple 
    (err_code, err_string, dict) if problems were found
    """
    if not initrd:
	return (3, "Kickstart create new init failed: initrd not found: %s" %
            initrd, {})

    if preserve_files:
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
        "/usr/sbin/merge-rd.sh", initrd, initrd + ".merged", SHADOW])
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


def _build_error(status, stdout, stderr):
    params = {
        'status'    : status,
        'stdout'    : stdout.read(),
        'stderr'    : stderr.read(),
    }
    return params
    


class QuotaExceeded(Exception):
    pass


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
