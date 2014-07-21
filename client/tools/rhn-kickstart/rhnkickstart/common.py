#
# Copyright (c) 2008--2013 Red Hat, Inc.
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

import os
import re
import tempfile
import urllib
import sys

from rhnkickstart.kickstart_exceptions import \
    MalformedKickstartFileException, MalformedKickstartURLException, \
    KickstartDownloadException, ImageDownloadException

def download_install_images(kickstart_config, remote_path, local_path):
    # Dig out the URL for the kernel image and ramdisk.
    ks_tree_url = _extract_ks_tree_from_config(kickstart_config)

    # Now download the kernel and ramdisk files.  We'll store them in
    # temporary files.
    (kernel_path, initrd_path) = _download_install_images(ks_tree_url,
        remote_path, local_path)

    return (kernel_path, initrd_path)


def extract_kickstart_url(extra_append):
    """
    Find the url for the kickstart config file in the kernel append line.

    Return the regular expression match object and an error code.
    """
    match = re.search("(ks=(http://\S+))", extra_append)
    if not match:
        raise MalformedKickstartURLException, \
              "Unable to extract ks=http://path from append line: %s" % \
                  (extra_append)

    return match


def download_kickstart_file(extra_append):
    """
    Download the kickstart config file.

    Read the location from the kernel parameters found in extra_append.
    Return a string containing the contents of the config file.
    """
    match = extract_kickstart_url(extra_append)
    ks_url = match.group(2)
    try:
        ks_data = urllib.urlopen(ks_url).read()
    except urllib.HTTPError, e:
        raise KickstartDownloadException, \
                  "Error downloading kickstart file from '%s': %s" % \
                      (ks_url, str(e)), sys.exc_info()[2]

    # Sanity check to make sure we actually received a kickstart file.
    _ensure_valid_kickstart_file(ks_url, ks_data)

    return ks_data

def _ensure_valid_kickstart_file(ks_url, ks_data):
    # Search for the %packages string in the config file.  Might want to add
    # further validation at some point.
    import string
    found_index = string.find(ks_data, "%packages")
    if found_index == -1:
        raise KickstartDownloadException, \
            "Did not receive a valid kickstart config file.  It's possible " \
            "that the URL %s was not found." % \
                (ks_url)

def _extract_ks_tree_from_config(kickstart_config):
    tree_url_match = re.search("url --url (\S+)",
                               kickstart_config,
                               re.MULTILINE)
    if not tree_url_match:
        raise MalformedKickstartFileException, \
              "Unable to find a url in the kickstart file."

    ks_tree_url = tree_url_match.group(1)

    return ks_tree_url


def _download_install_images(tree_location, remote_path, local_path):
    """
    Download the kickstart xen kernel image and ramdisk.

    tree_location is a string specifying the base url of the kickstart tree.
    remote_path is the directory on the remote system containing the images.
    local_path is the location to write the image and ramdisk.

    The return value is a tuple: (kernel_file_name, initrd_file_name)
    """

    kernel_url = '%s/%s/%s' % (tree_location, remote_path, "vmlinuz")
    initrd_url = '%s/%s/%s' % (tree_location, remote_path, "initrd.img")

    try:
        kernel = urllib.urlopen(kernel_url)
    except urllib.HTTPError, e:
        raise ImageDownloadException, \
                  "Error downloading kernel from '%s': %s" % \
                      (kernel_url, str(e)), sys.exc_info()[2]

    try:
        initrd = urllib.urlopen(initrd_url)
    except urllib.HTTPError, e:
        raise ImageDownloadException, \
                  "Error downloading initrd from '%s': %s" % \
                      (initrd_url, str(e)), sys.exc_info()[2]

    if not os.path.isdir(local_path):
        os.makedirs(local_path)

    # Save the kernel image to disk.
    try:
        (kfd, kfn) = tempfile.mkstemp(prefix = "vmlinuz.", dir = local_path)
    except AttributeError:
       kfn = local_path + "kickstart-kernel"
       kfd = os.open(kfn, os.O_CREAT | os.O_WRONLY)

    buffer = kernel.read()
    while buffer != "":
        os.write(kfd, buffer)
        buffer = kernel.read()
    kernel.close()
    os.close(kfd)

    # Make sure what we actually downloaded was in fact the kernel.
    if _is_valid_kernel(kfn):
        os.unlink(kfn)
        raise ImageDownloadException, \
            "Did not download a valid kernel image.  It's possible that %s " \
            "was not found." % \
                kernel_url

    # Save the initrd image to disk.
    try:
        (ifd, ifn) = tempfile.mkstemp(prefix = "initrd.", dir = local_path)
    except AttributeError:
        ifn = local_path + "kickstart-initrd"
        ifd = os.open(ifn, os.O_CREAT | os.O_WRONLY)

    buffer = initrd.read()
    while buffer != "":
        os.write(ifd, buffer)
        buffer = initrd.read()
    initrd.close()
    os.close(ifd)

    # Make sure what we actually downloaded was in fact the initrd.
    if _is_valid_initrd(ifn):
        os.unlink(ifn)
        raise ImageDownloadException, \
            "Did not download a valid initrd image.  It's possible that %s " \
            "was not found." % \
                initrd_url

    return (kfn, ifn)

def _is_valid_initrd(initrd_name):
    # We'll verify by ensuring that we downloaded a gzipped file.  Not the best
    # way, but better than nothing for now.
    return _is_valid_gzip_file(initrd_name)

def _is_valid_kernel(kernel_name):
    # We'll verify by ensuring that we downloaded a gzipped file.  Not the best
    # way, but better than nothing for now.
    return _is_valid_gzip_file(kernel_name)

def _is_valid_gzip_file(file_name):
    f = open(file_name)
    first_two_bytes = f.read(2)
    f.close()
    valid = first_two_bytes[0] == 0x8b and first_two_bytes[1] == 0x1f
    return valid

