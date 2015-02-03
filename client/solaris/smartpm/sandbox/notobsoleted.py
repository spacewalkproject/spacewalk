import sys
sys.argv = ["./smart.py", "test"]
execfile('./smart.py')

def main():
    for pkg in cache.getPackages():
        for loader in pkg.loaderinfo:
            if loader.getRepository().getName().startswith("cl9"):
                break
        else:
            continue
        obsoleted = False
        for prv in pkg.provides:
            for obs in prv.obsoletedby:
                for obspkg in obs.packages:
                    for loader in obspkg.loaderinfo:
                        if loader.getRepository().getName().startswith("cl10"):
                            obsoleted = True
                            break
        if not obsoleted:
            conflicted = []
            for prv in pkg.provides:
                for cnf in prv.conflictedby:
                    for cnfpkg in cnf.packages:
                        for loader in cnfpkg.loaderinfo:
                            if loader.getRepository().getName() == "cl10":
                                conflicted.append(str(cnfpkg))
                                break
            if conflicted:
                print pkg, "(conflicted by %s)" % ", ".join(conflicted)
            else:
                print pkg

if __name__ == "__main__":
    main()
