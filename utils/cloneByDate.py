#!/usr/bin/python
#
# Clonse channels by a particular date
#
# Copyright (c) 2008--2015 Red Hat, Inc.
#
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
# in this software or its documentation.
#

import os
import sys
import shutil
import tempfile
import xmlrpclib
import pprint
import subprocess
import datetime
import re
import time

from yum.Errors import RepoError


from depsolver import DepSolver

try:
    from spacewalk.common import rhnLog
    from spacewalk.common.rhnConfig import CFG, initCFG
    from spacewalk.common.rhnLog import log_debug, log_clean
    from spacewalk.satellite_tools.progress_bar import ProgressBar
    from spacewalk.server import rhnSQL
except ImportError:
    # pylint: disable=F0401
    _LIBPATH = "/usr/share/rhn"
    if _LIBPATH not in sys.path:
        sys.path.append(_LIBPATH)
    from server import rhnSQL
    from common import rhnLog
    from common.rhnLog import log_debug, log_clean
    from common.rhnConfig import CFG, initCFG
    from satellite_tools.progress_bar import ProgressBar


LOG_LOCATION = '/var/log/rhn/errata-clone.log'


def confirm(txt, options):
    if not options.assumeyes:
        response = raw_input(txt)
        while ['y', 'n'].count(response.lower()) == 0:
            response = raw_input(txt)
        if response.lower() == "n":
            print "Cancelling"
            sys.exit(0)
        print ""


def validate(channel_labels):
    tmp_dirs = {}
    for llabel in channel_labels:
        label = llabel[0]
        path = repodata(label)
        tmp = tempfile.mkdtemp()
        tmp_dirs[label] = tmp
        shutil.copytree(path, "%s/repodata/" % tmp)

    cmd = ["repoclosure"]
    for label, path in tmp_dirs.items():
        cmd.append("--repofrompath=%s,%s" % (label, path))
        cmd.append("--repoid=%s" % (label))
    subprocess.call(cmd)

    for tmp in tmp_dirs.values():
        shutil.rmtree(tmp, True)


def repodata(label):
    return "%s/rhn/repodata/%s" % (CFG.REPOMD_CACHE_MOUNT_POINT, label)


def create_repodata_link(src_path, dst_path):
    if not os.path.exists(os.path.dirname(dst_path)):
        # create a dir if missing
        os.makedirs(os.path.dirname(dst_path))
    if not os.path.exists(dst_path):
        if os.path.lexists(dst_path):
            # remove dead links
            os.unlink(dst_path)
        # create the link
        os.symlink(src_path, dst_path)


def remove_repodata_link(link_path):
    if os.path.exists(link_path):
        return os.unlink(link_path)


def diff_packages(old, new):
    old_hash = {}
    new_hash = {}
    to_ret = []

    for pkg in old:
        old_hash[pkg["id"]] = pkg
    for pkg in new:
        new_hash[pkg["id"]] = pkg
    id_diff = set(new_hash.keys()) - set(old_hash.keys())
    for pkg_id in id_diff:
        to_ret.append(new_hash[pkg_id])
    return to_ret


