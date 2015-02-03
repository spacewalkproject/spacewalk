#
# Copyright (c) 2004 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
from smart.const import INSTALL, REMOVE, UPGRADE, FIX, REINSTALL, KEEP
from smart.cache import PreRequires, Package
from smart import *

class ChangeSet(dict):

    def __init__(self, cache, state=None):
        self._cache = cache
        if state:
            self.update(state)

    def getCache(self):
        return self._cache

    def getState(self):
        return self.copy()

    def setState(self, state):
        if state is not self:
            self.clear()
            self.update(state)

    def getPersistentState(self):
        state = {}
        for pkg in self:
            state[(pkg.__class__, pkg.name, pkg.version)] = self[pkg]
        return state

    def setPersistentState(self, state):
        self.clear()
        for pkg in self._cache.getPackages():
            op = state.get((pkg.__class__, pkg.name, pkg.version))
            if op is not None:
                self[pkg] = op

    def copy(self):
        return ChangeSet(self._cache, self)

    def set(self, pkg, op, force=False):
        if self.get(pkg) is op:
            return
        if op is INSTALL:
            if force or not pkg.installed:
                self[pkg] = INSTALL
            else:
                if pkg in self:
                    del self[pkg]
        else:
            if force or pkg.installed:
                self[pkg] = REMOVE
            else:
                if pkg in self:
                    del self[pkg]

    def installed(self, pkg):
        op = self.get(pkg)
        return op is INSTALL or pkg.installed and not op is REMOVE

    def difference(self, other):
        diff = ChangeSet(self._cache)
        for pkg in self:
            sop = self[pkg]
            if sop is not other.get(pkg):
                diff[pkg] = sop
        return diff

    def intersect(self, other):
        isct = ChangeSet(self._cache)
        for pkg in self:
            sop = self[pkg]
            if sop is other.get(pkg):
                isct[pkg] = sop
        return isct

    def __str__(self):
        l = []
        for pkg in self:
            l.append("%s %s\n" % (self[pkg] is INSTALL and "I" or "R", pkg))
        return "".join(l)

class Policy(object):

    def __init__(self, trans):
        self._trans = trans
        self._locked = {}
        self._sysconflocked = []
        self._priorities = {}

    def runStarting(self):
        self._priorities.clear()
        cache = self._trans.getCache()
        for pkg in pkgconf.filterByFlag("lock", cache.getPackages()):
            if pkg not in self._locked:
                self._sysconflocked.append(pkg)
                self._locked[pkg] = True

    def runFinished(self):
        self._priorities.clear()
        for pkg in self._sysconflocked:
            del self._locked[pkg]
        del self._sysconflocked[:]

    def getLocked(self, pkg):
        return pkg in self._locked

    def setLocked(self, pkg, flag):
        if flag:
            self._locked[pkg] = True
        else:
            if pkg in self._locked:
                del self._locked[pkg]

    def getLockedSet(self):
        return self._locked

    def getWeight(self, changeset):
        return 0

    def getPriority(self, pkg):
        priority = self._priorities.get(pkg)
        if priority is None:
            self._priorities[pkg] = priority = pkg.getPriority()
        return priority

    def getPriorityWeights(self, targetPkg, pkgs):
        set = {}
        lower = None
        for pkg in pkgs:
            priority = self.getPriority(pkg)
            if lower is None or priority < lower:
                lower = priority
            set[pkg] = priority
        for pkg in set:
            set[pkg] = -(set[pkg] - lower)*10
        return set

class PolicyInstall(Policy):
    """Give precedence for keeping functionality in the system."""

    def runStarting(self):
        Policy.runStarting(self)
        self._upgrading = upgrading = {}
        self._upgraded = upgraded = {}
        self._downgraded = downgraded = {}
        for pkg in self._trans.getCache().getPackages():
            # Precompute upgrade relations.
            for upg in pkg.upgrades:
                for prv in upg.providedby:
                    for prvpkg in prv.packages:
                        if prvpkg.installed:
                            if (self.getPriority(pkg) >=
                                self.getPriority(prvpkg)):
                                upgrading[pkg] = True
                                if prvpkg in upgraded:
                                    upgraded[prvpkg].append(pkg)
                                else:
                                    upgraded[prvpkg] = [pkg]
                            else:
                                if prvpkg in downgraded:
                                    downgraded[prvpkg].append(pkg)
                                else:
                                    downgraded[prvpkg] = [pkg]
            # Downgrades are upgrades if they have a higher priority.
            for prv in pkg.provides:
                for upg in prv.upgradedby:
                    for upgpkg in upg.packages:
                        if upgpkg.installed:
                            if (self.getPriority(pkg) >
                                self.getPriority(upgpkg)):
                                upgrading[pkg] = True
                                if upgpkg in upgraded:
                                    upgraded[upgpkg].append(pkg)
                                else:
                                    upgraded[upgpkg] = [pkg]
                            else:
                                if upgpkg in downgraded:
                                    downgraded[upgpkg].append(pkg)
                                else:
                                    downgraded[upgpkg] = [pkg]

    def runFinished(self):
        Policy.runFinished(self)
        del self._upgrading
        del self._upgraded
        del self._downgraded

    def getWeight(self, changeset):
        weight = 0
        upgrading = self._upgrading
        upgraded = self._upgraded
        downgraded = self._downgraded
        for pkg in changeset:
            if changeset[pkg] is REMOVE:
                # Upgrading a package that will be removed
                # is better than upgrading a package that will
                # stay in the system.
                for upgpkg in upgraded.get(pkg, ()):
                    if changeset.get(upgpkg) is INSTALL:
                        weight -= 1
                        break
                else:
                    for dwnpkg in downgraded.get(pkg, ()):
                        if changeset.get(dwnpkg) is INSTALL:
                            weight += 15
                            break
                    else:
                        weight += 20
            else:
                if pkg in upgrading:
                    weight += 2
                else:
                    weight += 3
        return weight

