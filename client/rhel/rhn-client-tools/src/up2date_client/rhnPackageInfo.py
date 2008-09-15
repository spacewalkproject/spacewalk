
# all the crap that is stored on the rhn side of stuff
# updating/fetching package lists, channels, etc


import up2dateAuth
import up2dateLog
import rhnserver
import rpmUtils


def remoteDeltaPackages(pkgs):
    log = up2dateLog.initLog()
    log.log_me("Adding packages to package profile: %s" %
               pprint_pkglist(pkgs['added']))
    log.log_me("Removing packages from package profile: %s" %
               pprint_pkglist(pkgs['removed']))
    s = rhnserver.RhnServer()

    s.registration.delta_packages(up2dateAuth.getSystemId(), pkgs)

def updatePackageProfile():
    log = up2dateLog.initLog()
    log.log_me("Updating package profile")
    s = rhnserver.RhnServer()
    s.registration.update_packages(up2dateAuth.getSystemId(),
        rpmUtils.getInstalledPackageList(getArch=1))

def pprint_pkglist(pkglist):
    if type(pkglist) == type([]):
        output = map(lambda a : "%s-%s-%s" % (a[0],a[1],a[2]), pkglist)
    else:
        output = "%s-%s-%s" % (pkglist[0], pkglist[1], pkglist[2])
    return output