def main(options):
    xmlrpc = RemoteApi(options.server, options.username, options.password)
    db = DBApi()
    initCFG('server')
    rhnLog.initLOG(LOG_LOCATION)

    cleansed = vars(options)
    cleansed["password"] = "*****"
    log_clean(0, "")
    log_debug(0, "Started spacewalk-clone-by-date")
    log_clean(0, pprint.pformat(cleansed))

    print "Reading repository information."
    if options.use_update_date:
        options.use_update_date = 'update_date'
    else:
        options.use_update_date = 'issue_date'
    print "Using %s." % options.use_update_date

    cloners = []
    needed_channels = []
    errata = None
    if options.errata:
        errata = set(options.errata)
    for channel_list in options.channels:
        parents = None
        if options.parents:
            # if only the dest parent is specified, look up the src parent
            if len(options.parents) == 1:
                src_parent = xmlrpc.get_original(options.parents[0])
                if not src_parent:
                    print ("Channel %s is not a cloned channel." % options.parents[0])
                    sys.exit(1)
                print "Looking up the original channel for %s, %s found" % (
                    options.parents[0], src_parent)
                options.parents = [src_parent] + options.parents
            # options.parents is only set by command line, this must be the
            # only channel tree
            parents = options.parents

        # Handle the new-style channel specification that uses
        # key value pairs. Transform into channel / parent setup that
        # ChannelTreeCloner expects. This code has to be here now that you can
        # specify parents for multiple trees.
        # TODO: the channel / parents structure needs to be cleaned up throught
        # clone-by-date. Probably best thing would to make everywhere use the
        # dict structure instead of the list structure.
        for src_channel in channel_list.keys():
            dest_channel = channel_list[src_channel]
            # new-style config file channel specification
            if isinstance(dest_channel, dict):
                if 'label' not in dest_channel:
                    raise UserError("You must specify a label for the clone of %s" % src_channel)
                label = dest_channel['label']
                if 'name' in dest_channel:
                    name = dest_channel['name']
                else:
                    name = label
                if 'summary' in dest_channel:
                    summary = dest_channel['summary']
                else:
                    summary = label
                if 'description' in dest_channel:
                    description = dest_channel['description']
                else:
                    description = label
                # This is the options.parents equivalent for config files.
                # Add channels to parents option and remove from channels.
                if ('existing-parent-do-not-modify' in dest_channel
                        and dest_channel['existing-parent-do-not-modify']):
                    parents = [src_channel, label]
                    del channel_list[src_channel]
                else:  # else tranform channel_list entry to the list format
                    channel_list[src_channel] = [label, name, summary,
                                                 description]

        # before we start make sure we can get repodata for all channels
        # involved.
        channel_labels = channel_list.keys()
        for label in channel_labels:
            if not os.path.exists(repodata(label)):
                raise UserRepoError(label)
        # ensure the parent's channel metadata is available
        if parents:
            for label in parents:
                if not os.path.exists(repodata(label)):
                    raise UserRepoError(label)

        # if cloning specific errata validate that they actually exist
        # in the original channels
        if options.errata:
            for channel in channel_labels:
                channel_errata = set(xmlrpc.list_errata(channel))
                if len(errata - channel_errata) != 0:
                    print ("Error: all errata specified with --errata must "
                           + "exist in every original channel cloned in "
                           + "this operation.")
                    print ("Channel %s does not contain these errata: %s" %
                           (channel, errata - channel_errata))
                    sys.exit(1)

        tree_cloner = ChannelTreeCloner(channel_list, xmlrpc, db,
                                        options.to_date, options.blacklist,
                                        options.removelist,
                                        options.security_only, options.use_update_date,
                                        options.no_errata_sync, errata, parents)

        cloners.append(tree_cloner)
        needed_channels += tree_cloner.needing_create().values()

    if options.validate:
        if len(needed_channels) > 0:
            raise UserError("Cannot validate channels that do not exist %s" %
                            ', '.join(map(str, needed_channels)))
        for channel_list in options.channels:
            validate(channel_list.values())
        return

    if len(needed_channels) > 0:
        print "\nBy continuing the following channels will be created: "
        print ", ".join(needed_channels)
        confirm("\nContinue with channel creation (y/n)?", options)
        for cloner in cloners:
            cloner.create_channels(options.skip_depsolve)

    for tree_cloner in cloners:
        tree_cloner.prepare()

    if options.dry_run:
        for tree_cloner in cloners:
            d_errata = {}
            separator = "|"
            d_errata = tree_cloner.get_errata_to_clone()
            now = datetime.datetime.now()
            for ch in d_errata:
                log_file = ch + "_" + now.strftime("%Y-%m-%d-%H:%M")
                print "# Log file: " + log_file
                fh = open(log_file, 'w')
                for errata in d_errata[ch]:
                    line = ""
                    for item in list(set(errata) - set(['id'])):
                        line = line + str(errata[item]) + separator
                    fh.write(line + "\n")
                fh.close()
        sys.exit(0)

    print "\nBy continuing the following will be cloned:"
    total = 0
    for cloner in cloners:
        cloner.pre_summary()
        total += cloner.pending()

    if total == 0:
        print ("\nNo errata to clone, checking removelist.")
        for cloner in cloners:
            cloner.remove_packages()
        sys.exit(0)

    confirm("\nContinue with clone (y/n)?", options)
    for cloner in cloners:
        cloner.clone(options.skip_depsolve)
        cloner.remove_packages()


