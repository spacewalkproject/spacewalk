            
import up2dateAuth
import up2dateLog
import up2dateUtils
import rhnserver
import transaction
import config



def getAdvisoryInfo(pkg, warningCallback=None):
    log = up2dateLog.initLog()
    cfg = config.initUp2dateConfig()
    
    s = rhnserver.RhnServer()

    ts = transaction.initReadOnlyTransaction()
    mi = ts.dbMatch('Providename', pkg[0])
    if not mi:
        return None

    # odd,set h to last value in mi. mi has to be iterated
    # to get values from it...
    h = None
    for h in mi:
        break

    info = None

    # in case of package less errata that somehow apply
    if h:
        try:
            pkgName = "%s-%s-%s" % (h['name'],
                                h['version'],
                                h['release'])
            log.log_me("getAdvisoryInfo for %s" % pkgName)
            info = s.errata.getPackageErratum(up2dateAuth.getSystemId(), pkg)
        except up2dateErrors.RhnServerException, e:
            if warningCallback:
                warningCallback(e)
            return None
    
    if info:
        return info
    
    try:
        log.log_me("getAdvisoryInfo for %s-0-0" % pkg[0])
        info = s.errata.GetByPackage("%s-0-0" % pkg[0],
            up2dateUtils.getVersion())
    except up2dateErrors.RhnServerException, e:
        if warningCallback:
            warningCallback(e)
        return None
    
    return info