class PolicyRemove(Policy):
    """Give precedence to the choice with less changes."""

    def getWeight(self, changeset):
        weight = 0
        for pkg in changeset:
            if changeset[pkg] is REMOVE:
                weight += 1
            else:
                weight += 5
        return weight

class PolicyUpgrade(Policy):
    """Give precedence to the choice with more upgrades and smaller impact."""

    def runStarting(self):
        Policy.runStarting(self)
        self._upgrading = upgrading = {}
        self._upgraded = upgraded = {}
        self._sortbonus = sortbonus = {}
        self._requiredbonus = requiredbonus = {}
        queue = self._trans.getQueue()
        for pkg in self._trans.getCache().getPackages():
            # Precompute upgrade relations.
            for upg in pkg.upgrades:
                for prv in upg.providedby:
                    for prvpkg in prv.packages:
                        if (prvpkg.installed and
                            self.getPriority(pkg) >= self.getPriority(prvpkg)):
                            dct = upgrading.get(pkg)
                            if dct:
                                dct[prvpkg] = True
                            else:
                                upgrading[pkg] = {prvpkg: True}
                            lst = upgraded.get(prvpkg)
                            if lst:
                                lst.append(pkg)
                            else:
                                upgraded[prvpkg] = [pkg]
            # Downgrades are upgrades if they have a higher priority.
            for prv in pkg.provides:
                for upg in prv.upgradedby:
                    for upgpkg in upg.packages:
                        if (upgpkg.installed and
                            self.getPriority(pkg) > self.getPriority(upgpkg)):
                            dct = upgrading.get(pkg)
                            if dct:
                                dct[upgpkg] = True
                            else:
                                upgrading[pkg] = {upgpkg: True}
                            lst = upgraded.get(upgpkg)
                            if lst:
                                lst.append(pkg)
                            else:
                                upgraded[upgpkg] = [pkg]

        pkgs = self._trans._queue.keys()
        sortUpgrades(pkgs, self)
        for i, pkg in enumerate(pkgs):
            self._sortbonus[pkg] = -1./(i+100)

    def runFinished(self):
        Policy.runFinished(self)
        del self._upgrading
        del self._upgraded

    def getWeight(self, changeset):
        weight = 0
        upgrading = self._upgrading
        upgraded = self._upgraded
        sortbonus = self._sortbonus
        requiredbonus = self._requiredbonus

        installedcount = 0
        upgradedmap = {}
        for pkg in changeset:
            if changeset[pkg] is REMOVE:
                # Upgrading a package that will be removed
                # is better than upgrading a package that will
                # stay in the system.
                lst = upgraded.get(pkg, ())
                for lstpkg in lst:
                    if changeset.get(lstpkg) is INSTALL:
                        weight -= 1
                        break
                else:
                    weight += 3
            else:
                installedcount += 1
                upgpkgs = upgrading.get(pkg)
                if upgpkgs:
                    weight += sortbonus.get(pkg, 0)
                    upgradedmap.update(upgpkgs)
        upgradedcount = len(upgradedmap)
        weight += -30*upgradedcount+(installedcount-upgradedcount)
        return weight

class Failed(Error): pass

PENDING_REMOVE   = 1
PENDING_INSTALL  = 2
PENDING_UPDOWN   = 3

