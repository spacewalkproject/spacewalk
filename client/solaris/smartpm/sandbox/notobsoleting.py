import sys
sys.argv = ["./smart.py", "test"]
execfile('./smart.py')

def requiredByPackageObsoletingCL9(pkg, donemap=None):
    # Is any recursively requiring package obsoleting some package in CL9?
    if not donemap:
        donemap = {}
    donemap[pkg] = True
    try:
        for prv in pkg.provides:
            for req in prv.requiredby:
                for reqpkg in req.packages:
                    for reqpkgobs in reqpkg.obsoletes:
                        for reqpkgprv in reqpkgobs.providedby:
                            for reqpkgprvpkg in reqpkgprv.packages:
                                for loader in reqpkgprvpkg.loaderinfo:
                                    repos = loader.getRepository()
                                    if repos.getName().startswith("cl9"):
                                        raise StopIteration
                    if (reqpkg not in donemap and
                        requiredByPackageObsoletingCL9(reqpkg, donemap)):
                        raise StopIteration
    except StopIteration:
        return True
    return False

def main():
    for pkg in cache.getPackages():
        for loader in pkg.loaderinfo:
            if loader.getRepository().getName().startswith("cl10"):
                break
        else:
            continue
        # Check if it is obsoleting a package in CL9.
        try:
            for obs in pkg.obsoletes:
                for prv in obs.providedby:
                    for prvpkg in prv.packages:
                        for loader in prvpkg.loaderinfo:
                            repos = loader.getRepository()
                            if repos.getName().startswith("cl9"):
                                raise StopIteration
        except StopIteration:
            continue
        else:
            if not requiredByPackageObsoletingCL9(pkg):
                print pkg

if __name__ == "__main__":
    main()
