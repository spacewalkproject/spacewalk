import sys
sys.argv = ["./smart.py", "test"]
execfile('./smart.py')

from smart.cache import *
from sets import Set

def forwardRequires(pkg, set):
    for req in pkg.requires:
        if req not in set:
            set.add(req)
            for prv in req.providedby:
                if prv not in set:
                    set.add(prv)
                    for prvpkg in prv.packages:
                        if prvpkg not in set:
                            set.add(prvpkg)
                            forwardRequires(prvpkg, set)

def backwardRequires(pkg, set):
    for prv in pkg.provides:
        if prv not in set:
            set.add(prv)
            for req in prv.requiredby:
                if req not in set:
                    set.add(req)
                    for reqpkg in req.packages:
                        if reqpkg not in set:
                            set.add(reqpkg)
                            backwardRequires(reqpkg, set)

def findPkgLoops(pkg):
    fwd = Set([pkg])
    forwardRequires(pkg, fwd)
    bwd = Set([pkg])
    backwardRequires(pkg, bwd)
    set = fwd.intersection(bwd)
    pkgs = Set([x for x in set if isinstance(x, Package)])
    prvs = Set([x for x in set if isinstance(x, Provides)])
    reqs = Set([x for x in set if isinstance(x, Requires)])
    for prv in prvs:
        prvpkgs = Set([x for x in prv.packages if x in set])
        reqpkgs = Set()
        for req in prv.requiredby:
            if req in set:
                reqpkgs.update([x for x in req.packages if x in set])
        if prvpkgs == reqpkgs:
            set.remove(prv)
    prvs = Set([x for x in set if isinstance(x, Provides)])
    for req in reqs:
        if not Set(req.providedby).intersection(prvs):
            set.remove(req)
    for pkg in pkgs:
        if not Set(pkg.provides).intersection(prvs):
            set.remove(pkg)
    return set

def findLoops():
    pkgs = cache.getPackages()
    doneset = Set()
    loops = []
    for pkg in pkgs:
        if pkg not in doneset:
            set = findPkgLoops(pkg)
            if len([x for x in set if isinstance(x, Package)]) > 1:
                loops.append(set)
            doneset.update(set)
    return [x for x in loops if x]

def dumpLoops():
    loops = findLoops()
    shown = Set()
    n = 0
    for set in loops:
        n += 1
        file = open("loop%03d.dot" % n, "w")
        file.write("digraph Loops {\n")
        for pkg in [x for x in set if isinstance(x, Package)]:
            if pkg not in shown:
                shown.add(pkg)
                file.write('    "%s" [ shape=box, style=filled, fillcolor=yellow ];\n' % pkg)
            for req in pkg.requires:
                if req not in set:
                    continue
                if (pkg, req) not in shown:
                    shown.add((pkg, req))
                    file.write('    "%s" -> "Requires: %s";\n' % (pkg, req))
                for prv in req.providedby:
                    if prv not in set:
                        continue
                    if (req, prv) not in shown:
                        shown.add((req, prv))
                        file.write('    "Requires: %s" -> "Provides: %s";\n' % (req, prv))
                    for prvpkg in prv.packages:
                        if prvpkg not in set:
                            continue
                        if (prv, prvpkg) not in shown:
                            shown.add((prv, prvpkg))
                            file.write('    "Provides: %s" -> "%s";\n' % (prv, prvpkg))
        file.write("}\n")

if __name__ == "__main__":
    dumpLoops()
