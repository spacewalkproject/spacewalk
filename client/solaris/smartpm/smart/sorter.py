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
from smart.const import ENFORCE, OPTIONAL, INSTALL, REMOVE, RECURSIONLIMIT
from smart.cache import PreRequires
from smart import *
import os, sys

MAXSORTERDEPTH = RECURSIONLIMIT-50

class LoopError(Error): pass

class ElementGroup(object):

    def __init__(self):
        self._relations = {} # (pred, succ) -> True

    def getRelations(self):
        return self._relations.keys()

    def addPredecessor(self, succ, pred):
        self._relations[(pred, succ)] = True

    def addSuccessor(self, pred, succ):
        self._relations[(pred, succ)] = True

class ElementOrGroup(ElementGroup): pass
class ElementAndGroup(ElementGroup): pass

class ElementSorter(object):

    def __init__(self):
        self._successors = {} # pred -> {(succ, kind): True}
        self._predcount = {}  # succ -> n
        self._groups = {}     # (pred, succ, kind) -> [group, ...]
        self._disabled = {}   # (pred, succ, kind) -> True

    def reset(self):
        self._successors.clear()
        self._groups.clear()

    def _getLoop(self, start, end=None):
        if end is None:
            end = start
        successors = self._successors
        path = [start]
        done = {}
        loop = {}
        while path:
            head = path[-1]
            dct = successors.get(head)
            if dct:
                for succ, kind in dct:
                    if (head, succ, kind) not in self._disabled:
                        if succ in loop or succ == end:
                            loop.update(dict.fromkeys(path, True))
                            loop[end] = True # If end != start
                        elif succ not in done:
                            done[succ] = True
                            path.append(succ)
                            break
                else:
                    path.pop()
            else:
                path.pop()
        return loop

    def _checkLoop(self, start, end=None):
        if end is None:
            end = start
        successors = self._successors
        queue = [start]
        done = {}
        while queue:
            elem = queue.pop()
            dct = successors.get(elem)
            if dct:
                for succ, kind in dct:
                    if (elem, succ, kind) not in self._disabled:
                        if succ == end:
                            return True
                        elif succ not in done:
                            done[succ] = True
                            queue.append(succ)
        return False

    def getLoops(self):
        successors = self._successors
        predcount = self._predcount
        loops = {}
        for elem in successors:
            if predcount.get(elem) and elem not in loops:
                loop = self._getLoop(elem)
                if loop:
                    loops.update(loop)
        return loops

    def getLoopPaths(self, loops):
        if not loops:
            return []
        successors = self._successors
        paths = []
        done = {}
        for elem in loops:
            if elem not in done:
                path = [elem]
                while path:
                    head = path[-1]
                    dct = successors.get(head)
                    if dct:
                        for succ, kind in dct:
                            if (succ in loops and
                                (head, succ, kind) not in self._disabled):
                                done[succ] = True
                                if succ == elem:
                                    paths.append(path+[elem])
                                else:
                                    headsucc = (head, succ)
                                    if headsucc not in done:
                                        done[headsucc] = True
                                        path.append(succ)
                                        break
                        else:
                            path.pop()
                    else:
                        path.pop()
        return paths

    def _breakLoops(self, elem, loops, rellock, reclock, depth=0):

        if depth > MAXSORTERDEPTH:
            return False

        result = True

        dct = self._successors.get(elem)
        if dct:
            for succ, kind in dct.keys():
                    
                # Should we care about this relation?
                if succ not in loops:
                    continue
                tup = (elem, succ, kind)
                if tup in self._disabled:
                    continue

                # Check if the loop for this specific relation is still alive.
                if not self._checkLoop(succ, elem):
                    continue

                # Some upper frame is already checking this. Protect
                # from infinite recursion.
                if tup in reclock:
                    result = False
                    break

                # If this relation is locked, our only chance is breaking
                # it forward.
                if tup in rellock:
                    reclock[tup] = True
                    loop = self._getLoop(succ, elem)
                    broke = self._breakLoops(succ, loop, rellock,
                                             reclock, depth+1)
                    del reclock[tup]
                    if not broke:
                        result = False
                    continue

                # If this relation is optional, break it now.
                if kind is OPTIONAL:
                    self._breakRelation(*tup)
                    continue

                # We have an enforced relation. Let's check if we
                # have OR groups that could satisfy it. 
                groups = self._groups.get(tup)
                if groups:
                    # Any enforced AND groups tell us we can't
                    # break this relation.
                    for group in groups:
                        if type(group) is ElementAndGroup:
                            groups = None
                            break


                if groups:

                    # Check if we can remove the relation from all groups.
                    reenable = {}
                    for group in groups:
                        reenable[group] = []
                        active = 0
                        for gpred, gsucc in group._relations:
                            gtup = (gpred, gsucc, kind)
                            if gtup in self._disabled:
                                if gtup not in rellock:
                                    reenable[group].append(gtup)
                            else:
                                active += 1
                                if active > 1: break
                        if active > 1:
                            del reenable[group]
                        elif not reenable[group]:
                            break

                    else:

                        # These relations must not be reenabled in
                        # the loop breaking steps below.
                        relations = self._breakRelation(*tup)
                        for rtup in relations:
                            rellock[rtup] = True

                        # Reenable the necessary relations, if possible.
                        # Every group must have at least one active relation
                        # so that we can disable our own relation.
                        for group in reenable:
                            succeeded = False
                            # Check if some iteration of _breakLoop() below
                            # already reenabled one relation with success.
                            for gtup in reenable[group]:
                                if gtup not in self._disabled:
                                    succeeded = True
                                    break
                            if succeeded:
                                continue
                            # Nope. Let's try to do that here.
                            for gtup in reenable[group]:
                                erelations = self._enableRelation(*gtup)
                                for etup in erelations:
                                    rellock[etup] = True
                                for epred, esucc, ekind in erelations:
                                    eloop = self._getLoop(esucc, epred)
                                    if (eloop and not
                                        self._breakLoops(esucc, eloop, rellock,
                                                         reclock, depth+1)):
                                        break
                                else:
                                    succeeded = True
                                for etup in erelations:
                                    del rellock[etup]
                                if succeeded:
                                    break
                                self._breakRelation(*gtup)
                            if not succeeded:
                                break
                        else:
                            # Done!
                            for rtup in relations:
                                del rellock[rtup]
                            continue

                        # Some OR group failed to exchange the relation,
                        # so we can't break our own relation.
                        for rtup in self._enableRelation(*tup):
                            del rellock[rtup]

                # Our last chance is breaking it forward.
                reclock[tup] = True
                loop = self._getLoop(succ, elem)
                broke = self._breakLoops(succ, loop, rellock, reclock, depth+1)
                del reclock[tup]
                if not broke:
                    result = False
    
        return result

    def _breakRelation(self, pred, succ, kind):
        tup = (pred, succ, kind)
        self._disabled[tup] = True
        relations = {tup: True}
        groups = self._groups.get(tup)
        if groups:
            for group in groups:
                if type(group) is ElementAndGroup:
                    for gpred, gsucc in group._relations:
                        gtup = (gpred, gsucc, kind)
                        self._disabled[gtup] = True
                        relations[gtup] = True
        return relations

    def _enableRelation(self, pred, succ, kind):
        tup = (pred, succ, kind)
        del self._disabled[tup]
        relations = {tup: True}
        groups = self._groups.get(tup)
        if groups:
            for group in groups:
                if type(group) is ElementAndGroup:
                    for gpred, gsucc in group._relations:
                        if gpred != pred or gsucc != succ:
                            gtup = (gpred, gsucc, kind)
                            del self._disabled[gtup]
                            relations[gtup] = True
        return relations

    def getSuccessors(self, elem):
        succs = {}
        for succ, kind in self._successors[elem]:
            if (pred, succ, kind) not in self._disabled:
                succs[succ] = True
        return succs

    def getPredecessors(self, elem):
        preds = {}
        for pred in self._successors:
            for succ, kind in self._successors[pred]:
                if succ == elem and (pred, succ, kind) not in self._disabled:
                    preds[pred] = True
        return preds

    def getAllSuccessors(self, elem):
        succs = {}
        queue = [elem]
        while queue:
            elem = queue.pop()
            for succ, kind in self._successors[elem]:
                if (succ not in all and
                    (elem, succ, kind) not in self._disabled):
                    succs[succ] = True
                    queue.append(succ)
        return succs

    def getAllPredecessors(self, elem):
        preds = {}
        queue = [elem]
        while queue:
            elem = queue.pop()
            for pred in self._successors:
                for succ, kind in self._successors[pred]:
                    if (succ == elem and
                        (pred, succ, kind) not in self._disabled):
                        preds[elem] = True
                        queue.append(elem)
        return preds

    def breakLoops(self):
        successors = self._successors
        result = True
        loops = self.getLoops()
        if loops:
            for elem in successors:
                if elem in loops:
                    if not self._breakLoops(elem, loops, {}, {}):
                        result = False
        return result

    def addElement(self, elem):
        if elem not in self._successors:
            self._successors[elem] = ()

    def addPredecessor(self, succ, pred, kind=ENFORCE):
        self.addSuccessor(pred, succ, kind)

    def addSuccessor(self, pred, succ, kind=ENFORCE):
        successors = self._successors
        predcount = self._predcount
        if succ not in successors:
            successors[succ] = ()
        dct = successors.get(pred)
        if not dct:
            successors[pred] = {(succ, kind): True}
            if succ not in predcount:
                predcount[succ] = 1
            else:
                predcount[succ] += 1
        elif (succ, kind) not in dct:
            dct[(succ, kind)] = True
            if succ not in predcount:
                predcount[succ] = 1
            else:
                predcount[succ] += 1
        groups = self._groups.get((pred, succ, kind))
        if groups:
            group = ElementAndGroup()
            group.addPredecessor(succ, pred)
            groups.append(group)

    def addGroup(self, group, kind=ENFORCE):
        if not group._relations:
            return
        if len(group._relations) == 1:
            pred, succ = iter(group._relations).next()
            self.addSuccessor(pred, succ, kind)
            return
        successors = self._successors
        predcount = self._predcount
        for pred, succ in group._relations:
            groups = self._groups.get((pred, succ, kind))
            if not groups:
                groups = self._groups[(pred, succ, kind)] = []
                dct = successors.get(pred)
                if dct and (succ, kind) in dct:
                    group = ElementAndGroup()
                    group.addSuccessor(pred, succ)
                    groups.append(group)
            groups.append(group)
            if succ not in successors:
                successors[succ] = ()
            dct = successors.get(pred)
            if not dct:
                successors[pred] = {(succ, kind): True}
                if succ not in predcount:
                    predcount[succ] = 1
                else:
                    predcount[succ] += 1
            elif (succ, kind) not in dct:
                dct[(succ, kind)] = True
                if succ not in predcount:
                    predcount[succ] = 1
                else:
                    predcount[succ] += 1

    def getSorted(self):

        successors = self._successors
        predcount = self._predcount.copy()

        self._profile(1)
        brokeall = self.breakLoops()
        self._profile(2)

        if not brokeall:
            raise LoopError, _("Unbreakable loops found while sorting")

        for pred, succ, kind in self._disabled:
            predcount[succ] -= 1

        result = [x for x in successors if not predcount.get(x)]

        for elem in result:
            dct = successors.get(elem)
            if dct:
                for succ, kind in dct:
                    if (elem, succ, kind) in self._disabled:
                        continue
                    left = predcount.get(succ)
                    if left is None:
                        continue
                    if left-1 == 0:
                        del predcount[succ]
                        result.append(succ)
                    else:
                        predcount[succ] -= 1

        self._profile(3)

        if len(result) != len(successors):
            raise Error, _("Internal error: there are still loops (%d != %d)!")\
                         % (len(result), len(successors))

        return result

    def _profile(self, id):
        if sysconf.get("sorter-profile"):
            import time
            if id == 1:
                successors = self._successors
                enforce = 0
                optional = 0
                ngroups = 0
                for pred in self._successors:
                    for succ, kind in successors[pred]:
                        groups = self._groups.get((pred, succ, kind))
                        if groups:
                            ngroups += len(groups)
                        if kind is ENFORCE:
                            enforce += 1
                        else:
                            optional += 1
                print "Number of elements:", len(successors)
                print "Number of relations:", enforce+optional
                print "Number of relation groups:", ngroups
                print "Number of enforced relations:", enforce
                print "Number of optional relations:", optional
                
                self._profile_start = time.clock()
            elif id == 2:
                print "Number of disabled relations:", len(self._disabled)
                print "Break delay: %.2fs" % (time.clock()-self._profile_start)
                self._profile_start = time.clock()
            elif id == 3:
                print "Sort delay: %.2fs" % (time.clock()-self._profile_start)

