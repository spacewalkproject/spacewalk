#
# Copyright (c) 1999--2010 Red Hat, Inc.
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
import sys
import time

import yum
import yum.Errors

sys.path.append("/usr/share/yum-cli")

import callback

sys.path.append("/usr/share/rhn/")

from up2date_client import up2dateLog
from up2date_client import config
from up2date_client import rpmUtils
from up2date_client import rhnPackageInfo
from up2date_client import rhncli

from rpm import RPMPROB_FILTER_OLDPACKAGE

log = up2dateLog.initLog()

YUM_PID_FILE = '/var/run/yum.pid'

# file used to keep track of the next time rhn_check 
# is allowed to update the package list on the server
LAST_UPDATE_FILE="/var/lib/up2date/dbtimestamp"

# mark this module as acceptable
__rhnexport__ = [
    'update',
    'remove',
    'refresh_list',
    'fullUpdate',
    'checkNeedUpdate',
    'runTransaction',
    'verify',
    'verifyAll'
]

class YumAction(yum.YumBase):

    def __init__(self):
        yum.YumBase.__init__(self)
        cfg = config.initUp2dateConfig()
        self.doConfigSetup(debuglevel=cfg["debug"])

        self.doTsSetup()
        self.doRpmDBSetup()
        self.doRepoSetup()
        self.doSackSetup()

    # Copied from yum/cli.py, more or less
    def doTransaction(self):
        """takes care of package downloading, checking, user confirmation and actually
           RUNNING the transaction"""


        #allow downgrades to support rollbacks
        self.tsInfo.probFilterFlags.append(RPMPROB_FILTER_OLDPACKAGE)

        # Check which packages have to be downloaded
        downloadpkgs = []
        for txmbr in self.tsInfo.getMembers():
            if txmbr.ts_state in ['i', 'u']:
                po = txmbr.po
                if po:
                    downloadpkgs.append(po)

        log.log_debug('Downloading Packages:')
        problems = self.downloadPkgs(downloadpkgs) 

        if len(problems.keys()) > 0:
            errstring = ''
            errstring += 'Error Downloading Packages:\n'
            for key in problems.keys():
                errors = yum.misc.unique(problems[key])
                for error in errors:
                    errstring += '  %s: %s\n' % (key, error)
            raise yum.Errors.YumBaseError, errstring

        cfg = config.initUp2dateConfig()
        if cfg['retrieveOnly']:
            # We are configured to only download packages, so
            # skip rest of transaction work and return now.
            log.log_debug('Configured to "retrieveOnly" so skipping package install')
            return 0

        # Check GPG signatures
        if self.gpgsigcheck(downloadpkgs) != 0:
            return 1
        
        log.log_debug('Running Transaction Test')
        tsConf = {}
        for feature in ['diskspacecheck']: # more to come, I'm sure
            tsConf[feature] = getattr(self.conf, feature)
        
        # clean out the ts b/c we have to give it new paths to the rpms 
        del self.ts
        
        self.initActionTs()
        # save our dsCallback out
        testcb = callback.RPMInstallCallback(output=0)
        testcb.tsInfo = self.tsInfo
        dscb = self.dsCallback
        self.dsCallback = None # dumb, dumb dumb dumb!
        self.populateTs(keepold=0) # sigh
        tserrors = self.ts.test(testcb, conf=tsConf)
        
        log.log_debug('Finished Transaction Test')
        if len(tserrors) > 0:
            errstring = 'Transaction Check Error: '
            for descr in tserrors:
                errstring += '  %s\n' % descr 
            
            raise yum.Errors.YumBaseError, errstring
        log.log_debug('Transaction Test Succeeded')
        del self.ts
        
        self.initActionTs() # make a new, blank ts to populate
        self.populateTs(keepold=0) # populate the ts
        self.ts.check() #required for ordering
        self.ts.order() # order

        # put back our depcheck callback
        self.dsCallback = dscb

        log.log_debug('Running Transaction')
        self.runTransaction(testcb)

        # close things
        return 0

    # Also taken from yum/cli.py
    def gpgsigcheck(self, pkgs):
        '''Perform GPG signature verification on the given packages, installing
        keys if possible

        Returns non-zero if execution should stop (user abort).
        Will raise YumBaseError if there's a problem
        '''
        for po in pkgs:
            result, errmsg = self.sigCheckPkg(po)

            if result == 0:
                # Verified ok, or verify not req'd
                continue            

            elif result == 1:
                # bz 433781
                # If the package is a Red Hat pkg, try to install the key and see if it helps
                if self.isRepoUsingRedHatGPG(po):
                    log.log_debug("GPG check wasn't successful, will attempt to import key")
                    self.getKeyForPackage(po, askcb=lambda x,y,z: True)
                    log.log_debug("GPG key import was good.")
                    # if we got here, the key worked, otherwise an exception is thrown
                else:
                    raise yum.Errors.YumBaseError, \
                            'Refusing to automatically import keys when running ' \
                            'unattended.'
            else:
                # Fatal error
                raise yum.Errors.YumBaseError, errmsg

        return 0

    def isRepoUsingRedHatGPG(self, po):
        goodValues = ["file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release"]
        repo = self.repos.getRepo(po.repoid)
        keyurls = repo.gpgkey
        if len(keyurls) < 1:
            return False
        for keyurl in keyurls:
            if keyurl not in goodValues:
                log.log_debug(
                        "keyurl = %s, isn't a known Red Hat key, so this " \
                        "will not be imported.  Manually import this key "  \
                        "or set gpgcheck=0 in the RHN yum plugin configuration file" 
                        % (keyurl))
                return False
        return True

    def getInstalledPkgObject(self, package_tup):
        installed = self.rpmdb.returnPackages()
       
        log.log_debug("Searching for installed package to remove: %s"
            % str(package_tup))
        exactmatch, matched, unmatched = yum.packages.parsePackages(
                                         installed, (package_tup), casematch=1)
        erases = yum.misc.unique(matched + exactmatch)

        if len(erases) >= 1:
            log.log_debug("Found %d package(s) to remove" % len(erases))
            return erases
        else:
            # TODO: we should just fail, I think
            log.log_debug("Couldn't find packages to remove")
            return ()

    def add_transaction_data(self, transaction_data):
        """ Add packages to transaction. 
            transaction_data is in format:
            { 'packages' : [
                [['name', '1.0.0', '1', '', ''], 'e'], ...
                # name,    versio, rel., epoch, arch,   flag
            ]}
            where flag can be:
                i - install
                u - update
                e - remove
                r - rollback
            Note: install and update will check for dependecies and
            obsoletes and will install them if needed.
            Rollback do not check anything and will assume that state
            to which we are rolling back should be correct.
        """
        for pkgtup, action in transaction_data['packages']:
            pkgkeys = {
                    'name' : pkgtup[0],
                    'epoch' : pkgtup[3],
                    'version' : pkgtup[1],
                    'release' : pkgtup[2],
                    }
            if len(pkgtup) > 4:
                pkgkeys['arch'] = pkgtup[4]
            else:
                pkgtup.append('')
                pkgkeys['arch'] = None
            if action == 'u':
                self.update(**pkgkeys)
            elif action == 'i':
                self.install(**pkgkeys)
            elif action == 'r':
                # we are doing rollback, we want exact version
                # no dependecy check
                pkgs = self.pkgSack.searchNevra(name=pkgkeys['name'],
                     epoch=pkgkeys['epoch'], arch=pkgkeys['arch'],
                     ver=pkgkeys['version'], rel=pkgkeys['release'])
                for po in pkgs:
                     self.tsInfo.addInstall(po)
            elif action == 'e':
                package_tup = _yum_package_tup(pkgtup)
                packages = self.getInstalledPkgObject(package_tup)
                for package in packages: 
                    self.remove(package)
            else:
                assert False, "Unknown package transaction action."