class ChannelTreeCloner:

    """Usage:
        a = ChannelTreeCloner(channel_hash, xmlrpc, db, to_date, blacklist,
            removelist, security_only, use_update_date,
            no_errata_sync, errata, parents)
        a.create_channels()
        a.prepare()
        a.clone()
         """
    # pylint: disable=R0902

    def __init__(self, channels, remote_api, db_api, to_date, blacklist,
                 removelist, security_only, use_update_date,
                 no_errata_sync, errata, parents=None):
        self.remote_api = remote_api
        self.db_api = db_api
        self.channel_map = channels
        self.to_date = to_date
        self.cloners = []
        self.blacklist = blacklist
        self.removelist = removelist
        if parents:
            self.src_parent = parents[0]
            self.dest_parent = parents[1]
            self.parents_specified = True
        else:
            self.src_parent = None
            self.dest_parent = None
            self.parents_specified = False
        self.channel_details = None
        self.security_only = security_only
        self.use_update_date = use_update_date
        self.no_errata_sync = no_errata_sync
        self.solver = None
        self.visited = {}

        self.validate_source_channels()
        for from_label in self.ordered_labels():
            to_label = self.channel_map[from_label][0]
            cloner = ChannelCloner(from_label, to_label, self.to_date,
                                   self.remote_api, self.db_api,
                                   self.security_only, self.use_update_date,
                                   self.no_errata_sync, errata)
            self.cloners.append(cloner)

    def needing_create(self):
        """
        returns a trimmed down version of channel_map where the
        value needs creating
        """
        to_create = {}
        existing = self.remote_api.list_channel_labels()
        if self.parents_specified:
            if (self.dest_parent not in existing
                    or self.src_parent not in existing):
                raise UserError("Channels specified with --parents must"
                                + " already exist.\nIf you want to clone the"
                                + " parent channels too simply add another"
                                + " --channels option.")
        for src, dest in self.channel_map.items():
            if dest[0] not in existing:
                to_create[src] = dest[0]
        return to_create

    def pending(self):
        total = 0
        for cloner in self.cloners:
            total += cloner.pending()
        return total

    def find_cloner(self, src_label):
        for cloner in self.cloners:
            if cloner.src_label() == src_label:
                return cloner

    def create_channels(self, skip_depsolve=False):
        to_create = self.needing_create()

        if len(to_create) == 0:
            return
        if self.parents_specified:
            dest_parent = [self.dest_parent]
        else:
            dest_parent = self.channel_map[self.src_parent]
        nvreas = []

        #clone the destination parent if it doesn't exist
        if dest_parent[0] in to_create.values():
            self.remote_api.clone_channel(self.src_parent, dest_parent, None)
            del to_create[self.src_parent]
            cloner = self.find_cloner(self.src_parent)
            nvreas += [pkg['nvrea'] for pkg in
                       cloner.reset_new_pkgs().values()]
        #clone the children
        for cloner in self.cloners:
            if cloner.dest_label() in to_create.values():
                dest = self.channel_map[cloner.src_label()]
                self.remote_api.clone_channel(cloner.src_label(),
                                              dest, dest_parent[0])
                nvreas += [pkg['nvrea'] for pkg in
                           cloner.reset_new_pkgs().values()]

        #dep solve all added packages with the parent channel
        if not skip_depsolve:
            self.dep_solve(nvreas, labels=(to_create.keys()
                                           + [self.src_parent]))

    def validate_source_channels(self):
        self.channel_details = self.remote_api.channel_details(
            self.channel_map, values=False)
        if not self.src_parent:
            self.src_parent = self.find_parent(self.channel_map.keys())
        self.validate_children(self.src_parent, self.channel_map.keys())

    def validate_dest_channels(self):
        self.channel_details = self.remote_api.channel_details(
            self.channel_map)
        if not self.dest_parent:
            self.dest_parent = self.find_parent(self.channel_map.values())
        self.validate_children(self.dest_parent, self.channel_map.values())

    def validate_children(self, parent, channel_list):
        """ Make sure all children are children of the parent"""
        for channel in channel_list:
            if isinstance(channel, type([])):
                channel = channel[0]
            if channel != parent:
                if (self.channel_details[channel]['parent_channel_label']
                        != parent):
                    raise UserError(("Child channel '%s' is not a child of "
                                     + "parent channel '%s'. If you are using --config "
                                     + "ensure you have not specified "
                                     + "existing-parent-do-not-modify on a child "
                                     + "channel.") % (channel, parent))

    def find_parent(self, label_list):
        found_list = []
        for label in label_list:
            if isinstance(label, type([])):
                label = label[0]
            if self.channel_details[label]['parent_channel_label'] == '':
                found_list.append(label)
        if len(found_list) == 0:
            raise UserError("Parent Channel not specified.")
        if len(found_list) > 1:
            raise UserError("Multiple parent channels specified within the "
                            + "same channel tree.")
        return found_list[0]

    def ordered_labels(self):
        """Return list of labels with parent first"""
        if self.parents_specified:
            return self.channel_map.keys()
        labels = self.channel_map.keys()
        labels.remove(self.src_parent)
        labels.insert(0, self.src_parent)
        return labels

    def prepare(self):
        self.validate_dest_channels()
        for cloner in self.cloners:
            cloner.prepare()

    def get_errata_to_clone(self):
        d_result = {}
        for cloner in self.cloners:
            d_result[cloner.src_label() + "_to_" + cloner.dest_label()] = \
                cloner.get_errata_to_clone()
        return d_result

    def pre_summary(self):
        for cloner in self.cloners:
            cloner.pre_summary()

    def clone(self, skip_depsolve=False):
        added_pkgs = []
        for cloner in self.cloners:
            cloner.process()
            pkg_diff = cloner.pkg_diff()
            added_pkgs += pkg_diff
            log_clean(0, "")
            log_clean(0, "%i packages were added to %s as a result of clone:"
                      % (len(pkg_diff), cloner.dest_label()))
            log_clean(0, "\n".join([pkg['nvrea'] for pkg in pkg_diff]))
        if len(added_pkgs) > 0 and not skip_depsolve:
            self.dep_solve([pkg['nvrea'] for pkg in added_pkgs])

    def dep_solve(self, nvrea_list, labels=None):
        if not labels:
            labels = self.channel_map.keys()
        repos = [{"id": label, "relative_path": repodata(label)}
                 for label in labels]

        print "Copying repodata, please wait."

        # dep solver expects the metadata to be in /repodata directory;
        # create temporary symlinks
        temp_repo_links = []
        repo = None
        for repo in repos:
            yum_repodata_path = "%s/repodata" % (repo['relative_path'])
            create_repodata_link(repo['relative_path'], yum_repodata_path)
            temp_repo_links.append(yum_repodata_path)
        try:
            try:
                self.solver = DepSolver(repos)
                self.__dep_solve(nvrea_list)
                self.solver.cleanup()
            except RepoError, e:
                raise UserRepoError(repo["id"], e.value)
        finally:
            # clean up temporary symlinks
            for link in temp_repo_links:
                remove_repodata_link(link)

    def __dep_solve(self, nvrea_list):
        self.solver.setPackages(nvrea_list)
        dep_results = self.solver.processResults(self.solver.getDependencylist())
        self.process_deps(dep_results)

    def process_deps(self, deps):
        # pylint: disable=deprecated-lambda, unnecessary-lambda
        list_to_set = lambda x: set(map(lambda y: tuple(y), x))
        needed_list = dict((channel[0], [])
                           for channel in self.channel_map.values())
        for cloner in self.cloners:
            if not cloner.dest_label() in self.visited:
                self.visited[cloner.dest_label()] = list_to_set(needed_list[cloner.dest_label()])
            self.visited[cloner.dest_label()] |= list_to_set(needed_list[cloner.dest_label()])

        print('Processing Dependencies:')
        pb = ProgressBar(prompt="", endTag=' - complete',
                         finalSize=len(deps), finalBarLength=40, stream=sys.stdout)
        pb.printAll(1)

        #loop through all the deps and find any that don't exist in the
        #  destination channels
        for pkg in deps:
            pb.addTo(1)
            pb.printIncrement()
            for solved_list in pkg.values():
                for cloner in self.cloners:
                    if cloner.src_pkg_exist(solved_list) and not cloner.dest_pkg_exist(solved_list):
                        #grab oldest package
                        needed_list[cloner.dest_label()].append(solved_list[0])

        added_nevras = []
        for cloner in self.cloners:
            needed = needed_list[cloner.dest_label()]
            needed_str = list_to_set(needed)
            for needed_pkg in needed_str:
                if needed_pkg in self.visited[cloner.dest_label()]:
                    needed.remove(list(needed_pkg))
            self.visited[cloner.dest_label()] |= needed_str
            if len(needed) > 0:
                added_nevras = added_nevras + cloner.process_deps(needed)

        pb.printComplete()

        # recursively solve dependencies to get dependencies-of-dependencies
        if len(added_nevras) > 0:
            print 'Dependencies added, looking for new dependencies'
            self.__dep_solve(added_nevras)

    def remove_packages(self):
        for cloner in self.cloners:
            if self.removelist:
                cloner.remove_removelist(self.removelist)
            if self.blacklist:
                cloner.remove_blacklisted(self.blacklist)