class Transaction(object):
    def __init__(self, cache, policy=None, changeset=None, queue=None):
        self._cache = cache
        self._policy = policy and policy(self) or Policy(self)
        self._changeset = changeset or ChangeSet(cache)
        self._queue = queue or {}

    def clear(self):
        self._changeset.clear()
        self._queue.clear()

    def getCache(self):
        return self._cache

    def getQueue(self):
        return self._queue

    def getPolicy(self):
        return self._policy

    def setPolicy(self, policy):
        self._policy = policy(self)

    def getWeight(self):
        return self._policy.getWeight(self._changeset)

    def getChangeSet(self):
        return self._changeset

    def setChangeSet(self, changeset):
        self._changeset = changeset

    def getState(self):
        return self._changeset.getState()

    def setState(self, state):
        self._changeset.setState(state)

    def __nonzero__(self):
        return bool(self._changeset)

    def __str__(self):
        return str(self._changeset)

    def _install(self, pkg, changeset, locked, pending, depth=0):
        #print "[%03d] _install(%s)" % (depth, pkg)
        #depth += 1

        locked[pkg] = True
        changeset.set(pkg, INSTALL)
        isinst = changeset.installed

        # Remove packages conflicted by this one.
        for cnf in pkg.conflicts:
            for prv in cnf.providedby:
                for prvpkg in prv.packages:
                    if prvpkg is pkg:
                        continue
                    if not isinst(prvpkg):
                        locked[prvpkg] = True
                        continue
                    if prvpkg in locked:
                        raise Failed, _("Can't install %s: conflicted package "
                                        "%s is locked") % (pkg, prvpkg)
                    self._remove(prvpkg, changeset, locked, pending, depth)
                    pending.append((PENDING_UPDOWN, prvpkg))

        # Remove packages conflicting with this one.
        for prv in pkg.provides:
            for cnf in prv.conflictedby:
                for cnfpkg in cnf.packages:
                    if cnfpkg is pkg:
                        continue
                    if not isinst(cnfpkg):
                        locked[cnfpkg] = True
                        continue
                    if cnfpkg in locked:
                        raise Failed, _("Can't install %s: it's conflicted by "
                                        "the locked package %s") \
                                      % (pkg, cnfpkg)
                    self._remove(cnfpkg, changeset, locked, pending, depth)
                    pending.append((PENDING_UPDOWN, cnfpkg))

        # Remove packages with the same name that can't
        # coexist with this one.
        namepkgs = self._cache.getPackages(pkg.name)
        for namepkg in namepkgs:
            if namepkg is not pkg and not pkg.coexists(namepkg):
                if not isinst(namepkg):
                    locked[namepkg] = True
                    continue
                if namepkg in locked:
                    raise Failed, _("Can't install %s: it can't coexist "
                                    "with %s") % (pkg, namepkg)
                self._remove(namepkg, changeset, locked, pending, depth)

        # Install packages required by this one.
        for req in pkg.requires:

            # Check if someone is already providing it.
            prvpkgs = {}
            found = False
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if isinst(prvpkg):
                        found = True
                        break
                    if prvpkg not in locked:
                        prvpkgs[prvpkg] = True
                else:
                    continue
                break
            if found:
                # Someone is already providing it. Good.
                continue

            # No one is currently providing it. Do something.

            if not prvpkgs:
                # No packages provide it at all. Give up.
                raise Failed, _("Can't install %s: no package provides %s") % \
                              (pkg, req)

            if len(prvpkgs) == 1:
                # Don't check locked here. prvpkgs was
                # already filtered above.
                self._install(prvpkgs.popitem()[0], changeset, locked,
                              pending, depth)
            else:
                # More than one package provide it. This package
                # must be post-processed.
                pending.append((PENDING_INSTALL, pkg, req, prvpkgs.keys()))

    def _remove(self, pkg, changeset, locked, pending, depth=0):
        #print "[%03d] _remove(%s)" % (depth, pkg)
        #depth += 1

        if pkg.essential:
            raise Failed, _("Can't remove %s: it's an essential package")

        locked[pkg] = True
        changeset.set(pkg, REMOVE)
        isinst = changeset.installed

        # Check packages requiring this one.
        for prv in pkg.provides:
            for req in prv.requiredby:
                # Check if someone installed is requiring it.
                for reqpkg in req.packages:
                    if isinst(reqpkg):
                        break
                else:
                    # No one requires it, so it doesn't matter.
                    continue

                # Check if someone installed is still providing it.
                prvpkgs = {}
                found = False
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if prvpkg is pkg:
                            continue
                        if isinst(prvpkg):
                            found = True
                            break
                        if prvpkg not in locked:
                            prvpkgs[prvpkg] = True
                    else:
                        continue
                    break
                if found:
                    # Someone is still providing it. Good.
                    continue

                # No one is providing it anymore. We'll have to do
                # something about it.

                if prvpkgs:
                    # There are other options, besides removing.
                    pending.append((PENDING_REMOVE, pkg, prv, req.packages,
                                    prvpkgs.keys()))
                else:
                    # Remove every requiring package, or
                    # upgrade/downgrade them to something which
                    # does not require this dependency.
                    for reqpkg in req.packages:
                        if not isinst(reqpkg):
                            continue
                        if reqpkg in locked:
                            raise Failed, _("Can't remove %s: %s is locked") \
                                          % (pkg, reqpkg)
                        self._remove(reqpkg, changeset, locked, pending, depth)
                        pending.append((PENDING_UPDOWN, reqpkg))

    def _updown(self, pkg, changeset, locked, depth=0):
        #print "[%03d] _updown(%s)" % (depth, pkg)
        #depth += 1

        isinst = changeset.installed
        getpriority = self._policy.getPriority

        pkgpriority = getpriority(pkg)

        # Check if any upgrading version of this package is installed.
        # If so, we won't try to install any other version.
        upgpkgs = {}
        for prv in pkg.provides:
            for upg in prv.upgradedby:
                for upgpkg in upg.packages:
                    if isinst(upgpkg):
                        return
                    if getpriority(upgpkg) < pkgpriority:
                        continue
                    if upgpkg not in locked and upgpkg not in upgpkgs:
                        upgpkgs[upgpkg] = True
        # Also check if any downgrading version with a higher
        # priority is installed.
        for upg in pkg.upgrades:
            for prv in upg.providedby:
                for prvpkg in prv.packages:
                    if getpriority(prvpkg) <= pkgpriority:
                        continue
                    if isinst(prvpkg):
                        return
                    if prvpkg not in locked and prvpkg not in upgpkgs:
                        upgpkgs[prvpkg] = True

        # No, let's try to upgrade it.
        getweight = self._policy.getWeight
        alternatives = [(getweight(changeset), changeset)]

        # Check if upgrading is possible.
        for upgpkg in upgpkgs:
            try:
                cs = changeset.copy()
                lk = locked.copy()
                _pending = []
                self._install(upgpkg, cs, lk, _pending, depth)
                if _pending:
                    self._pending(cs, lk, _pending, depth)
            except Failed:
                pass
            else:
                alternatives.append((getweight(cs), cs))

        # Is any downgrading version of this package installed?
        try:
            dwnpkgs = {}
            for upg in pkg.upgrades:
                for prv in upg.providedby:
                    for prvpkg in prv.packages:
                        if getpriority(prvpkg) > pkgpriority:
                            continue
                        if isinst(prvpkg):
                            raise StopIteration
                        if prvpkg not in locked:
                            dwnpkgs[prvpkg] = True
            # Also check if any upgrading version with a lower
            # priority is installed.
            for prv in pkg.provides:
                for upg in prv.upgradedby:
                    for upgpkg in upg.packages:
                        if getpriority(upgpkg) >= pkgpriority:
                            continue
                        if isinst(upgpkg):
                            raise StopIteration
                        if upgpkg not in locked:
                            dwnpkgs[upgpkg] = True
        except StopIteration:
            pass
        else:
            # Check if downgrading is possible.
            for dwnpkg in dwnpkgs:
                try:
                    cs = changeset.copy()
                    lk = locked.copy()
                    _pending = []
                    self._install(dwnpkg, cs, lk, _pending, depth)
                    if _pending:
                        self._pending(cs, lk, _pending, depth)
                except Failed:
                    pass
                else:
                    alternatives.append((getweight(cs), cs))

        # If there's only one alternative, it's the one currenlty in use.
        if len(alternatives) > 1:
            alternatives.sort()
            changeset.setState(alternatives[0][1])

    def _pending(self, changeset, locked, pending, depth=0):
        #print "[%03d] _pending()" % depth
        #depth += 1

        isinst = changeset.installed
        getweight = self._policy.getWeight

        updown = []
        while pending:
            item = pending.pop(0)
            kind = item[0]
            if kind == PENDING_UPDOWN:
                updown.append(item[1])
            elif kind == PENDING_INSTALL:
                kind, pkg, req, prvpkgs = item

                # Check if any prvpkg was already selected for installation
                # due to some other change.
                found = False
                for i in range(len(prvpkgs)-1,-1,-1):
                    prvpkg = prvpkgs[i]
                    if isinst(prvpkg):
                        found = True
                        break
                    if prvpkg in locked:
                        del prvpkgs[i]
                if found:
                    continue

                if not prvpkgs:
                    # No packages provide it at all. Give up.
                    raise Failed, _("Can't install %s: no package "
                                    "provides %s") % (pkg, req)

                if len(prvpkgs) > 1:
                    # More than one package provide it. We use _pending here,
                    # since any option must consider the whole change for
                    # weighting.
                    alternatives = []
                    failures = []
                    sortUpgrades(prvpkgs)
                    keeporder = 0.000001
                    pw = self._policy.getPriorityWeights(pkg, prvpkgs)
                    for prvpkg in prvpkgs:
                        try:
                            _pending = []
                            cs = changeset.copy()
                            lk = locked.copy()
                            self._install(prvpkg, cs, lk, _pending, depth)
                            if _pending:
                                self._pending(cs, lk, _pending, depth)
                        except Failed, e:
                            failures.append(unicode(e))
                        else:
                            alternatives.append((getweight(cs)+pw[prvpkg]+
                                                 keeporder, cs, lk))
                            keeporder += 0.000001
                    if not alternatives:
                        raise Failed, _("Can't install %s: all packages "
                                        "providing %s failed to install:\n%s")\
                                      % (pkg, req,  "\n".join(failures))
                    alternatives.sort()
                    changeset.setState(alternatives[0][1])
                    if len(alternatives) == 1:
                        locked.update(alternatives[0][2])
                else:
                    # This turned out to be the only way.
                    self._install(prvpkgs[0], changeset, locked,
                                  pending, depth)

            elif kind == PENDING_REMOVE:
                kind, pkg, prv, reqpkgs, prvpkgs = item

                # Check if someone installed is still requiring it.
                reqpkgs = [x for x in reqpkgs if isinst(x)]
                if not reqpkgs:
                    continue

                # Check if someone installed is providing it.
                found = False
                for prvpkg in prvpkgs:
                    if isinst(prvpkg):
                        found = True
                        break
                if found:
                    # Someone is still providing it. Good.
                    continue

                prvpkgs = [x for x in prvpkgs if x not in locked]

                # No one is providing it anymore. We'll have to do
                # something about it.

                # Try to install other providing packages.
                if prvpkgs:

                    alternatives = []
                    failures = []

                    pw = self._policy.getPriorityWeights(pkg, prvpkgs)
                    for prvpkg in prvpkgs:
                        try:
                            _pending = []
                            cs = changeset.copy()
                            lk = locked.copy()
                            self._install(prvpkg, cs, lk, _pending, depth)
                            if _pending:
                                self._pending(cs, lk, _pending, depth)
                        except Failed, e:
                            failures.append(unicode(e))
                        else:
                            alternatives.append((getweight(cs)+pw[prvpkg],
                                                cs, lk))

                if not prvpkgs or not alternatives:

                    # There's no alternatives. We must remove
                    # every requiring package.

                    for reqpkg in reqpkgs:
                        if reqpkg in locked and isinst(reqpkg):
                            raise Failed, _("Can't remove %s: requiring "
                                            "package %s is locked") % \
                                          (pkg, reqpkg)
                    for reqpkg in reqpkgs:
                        # We check again, since other actions may have
                        # changed their state.
                        if not isinst(reqpkg):
                            continue
                        if reqpkg in locked:
                            raise Failed, _("Can't remove %s: requiring "
                                            "package %s is locked") % \
                                          (pkg, reqpkg)
                        self._remove(reqpkg, changeset, locked,
                                     pending, depth)
                    continue

                # Then, remove every requiring package, or
                # upgrade/downgrade them to something which
                # does not require this dependency.
                cs = changeset.copy()
                lk = locked.copy()
                try:
                    for reqpkg in reqpkgs:
                        if reqpkg in locked and isinst(reqpkg):
                            raise Failed, _("%s is locked") % reqpkg
                    for reqpkg in reqpkgs:
                        if not cs.installed(reqpkg):
                            continue
                        if reqpkg in lk:
                            raise Failed, _("%s is locked") % reqpkg
                        _pending = []
                        self._remove(reqpkg, cs, lk, _pending, depth)
                        if _pending:
                            self._pending(cs, lk, _pending, depth)
                except Failed, e:
                    failures.append(unicode(e))
                else:
                    alternatives.append((getweight(cs), cs, lk))

                if not alternatives:
                    raise Failed, _("Can't install %s: all packages providing "
                                    "%s failed to install:\n%s") \
                                  % (pkg, prv,  "\n".join(failures))

                alternatives.sort()
                changeset.setState(alternatives[0][1])
                if len(alternatives) == 1:
                    locked.update(alternatives[0][2])

        for pkg in updown:
            self._updown(pkg, changeset, locked, depth)

        del pending[:]

    def _upgrade(self, pkgs, changeset, locked, pending, depth=0):
        #print "[%03d] _upgrade()" % depth
        #depth += 1

        isinst = changeset.installed
        getweight = self._policy.getWeight

        sortUpgrades(pkgs, self._policy)
        pkgs.reverse()

        lockedstate = {}

        origchangeset = changeset.copy()

        weight = getweight(changeset)
        for pkg in pkgs:
            if pkg in locked and not isinst(pkg):
                continue

            try:
                cs = changeset.copy()
                lk = locked.copy()
                _pending = []
                self._install(pkg, cs, lk, _pending, depth)
                if _pending:
                    self._pending(cs, lk, _pending, depth)
            except Failed, e:
                pass
            else:
                lockedstate[pkg] = lk
                csweight = getweight(cs)
                if csweight < weight:
                    weight = csweight
                    changeset.setState(cs)

        lockedstates = {}
        for pkg in pkgs:
            if changeset.get(pkg) is INSTALL:
                state = lockedstate.get(pkg)
                if state:
                    lockedstates.update(state)

        for pkg in changeset.keys():

            op = changeset.get(pkg)
            if (op and op != origchangeset.get(pkg) and
                pkg not in locked and pkg not in lockedstates):

                try:
                    cs = changeset.copy()
                    lk = locked.copy()
                    _pending = []
                    if op is REMOVE:
                        self._install(pkg, cs, lk, _pending, depth)
                    elif op is INSTALL:
                        self._remove(pkg, cs, lk, _pending, depth)
                    if _pending:
                        self._pending(cs, lk, _pending, depth)
                except Failed, e:
                    pass
                else:
                    csweight = getweight(cs)
                    if csweight < weight:
                        weight = csweight
                        changeset.setState(cs)

    def _fix(self, pkgs, changeset, locked, pending, depth=0):
        #print "[%03d] _fix()" % depth
        #depth += 1

        getweight = self._policy.getWeight
        isinst = changeset.installed

        for pkg in pkgs:

            if not isinst(pkg):
                continue

            # Is it broken at all?
            try:
                for req in pkg.requires:
                    for prv in req.providedby:
                        for prvpkg in prv.packages:
                            if isinst(prvpkg):
                                break
                        else:
                            continue
                        break
                    else:
                        iface.debug(_("Unsatisfied dependency: "
                                      "%s requires %s") % (pkg, req))
                        raise StopIteration
                for cnf in pkg.conflicts:
                    for prv in cnf.providedby:
                        for prvpkg in prv.packages:
                            if prvpkg is pkg:
                                continue
                            if isinst(prvpkg):
                                iface.debug(_("Unsatisfied dependency: "
                                              "%s conflicts with %s")
                                            % (pkg, prvpkg))
                                raise StopIteration
                for prv in pkg.provides:
                    for cnf in prv.conflictedby:
                        for cnfpkg in cnf.packages:
                            if cnfpkg is pkg:
                                continue
                            if isinst(cnfpkg):
                                iface.debug(_("Unsatisfied dependency: "
                                              "%s conflicts with %s")
                                            % (cnfpkg, pkg))
                                raise StopIteration
                # Check packages with the same name that can't
                # coexist with this one.
                namepkgs = self._cache.getPackages(pkg.name)
                for namepkg in namepkgs:
                    if (isinst(namepkg) and namepkg is not pkg
                        and not pkg.coexists(namepkg)):
                        iface.debug(_("Package %s can't coexist with %s") %
                                    (namepkg, pkg))
                        raise StopIteration
            except StopIteration:
                pass
            else:
                continue

            # We have a broken package. Fix it.

            alternatives = []
            failures = []

            # Try to fix by installing it.
            try:
                cs = changeset.copy()
                lk = locked.copy()
                _pending = []
                self._install(pkg, cs, lk, _pending, depth)
                if _pending:
                    self._pending(cs, lk, _pending, depth)
            except Failed, e:
                failures.append(unicode(e))
            else:
                # If they weight the same, it's better to keep the package.
                alternatives.append((getweight(cs)-0.000001, cs))

            # Try to fix by removing it.
            try:
                cs = changeset.copy()
                lk = locked.copy()
                _pending = []
                self._remove(pkg, cs, lk, _pending, depth)
                if _pending:
                    self._pending(cs, lk, _pending, depth)
                self._updown(pkg, cs, lk, depth)
            except Failed, e:
                failures.append(unicode(e))
            else:
                alternatives.append((getweight(cs), cs))

            if not alternatives:
                raise Failed, _("Can't fix %s:\n%s") % \
                              (pkg, "\n".join(failures))

            alternatives.sort()
            changeset.setState(alternatives[0][1])

    def enqueue(self, pkg, op):
        if op is UPGRADE:
            isinst = self._changeset.installed
            _upgpkgs = {}
            try:
                pkgpriority = pkg.getPriority()
                for prv in pkg.provides:
                    for upg in prv.upgradedby:
                        for upgpkg in upg.packages:
                            if upgpkg.getPriority() < pkgpriority:
                                continue
                            if isinst(upgpkg):
                                raise StopIteration
                            _upgpkgs[upgpkg] = True
                for upg in pkg.upgrades:
                    for prv in upg.providedby:
                        for prvpkg in prv.packages:
                            if prvpkg.getPriority() <= pkgpriority:
                                continue
                            if isinst(prvpkg):
                                raise StopIteration
                            _upgpkgs[prvpkg] = True
            except StopIteration:
                pass
            else:
                for upgpkg in _upgpkgs:
                    self._queue[upgpkg] = op
        else:
            self._queue[pkg] = op

    def run(self):

        self._policy.runStarting()

        try:
            changeset = self._changeset.copy()
            isinst = changeset.installed
            locked = self._policy.getLockedSet().copy()
            pending = []

            for pkg in self._queue:
                op = self._queue[pkg]
                if op is KEEP:
                    if pkg in changeset:
                        del changeset[pkg]
                elif op is INSTALL:
                    if not isinst(pkg) and pkg in locked:
                        raise Failed, _("Can't install %s: it's locked") % pkg
                    changeset.set(pkg, INSTALL)
                elif op is REMOVE:
                    if isinst(pkg) and pkg in locked:
                        raise Failed, _("Can't remove %s: it's locked") % pkg
                    changeset.set(pkg, REMOVE)
                elif op is REINSTALL:
                    if pkg in locked:
                        raise Failed, _("Can't reinstall %s: it's locked")%pkg
                    changeset.set(pkg, INSTALL, force=True)

            upgpkgs = []
            fixpkgs = []
            for pkg in self._queue:
                op = self._queue[pkg]
                if op is KEEP:
                    if pkg.installed:
                        op = INSTALL
                    else:
                        op = REMOVE
                if op is INSTALL or op is REINSTALL:
                    self._install(pkg, changeset, locked, pending)
                elif op is REMOVE:
                    self._remove(pkg, changeset, locked, pending)
                elif op is UPGRADE:
                    upgpkgs.append(pkg)
                elif op is FIX:
                    fixpkgs.append(pkg)

            if pending:
                self._pending(changeset, locked, pending)

            if upgpkgs:
                self._upgrade(upgpkgs, changeset, locked, pending)

            if fixpkgs:
                self._fix(fixpkgs, changeset, locked, pending)

            self._changeset.setState(changeset)

        finally:
            self._queue.clear()
            self._policy.runFinished()


