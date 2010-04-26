#
# $Id$

import rhnserver
import config
import os
import up2dateErrors
import up2dateUtils
import string
import up2dateLog
import clientCaps
import pickle
import time

from types import DictType

from rhn import rpclib

loginInfo = None
pcklAuthFileName = "/var/spool/up2date/loginAuth.pkl"

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
        idVer = rpclib.xmlrpclib.loads(getSystemId())[0][0]['os_release']
    except:
        # they may not even have a system id yet.
        return 0

    systemVer = up2dateUtils.getVersion()
    
    if idVer != systemVer:
      s = rhnserver.RhnServer()
    
      newSystemId = s.registration.upgrade_version(getSystemId(), systemVer)

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


def writeCachedLogin():
    """
    Pickle loginInfo to a file
    Returns:
    True    -- wrote loginInfo to a pickle file
    False   -- did _not_ write loginInfo to a pickle file
    """
    log = up2dateLog.initLog()
    log.log_debug("writeCachedLogin() invoked")
    if not loginInfo:
        log.log_debug("writeCachedLogin() loginInfo is None, so bailing.")
        return False
    data = {'time': time.time(),
            'loginInfo': loginInfo}
    
    pcklDir = os.path.dirname(pcklAuthFileName)
    if not os.access(pcklDir, os.W_OK):
        try:
            os.mkdir(pcklDir)
            os.chmod(pcklDir, 0700)
        except:
            log.log_me("Unable to write pickled loginInfo to %s" % pcklDir)
            return False
    pcklAuth = open(pcklAuthFileName, 'wb')
    os.chmod(pcklAuthFileName, 0600)
    pickle.dump(data, pcklAuth)
    pcklAuth.close()
    expireTime = data['time'] + float(loginInfo['X-RHN-Auth-Expire-Offset'])
    log.log_debug("Wrote pickled loginInfo at ", data['time'], " with expiration of ", 
            expireTime, " seconds.")
    return True

def readCachedLogin():
    """
    Read pickle info from a file
    Caches authorization info for connecting to the server.
    """
    log = up2dateLog.initLog()
    log.log_debug("readCachedLogin invoked")
    if not os.access(pcklAuthFileName, os.R_OK):
        log.log_debug("Unable to read pickled loginInfo at: %s" % pcklAuthFileName)
        return False
    pcklAuth = open(pcklAuthFileName, 'rb')
    try:
        data = pickle.load(pcklAuth)
    except EOFError:
        log.log_debug("Unexpected EOF. Probably an empty file, \
                       regenerate auth file")
        pcklAuth.close()
        return False
    pcklAuth.close()
    createdTime = data['time']
    li = data['loginInfo']
    currentTime = time.time()
    expireTime = createdTime + float(li['X-RHN-Auth-Expire-Offset'])
    #Check if expired, offset is stored in "X-RHN-Auth-Expire-Offset" 
    log.log_debug("Checking pickled loginInfo, currentTime=", currentTime,
            ", createTime=", createdTime, ", expire-offset=", 
            float(li['X-RHN-Auth-Expire-Offset']))
    if (currentTime > expireTime):
        log.log_debug("Pickled loginInfo has expired, created = %s, expire = %s." \
                %(createdTime, expireTime))
        return False
    _updateLoginInfo(li)
    log.log_debug("readCachedLogin(): using pickled loginInfo set to expire at ", expireTime)
    return True

def _updateLoginInfo(li):
    """
    Update the global var, "loginInfo"
    """
    global loginInfo
    if type(li) == DictType:
        if type(loginInfo) == DictType:
            # must retain the reference.
            loginInfo.update(li)
        else:
            # this had better be the initial login or we lose the reference.
            loginInfo = li
    else:
        loginInfo = None

# allow to pass in a system id for use in rhnreg
# a bit of a kluge to make caps work correctly
def login(systemId=None, forceUpdate=False):
    log = up2dateLog.initLog()
    log.log_debug("login(forceUpdate=%s) invoked" % (forceUpdate))
    if not forceUpdate and not loginInfo:
        if readCachedLogin():
            return loginInfo

    server = rhnserver.RhnServer()

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

    li = server.up2date.login(systemId)
    
    # figure out if were missing any needed caps
    server.capabilities.validate()
    _updateLoginInfo(li) #update global var, loginInfo
    writeCachedLogin() #pickle global loginInfo

    if loginInfo:
        log.log_me("successfully retrieved authentication token "
                   "from up2date server")

    log.log_debug("logininfo:", loginInfo)
    return loginInfo

def updateLoginInfo():
    log = up2dateLog.initLog()
    log.log_me("updateLoginInfo() login info")
    # NOTE: login() updates the loginInfo object
    login(forceUpdate=True)
    if not loginInfo:
        raise up2dateErrors.AuthenticationError("Unable to authenticate")
    return loginInfo


def getLoginInfo():
    global loginInfo
    try:
        loginInfo = loginInfo
    except NameError:
        loginInfo = None
    if loginInfo:
        return loginInfo
    # NOTE: login() updates the loginInfo object
    login()
    return loginInfo