class ChannelCloner:
    # pylint: disable=R0902

    def __init__(self, from_label, to_label, to_date, remote_api, db_api,
                 security_only, use_update_date, no_errata_sync, errata):
        self.remote_api = remote_api
        self.db_api = db_api
        self.from_label = from_label
        self.to_label = to_label
        self.to_date = to_date
        self.from_pkg_hash = None
        self.errata_to_clone = None
        self.available_errata = None
        self.new_pkg_hash = {}
        self.old_pkg_hash = {}
        self.security_only = security_only
        self.use_update_date = use_update_date
        self.no_errata_sync = no_errata_sync
        self.errata = errata
        # construct a set of every erratum name in the original channel
        self.original_errata = set(self.remote_api.list_errata(self.from_label))
        self.original_pid_errata_map = {}
        self.bunch_size = 10

    def dest_label(self):
        return self.to_label

    def src_label(self):
        return self.from_label

    def pkg_diff(self):
        return diff_packages(self.old_pkg_hash.values(),
                             self.new_pkg_hash.values())

    def reset_original_pkgs(self):
        self.old_pkg_hash = dict((pkg['nvrea'], pkg)
                                 for pkg in self.remote_api.list_packages(self.to_label))
        return self.old_pkg_hash

    def reset_new_pkgs(self):
        self.new_pkg_hash = dict((pkg['nvrea'], pkg)
                                 for pkg in self.remote_api.list_packages(self.to_label))
        return self.new_pkg_hash

    def reset_from_pkgs(self):
        self.from_pkg_hash = dict((pkg['nvrea'], pkg)
                                  for pkg in self.remote_api.list_packages(self.from_label))

    def prepare(self):
        self.reset_original_pkgs()
        self.errata_to_clone, self.available_errata = self.get_errata()

    def pending(self):
        return len(self.errata_to_clone)

    def get_errata_to_clone(self):
        return self.errata_to_clone

    def pre_summary(self):
        print "  %s -> %s  (%i/%i Errata)" % (self.from_label, self.to_label,
                                              len(self.errata_to_clone), len(self.available_errata))

    def process(self):
        self.clone()
        #print "New packages added: %i" % (len(self.new_pkg_hash)
        #        - len(self.old_pkg_hash))

    def process_deps(self, needed_pkgs):
        needed_ids = []
        needed_names = []
        for pkg in needed_pkgs:
            found = self.src_pkg_exist([pkg])
            if found:
                needed_ids.append(found['id'])
                needed_names.append(found['nvrea'])

        needed_errata = []
        still_needed_pids = []
        for pid in needed_ids:
            if pid not in self.original_pid_errata_map:
                errata_list = self.remote_api.list_providing_errata(pid)
                for erratum in errata_list:
                    if erratum['advisory'] in self.original_errata:
                        if not self.to_date or (self.to_date and \
    datetime.datetime(*time.strptime(erratum[self.use_update_date], '%Y-%m-%d %H:%M:%S')[0:6]).date() <= \
    self.to_date.date()):
                            self.original_pid_errata_map[pid] = erratum['advisory']
                            break
                else:  # no match found, store so we don't repeat search
                    self.original_pid_errata_map[pid] = None
            if self.original_pid_errata_map[pid] != None:
                needed_errata.append(self.original_pid_errata_map[pid])
            else:
                still_needed_pids.append(pid)
        needed_ids = still_needed_pids

        for name in needed_names:
            log_clean(0, name)
        if len(needed_errata) > 0:
            log_clean(0, "")
            log_clean(0, "Cloning %i errata for dependencies to %s" %
                      (len(needed_errata), self.to_label))
        while(len(needed_errata) > 0):
            errata_set = needed_errata[:self.bunch_size]
            del needed_errata[:self.bunch_size]
            self.remote_api.clone_errata(self.to_label, errata_set)

        if len(needed_ids) > 0:
            log_clean(0, "")
            log_clean(0, "Adding %i needed dependencies to %s" %
                      (len(needed_ids), self.to_label))
            self.remote_api.add_packages(self.to_label, needed_ids)

        self.reset_new_pkgs()
        return needed_names

    def src_pkg_exist(self, needed_list):
        if not self.from_pkg_hash:
            self.reset_from_pkgs()
        return self.pkg_exists(needed_list, self.from_pkg_hash)

    def dest_pkg_exist(self, needed_list):
        return self.pkg_exists(needed_list, self.new_pkg_hash)

    @staticmethod
    def pkg_exists(needed_list, pkg_list):
        """Given a list of packages in [N, V, E, R, A] format, do any of them
            exist in the pkg_hash with key of N-V-R.A  format"""
        for i in needed_list:
            key = "%s-%s-%s.%s" % (i[0], i[1], i[3], i[4])
            if pkg_list.has_key(key):
                return pkg_list[key]
        return False

    def clone(self):
        errata_ids = [e["advisory_name"] for e in self.errata_to_clone]
        if len(errata_ids) == 0:
            return

        msg = 'Cloning Errata into %s (%i):' % (self.to_label, len(errata_ids))
        print msg
        log_clean(0, "")
        log_clean(0, msg)
        for e in self.errata_to_clone:
            log_clean(0, "%s - %s" % (e['advisory_name'], e['synopsis']))

        pb = ProgressBar(prompt="", endTag=' - complete',
                         finalSize=len(errata_ids), finalBarLength=40,
                         stream=sys.stdout)
        pb.printAll(1)
        while(len(errata_ids) > 0):
            errata_set = errata_ids[:self.bunch_size]
            del errata_ids[:self.bunch_size]
            self.remote_api.clone_errata(self.to_label, errata_set)
            pb.addTo(self.bunch_size)
            pb.printIncrement()

        self.reset_new_pkgs()
        pb.printComplete()

        if not self.no_errata_sync:
            log_clean(0, "")
            log_clean(0, "Synchronizing Errata in %s with originals"
                      % self.to_label)
            self.remote_api.sync_errata(self.to_label)

    def get_errata(self):
        """ Returns tuple of all available for cloning and what falls in
        the date range or is in the errata list"""
        available_errata = self.db_api.applicable_errata(self.from_label,
                                                         self.to_label)
        to_clone = []
        for err in available_errata:
            if self.errata:
                if err['advisory_name'] in self.errata:
                    to_clone.append(err)
            else:
                if (self.to_date and err[self.use_update_date].date()
                        <= self.to_date.date()):
                    if self.security_only:
                        if err['advisory_type'] == 'Security Advisory':
                            to_clone.append(err)
                    else:
                        to_clone.append(err)

        return (to_clone, available_errata)

    def __remove_packages(self, names_dict, pkg_list, name):
        """Base removal of packages
            names_dict  - dict containing  list of package names, with channel
                          lables as keys
            pkg_list  -  list of package dicts to consider
            name   - name of removal  'blacklist' or 'removelist', for display
        """
        found_ids = []
        found_names = []
        if not names_dict:
            return

        full_pkgs = []
        if names_dict.has_key("ALL"):
            full_pkgs += names_dict["ALL"]
        if names_dict.has_key(self.dest_label()):
            full_pkgs += names_dict[self.dest_label()]

        #add dollar signs to each one, other wise  foo would match foobar
        reg_ex = re.compile("$|".join(full_pkgs) + '$')
        for pkg in pkg_list:
            if reg_ex.match(pkg['name']):
                found_ids.append(pkg['id'])
                found_names.append(pkg['nvrea'])

        log_clean(0, "")
        log_clean(0, "%s: Removing %i packages from %s." %
                  (name, len(found_ids), self.to_label))
        log_clean(0, "\n".join(found_names))

        if len(found_ids) > 0:
            print "%s: Removing %i packages from %s" % (name, len(found_ids),
                                                        self.to_label)
            self.remote_api.remove_packages(self.to_label, found_ids)

    def remove_removelist(self, pkg_names):
        self.__remove_packages(pkg_names, self.reset_new_pkgs().values(),
                               "Removelist")

    def remove_blacklisted(self, pkg_names):
        self.reset_new_pkgs()
        self.__remove_packages(pkg_names, self.pkg_diff(), "Blacklist")