class ChangeSetSplitter(object):
    # This class operates on *sane* changesets.

    DEBUG = 0

    def __init__(self, changeset, forcerequires=True):
        self._changeset = changeset
        self._forcerequires = forcerequires
        self._locked = {}

    def getForceRequires(self):
        return self._userequires

    def setForceRequires(self, flag):
        self._forcerequires = flag

    def getLocked(self, pkg):
        return pkg in self._locked

    def setLocked(self, pkg, flag):
        if flag:
            self._locked[pkg] = True
        else:
            if pkg in self._locked:
                del self._locked[pkg]

    def setLockedSet(self, set):
        self._locked.clear()
        self._locked.update(set)

    def resetLocked(self):
        self._locked.clear()

    def _remove(self, subset, pkg, locked):
        set = self._changeset

        # Include requiring packages being removed, or exclude
        # requiring packages being installed.
        for prv in pkg.provides:
            for req in prv.requiredby:

                reqpkgs = [reqpkg for reqpkg in req.packages if
                           subset.get(reqpkg) is INSTALL or
                           subset.get(reqpkg) is not REMOVE and
                           reqpkg.installed]

                if not reqpkgs:
                    continue

                # Check if some package that will stay
                # in the system or some package already
                # selected for installation provide the
                # needed dependency.
                found = False
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if (subset.get(prvpkg) is INSTALL or
                            (prvpkg.installed and not
                             subset.get(prvpkg) is REMOVE)):
                            found = True
                            break
                    else:
                        continue
                    break
                if found:
                    continue

                # Try to include some providing package
                # that is selected for installation.
                found = False
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if (set.get(prvpkg) is INSTALL and
                            prvpkg not in locked):
                            try:
                                self.include(subset, prvpkg, locked)
                            except Error:
                                pass
                            else:
                                found = True
                                break
                    else:
                        continue
                    break
                if found:
                    continue

                # Now, try to keep in the system some
                # providing package which is already installed.
                found = False
                wasbroken = True
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if set.get(prvpkg) is not REMOVE:
                            continue
                        wasbroken = False
                        # Package is necessarily in subset
                        # otherwise we wouldn't get here.
                        if prvpkg not in locked:
                            try:
                                self.exclude(subset, prvpkg, locked)
                            except Error:
                                pass
                            else:
                                found = True
                                break
                    else:
                        continue
                    break
                if found:
                    continue

                needed = (not wasbroken and
                          (self._forcerequires or
                           isinstance(req, PreRequires)))

                for reqpkg in reqpkgs:

                    # Finally, try to exclude the requiring
                    # package if it is being installed, or
                    # include it if it's being removed.
                    reqpkgop = set.get(reqpkg)
                    if reqpkgop and reqpkg not in locked:
                        try:
                            if reqpkgop is INSTALL:
                                self.exclude(subset, reqpkg, locked)
                            else:
                                self.include(subset, reqpkg, locked)
                        except Error:
                            if needed: raise
                        else:
                            continue

                    # Should we care about this?
                    if needed:
                        raise Error, _("No providers for '%s', "
                                       "required by '%s'") % (req, reqpkg)

        # Check upgrading/downgrading packages.
        relpkgs = [upgpkg for prv in pkg.provides
                          for upg in prv.upgradedby
                          for upgpkg in upg.packages]
        relpkgs.extend([prvpkg for upg in pkg.upgrades
                               for prv in upg.providedby
                               for prvpkg in prv.packages])
        if set[pkg] is INSTALL:
            # Package is being installed, but excluded from the
            # subset. Exclude every related package which is
            # being removed.
            for relpkg in relpkgs:
                if subset.get(relpkg) is REMOVE:
                    if relpkg in locked:
                        raise Error, _("Package '%s' is locked") % relpkg
                    self.exclude(subset, relpkg, locked)
        else:
            # Package is being removed, and included in the
            # subset. Include every related package which is
            # being installed.
            for relpkg in relpkgs:
                if set.get(relpkg) is INSTALL and relpkg not in subset:
                    if relpkg in locked:
                        raise Error, _("Package '%s' is locked") % relpkg
                    self.include(subset, relpkg, locked)

    def _install(self, subset, pkg, locked):
        set = self._changeset

        # Check all dependencies needed by this package.
        for req in pkg.requires:

            # Check if any already installed or to be installed
            # package will solve the problem.
            found = False
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if (subset.get(prvpkg) is INSTALL or
                        (prvpkg.installed and
                         subset.get(prvpkg) is not REMOVE)):
                        found = True
                        break
                else:
                    continue
                break
            if found:
                continue

            # Check if any package that could be installed
            # may solve the problem.
            found = False
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if (set.get(prvpkg) is INSTALL
                        and prvpkg not in locked):
                        try:
                            self.include(subset, prvpkg, locked)
                        except Error:
                            pass
                        else:
                            found = True
                            break
                else:
                    continue
                break
            if found:
                continue

            # Nope. Let's try to keep in the system some
            # package providing the dependency.
            found = False
            wasbroken = True
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if set.get(prvpkg) is not REMOVE:
                        continue
                    wasbroken = False
                    # Package is necessarily in subset
                    # otherwise we wouldn't get here.
                    if prvpkg not in locked:
                        try:
                            self.exclude(subset, prvpkg, locked)
                        except Error:
                            pass
                        else:
                            found = True
                            break
                else:
                    continue
                break
            if found or wasbroken:
                continue

            # There are no solutions for the problem.
            # Should we really care about it?
            if (self._forcerequires or
                isinstance(req, PreRequires)):
                raise Error, _("No providers for '%s', "
                               "required by '%s'") % (req, pkg)

        cnfpkgs = [prvpkg for cnf in pkg.conflicts
                          for prv in cnf.providedby
                          for prvpkg in prv.packages
                           if prvpkg is not pkg]
        cnfpkgs.extend([cnfpkg for prv in pkg.provides
                               for cnf in prv.conflictedby
                               for cnfpkg in cnf.packages
                                if cnfpkg is not pkg])

        for cnfpkg in cnfpkgs:
            if (subset.get(cnfpkg) is INSTALL or
                cnfpkg.installed and subset.get(cnfpkg) is not REMOVE):
                if cnfpkg not in set:
                    raise Error, _("Can't remove %s, which conflicts with %s")\
                                 % (cnfpkg, pkg)
                if set[cnfpkg] is INSTALL:
                    self.exclude(subset, cnfpkg, locked)
                else:
                    self.include(subset, cnfpkg, locked)

        # Check upgrading/downgrading packages.
        relpkgs = [upgpkg for prv in pkg.provides
                          for upg in prv.upgradedby
                          for upgpkg in upg.packages]
        relpkgs.extend([prvpkg for upg in pkg.upgrades
                               for prv in upg.providedby
                               for prvpkg in prv.packages])
        if set[pkg] is INSTALL:
            # Package is being installed, and included in the
            # subset. Include every related package which is
            # being removed.
            for relpkg in relpkgs:
                if set.get(relpkg) is REMOVE and relpkg not in subset:
                    if relpkg in locked:
                        raise Error, _("Package '%s' is locked") % relpkg
                    self.include(subset, relpkg, locked)
        else:
            # Package is being removed, but excluded from the
            # subset. Exclude every related package which is
            # being installed.
            for relpkg in relpkgs:
                if subset.get(relpkg) is INSTALL:
                    if relpkg in locked:
                        raise Error, _("Package '%s' is locked") % relpkg
                    self.exclude(subset, relpkg, locked)

    def include(self, subset, pkg, locked=None):
        set = self._changeset

        if locked is None:
            locked = self._locked
            if self.DEBUG: print "-"*79
        else:
            locked = locked.copy()
        if self.DEBUG:
            strop = set.get(pkg) is INSTALL and "INSTALL" or "REMOVE"
            print "Including %s of %s" % (strop, pkg)

        if pkg not in set:
            raise Error, _("Package '%s' is not in changeset") % pkg
        if pkg in locked:
            raise Error, _("Package '%s' is locked") % pkg

        locked[pkg] = True

        op = subset[pkg] = set[pkg]
        try:
            if op is INSTALL:
                self._install(subset, pkg, locked)
            else:
                self._remove(subset, pkg, locked)
        except Error, e:
            if self.DEBUG:
                print "FAILED: Including %s of %s: %s" % (strop, pkg, e)
            del subset[pkg]
            raise

    def exclude(self, subset, pkg, locked=None):
        set = self._changeset

        if locked is None:
            locked = self._locked
            if self.DEBUG: print "-"*79
        else:
            locked = locked.copy()
        if self.DEBUG:
            strop = set.get(pkg) is INSTALL and "INSTALL" or "REMOVE"
            print "Excluding %s of %s" % (strop, pkg)

        if pkg not in set:
            raise Error, _("Package '%s' is not in changeset") % pkg
        if pkg in locked:
            raise Error, _("Package '%s' is locked") % pkg

        locked[pkg] = True

        if pkg in subset:
            del subset[pkg]

        op = set[pkg]
        try:
            if op is INSTALL:
                self._remove(subset, pkg, locked)
            elif op is REMOVE:
                self._install(subset, pkg, locked)
        except Error, e:
            if self.DEBUG:
                print "FAILED: Excluding %s of %s: %s" % (strop, pkg, e)
            subset[pkg] = op
            raise

    def includeAll(self, subset):
        # Include everything that doesn't change locked packages
        set = self._changeset.get()
        for pkg in set.keys():
            try:
                self.include(subset, pkg)
            except Error:
                pass

    def excludeAll(self, subset):
        # Exclude everything that doesn't change locked packages
        set = self._changeset.get()
        for pkg in set.keys():
            try:
                self.exclude(subset, pkg)
            except Error:
                pass

