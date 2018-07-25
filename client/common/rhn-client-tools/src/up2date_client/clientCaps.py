
# a dict with "capability name" as the key, and the version
# as the value.

import glob
import os

from up2date_client.capabilities import parseCap

try: # python2
    import UserDict
except ImportError: # python3
    import collections as UserDict

class ClientCapabilities(UserDict.UserDict):
    def __init__(self):
        UserDict.UserDict.__init__(self)
        self.populate()

    def populate(self, capsToPopulate=None):
        # FIXME: at some point, this will be
        # intelligently populated...
        localcaps = {
            "caneatCheese":{'version':1, 'value': 1}
            }
        if capsToPopulate:
            localcaps = capsToPopulate
        self.data = localcaps

    def headerFormat(self):
        headerList = []
        for key in self.data.keys():
            headerName = "X-RHN-Client-Capability"
            value = "%s(%s)=%s" % (key,
                                   self.data[key]['version'],
                                   self.data[key]['value'])
            headerList.append((headerName, value))
        return headerList

caps = ClientCapabilities()

def loadLocalCaps(capsDir = "/etc/sysconfig/rhn/clientCaps.d"):

    capsFiles = glob.glob("%s/*" % capsDir)

    for capsFile in capsFiles:
        if os.path.isdir(capsFile):
            continue
        if not os.access(capsFile, os.R_OK):
            continue

        fd = open(capsFile, "r")
        for line in fd.readlines():
            line = line.strip()
            if not line or line[0] == "#":
                continue
            caplist = parseCap(line)

            for (cap,data) in caplist:
                caps.data[cap] = data

#    print(caps.data)

loadLocalCaps()

# register local caps we require.
def registerCap(cap, data):
    caps.data[cap] = data


# figure out something pretty here
registerCap("packages.runTransaction", {'version':'1', 'value':'1'})
registerCap("packages.rollBack", {'version':'1', 'value':'1'})
registerCap("packages.verify", {'version':'1', 'value':'1'})
registerCap("packages.extended_profile", {'version':'2', 'value':'1'})
registerCap("reboot.reboot", {'version':'1', 'value':'1'})
registerCap("packages.update", {'version':'2', 'value':'2'})
