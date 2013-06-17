#!/usr/bin/python
#

import rpcServer
import config
import os
import xmlrpclib
import rhnErrors
import rhnUtils
import string
import rhnLog
import clientCaps
import capabilities
import time

from rhn import rpclib

#global loginInfo
loginInfo = None
loginTime = 0.0
loginOffset = 0.0

def getSystemId():
    cfg = config.initUp2dateConfig()
    path = cfg["systemIdPath"]
    if not os.access(path, os.R_OK):
        return None
    
    f = open(path, "r")
    ret = f.read()
        
    f.close()
    return ret

# if a user has upgraded to a newer release of Red Hat but still
# has a systemid from their older release, they need to get an updated
# systemid from the RHN servers.  This takes care of that.
def maybeUpdateVersion():
    cfg = config.initUp2dateConfig()
    try:
        idVer = xmlrpclib.loads(getSystemId())[0][0]['os_release']
    except:
        # they may not even have a system id yet.
        return 0

    systemVer = rhnUtils.getVersion()
    
    if idVer != systemVer:
      s = rpcServer.getServer()
    
      try:
          newSystemId = rpcServer.doCall(s.registration.upgrade_version,
                                         getSystemId(), systemVer)
      except xmlrpclib.Fault, f:
          raise rhnErrors.CommunicationError(f.faultString)

      path = cfg["systemIdPath"]
      dir = path[:string.rfind(path, "/")]
      if not os.access(dir, os.W_OK):
          try:
              os.mkdir(dir)
          except:
              return 0
      if not os.access(dir, os.W_OK):
          return 0

      if os.access(path, os.F_OK):
          # already have systemid file there; let's back it up
          savePath = path + ".save"
          try:
              os.rename(path, savePath)
          except:
              return 0

      f = open(path, "w")
      f.write(newSystemId)
      f.close()
      try:
          os.chmod(path, 0600)
      except:
          pass



# allow to pass in a system id for use in rhnreg
# a bit of a kluge to make caps work correctly
def login(systemId=None):
    server = rpcServer.getServer()
    log = rhnLog.initLog()

    # send up the capabality info
    headerlist = clientCaps.caps.headerFormat()
    for (headerName, value) in headerlist:
        server.add_header(headerName, value)

    if systemId == None:
        systemId = getSystemId()

    if not systemId:
        return None
        
    maybeUpdateVersion()
    log.log_me("logging into up2date server")

    # the list of caps the client needs
    caps = capabilities.Capabilities()

    global loginInfo, loginTime, loginOffset
    try:
        loginInfo = rpcServer.doCall(server.up2date.login, systemId)
        loginTime = time.time()
        loginOffset = float(loginInfo['X-RHN-Auth-Expire-Offset']) - 60.0
    except xmlrpclib.Fault, f:
        if abs(f.faultCode) == 49:
#            print f.faultString
            raise rhnErrors.AbuseError(f.faultString)
        else:
            raise f
    # set a static in the LoginInfo class...
    response_headers =  server.get_response_headers()
    caps.populate(response_headers)

    # figure out if were missing any needed caps
    caps.validate()

#    for i in response_headers.keys():
#        print "key: %s foo: %s" % (i, response_headers[i])
    
        
    log.log_me("successfully retrieved authentication token "
               "from up2date server")

    log.log_debug("logininfo:", loginInfo)
    return loginInfo

def updateLoginInfo():
    log = rhnLog.initLog()
    log.log_me("updating login info")
    global loginInfo
    loginInfo = None
    try:
        login()
    except:
        pass
    if loginInfo is None:
        raise rhnErrors.AuthenticationError("Unable to authenticate")
    return loginInfo


def getLoginInfo():
    global loginInfo, loginTime, loginOffset
    # check for a valid loginInfo
    if loginInfo is None or time.time() > loginTime + loginOffset:
        login()
    return loginInfo