class RemoteApi:

    """ Class for connecting to the XMLRPC spacewalk interface"""

    cache = {}

    def __init__(self, server_url, username, password):
        self.client = xmlrpclib.Server(server_url)
        self.auth_time = None
        self.auth_token = None
        try:
            self.username = username
            self.password = password
            self.__login()
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString)

    def auth_check(self):
        """ makes sure that more than an hour hasn't passed since we
             logged in and will relogin if it has
        """
        if not self.auth_time or (datetime.datetime.now()
                                  - self.auth_time).seconds > 60 * 15:  # 15 minutes
            self.__login()

    def __login(self):
        self.auth_token = self.client.auth.login(self.username, self.password)
        self.auth_time = datetime.datetime.now()

    def list_channel_labels(self):
        self.auth_check()
        key = "chan_labels"
        if self.cache.has_key(key):
            return self.cache[key]

        chan_list = self.client.channel.listAllChannels(self.auth_token)
        to_ret = []
        for item in chan_list:
            to_ret.append(item["label"])
        self.cache[key] = to_ret
        return to_ret

    def channel_details(self, label_hash, keys=True, values=True):
        self.auth_check()
        to_ret = {}
        for src, dst in label_hash.items():
            if keys:
                to_ret[src] = self.get_details(src)
            if values:
                to_ret[dst[0]] = self.get_details(dst[0])
        return to_ret

    def list_packages(self, label):
        self.auth_check()
        pkg_list = self.client.channel.software.listAllPackages(
            self.auth_token, label)
        #name-ver-rel.arch,
        for pkg in pkg_list:
            pkg['nvrea'] = "%s-%s-%s.%s" % (pkg['name'], pkg['version'],
                                            pkg['release'], pkg['arch_label'])
        return pkg_list

    def clone_errata(self, to_label, errata_list):
        self.auth_check()
        self.client.errata.cloneAsOriginal(self.auth_token, to_label,
                                           errata_list)

    def sync_errata(self, to_label):
        self.auth_check()
        self.client.channel.software.syncErrata(self.auth_token, to_label)

    def get_details(self, label):
        self.auth_check()
        try:
            return self.client.channel.software.getDetails(self.auth_token,
                                                           label)
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString + ": " + label)

    def add_packages(self, label, package_ids):
        self.auth_check()
        while(len(package_ids) > 0):
            pkg_set = package_ids[:20]
            del package_ids[:20]
            self.client.channel.software.addPackages(self.auth_token, label,
                                                     pkg_set)

    def remove_packages(self, label, package_ids):
        self.auth_check()
        while(len(package_ids) > 0):
            pkg_set = package_ids[:20]
            del package_ids[:20]
            self.client.channel.software.removePackages(self.auth_token,
                                                        label, pkg_set)

    def clone_channel(self, original_label, channel, parent):
        self.auth_check()
        details = {'name': channel[0], 'label': channel[0],
                   'summary': channel[0]}
        if len(channel) > 1:
            details['name'] = channel[1]
        if len(channel) > 2:
            details['summary'] = channel[2]
        if len(channel) > 3:
            details['description'] = channel[3]
        if parent and parent != '':
            details['parent_label'] = parent

        msg = "Cloning %s to %s with original package set." % (original_label,
                                                               details['label'])
        log_clean(0, "")
        log_clean(0, msg)
        print(msg)
        self.client.channel.software.clone(self.auth_token, original_label,
                                           details, True)

    def list_errata(self, channel_label):
        self.auth_check()
        errata = self.client.channel.software.listErrata(self.auth_token,
                                                         channel_label)
        return [erratum['advisory_name'] for erratum in errata]

    def get_original(self, clone_label):
        self.auth_check()
        return self.client.channel.software.getDetails(self.auth_token,
                                                       clone_label)['clone_original']

    def list_providing_errata(self, pid):
        self.auth_check()
        return self.client.packages.listProvidingErrata(self.auth_token, pid)


