#!/usr/bin/python
#
# Clonse channels by a particular date
#
# Copyright (c) 2008 Red Hat, Inc.
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
    for label in channel_labels:        
        path = repodata(label)
        tmp = tempfile.mkdtemp()        
        tmp_dirs[label] = tmp
        shutil.copytree(path, "%s/repodata/" % tmp)

    cmd = ["repoclosure"]
    for label, path in tmp_dirs.items():
        cmd.append("--repofrompath=%s,%s" %(label, path))
        cmd.append("--repoid=%s" % (label)) 
    subprocess.call(cmd)
            
    for tmp in tmp_dirs.values():
        shutil.rmtree(tmp, True)

def repodata(label):
    return "%s/rhn/repodata/%s" % ( CFG.REPOMD_CACHE_MOUNT_POINT, label)

        
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
    
    
    cloners = []
    needed_channels = []
    for channel_list in options.channels:
        tree_cloner = ChannelTreeCloner(channel_list, xmlrpc, db, 
                                        options.to_date, options.blacklist, options.removelist)
        cloners.append(tree_cloner)
        needed_channels += tree_cloner.needing_create().values()

    
    if options.validate:
        if len(needed_channels) > 0:
            raise UserError("Cannot validate channels that do not exist %s" % ', '.join(map(str, needed_channels)))
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
        a = ChannelTreeCloner(channel_hash, xmlrpc, db, to_date, blacklist)
        a.create_channels()
        a.prepare()
        a.clone()
         """
    # pylint: disable=R0902
    def __init__(self, channels, remote_api, db_api, to_date, blacklist, 
                                            removelist):
        self.remote_api = remote_api
        self.db_api = db_api
        self.channel_map = channels
        self.to_date = to_date
        self.cloners = []
        self.blacklist = blacklist
        self.removelist = removelist
        self.dest_parent = None
        self.src_parent = None
        self.channel_details = None        
        
        self.validate_source_channels()        
        for from_label in self.ordered_labels():
            to_label = self.channel_map[from_label]            
            cloner = ChannelCloner(from_label, to_label, self.to_date, 
                                   self.remote_api, self.db_api)
            self.cloners.append(cloner)
            
    
    def needing_create(self):
        """
        returns a trimmed down version of channel_map where the 
        value needs creating    
        """
        to_create = {}        
        existing = self.remote_api.list_channel_labels()
        for src, dest in self.channel_map.items():
            if dest not in existing:
                to_create[src] = dest
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
        dest_parent = self.channel_map[self.src_parent]
        nvreas  = []
                
        #clone the destination parent if it doesn't exist
        if dest_parent in to_create.values():            
            self.remote_api.clone_channel(self.src_parent, dest_parent, None)
            del to_create[self.src_parent]
            cloner = self.find_cloner(self.src_parent)          
            nvreas += [ pkg['nvrea'] for pkg in  
                       cloner.reset_new_pkgs().values()]
        #clone the children
        for cloner in self.cloners:
            if cloner.dest_label() in to_create.values():                                            
                self.remote_api.clone_channel(cloner.src_label(), 
                                              cloner.dest_label(), dest_parent)
                nvreas += [ pkg['nvrea'] for pkg in  
                           cloner.reset_new_pkgs().values()]
                        
        #dep solve all added packages with the parent channel
        if not skip_depsolve:
            self.dep_solve(nvreas, labels=(to_create.keys() + [self.src_parent]))
        
                
    def validate_source_channels(self):
        self.channel_details = self.remote_api.channel_details(
                                       self.channel_map, values=False)
        self.src_parent = self.find_parent(self.channel_map.keys())
        self.validate_children(self.src_parent, self.channel_map.keys())        

    def validate_dest_channels(self):       
        self.channel_details = self.remote_api.channel_details(self.channel_map)
        self.dest_parent = self.find_parent(self.channel_map.values())
        self.validate_children(self.dest_parent, self.channel_map.values())
    
    def validate_children(self, parent, label_list):
        """ Make sure all children are children of the parent"""
        for label in label_list:
            if label != parent:
                if self.channel_details[label]['parent_channel_label'] != parent:
                    raise UserError("Child channel '%s' is not a child of parent channel '%s'" % (label, parent))
                    
    def find_parent(self, label_list):        
        found_list = []
        for label in label_list:
            if self.channel_details[label]['parent_channel_label'] == '':
                found_list.append(label)
        if len(found_list) == 0:
            raise UserError("Parent Channel not specified.")
        if len(found_list) > 1:
            raise UserError("Multiple parent channels specified within the same channel tree.")
        return found_list[0]

    def ordered_labels(self):
        """Return list of labels with parent first"""
        labels = self.channel_map.keys()
        labels.remove(self.src_parent)
        labels.insert(0, self.src_parent)
        return labels
        
    def prepare(self):
        self.validate_dest_channels()        
        for cloner in self.cloners:
            cloner.prepare()            

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
            log_clean(0, "%i packages were added to %s as a result of clone:" % (len(pkg_diff), cloner.dest_label()))
            log_clean(0, "\n".join([pkg['nvrea'] for pkg in pkg_diff]))  
        if len(added_pkgs) > 0 and not skip_depsolve:          
            self.dep_solve([pkg['nvrea'] for pkg in added_pkgs])
            

    def dep_solve(self, nvrea_list, labels=None):             
        if not labels:
            labels = self.channel_map.keys()
        repos = [{"id":label, "relative_path":repodata(label)} for label in labels]

        print "Copying repodata, please wait."

        # dep solver expects the metadata to be in /repodata directory;
        # create temporary symlinks
        temp_repo_links = []
        for repo in repos:
            yum_repodata_path = "%s/repodata" % (repo['relative_path'])
            create_repodata_link(repo['relative_path'], yum_repodata_path)
            temp_repo_links.append(yum_repodata_path)
        try:
            solver = DepSolver(repos, nvrea_list)
            dep_results = solver.processResults(solver.getDependencylist())
            solver.cleanup()
            self.process_deps(dep_results)
        except RepoError, e:
            raise UserError("""Unable to read repository information.
                Please verify repodata has been generated in /var/cache/rhn/repodata/LABEL.
                Error from yum: %s""" % e.value)
        
        # clean up temporary symlinks
        for link in temp_repo_links:
            remove_repodata_link(link)
        
    def process_deps(self, deps):
        needed_list = dict((label, []) for label in self.channel_map.values())
        unsolved_deps = []
        
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
                found = False                
                for cloner in self.cloners:
                    exists_from = cloner.src_pkg_exist(solved_list)
                    exists_to = cloner.dest_pkg_exist(solved_list) 
                    if  exists_from and not exists_to:                        
                        needed_list[cloner.dest_label()].append(solved_list[0]) #grab oldest package 
                    elif exists_from:
                        found = True                    
                if not found:
                    unsolved_deps.append((pkg))
        pb.printComplete()
   
                            
        for cloner in self.cloners:
            needed = needed_list[cloner.dest_label()]
            if len(needed) > 0:
                cloner.process_deps(needed)
                                  
    def remove_packages(self):
        for cloner in self.cloners:
            if self.removelist:
                cloner.remove_removelist(self.removelist)
            if self.blacklist:
                cloner.remove_blacklisted(self.blacklist)

class ChannelCloner:
    # pylint: disable=R0902
    def __init__(self, from_label, to_label, to_date, remote_api, db_api):
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
        
        
    def dest_label(self):
        return self.to_label
    
    def src_label(self):
        return self.from_label
    
    def pkg_diff(self):
        return diff_packages(self.old_pkg_hash.values(), self.new_pkg_hash.values()) 

        
    def reset_original_pkgs(self):        
        self.old_pkg_hash = dict((pkg['nvrea'], pkg) for pkg in self.remote_api.list_packages(self.to_label))         
        return self.old_pkg_hash
        
    def reset_new_pkgs(self):
        self.new_pkg_hash = dict((pkg['nvrea'], pkg) for pkg in self.remote_api.list_packages(self.to_label)) 
        return self.new_pkg_hash
        
    def reset_from_pkgs(self):
        self.from_pkg_hash = dict((pkg['nvrea'], pkg) for pkg in self.remote_api.list_packages(self.from_label))
            
    def prepare(self):        
        self.reset_original_pkgs()
        self.errata_to_clone, self.available_errata = self.get_errata()     
           
        
    def pending(self):
        return len(self.errata_to_clone)
        
    def pre_summary(self):
        print "  %s -> %s  (%i/%i Errata)" % (self.from_label, self.to_label,
                                 len(self.errata_to_clone), len(self.available_errata))
    
    def process(self):
        self.clone()
        #print "New packages added: %i" % (len(self.new_pkg_hash) - len(self.old_pkg_hash))
                                   
    def process_deps(self, needed_pkgs):                                
        needed_ids = []
        needed_names = []
        unsolved_deps = []
        for pkg in needed_pkgs:
            found = self.src_pkg_exist([pkg])
            if found:
                needed_ids.append(found['id'])
                needed_names.append(found['nvrea'])
            else:
                unsolved_deps.append(pkg)
        
        if len(needed_ids) > 0:    
            log_clean(0, "")
            log_clean(0, "Adding %i needed dependencies to %s" % (len(needed_ids), self.to_label))
            for name in needed_names:
                log_clean(0, name)         
            self.remote_api.add_packages(self.to_label, needed_ids)
        
    def src_pkg_exist(self, needed_list):
        if not self.from_pkg_hash:
            self.reset_from_pkgs()
        return self.pkg_exists(needed_list, self.from_pkg_hash)
    
    def dest_pkg_exist(self, needed_list):
        return self.pkg_exists(needed_list, self.new_pkg_hash)
            
    @staticmethod
    def pkg_exists(needed_list, pkg_list):
        """Given a list of packages in [N, V, E, R, A] format, do any of them exist
            in the pkg_hash with key of N-V-R.A  format"""            
        for i in needed_list:
            key = "%s-%s-%s.%s" % (i[0], i[1], i[3], i[4])
            if pkg_list.has_key(key):
                return pkg_list[key]
        return False
           
    
    def clone(self):
        bunch_size = 10
        errata_ids = [ e["advisory_name"] for e in self.errata_to_clone]
        if len(errata_ids) == 0:
            return
        
        msg = 'Cloning Errata into %s (%i):' % (self.to_label, len(errata_ids))                
        print msg
        log_clean(0, "")
        log_clean(0, msg)        
        for e in self.errata_to_clone:
            log_clean(0, "%s - %s" % (e['advisory_name'], e['synopsis']))
            
        pb = ProgressBar(prompt="", endTag=' - complete',
                     finalSize=len(errata_ids), finalBarLength=40, stream=sys.stdout)
        pb.printAll(1)
        while(len(errata_ids) > 0):
            errata_set = errata_ids[:bunch_size]
            del errata_ids[:bunch_size]            
            self.remote_api.clone_errata(self.to_label, errata_set)
            pb.addTo(bunch_size)
            pb.printIncrement()
            
        self.reset_new_pkgs()
        pb.printComplete()
                
    def get_errata(self):
        """ Returns tuple of all available for cloning, and what falls in the date range"""
        available_errata = self.db_api.applicable_errata(self.from_label, self.to_label)
        to_clone = []
        
        for err in available_errata:
            if err['issue_date'] <= self.to_date:
                to_clone.append(err)
        
        return (to_clone, available_errata)   
        
        
    def __remove_packages(self, names_dict, pkg_list, name):
        """Base removal of packages
            names_dict  - dict containing  list of package names, with channel lables as keys
            pkg_list  -  list of package dicts to consider
            name   - name of removal  'blacklist' or 'removelist', for display
        """
        found_ids  = []
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
        log_clean(0, "%s: Removing %i packages from %s." % (name, len(found_ids), self.to_label))        
        log_clean(0, "\n".join(found_names))
                          
        if len(found_ids) > 0:
            print "%s: Removing %i packages from %s" % (name, len(found_ids), self.to_label)
            self.remote_api.remove_packages(self.to_label, found_ids)
    
    def remove_removelist(self, pkg_names):
        self.__remove_packages(pkg_names, self.reset_new_pkgs().values(), "Removelist")
                            
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
        if not self.auth_time or (datetime.datetime.now() - self.auth_time).seconds > 60*15: #15 minutes
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
                to_ret[dst] = self.get_details(dst)
        return to_ret

    def list_packages(self, label):
        self.auth_check()
        pkg_list = self.client.channel.software.listAllPackages(self.auth_token, label)
        #name-ver-rel.arch,
        for pkg in pkg_list:
            pkg['nvrea'] =  "%s-%s-%s.%s" % (pkg['name'], pkg['version'], pkg['release'], pkg['arch_label']) 
        return pkg_list
    
    def clone_errata(self, to_label, errata_list):
        self.auth_check()
        self.client.errata.cloneAsOriginal(self.auth_token, to_label, errata_list)
    
    def get_details(self, label):
        self.auth_check()
        try:
            return self.client.channel.software.getDetails(self.auth_token, label)
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString + ": " + label)
        
    def add_packages(self, label, package_ids):
        self.auth_check()        
        while(len(package_ids) > 0):
            pkg_set = package_ids[:20]
            del package_ids[:20]        
            self.client.channel.software.addPackages(self.auth_token, label, pkg_set)

    def remove_packages(self, label, package_ids):
        self.auth_check()
        while(len(package_ids) > 0):
            pkg_set = package_ids[:20]
            del package_ids[:20]        
            self.client.channel.software.removePackages(self.auth_token, label, pkg_set)
                        
    def clone_channel(self, original_label, new_label, parent):
        self.auth_check()
        details = {'name': new_label, 'label':new_label, 'summary': new_label}
        if parent and parent != '':
            details['parent_label'] = parent
        
        msg = "Cloning %s to %s with original package set." % (original_label, new_label)
        log_clean(0, "")
        log_clean(0, msg)
        print(msg)
        self.client.channel.software.clone(self.auth_token, original_label, details, True)
        
             

class DBApi:
    """Class for connecting to the spacewalk DB"""    
   
    def __init__(self):
        initCFG('server')
        db_string = CFG.DEFAULT_DB #"rhnsat/rhnsat@rhnsat"
        rhnSQL.initDB(db_string)        

    @staticmethod
    def applicable_errata(from_label, to_label):
        """list of errata that is applicable to be cloned, used db because we 
            need to exclude cloned errata too"""
        h = rhnSQL.prepare("""
                select e.id, e.advisory_name, e.advisory_type, e.issue_date, e.synopsis
                from rhnErrata e  inner join               
                     rhnChannelErrata ce on e.id = ce.errata_id inner join
                     rhnChannel c on c.id = ce.channel_id 
                where C.label = :from_label and
                      e.id not in (select e2.id 
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
