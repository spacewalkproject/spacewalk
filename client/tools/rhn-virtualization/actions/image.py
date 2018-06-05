#!/usr/bin/env python
import base64
try:
    # python2
    import ConfigParser
except ImportError:
    # python3
    import configparser as ConfigParser
import itertools
import os
import platform
import pycurl
import sys

import virtualization.support as virt_support
from virtualization.util import generate_uuid
from virtualization.errors import VirtualizationException
from up2date_client import up2dateLog

log = up2dateLog.initLog()

config = ConfigParser.ConfigParser({
    "IMAGE_BASE_PATH"      : "/var/lib/libvirt/images/",
    "IMAGE_CFG_TEMPLATE"   : "/etc/sysconfig/rhn/kvm-template.xml",
    "PRE_SCRIPT"           : "",
})
config.read('/etc/sysconfig/rhn/image.cfg')
IMAGE_BASE_PATH    = config.get("global", "IMAGE_BASE_PATH")
IMAGE_CFG_TEMPLATE = config.get("global", "IMAGE_CFG_TEMPLATE")
PRE_SCRIPT         = config.get("global", "PRE_SCRIPT")

# mark this module as acceptable
__rhnexport__ = [
    'deploy'
]

def _download_file(target_filename, server_url, proxy_settings):
    """Download file from a URL to given filename using given proxy settings."""
    log.log_debug("downloading %s" % server_url)

    # get the file via pycurl
    c = pycurl.Curl()
    c.setopt(pycurl.URL, server_url)

    # proxy_settings: { proxyURL  : http://myproxy.site:3128
    #                   proxyUser : user
    #                   proxyPass : s3cr3t }
    # proxyUser and proxyPass are optional
    if "proxyURL" in proxy_settings and proxy_settings["proxyURL"] is not None and proxy_settings["proxyURL"] != "":
        server = proxy_settings["proxyURL"]
        c.setopt(pycurl.PROXY, server )
        if "proxyUser" in proxy_settings and proxy_settings["proxyUser"] is not None and proxy_settings["proxyUser"] != "":
            user     = proxy_settings["proxyUser"]
            password = base64.b64decode(proxy_settings["proxyPass"])
            c.setopt(pycurl.PROXYUSERPWD, "%s:%s" % (user, password))
    # default IMAGE_BASE_PATH is /var/lib/libvirt/images
    file_path = "/%s/%s" % (IMAGE_BASE_PATH, target_filename)
    f = open(file_path, 'w')
    c.setopt(pycurl.FOLLOWLOCATION, 1)
    c.setopt(pycurl.WRITEFUNCTION, f.write)
    c.setopt(pycurl.SSL_VERIFYPEER, 0)
    c.perform()
    log.log_debug("curl got HTTP code: %s" % c.getinfo(pycurl.HTTP_CODE))
    f.close()
    return c.getinfo(pycurl.HTTP_CODE)

def _connect_to_hypervisor():
    """Connect to the hypervisor."""
    # First, attempt to import libvirt.  If we don't have that, we can't do
    # much else.
    try:
        import libvirt
    except ImportError as ie:
        raise VirtualizationException("Unable to locate libvirt: %s" % str(ie))

    # Attempt to connect to the hypervisor.
    try:
        connection = libvirt.open(None)
    except Exception as e:
        raise VirtualizationException("Could not connect to hypervisor: %s" % str(e))

    return connection

def _file_exists(name):
    return os.path.exists(name)

def _domain_exists(dom, connection):
    try:
        connection.lookupByName(dom)
    except Exception:
        log.log_debug("domain %s does not exist" % dom)
        return False
    log.log_debug("domain %s exists" % dom)
    return True

def _generate_xml(params):
    """Populate the variables in the XML template file."""
    if PRE_SCRIPT != "":
        log.log_debug("running image pre-script %s" % PRE_SCRIPT)
        os.system(PRE_SCRIPT)

    if os.path.isfile(IMAGE_CFG_TEMPLATE):
        f = open(IMAGE_CFG_TEMPLATE, 'r')
        CREATE_TEMPLATE = f.read()
        f.close()

    created_xml = CREATE_TEMPLATE % params
    log.log_debug("libvirt XML: %s" % created_xml)
    return created_xml

