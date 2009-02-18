#!/usr/bin/python
import sys
import os.path
import yum
from yum import config

_LIBPATH = "/usr/share/rhn"
# add to the path if need be
if _LIBPATH not in sys.path:
    sys.path.append(_LIBPATH)

from server.rhnLib import get_package_path
from common import CFG, initCFG



initCFG('server.satellite')


get_package_pathh(nevra, org_id, prepend=CFG.PREPENDED_DIR,
            source=source, md5sum=md5sum)




