import sys
sys.argv = ["./smart.py", "test"]
execfile('./smart.py')

# A problem is identified when:
#
# 1) a file has been moved to a different package;
# 2) the new package is not obsoleting nor conflicting with
#    the original package;
# 3) the new package does not require any package obsoleting or
#    conflicting with the original package;
#
# If there's any package obsoleting the original package at
# all, the problem is reduced, but it still exists since the
# new owner may be installed with the original package in
# the system.
#
# Internal problems occur when two packages have the same file
# in the same distribution version. If one package requires the
# same version of the other package explicitly, then this is
# not considered a problem, as it's expected to be the same file
# in both packages.

def isRequiringConflictingPackage(cl10pkg, cl9pkg, donemap=None):
    if not donemap:
        donemap = {}
    donemap[cl10pkg] = True
    # Is any recursively required package conflicting with it?
    for req in cl10pkg.requires:
        for prv in req.providedby:
            # *All* providing packages must conflict with it.
            # Otherwise, it might be installed with one of the
            # non-conflicting package satisfying this dependency.
            found = False
            for pkg in prv.packages:
                try:
                    for cnf in pkg.conflicts:
                        for prv in cnf.providedby:
                            if cl9pkg in prv.packages:
                                raise StopIteration
                    # This providing package is not conflicting,
                    # but a package required by it might be.
                    if (pkg not in donemap and
                        isRequiringConflictingPackage(pkg, cl9pkg, donemap)):
                        raise StopIteration
                except StopIteration:
                    found = True
                else:
                    found = False
                    break
            if found:
                return True
    return False

def main():

    cl9dict = {}
    cl10dict = {}
    cl9pathdict = {}
    cl10pathdict = {}
    for pkg in cache.getPackages():
        for loader in pkg.loaderinfo:
            if loader.getRepository().getName().startswith("cl9"):
                info = loader.getInfo(pkg)
                for path in info.getPathList():
                    if info.pathIsDir(path):
                        continue
                    cl9dict[pkg] = True
                    try:
                        cl9pathdict[path].append(pkg)
                    except KeyError:
                        cl9pathdict[path] = [pkg]
        for loader in pkg.loaderinfo:
            if loader.getRepository().getName().startswith("cl10"):
                info = loader.getInfo(pkg)
                for path in info.getPathList():
                    if info.pathIsDir(path):
                        continue
                    cl10dict[pkg] = True
                    try:
                        cl10pathdict[path].append(pkg)
                    except KeyError:
                        cl10pathdict[path] = [pkg]

    # A problem is considered serious when no package conflicts with
    # the original package at all.
    problems = {}
    noupgproblems = {}
    for path in cl9pathdict:
        if path not in cl10pathdict:
            continue

        cl9pkgs = cl9pathdict[path]
        cl10pkgs = cl10pathdict[path]

        # The same rules apply to every owner in cl9, and
        # to every owner in cl10.
        for cl9pkg in cl9pkgs:
            for cl10pkg in cl10pkgs:
                if cl9pkg.name == cl10pkg.name:
                    continue
                try:
                    # Is it directly conflicted?
                    for cnf in cl10pkg.conflicts:
                        for prv in cnf.providedby:
                            if cl9pkg in prv.packages:
                                raise StopIteration

                    # Is it indirectly conflicted?
                    if isRequiringConflictingPackage(cl10pkg, cl9pkg):
                        raise StopIteration

                    try:
                        problems[(cl9pkg, cl10pkg)].append(path)
                    except KeyError:
                        problems[(cl9pkg, cl10pkg)] = [path]

                    # Check if some package is conflicting and upgrading
                    # the original package at all.
                    try:
                        for prv in cl9pkg.provides:
                            for cnf in prv.conflictedby:
                                for cnfpkg in cnf.packages:
                                    # Check if it's also upgrading.
                                    if cnfpkg not in [x for y in prv.upgradedby
                                                        for x in y.packages]:
                                        continue
                                    for loader in cnfpkg.loaderinfo:
                                        if loader.getRepository().getName() \
                                                        .startswith("cl10"):
                                            raise StopIteration
                    except StopIteration:
                        pass
                    else:
                        noupgproblems[(cl9pkg, cl10pkg)] = True

                except StopIteration:
                    pass

    # Now check for internal conflicts.
    for path in cl10pathdict:
        cl10pkgs = cl10pathdict[path]
        for cl10pkg1 in cl10pkgs:
            for cl10pkg2 in cl10pkgs:
                if cl10pkg1 is cl10pkg2 or cl10pkg1.name == cl10pkg2.name:
                    continue
                if (cl10pkg2, cl10pkg1) in problems:
                    continue
                try:

                    # Is one package requiring another explicitly?
                    for req in cl10pkg1.requires:
                        if req.relation == "=":
                            for prv in req.providedby:
                                if cl10pkg2 in req.packages:
                                    raise StopIteration
                    for req in cl10pkg2.requires:
                        if req.relation == "=":
                            for prv in req.providedby:
                                if cl10pkg1 in req.packages:
                                    raise StopIteration

                    # Is it directly conflicted?
                    for cnf in cl10pkg1.conflicts:
                        for prv in cnf.providedby:
                            if cl10pkg2 in prv.packages:
                                raise StopIteration
                    for cnf in cl10pkg2.conflicts:
                        for prv in cnf.providedby:
                            if cl10pkg1 in prv.packages:
                                raise StopIteration

                    # Is it indirectly conflicted?
                    if isRequiringConflictingPackage(cl10pkg1, cl10pkg2):
                        raise StopIteration

                except StopIteration:
                    continue
                else:
                    try:
                        problems[(cl10pkg1, cl10pkg2)].append(path)
                    except KeyError:
                        problems[(cl10pkg1, cl10pkg2)] = [path]

    print "Problem classes:"
    print "A) An old package has file conflicts with a new package"
    print "B) Same as A, and there's no package upgrading the old package"
    print "C) Same as B, with both packages in the same distribution"
    print
    print "Problems:", len(problems)
    print
    for problem in problems:
        print "Problem class:",
        pkg1, pkg2 = problem
        if pkg1 in cl10dict and pkg2 in cl10dict:
            print "C"
        elif problem in noupgproblems:
            print "B"
        else:
            print "A"
        cl = pkg1 in cl10dict and "CL10:" or "CL9: "
        print cl, pkg1
        cl = pkg2 in cl10dict and "CL10:" or "CL9: "
        print cl, pkg2
        for path in problems[problem]:
            print path
        print

if __name__ == "__main__":
    main()
