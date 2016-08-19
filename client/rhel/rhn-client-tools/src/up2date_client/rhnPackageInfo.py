
# all the crap that is stored on the rhn side of stuff
# updating/fetching package lists, channels, etc


from up2date_client import up2dateAuth
from up2date_client import up2dateLog
from up2date_client import rhnserver
from up2date_client import pkgUtils


def logDeltaPackages(pkgs):
    log = up2dateLog.initLog()
    log.log_me("Adding packages to package profile: %s" %
               pprint_pkglist(pkgs['added']))
    log.log_me("Removing packages from package profile: %s" %
               pprint_pkglist(pkgs['removed']))

def updatePackageProfile(timeout=None):
    """ get a list of installed packages and send it to rhnServer """
    log = up2dateLog.initLog()
    log.log_me("Updating package profile")
    packages = pkgUtils.getInstalledPackageList(getArch=1)
    s = rhnserver.RhnServer(timeout=timeout)
    if not s.capabilities.hasCapability('xmlrpc.packages.extended_profile', 2):
        # for older satellites and hosted - convert to old format
        packages = convertPackagesFromHashToList(packages)
    s.registration.update_packages(up2dateAuth.getSystemId(), packages)

def pprint_pkglist(pkglist):
    if type(pkglist) == type([]):
        output = ["%s-%s-%s" % (a[0],a[1],a[2]) for a in pkglist]
    else:
        output = "%s-%s-%s" % (pkglist[0], pkglist[1], pkglist[2])
    return output

def convertPackagesFromHashToList(packages):
    """ takes list of hashes and covert it to list of lists
        resulting strucure is:
        [[name, version, release, epoch, arch, cookie], ... ]
    """
    result = []
    for package in packages:
        if 'arch' in package and 'cookie' in package:
            result.append([package['name'], package['version'], package['release'],
                package['epoch'], package['arch'], package['cookie']])
        elif 'arch' in package:
            result.append([package['name'], package['version'], package['release'],
                package['epoch'], package['arch']])
        else:
            result.append([package['name'], package['version'], package['release'], package['epoch']])
    return result