def sortUpgrades(pkgs, policy=None):
    upgpkgs = {}
    for pkg in pkgs:
        dct = {}
        rupg = recursiveUpgrades(pkg, dct)
        del dct[pkg]
        upgpkgs[pkg] = dct
    pkgs.sort()
    pkgs.reverse()
    newpkgs = []
    priority = {}
    if policy:
        for pkg in pkgs:
            priority[pkg] = policy.getPriority(pkg)
    else:
        for pkg in pkgs:
            priority[pkg] = pkg.getPriority()
    for pkg in pkgs:
        pkgupgs = upgpkgs[pkg]
        for i in range(len(newpkgs)):
            newpkg = newpkgs[i]
            if newpkg in pkgupgs or priority[pkg] > priority[newpkg]:
                newpkgs.insert(i, pkg)
                break
        else:
            newpkgs.append(pkg)
    pkgs[:] = newpkgs

def recursiveUpgrades(pkg, set):
    set[pkg] = True
    for upg in pkg.upgrades:
        for prv in upg.providedby:
            for prvpkg in prv.packages:
                if prvpkg not in set:
                    recursiveUpgrades(prvpkg, set)

def sortInternalRequires(pkgs):
    rellst = []
    numrel = {}
    pkgmap = dict.fromkeys(pkgs, True)
    for pkg in pkgs:
        rellst.append((recursiveInternalRequires(pkgmap, pkg, numrel), pkg))
    rellst.sort()
    rellst.reverse()
    pkgs[:] = [x[1] for x in rellst]

