#!/usr/bin/python
#
# -*- coding: utf-8 -*-
#
# Copyright (c) 2012 Red Hat, Inc.
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
import re
import shutil
import sys
import yum
from yum.misc import prco_tuple_to_string
from yum.packageSack import ListPackageSack
from yum.packages import parsePackages
from yum.repos import RepoStorage

try:    
    from spacewalk.satellite_tools.progress_bar import ProgressBar
except ImportError:
    _LIBPATH = "/usr/share/rhn"
    if _LIBPATH not in sys.path:
        sys.path.append(_LIBPATH)    
    from satellite_tools.progress_bar import ProgressBar


log = logging.getLogger(__name__)

CACHE_DIR = "/tmp/cache/yum"

class DepSolver:
    def __init__(self, repos, pkgs_in=[]):
        self.pkgs = pkgs_in
        self.repos = repos
        self._repostore = RepoStorage(self)
        self.cleanup() #call cleanup before and after, to ensure no stale metadata
        self.setup()
        self.loadPackages()
        self.yrepo =  None

    def setup(self):
        """
         Load the repos into repostore to query package dependencies
        """
        for repo in self.repos:
            self.yrepo = yum.yumRepo.YumRepository(repo['id'])
            self.yrepo.baseurl = ["file://%s/" % str(repo['relative_path'])]
            self.yrepo.basecachedir = CACHE_DIR
            self._repostore.add(self.yrepo)

    def loadPackages(self):
        """
         populate the repostore with packages
        """
        self._repostore._setup = True
        self._repostore.populateSack(which='all')

    def cleanup(self):
        """
         clean up the repo metadata cache from /tmp/cache/yum
        """
        for repo in self._repostore.repos:
            cachedir = "%s/%s" % (CACHE_DIR, repo)
            try:
                shutil.rmtree(cachedir)
            except IOError:
                pass

    def getDependencylist(self):
        """
         Get dependency list and suggested packages for package names provided.
         The dependency lookup is only one level in this case.
         The package name format could be any of the following:
         name, name.arch, name-ver-rel.arch, name-ver, name-ver-rel,
         epoch:name-ver-rel.arch, name-epoch:ver-rel.arch
        """                    
        
        ematch, match, unmatch = parsePackages(self._repostore.pkgSack, self.pkgs)
        pkgs = []
        for po in ematch + match:
            pkgs.append(po)
        results = self.__locateDeps(pkgs)
        return results

    def getRecursiveDepList(self):
        """
         Get dependency list and suggested packages for package names provided.
         The dependency lookup is recursive. All available packages in the repo
         are returned matching whatprovides.
         The package name format could be any of the following:
         name, name.arch, name-ver-rel.arch, name-ver, name-ver-rel,
         epoch:name-ver-rel.arch, name-epoch:ver-rel.arch
         returns a dictionary of {'n-v-r.a' : [n,v,e,r,a],...}
        """
        solved = []
        to_solve = self.pkgs
        all_results = {}    
        
        while to_solve:
            log.debug("Solving %s \n\n" % to_solve)
            results = self.getDependencylist()
            all_results.update(results)
            found = self.processResults(results)[0]
            solved += to_solve
            to_solve = []
            for dep, pkgs in found.items():
                for pkg in pkgs:
                    name, version, epoch, release, arch = pkg
                    ndep = "%s-%s-%s.%s" % (name, version, release, arch)
                    solved = list(set(solved))
                    if ndep not in solved:
                        to_solve.append(ndep)
            self.pkgs = to_solve
        return all_results

    def __locateDeps(self, pkgs):
        results = {}
        regex_filename_match = re.compile('[/*?]|\[[^]]*/[^]]*\]').match
                
        print("Solving Dependencies (%i): " % len(pkgs))
        pb = ProgressBar(prompt='', endTag=' - complete',
                     finalSize=len(pkgs), finalBarLength=40, stream=sys.stdout)
        pb.printAll(1)
                
        for pkg in pkgs:
            pb.addTo(1)
            pb.printIncrement()
            results[pkg] = {}
            reqs = pkg.requires
            reqs.sort()
            pkgresults = results[pkg]
            for req in reqs:
                (r, f, v) = req
                if r.startswith('rpmlib('):
                    continue
                satisfiers = []
                for po in self.__whatProvides(r, f, v):
                    # verify this po indeed provides the dep,
                    # el5 version could give some false positives
                    if regex_filename_match(r) or \
                       po.checkPrco('provides', (r, f, v)):
                        satisfiers.append(po)
                pkgresults[req] = satisfiers
        pb.printComplete()
        return results

    def __whatProvides(self, name, flags, version):
        try:
            return ListPackageSack(self._repostore.pkgSack.searchProvides((name, flags, version)))
        except:
            #perhaps we're on older version of yum try old style
            return ListPackageSack(self._repostore.pkgSack.searchProvides(name))

    def processResults(self, results):
        reqlist = {}
        notfound = {}
        for pkg in results:
            if len(results[pkg]) == 0:
                continue
            for req in results[pkg]:
                rlist = results[pkg][req]
                if not rlist:
                    # Unsatisfied dependency
                    notfound[prco_tuple_to_string(req)] = []
                    continue
                reqlist[prco_tuple_to_string(req)] = rlist
        found = {}
        for req, rlist in reqlist.items():
            found[req] = []
            for r in rlist:
                dep = [r.name, r.version, r.epoch, r.release, r.arch]
                if dep not in found[req]:
                    found[req].append(dep)
        return found, notfound

    def printable_result(self, results):
        print_doc_str = ""
        for pkg in results:
            if len(results[pkg]) == 0:
                continue
            for req in results[pkg]:
                rlist = results[pkg][req]
                print_doc_str += "\n dependency: %s \n" % prco_tuple_to_string(req)
                if not rlist:
                    # Unsatisfied dependency
                    print_doc_str += "   Unsatisfied dependency \n"
                    continue

                for po in rlist:
                    print_doc_str += "   provider: %s\n" % po.compactPrint()
        return print_doc_str


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "USAGE: python depsolver.py <repoid> <repodata_path> <pkgname1> <pkgname2> ....<pkgnameN>"
        sys.exit(0)    
    arg_repo = {'id' : sys.argv[1],
            'relative_path' : sys.argv[2],} #path to where repodata is located
    arg_pkgs = sys.argv[3:]
    dsolve = DepSolver([arg_repo], arg_pkgs)
    deplist = dsolve.getDependencylist()
    result_set = dsolve.processResults(deplist)
    print result_set
    print "Printable dependency Results: \n\n %s" % dsolve.printable_result(deplist)