# Download and start a new image given by the following parameters:
#
# downloadURL   : http://download.suse.de/install/SLE-15-JeOS-RC2/SLES15-JeOS.x86_64-15.0-kvm-and-xen-RC2.qcow2
# proxySettings : { proxyURL  : http://myproxy.site:3128
#                  proxyUser : user
#                  proxyPass : s3cr3t }
# memKB         : 524288
# vCPUs         : 1
# domainName    : virt_test_machine
# virtBridge    : br0
def deploy(params, extra_params="", cache_only=None):
    """Download and start a new image."""

    image_filename  = params["downloadURL"].split('/')[-1]
    domain_name, image_extension = os.path.splitext(image_filename)
    if not image_extension or image_extension != ".qcow2":
        return (1, "image type is not qcow2: %s" % image_filename, {})
    image_arch = platform.machine() or 'x86_64'

    try:
        connection = _connect_to_hypervisor()
    except Exception as e:
        return (1, "%s" % e, {})

    # If we got an explicit domain name then use it and update the filename
    if "domainName" in params and params["domainName"] != "":
        domain_name = params["domainName"]
    image_filename = domain_name + image_extension

    # If domain or file exists try to find a free name for both
    if _domain_exists(domain_name, connection) or _file_exists("%s/%s" % (IMAGE_BASE_PATH, image_filename)):
        for i in itertools.count(1):
            new_domain_name = ("%s-%i" % (domain_name, i))
            image_filename = new_domain_name + image_extension
            if not _domain_exists(new_domain_name, connection) and not _file_exists("%s/%s" % (IMAGE_BASE_PATH, image_filename)):
                log.log_debug("free domain and matching filename found")
                domain_name = new_domain_name
                break

    log.log_debug("filename=%s domain=%s arch=%s" % (image_filename, domain_name, image_arch))

    if not domain_name or image_arch not in ['x86_64', 'i686', 'ppc64le', 's390x']:
        log.log_debug("invalid domain name or arch")
        return (1, "invalid domain name or arch: domain=%s arch=%s" % (domain_name, image_arch), {})

    http_response_code = -1
    try:
        http_response_code = _download_file(image_filename, params["downloadURL"], params["proxySettings"])
        if not _file_exists("%s/%s" % (IMAGE_BASE_PATH, image_filename)):
            log.log_debug("downloading image file failed, HTTP return code: %s" % http_response_code)
            return (1, "downloading image file failed: %s/%s (%s)" % (IMAGE_BASE_PATH, image_filename, http_response_code), {})
    except Exception as e:
        return (1, "getting the image failed with: %s" % e, {})
    if cache_only:
        return (0, "image fetched and cached for later deployment", {})

    image_path = "%s/%s" % (IMAGE_BASE_PATH, image_filename)
    if not os.path.exists(image_path):
        return (1, "image not found at %s" % image_path, {})
    log.log_debug("working on image in %s" % image_path)

    create_params = { 'name'           : domain_name,
                      'arch'           : image_arch,
                      'extra'          : extra_params,
                      'mem_kb'         : params["memKB"],
                      'vcpus'          : params["vCPUs"],
                      'uuid'           : generate_uuid(),
                      'disk'           : image_path,
                      'imageType'      : 'qcow2',
                      'virtBridge'     : params["virtBridge"],
                    }
    create_xml = _generate_xml(create_params)
    domain = None
    try:
        domain = connection.defineXML(create_xml)
    except Exception as e:
        return (1, "failed to pass XML to libvirt: %s" % e, {})

    domain.create()
    virt_support.refresh()

    return (0, "image '%s' deployed and started" % domain_name, {})

# just for testing
if __name__ == "__main__":
    # test code
    log.log_debug("actions/image.py called")
    print("You can not run this module by itself")
    sys.exit(-1)