def recursiveInternalRequires(pkgmap, pkg, numrel, done=None):
    if done is None:
        done = {}
    done[pkg] = True
    if pkg in numrel:
        return numrel[pkg]
    n = 0
    for prv in pkg.provides:
        for req in prv.requiredby:
            for relpkg in req.packages:
                if relpkg in pkgmap and relpkg not in done:
                    n += 1
                    if relpkg in numrel:
                        n += numrel[relpkg]
                    else:
                        n += recursiveInternalRequires(pkgmap, relpkg,
                                                       numrel, done)
    numrel[pkg] = n
    return n

def forwardRequires(pkg, map):
    for req in pkg.requires:
        if req not in map:
            map[req] = True
            for prv in req.providedby:
                if prv not in map:
                    map[prv] = True
                    for prvpkg in prv.packages:
                        if prvpkg not in map:
                            map[prvpkg] = True
                            forwardRequires(prvpkg, map)

def backwardRequires(pkg, map):
    for prv in pkg.provides:
        if prv not in map:
            map[prv] = True
            for req in prv.requiredby:
                if req not in map:
                    map[req] = True
                    for reqpkg in req.packages:
                        if reqpkg not in map:
                            map[reqpkg] = True
                            backwardRequires(reqpkg, map)

def forwardPkgRequires(pkg, map=None):
    if map is None:
        map = {}
    forwardRequires(pkg, map)
    for item in map.keys():
        if not isinstance(item, Package):
            del map[item]
    return map

