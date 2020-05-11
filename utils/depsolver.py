#!/usr/bin/python2
#
# -*- coding: utf-8 -*-
#
# Copyright (c) 2012--2018 Red Hat, Inc.
#
# Lookup package dependencies in a yum repository
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
# in this software or its documentation

import logging
import shutil
import sys
import os
import glob
import dnf

try:
    from spacewalk.satellite_tools.progress_bar import ProgressBar
except ImportError:
    # pylint: disable=F0401
    _LIBPATH = "/usr/share/rhn"
    if _LIBPATH not in sys.path:
        sys.path.append(_LIBPATH)
    from satellite_tools.progress_bar import ProgressBar


logging.basicConfig()
log = logging.getLogger(__name__)

CACHE_DIR = "/tmp/cache/dnf"
PERSIST_DIR = "/var/lib/dnf"


class DepSolver:

    def __init__(self, repos, pkgs_in=None):
        self.pkgs = pkgs_in or []
        self.repos = repos
        self._repostore = dnf.Base()
        self.setup()
        self.cleanup()  # call cleanup before and after, to ensure no stale metadata
        self.loadPackages()
        self.yrepo = None

    def setPackages(self, pkgs_in):
        self.pkgs = pkgs_in

    def setup(self):
        """
         Load the repos into repostore to query package dependencies
        """
        self._repostore.conf.cachedir  = CACHE_DIR
        for repo in self.repos:
            self._repostore.repos.add_new_repo(repo['id'],
                                               self._repostore.conf,
                                               baseurl = ["file://%s/" % str(repo['relative_path'])])

    def loadPackages(self):
        """
         populate the repostore with packages
        """
        self._repostore.fill_sack(load_available_repos=True)

    def cleanup(self):
        """
         clean up the repo metadata cache from /tmp/cache/dnf.
        """
        for repo in self._repostore.repos:
            cachedir = "%s/%s" % (CACHE_DIR, repo)
            fullcachedir =  glob.glob( cachedir + "-????????????????" )
            try:
                if len(fullcachedir) > 0:
                    shutil.rmtree(fullcachedir[0], ignore_errors=True)
                os.remove( cachedir + "-filenames.solvx" )
                os.remove( cachedir + ".solv" )
            except (IOError,OSError):
                pass

    def close(self):
        self._repostore.close()

    def __parsePackages(self):
        """
         Substitute for yum's parsePackages.
         The function parses a list of package names and returns their Hawkey
         list if it exists in the package sack. Inputs are a package sack and
         a list of packages. Returns a list of latest existing packages in
         Hawkey format.
        """

        pkgSack = self._repostore.sack
        matches = set()
        for pkg in self.pkgs:
            hkpkgs = set()
            subject = dnf.subject.Subject(pkg)
            hkpkgs |= set(subject.get_best_selector(pkgSack, obsoletes=True).matches())
            if len(matches) == 0:
                matches = hkpkgs
            else:
                matches |= hkpkgs
        result = list(matches)
        a = pkgSack.query().available() # Load all available packages from the repository
        result = a.filter(pkg=result).latest().run()
        return result


    def getDependencylist(self):
        """
         Get dependency list and suggested packages for package names provided.
         The dependency lookup is only one level in this case.
         The package name format could be any of the following:
         name, name.arch, name-ver-rel.arch, name-ver, name-ver-rel,
         epoch:name-ver-rel.arch, name-epoch:ver-rel.arch
        """

        match = self.__parsePackages()
        pkgs = []
        for po in match:
            pkgs.append(po)
        results = self.__locateDeps(pkgs)
        return results

    def getRecursiveDepList(self):
        """
         Get dependency list and suggested packages for package names provided.
         The dependency lookup is recursive. All available packages in the repo
         are returned.
         The package name format could be any of the following:
         name, name.arch, name-ver-rel.arch, name-ver, name-ver-rel,
         epoch:name-ver-rel.arch, name-epoch:ver-rel.arch
         returns a hawkey list.
         As this function is not being used, it has not been tested.
        """
        solved = []
        to_solve = self.pkgs
        all_results = {}

        while to_solve:
            log.debug("Solving %s \n\n", to_solve)
            results = self.getDependencylist()
            all_results.update(results)
            found = self.processResults(results)[0]
            solved += to_solve
            to_solve = []
            for _dep, pkgs in found.items():
                for pkg in pkgs:
                    ndep = pkg
                    solved = list(set(solved))
                    if ndep not in solved:
                        to_solve.append(ndep)
            self.pkgs = to_solve
        return all_results

    def __locateDeps(self, pkgs):
        pkgSack = self._repostore.sack.query()
        results = {}
        a = pkgSack.available()
        print("Solving Dependencies (%i): " % len(pkgs))
        pb = ProgressBar(prompt='', endTag=' - complete',
                         finalSize=len(pkgs), finalBarLength=40, stream=sys.stdout)
        pb.printAll(1)

        for pkg in pkgs:
            pb.addTo(1)
            pb.printIncrement()
            results[pkg] = {}
            reqs = pkg.requires
            pkgresults = results[pkg]
            for req in reqs:
                if str(req).startswith('rpmlib('):
                    continue
                satisfiers = []
                for po in a.filter(provides = req).latest():
                    satisfiers.append(po)
                pkgresults[req] = satisfiers
        pb.printComplete()
        return results

    @staticmethod
    def processResults(results):
        reqlist = {}
        notfound = {}
        for pkg in results:
            if not results[pkg]:
                continue
            for req in results[pkg]:
                rlist = results[pkg][req]
                if not rlist:
                    # Unsatisfied dependency
                    notfound[str(req)] = []
                    continue
                reqlist[req] = rlist
        found = {}
        for req, rlist in reqlist.items():
            found[str(req)] = []
            for r in rlist:
                dep = [r.name, r.version, r.epoch, r.release, r.arch]
                if dep not in found[str(req)]:
                    found[str(req)].append(dep)
        return found, notfound

    @staticmethod
    def printable_result(results):
        print_doc_str = ""
        for pkg in results:
            if not results[pkg]:
                continue
            for req in results[pkg]:
                rlist = results[pkg][req]
                print_doc_str += "\n dependency: %s \n" % req
                if not rlist:
                    # Unsatisfied dependency
                    print_doc_str += "   Unsatisfied dependency \n"
                    continue

                for po in rlist:
                    print_doc_str += "   provider: %s\n" % po
        return print_doc_str


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print ("USAGE: python depsolver.py <repoid> <repodata_path> <pkgname1> <pkgname2> ....<pkgnameN>")
        sys.exit(0)
    arg_repo = {'id': sys.argv[1],
                'relative_path': sys.argv[2], }  # path to where repodata is located
    arg_pkgs = sys.argv[3:]
    dsolve = DepSolver([arg_repo], arg_pkgs)
    deplist = dsolve.getDependencylist()
    result_set = dsolve.processResults(deplist)
    dsolve.cleanup()
    dsolve.close()
    print (result_set)
    print ("Printable dependency Results: \n\n %s" % dsolve.printable_result(deplist))