# global module level reference to YumAction
yum_base = YumAction()
 
def _yum_package_tup(package_tup):
    """ Create a yum-style package tuple from an rhn package tuple. 
        Allowed styles: n, n.a, n-v-r, n-e:v-r.a, n-v, n-v-r.a, 
                        e:n-v-r.a
        Choose from the above styles to be compatible with yum.parsePackage
    """
    n, v, r, e, a = package_tup[:]
    if not e:
        # set epoch to 0 as yum expects
        e = '0'
    if not a:
        pkginfo = '%s-%s-%s' % (n, v, r)
    else:
        pkginfo = '%s-%s:%s-%s.%s' % (n, e, v, r, a)
    return (pkginfo,)

def remove(package_list):
    """We have been told that we should remove packages"""

    if type(package_list) != type([]):
        return (13, "Invalid arguments passed to function", {})

    log.log_debug("Called remove_packages", package_list)

    transaction_data = __make_transaction(package_list, 'e')
    
    return _runTransaction(transaction_data)

def update(package_list):        
    """We have been told that we should retrieve/install packages"""
 
    if type(package_list) != type([]):
        return (13, "Invalid arguments passed to function", {})

    log.log_debug("Called update", package_list)
  
    transaction_data = __make_transaction(package_list, 'i')
   
    return _runTransaction(transaction_data)

