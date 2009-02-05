#!/usr/bin/python
import sys
import os.path
import yum
from yum import config

_LIBPATH = "/usr/share/rhn"
# add to the path if need be
if _LIBPATH not in sys.path:
    sys.path.append(_LIBPATH)

from server.rhnServer import server_packages 
from server.rhnLib import get_package_path
from common import CFG, initCFG, rhn_rpm


initCFG('server.satellite');


# THESE WILL BECOME CONFIG OPTIONS
name = "satellite-fedora-9"
org_id = 1

repo = yum.yumRepo.YumRepository(name)
#repo.baseurl = ['http://download.fedora.redhat.com/pub/fedora/linux/releases/10/Fedora/i386/os/']
repo.baseurl = ['http://download.fedora.redhat.com/pub/fedora/linux/releases/9/Fedora/i386/os/']
repo.baseurlSetup()
repo.basecachedir = "./cache/"
repo.setup(False)
sack = repo.getPackageSack()
sack.populate(repo, 'metadata', None, 0)

list = sack.returnPackages()

if not os.path.exists(repo.hdrdir):
                os.makedirs(repo.hdrdir)


for pack in list:
   repo.getHeader(pack)
   hdrPath = pack.localHdr()
   hdrFile = open(hdrPath, "rb")
   nvrea = [pack.name, pack.epoch, pack.version, pack.release, pack.arch] 
   hdr = hdrFile.read() 

   rpm = rhn_rpm.RPM_Header(hdr)
   print rpm.signatures
   print pack.returnIdSum()
   break
   #path = get_package_path(nevra, org_id, prepend=CFG.PREPENDED_DIR,
   #         source=0, md5sum=md5sum)
   #does file exist?
      #it does, is its md5sum correct?
   #then push the file to the filesystem


   
   #rhnServer.server_packages.processPackageKeyAssociation( hdr, pack.checksums)


   
