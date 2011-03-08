#!/usr/bin/python

from rhn import rpclib
import config
import rhnAuth
import rhnReg
import rhnUtils
import rpcServer

# containment class for handling server config info
class ServerSettings:
    def __init__(self):
        self.cfg = config.initUp2dateConfig()
        self.xmlrpcServerUrl = self.cfg["serverURL"]
        if self.cfg["useNoSSLForPackages"]:
            self.httpServerUrl = self.cfg["noSSLServerURL"]
        else:
            self.httpServerUrl = self.cfg["serverURL"]

        self.proxyUrl = None
        self.proxyUser = None
        self.proxyPassword = None

        if self.cfg["enableProxy"] and rhnUtils.getProxySetting():
            self.proxyUrl = rhnUtils.getProxySetting()
            if self.cfg["enableProxyAuth"]:
                if self.cfg["proxyUser"] and self.cfg["proxyPassword"]:
                    self.proxyPassword = self.cfg["proxyPassword"]
                    self.proxyUser = self.cfg["proxyUser"]


    def settings(self):
        return self.xmlrpcServerUrl, self.httpServerUrl, \
               self.proxyUrl, self.proxyUser, self.proxyPassword

def getGETServer(logininfo, serverSettings):
    server= rpclib.GETServer(serverSettings.httpServerUrl,
                            proxy = serverSettings.proxyUrl,
                            username = serverSettings.proxyUser,
                            password = serverSettings.proxyPassword,
                            headers = logininfo)
    server.add_header("X-Up2date-Version", rhnUtils.version())
    return server


def refreshPackages(packageList):

    rhnReg.updatePackages(rhnAuth.getSystemId(), packageList)
    rhnUtils.touchTimeStamp()


def listAllAvailablePackages():
    serverSettings = ServerSettings()
    li = rhnAuth.getLoginInfo()

    channels = li.get('X-RHN-Auth-Channels')
    s = getGETServer(li, serverSettings)

    packagelist = []
    for channelInfo in channels:
        channelName = channelInfo[0]
        channelVersion = channelInfo[1]
        tmplist = s.listAllPackages(channelName, channelVersion)
        packagelist = packagelist + tmplist

    return packagelist

def listAllAvailablePackagesComplete(channelList = None):
    serverSettings = ServerSettings()
    li = rhnAuth.getLoginInfo()

    channels = li.get('X-RHN-Auth-Channels')
    s = getGETServer(li, serverSettings)

    packagelist = []
    for channelInfo in channels:
        channelName = channelInfo[0]
        if not channelList or channelName in channelList:
            channelVersion = channelInfo[1]
            tmplist = s.listAllPackagesComplete(channelName, channelVersion)
            packagelist = packagelist + tmplist

    return packagelist


BUFFER_SIZE=8092
def _readFD(fd, filename):
    f = open(filename, "w+")

    while 1:
        chunk = fd.read(BUFFER_SIZE)
        l = len(chunk)
        if not l:
            break
        f.write(chunk)

    f.flush()
    # Rewind
    f.seek(0, 0)
    return f

def downloadPackage(channel, pkghash, localfile, serverUrl=None):
    cfg = config.initUp2dateConfig()
    
    serverSettings = ServerSettings()
    if serverUrl is not None:
        serverSettings.httpServerUrl = serverUrl
    li = rhnAuth.getLoginInfo()
    s = getGETServer(li, serverSettings)

    fd = rpcServer.doCall(s.getPackage, channel, pkghash)
    status = s.get_response_status()
    
    f2 = _readFD(fd, localfile)
    f2.close()
    fd.close()