def __make_transaction(package_list, action):
    """
    Build transaction Data like _runTransaction would expect.
    This is a list of ((n,v,r,e,a), m) where m is either e, i, or u
    """

    transaction_data = {}
    transaction_data['packages'] = []

    #We don't care about this stuff.
    transaction_data['flags'] = []
    transaction_data['vsflags'] = []
    transaction_data['probFilterFlags'] = []

    for package in package_list:
        transaction_data['packages'].append((package, action))

    return transaction_data

class RunTransactionCommand:

    def __init__(self, transaction_data):
        self.transaction_data = transaction_data

    def execute(self, yum_base):
        yum_base.add_transaction_data(self.transaction_data)

def _runTransaction(transaction_data):
    """ Run a tranaction on a group of packages. """
    command = RunTransactionCommand(transaction_data)
    return _run_yum_action(command)

def runTransaction(transaction_data):
    """ Run a transaction on a group of packages. 
        This was historicaly meant as generic call, but
        is only called for rollback. 
        Therefore we change all actions "i" (install) to 
        "r" (rollback) where we will not check dependencies and obsoletes.
    """
    for index, data in enumerate(transaction_data['packages']):
        if data[1] == 'i':
            transaction_data['packages'][index][1] = 'r'
    return _runTransaction(transaction_data)

class FullUpdateCommand:

    def execute(self, yum_base):
        yum_base.update()

def fullUpdate(force=0):
    """ Update all packages on the system. """
    #TODO: force doesn't mean anything for yum.

    command = FullUpdateCommand()
    return _run_yum_action(command)