def backwardPkgRequires(pkg, map=None):
    if map is None:
        map = {}
    backwardRequires(pkg, map)
    for item in map.keys():
        if not isinstance(item, Package):
            del map[item]
    return map

def getAlternates(pkg, cache):
    """
    For a given package, return every package that *might* get
    removed if the given package was installed. The alternate
    packages are every package that conflicts with any of the
    required packages, or require any package conflicting with
    any of the required packages.
    """
    conflicts = {}

    # Direct conflicts.
    for namepkg in cache.getPackages(pkg.name):
        if namepkg is not pkg and not pkg.coexists(namepkg):
            conflicts[(pkg, namepkg)] = True
    for cnf in pkg.conflicts:
        for prv in cnf.providedby:
            for prvpkg in prv.packages:
                if prvpkg is not pkg:
                    conflicts[(pkg, prvpkg)] = True
    for prv in pkg.provides:
        for cnf in prv.conflictedby:
            for cnfpkg in cnf.packages:
                if cnfpkg is not pkg:
                    conflicts[(pkg, cnfpkg)] = True

    # Conflicts of requires.
    queue = [pkg]
    done = {}
    while queue:
        qpkg = queue.pop()
        done[qpkg] = True
        for req in qpkg.requires:
            prvpkgs = {}
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if prvpkg is qpkg or prvpkg is pkg:
                        break
                    prvpkgs[prvpkg] = True
                else:
                    continue
                break
            else:
                for prvpkg in prvpkgs:
                    if prvpkg in done:
                        continue
                    done[prvpkg] = True
                    queue.append(prvpkg)
                    for namepkg in cache.getPackages(prvpkg.name):
                        if (namepkg not in prvpkgs and
                            namepkg is not pkg and
                            not prvpkg.coexists(namepkg)):
                            conflicts[(prvpkg, namepkg)] = True
                    for cnf in prvpkg.conflicts:
                        for prv in cnf.providedby:
                            for _prvpkg in prv.packages:
                                if (_prvpkg is not pkg and
                                    _prvpkg not in prvpkgs):
                                    conflicts[(prvpkg, _prvpkg)] = True
                    for prv in prvpkg.provides:
                        for cnf in prv.conflictedby:
                            for cnfpkg in cnf.packages:
                                if (cnfpkg is not pkg and
                                    cnfpkg not in prvpkgs):
                                    conflicts[(prvpkg, cnfpkg)] = True

    alternates = {}
    for reqpkg, cnfpkg in conflicts:
        print reqpkg, cnfpkg
        alternates[cnfpkg] = True
        for prv in cnfpkg.provides:
            for req in prv.requiredby:
                # Do not ascend if reqpkg also provides
                # what cnfpkg is offering.
                for _prv in req.providedby:
                    if reqpkg in _prv.packages:
                        break
                else:
                    for _reqpkg in req.packages:
                        alternates[_reqpkg] = True
                        alternates.update(backwardPkgRequires(_reqpkg))

    return alternates

