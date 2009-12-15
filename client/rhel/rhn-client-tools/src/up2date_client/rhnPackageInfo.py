
# all the crap that is stored on the rhn side of stuff
# updating/fetching package lists, channels, etc


import up2dateAuth
import up2dateLog
import rhnserver
import rpmUtils


def logDeltaPackages(pkgs):
    log = up2dateLog.initLog()
    log.log_me("Adding packages to package profile: %s" %
               pprint_pkglist(pkgs['added']))
    log.log_me("Removing packages from package profile: %s" %
               pprint_pkglist(pkgs['removed']))

def updatePackageProfile():
    """ get a list of installed packages and send it to rhnServer """
    log = up2dateLog.initLog()
    log.log_me("Updating package profile")
    packages = rpmUtils.getInstalledPackageList(getArch=1)
    s = rhnserver.RhnServer()
    if not s.capabilities.hasCapability('xmlrpc.packages.extended_profile', 2):
        # for older satellites and hosted - convert to old format
        packages = convertPackagesFromHashToList(packages)
    s.registration.update_packages(up2dateAuth.getSystemId(), packages)

def pprint_pkglist(pkglist):
    if type(pkglist) == type([]):
        output = map(lambda a : "%s-%s-%s" % (a[0],a[1],a[2]), pkglist)
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
        if package.has_key('arch') and package.has_key('cookie'):
            result.append([package['name'], package['version'], package['release'],
                package['epoch'], package['arch'], package['cookie']])
        elif package.has_key('arch'):
            result.append([package['name'], package['version'], package['release'],
                package['epoch'], package['arch']])
        else:
            result.append([package['name'], package['version'], package['release'], package['epoch']])
    return result