def _run_yum_action(command):
    """
    Do something with yum.

    command is an object with an 'execute' method taking yum_base,
    so we can apply different operations to yum_base.
    """

    # TODO: Note to future programmers:
    # When this is running on python 2.5,
    # use the unified try/except/finally
    try:
        try:
            yum_base.doLock(YUM_PID_FILE)
            # Accumulate transaction data
            command.execute(yum_base)
            # depSolving stage
            (result, resultmsgs) = yum_base.buildTransaction()
            if result == 1:
                # Fatal Error
                for msg in resultmsgs:
                    log.log_debug('Error: %s' % msg)
                raise yum.Errors.DepError, resultmsgs 
            elif result == 0 or 2:
                # Continue on
                pass
            else:
                # Unknown Error
                for msg in resultmsgs:
                    log.log_debug('Error: %s' % msg)
                raise yum.Errors.YumBaseError, resultmsgs
                
            log.log_debug("Dependencies Resolved")
            yum_base.doTransaction()
    
        finally:
            yum_base.closeRpmDB()
            yum_base.doUnlock(YUM_PID_FILE)

    except (yum.Errors.InstallError, yum.Errors.UpdateError), e:
        data = {}
        data['version'] = "1"
        data['name'] = "package_install_failure"
        
        return (32, "Failed: Packages failed to install "\
                "properly: %s" % str(e), data)
    except yum.Errors.RemoveError, e:
        data = {}
        data['version'] = 0
        data['name'] = "rpmremoveerrors"

        return (15, "%s" % str(e), data)
    except yum.Errors.DepError, e:
        data = {}
        data["version"] = "1"
        data["name"] = "failed_deps"
        return (18, "Failed: packages requested raised "\
                "dependency problems: %s" % str(e), data)
    except yum.Errors.YumBaseError, e:
        status = 6,
        message = "Error while executing packages action: %s" % str(e)
        data = {}
        return (status, message, data)
  
    return (0, "Update Succeeded", {})


# The following functions are the same as the old up2date ones.

def checkNeedUpdate(rhnsd=None):
    """ Check if the locally installed package list changed, if
        needed the list is updated on the server
        In case of error avoid pushing data to stay safe
    """
    data = {}
    dbpath = "/var/lib/rpm"
    cfg = config.initUp2dateConfig()
    if cfg['dbpath']:
        dbpath = cfg['dbpath']
    RPM_PACKAGE_FILE="%s/Packages" % dbpath

    try:
        dbtime = os.stat(RPM_PACKAGE_FILE)[8] # 8 is st_mtime
    except:
        return (0, "unable to stat the rpm database", data)
    try:
        last = os.stat(LAST_UPDATE_FILE)[8]
    except:
        last = 0;

    # Never update the package list more than once every 1/2 hour
    if last >= (dbtime - 10):
        return (0, "rpm database not modified since last update (or package "
            "list recently updated)", data)
    
    if last == 0:
        try:
            file = open(LAST_UPDATE_FILE, "w+")
            file.close()
        except:
            return (0, "unable to open the timestamp file", data)

    # call the refresh_list action with a argument so we know it's
    # from rhnsd
    return refresh_list(rhnsd=1)
   
def refresh_list(rhnsd=None):
    """ push again the list of rpm packages to the server """
    log.log_debug("Called refresh_rpmlist")

    ret = None

    try:
        rhnPackageInfo.updatePackageProfile()
    except:
        print "ERROR: refreshing remote package list for System Profile"
        return (20, "Error refreshing package list", {})

    touch_time_stamp()
    return (0, "rpmlist refreshed", {})

 
def touch_time_stamp():
    try:
        file_d = open(LAST_UPDATE_FILE, "w+")
        file_d.close()
    except:
        return (0, "unable to open the timestamp file", {})
    # Never update the package list more than once every hour.
    t = time.time()
    try:
        os.utime(LAST_UPDATE_FILE, (t, t))

    except:
        return (0, "unable to set the time stamp on the time stamp file %s"
                % LAST_UPDATE_FILE, {})

def verify(packages):
    log.log_debug("Called packages.verify")

    data = {}
    data['name'] = "packages.verify"
    data['version'] = 0
    ret, missing_packages = rpmUtils.verifyPackages(packages)
                                                                                
    data['verify_info'] = ret
    
    if len(missing_packages):
        data['name'] = "packages.verify.missing_packages"
        data['version'] = 0
        data['missing_packages'] = missing_packages
        return(43, "packages requested to be verified are missing", data)

    return (0, "packages verified", data)

def verifyAll():
    log.log_debug("Called packages.verifyAll")

    data = {}
    data['name'] = "packages.verifyAll"
    data['version'] = 0

    ret = rpmUtils.verifyAllPackages()
    data['verify_info'] = ret
    return (0, "packages verified", data)
