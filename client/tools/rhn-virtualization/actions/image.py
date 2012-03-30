#!/usr/bin/env python
import base64
import ConfigParser
import hashlib
import itertools
import os
import pycurl
import re
import sys

sys.path.append("/usr/share/rhn/")
import virtualization.support as virt_support
from virtualization.util import generate_uuid
from up2date_client import up2dateLog

log = up2dateLog.initLog()

config = ConfigParser.ConfigParser({
    "IMAGE_BASE_PATH"      : "/var/lib/libvirt/images/",
    "IMAGE_CFG_TEMPLATE"   : "/etc/sysconfig/rhn/studio-kvm-template.xml",
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

# download and extract tar.gz file with image
def _downloadFile(imageName,serverUrl,proxySetting):
    log.log_debug("downloading %s" % serverUrl)

    # get the file via pycurl
    c = pycurl.Curl()
    c.setopt(pycurl.URL, serverUrl)

    # proxySetting : { proxyURL  : http://myproxy.site:3128
    #                  proxyUser : user
    #                  proxyPass : s3cr3t }
    # proxyUser and proxyPass are optional
    #
    if proxySetting.has_key("proxyURL") and proxySetting["proxyURL"] != None and proxySetting["proxyURL"] != "":
        server = proxySetting["proxyURL"]
        c.setopt(pycurl.PROXY, server )
        if proxySetting.has_key("proxyUser") and proxySetting["proxyUser"] != None and proxySetting["proxyUser"] != "":
            user     = proxySetting["proxyUser"]
            password = base64.b64decode( proxySetting["proxyPass"] )
            c.setopt(pycurl.PROXYUSERPWD, "%s:%s" % (user,password) )
    # default IMAGE_BASE_PATH is /var/lib/libvirt/images
    filePath = "/%s/%s" % (IMAGE_BASE_PATH, imageName)
    f = open(filePath, 'w')
    c.setopt(pycurl.WRITEFUNCTION, f.write)
    c.setopt(pycurl.SSL_VERIFYPEER, 0)
    c.perform()
    log.log_debug("curl got HTTP code: %s" % c.getinfo(pycurl.HTTP_CODE))
    f.close()
    return c.getinfo(pycurl.HTTP_CODE)

def _connect_to_hypervisor():
    """
    Connects to the hypervisor.
    """
    # First, attempt to import libvirt.  If we don't have that, we can't do
    # much else.
    try:
        import libvirt
    except ImportError, ie:
        raise VirtLibNotFoundException, \
              "Unable to locate libvirt: %s" % str(ie)

    # Attempt to connect to the hypervisor.
    try:
        connection = libvirt.open(None)
    except Exception, e:
        raise VirtualizationKickstartException, \
              "Could not connect to hypervisor: %s" % str(e)

    return connection

#
# this is not nice but tarfile.py does not support
# sparse file writing :(
#
def _extractImage( source, dest ):
    param = "xf"
    if not os.path.exists( source ):
        log.log_debug("source file not found: %s" % source)
        raise Exception("source file not found: %s" % source)

    if not os.path.exists( dest ):
        log.log_debug("target path not found: %s" % dest)
        raise Exception("target path not found: %s" % dest)

    if( source.endswith("gz") ):
        param = param + "z"
    elif( source.endswith("bz2") ):
        param = param + "j"

    # skip the root directory in the tar - extract only the image files
    cmd = "tar %s %s -C %s --strip-components=1" % ( param, source, dest )
    log.log_debug(cmd)
    if os.system( cmd ) != 0:
        log.log_debug( "%s failed" % cmd )
        raise Exception("%s failed" % cmd)

    return 0

def _md5(path):
    f = open(path, "rb")
    sum = hashlib.md5()
    while 1:
        block = f.read(128)
        if not block:
            break
        sum.update(block)
    f.close()
    return sum.hexdigest()


def _fileExists(name, md5Sum):
    return os.path.exists( name ) and md5Sum == _md5( name )

def _domainExists( dom, connection ):
    try:
        connection.lookupByName(dom)
    except Exception, e:
        log.log_debug("domain %s does not exist" % dom)
        return False
    log.log_debug("domain %s exists" % dom)
    return True

# create a new or reuse an existing directory
def _createTargetDir( wantedDir ):
    new_dir_name = wantedDir
    for i in itertools.count(1):
        if not os.path.exists(new_dir_name):
            try:
                os.makedirs( new_dir_name )
            except OSError, exc:
                return (1, "creating directory %s failed" % new_dir_name)
            return new_dir_name
        elif len(os.listdir(new_dir_name)) <= 1:
            # if the directory exists with zero or only one file, we'll use it
            # to extract the image into it
            return new_dir_name
        new_dir_name = "%s-%i" % ( wantedDir, i )

# fillout the variables in the XML template file
def _generateXML( params ):
    if PRE_SCRIPT != "":
        log.log_debug("running image pre-script %s" % PRE_SCRIPT)
        os.system( PRE_SCRIPT )

    if os.path.isfile(IMAGE_CFG_TEMPLATE):
        f = open(IMAGE_CFG_TEMPLATE, 'r')
        CREATE_TEMPLATE = f.read()
        f.close()

    created_xml = CREATE_TEMPLATE % params
    log.log_debug("libvirt XML: %s" % created_xml)
    return created_xml

# download/extract and start a new image
# imageName = myImage.x86_64.
#
# downloadURL  : http://susestudio.com/download/f98.../my_image.i686-0.0.3.vmx.tar.gz
# proxySetting : { proxyURL  : http://myproxy.site:3128
#                  proxyUser : user
#                  proxyPass : s3cr3t }
# memKB      : 524288
# vCPUs      : 1
# domainName : virt_test_machine
# virtBridge : br0
#
def deploy(params, extraParams="",cache_only=None):
    """start and connect a local image with SUSE Manager"""

    urlParts  = params["downloadURL"].split('/')
    studioArchiveFileName  = urlParts[-1]
    checksum  = urlParts[-2]

    # studioArchiveFileName = workshop_test_sles11sp1.i686-0.0.1.vmx.tar.gz
    # studioArchiveFileName = Just_enough_OS_openSUSE_12.1.x86_64-0.0.1.xen.tar.gz
    m = re.search( '(.*)\.(x86_64|i\d86)-(\d+\.\d+\.\d+)\.(xen|vmx)', studioArchiveFileName )

    imageName    = m.group(1)
    imageArch    = m.group(2)
    imageVersion = m.group(3)
    imageType    = m.group(4)
    studioImageDiskFileName = imageName+"."+imageArch+"-"+imageVersion

    connection = _connect_to_hypervisor()

    # if we got an explicit name, we'll use it
    if params.has_key("domainName") and params["domainName"] != "":
        imageName = params["domainName"]
    # if not, we'll try to find a free name
    elif( _domainExists(imageName, connection) ):
        for i in itertools.count(1):
            newImageName = ("%s-%i" % (imageName,i))
            if not _domainExists(newImageName, connection):
                log.log_debug("free domain found")
                imageName = newImageName
                break
    log.log_debug( "name=%s arch=%s ver=%s type=%s" % (imageName,imageArch,imageVersion,imageType) )

    if len(imageName) < 1 or len(imageArch) < 1:
        log.log_debug("invalid image name or arch")
        return (1, "invalid image name or arch: name=%s arch=%s ver=%s type=%s" % (imageName,imageArch,imageVersion,imageType), {})

    httpResponseCode = -1
    if not _fileExists("%s/%s" % (IMAGE_BASE_PATH,studioArchiveFileName), checksum):
        try:
            httpResponseCode = _downloadFile(studioArchiveFileName,params["downloadURL"],params["proxySettings"])
            if not _fileExists("%s/%s" % (IMAGE_BASE_PATH,studioArchiveFileName), checksum):
                log.log_debug("downloading image file failed. HTTP Code is: %s" % httpResponseCode)
                return (1, "downloading image file failed: %s/%s (%s)" % (IMAGE_BASE_PATH, studioArchiveFileName,httpResponseCode), {})
        except Exception, e:
            return ( 1, "getting the image failed with: %s" % e )
    if cache_only:
        return (0, "image fetched and cached for later deployment", {})
    try:
        targetDir = _createTargetDir( "%s/%s" % (IMAGE_BASE_PATH, imageName) )
        _extractImage( "%s/%s" % (IMAGE_BASE_PATH,studioArchiveFileName), targetDir )
    except Exception, e:
        return (1, "extracting the image tarball failed with: %s" % e, {})

    # image exists in $IMAGE_BASE_PATH/$imageName now

    uuid = generate_uuid()
    # FIXME: check for the extensions. There might be more
    studioFileExtension = "vmdk"
    if imageType == "xen":
        studioFileExtension = "raw"
    extractedImagePath = "%s/%s.%s" % (targetDir,studioImageDiskFileName,studioFileExtension)
    log.log_debug("working on image in %s" % extractedImagePath)
    if not os.path.exists( extractedImagePath ):
        return (1, "extracted image not found at %s" % extractedImagePath, {})
    if imageArch in ( 'i386', 'i486', 'i568' ):
        imageArch = 'i686'

    create_params = { 'name'           : imageName,
                      'arch'           : imageArch,
                      'extra'          : extraParams,
                      'mem_kb'         : params["memKB"],
                      'vcpus'          : params["vCPUs"],
                      'uuid'           : uuid,
                      'disk'           : extractedImagePath,
                      'imageType'      : imageType,
                      'virtBridge'     : params["virtBridge"],
                    }
    create_xml = _generateXML( create_params )
    domain = None
    try:
        domain = connection.defineXML(create_xml)
    except Exception, e:
        return (1, "failed to pass XML to libvirt: %s" % e, {})

    domain.create()
    virt_support.refresh()

    return (0, "image '%s' deployed and started" % imageName, {})

# just for testing
if __name__ == "__main__":
    # test code
    log.log_debug("actions/image.py called")
    print "You can not run this module by itself"
    sys.exit(-1)