class ChangeSetSorter(ElementSorter):

    def __init__(self, changeset=None):
        ElementSorter.__init__(self)
        if changeset:
            self.setChangeSet(changeset)

    def setChangeSet(self, changeset):
        self.reset()
        for pkg in changeset:
            op = changeset[pkg]
            elem = (pkg, op)
            self.addElement(elem)

            # Packages being installed or removed must go in
            # before their dependencies are removed, or after
            # their dependencies are reinstalled.
            for req in pkg.requires:
                group = ElementOrGroup()
                for prv in req.providedby:
                    for prvpkg in prv.packages:
                        if prvpkg is pkg:
                            continue
                        if changeset.get(prvpkg) is INSTALL:
                            group.addSuccessor((prvpkg, INSTALL), elem)
                        elif prvpkg.installed:
                            if changeset.get(prvpkg) is not REMOVE:
                                break
                            group.addSuccessor(elem, (prvpkg, REMOVE))
                    else:
                        continue
                    break
                else:
                    relations = group.getRelations()
                    if relations:
                        # Should Requires of PreRequires become PreRequires
                        # as well?
                        if isinstance(req, PreRequires):
                            kind = ENFORCE
                        else:
                            kind = OPTIONAL
                        self.addGroup(group, kind)

            if op is INSTALL:

                # Upgraded packages being removed must go in
                # before this package's installation. Notice that
                # depending on the package manager, these remove
                # entries will probably be ripped out and dealt
                # by the package manager itself during upgrades.
                upgpkgs = [upgpkg for prv in pkg.provides
                                  for upg in prv.upgradedby
                                  for upgpkg in upg.packages]
                upgpkgs.extend([prvpkg for upg in pkg.upgrades
                                       for prv in upg.providedby
                                       for prvpkg in prv.packages])
                for upgpkg in upgpkgs:
                    if upgpkg is pkg:
                        continue
                    if changeset.get(upgpkg) is REMOVE:
                        self.addSuccessor((upgpkg, REMOVE), elem, ENFORCE)

                # Conflicted packages being removed must go in
                # before this package's installation.
                cnfpkgs = [prvpkg for cnf in pkg.conflicts
                                  for prv in cnf.providedby
                                  for prvpkg in prv.packages
                                   if prvpkg is not pkg]
                cnfpkgs.extend([cnfpkg for prv in pkg.provides
                                       for cnf in prv.conflictedby
                                       for cnfpkg in cnf.packages
                                        if cnfpkg is not pkg])
                for cnfpkg in cnfpkgs:
                    if cnfpkg is pkg:
                        continue
                    if changeset.get(cnfpkg) is REMOVE:
                        self.addSuccessor((cnfpkg, REMOVE), elem, ENFORCE)

        assert len(self._successors) == len(changeset)