def checkPackages(cache, pkgs, report=False, all=False, uninstalled=False):
    pkgs.sort()

    problems = False
    coexistchecked = {}
    for pkg in pkgs:

        if not all:
            if uninstalled:
                for loader in pkg.loaders:
                    if not loader.getInstalled():
                        break
                else:
                    continue
            elif not pkg.installed:
                continue

        for req in pkg.requires:
            for prv in req.providedby:
                for prvpkg in prv.packages:
                    if all:
                        break
                    elif uninstalled:
                        for loader in prvpkg.loaders:
                            if not loader.getInstalled():
                                break
                        else:
                            continue
                        break
                    elif prvpkg.installed:
                        break
                else:
                    continue
                break
            else:
                if report:
                    iface.info(_("Unsatisfied dependency: %s requires %s") %
                               (pkg, req))
                problems = True

        if not pkg.installed:
            continue

        for cnf in pkg.conflicts:
            for prv in cnf.providedby:
                for prvpkg in prv.packages:
                    if prvpkg is pkg:
                        continue
                    if prvpkg.installed:
                        if report:
                            iface.info(_("Unsatisfied dependency: "
                                         "%s conflicts with %s") %
                                       (pkg, prvpkg))
                        problems = True

        namepkgs = cache.getPackages(pkg.name)
        for namepkg in namepkgs:
            if (namepkg, pkg) in coexistchecked:
                continue
            coexistchecked[(pkg, namepkg)] = True
            if (namepkg.installed and namepkg is not pkg and
                not pkg.coexists(namepkg)):
                if report:
                    iface.info(_("Package %s can't coexist with %s") %
                               (namepkg, pkg))
                problems = True

    return not problems