class DBApi:

    """Class for connecting to the spacewalk DB"""

    def __init__(self):
        initCFG('server')
        rhnSQL.initDB()

    @staticmethod
    def applicable_errata(from_label, to_label):
        """list of errata that is applicable to be cloned, used db because we
            need to exclude cloned errata too"""
        h = rhnSQL.prepare("""
        select e.id, e.advisory_name, e.advisory_type, e.issue_date,
               e.synopsis, e.update_date
        from rhnErrata e  inner join
             rhnChannelErrata ce on e.id = ce.errata_id inner join
             rhnChannel c on c.id = ce.channel_id
        where C.label = :from_label and
              e.id not in
              (select e2.id
                 from rhnErrata e2 inner join
                      rhnChannelErrata ce2 on ce2.errata_id = e2.id inner join
                      rhnChannel c2 on c2.id = ce2.channel_id
                where c2.label = :to_label
                UNION
               select cloned.original_id
                 from rhnErrata e2 inner join
                      rhnErrataCloned cloned on cloned.id = e2.id inner join
                      rhnChannelErrata ce2 on ce2.errata_id = e2.id inner join
                      rhnChannel c2 on c2.id = ce2.channel_id
                where c2.label = :to_label)
        """)
        h.execute(from_label=from_label, to_label=to_label)
        to_ret = h.fetchall_dict() or []
        return to_ret


class UserError(Exception):

    def __init__(self, msg):
        Exception.__init__(self)
        self.msg = msg

    def __str__(self):
        return self.msg


class UserRepoError(UserError):

    def __init__(self, label, yum_error=None):
        msg = ("Unable to read repository information.\n"
               + "Please verify repodata has been generated in "
               + "/var/cache/rhn/repodata/%s." % label)
        if yum_error:
            msg += "\nError from yum: %s" % yum_error
        UserError.__init__(self, msg)
