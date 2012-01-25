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

import pdb
import sys
import time
import copy
import shutil
import tempfile
from depsolver import DepSolver

try:
    import json
except ImportError:
    import simplejson as json

import xmlrpclib

try:
    from spacewalk.common.rhnConfig import CFG, initCFG
    from spacewalk.satellite_tools.progress_bar import ProgressBar
    from spacewalk.server import rhnSQL
except:
    _LIBPATH = "/usr/share/rhn"
    if _LIBPATH not in sys.path:
        sys.path.append(_LIBPATH)
    from server import rhnSQL
    from common import CFG, initCFG
    from satellite_tools.progress_bar import ProgressBar


def confirm(txt, options):
    if not options.assumeyes:
        confirm = raw_input(txt)
        while ['y', 'n'].count(confirm.lower()) == 0:
            confirm = raw_input(txt)
        if confirm.lower() == "n":
            print "Cancelling"
            sys.exit(0)        


def main(options):        
    xmlrpc = RemoteApi(options.server, options.username, options.password)
    db = DBApi()
    
    cloners = []
    needed_channels = []
    for channel_list in options.channels:
        tree_cloner = ChannelTreeCloner(channel_list, xmlrpc, db, options.to_date)
        cloners.append(tree_cloner)
        needed_channels += tree_cloner.needing_create()
        
    if len(needed_channels) > 0:        
        print "\nBy continuing the following channels will be created: "
        print ", ".join(needed_channels)
        confirm("\nContinue with channel creation (y/n)?", options)
        for cloner in cloners:
            cloner.create_channels()
        
    for tree_cloner in cloners:
        tree_cloner.prepare();
        
    print "\nBy continuing the following will be cloned:"
    total = 0
    for cloner in cloners:                
        cloner.pre_summary()
        total += cloner.pending()        
        
    if total == 0:
        print ("\nNothing to do.")
        sys.exit(0)

    confirm("\nContinue with clone (y/n)?", options)            
    for cloner in cloners:
        cloner.clone()
    


##
#  Usage:
#  a = ChannelTreeCloner(channel_hash, xmlrpc, db, to_date)
#  if len(a.needing_channels()) > 0:
#    a.create_channels()
#  a.prepare()
#  a.clone()
#
class ChannelTreeCloner:
    def __init__(self, channels, remote_api, db_api, to_date):
        self.remote_api = remote_api
        self.db_api = db_api
        self.channel_map = channels
        self.to_date = to_date
        self.cloners = []
        self.validate_source_channels()
        
        for from_label in self.ordered_labels():
            to_label = self.channel_map[from_label]            
            cloner = ChannelCloner(from_label, to_label, self.to_date, self.remote_api, self.db_api)
            self.cloners.append(cloner)        

    def needing_create(self):
        to_ret = []
        existing = self.remote_api.list_channel_labels()
        for label in self.channel_map.values():
            if existing.count(label) == 0:
                to_ret.append(label)
        return to_ret
    
    def pending(self):
        total = 0
        for cloner in self.cloners:
            total += cloner.pending()
        return total
    
    def find_cloner(self, label):        
        for cloner in self.cloners:
            if cloner.dest_label() == label:
                return cloner
    
    def create_channels(self):
        to_create = self.needing_create()
        if len(to_create) == 0:
            return        
        dest_parent = self.channel_map[self.src_parent]        
        if to_create.count(dest_parent) > 0:
            self.remote_api.clone_channel(self.src_parent, dest_parent, None)
            to_create.remove(dest_parent)
            self.find_cloner(dest_parent).after_create()
        for from_label, to_label in self.channel_map.items():
            if to_create.count(to_label) > 0:
                self.remote_api.clone_channel(from_label, to_label, dest_parent)
                self.find_cloner(to_label).after_create()
            
        
                
    def validate_source_channels(self):
        self.channel_details = self.remote_api.channel_details(self.channel_map, values=False)   
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
            UserError("Parent Channel not specified.")
        if len(found_list) > 1:
            UserError("Multiple parent channels specified within the same channel tree.")
        return found_list[0]

    def ordered_labels(self):
        """Return list of labels with parent first"""
        labels = self.channel_map.keys()
        labels.remove(self.src_parent)
        labels.insert(0,self.src_parent)
        return labels
        
    def prepare(self):
        self.validate_dest_channels()        
        for cloner in self.cloners:
            cloner.prepare()            

    def pre_summary(self):
        for cloner in self.cloners:
            cloner.pre_summary();

    def clone(self):
        for cloner in self.cloners:            
            cloner.process()
            
            
            
            


class ChannelCloner:
    def __init__(self, from_label, to_label, to_date, remote_api, db_api):
        self.remote_api = remote_api
        self.db_api = db_api
        self.from_label = from_label
        self.to_label = to_label
        self.to_date = to_date
        self.original_packages = None
        
        
    def dest_label(self):
        return self.to_label
        
    def prepare(self):
        self.original_packages = self.remote_api.list_packages(self.to_label)
        self.errata_to_clone, self.available_errata = self.get_errata()        
        
    def pending(self):
        return len(self.errata_to_clone)
        
    def pre_summary(self):
        print "%s -> %s  (%i/%i Errata)" %(self.from_label, self.to_label, len(self.errata_to_clone), len(self.available_errata))
    
    def process(self):
        self.clone();
        new_packages = self.remote_api.list_packages(self.to_label)               
        pkg_diff = self.diff_packages(self.original_packages, new_packages)        
        print "New packages added: %i" % len(pkg_diff)
        self.dep_solve(pkg_diff, new_packages)
                
    def after_create(self):
        new_packages = self.remote_api.list_packages(self.to_label)           
        self.dep_solve(new_packages, new_packages)
                              
    # pkg_list - list of packages to solve deps for
    # trim_list - list of packages that already exist 
    def dep_solve(self, pkg_list, trim_list):
        repo_dir = self.repodata(self.from_label)
        print "Solving deps"
        nvreas = [pkg['nvrea'] for pkg in pkg_list]        
        solver = DepSolver([{"id":self.from_label, "relative_path":repo_dir}], nvreas)
        dep_results = solver.processResults(solver.getDependencylist())
        
        print "Processing"
        self.process_deps(trim_list, dep_results)           
        
        
    def process_deps(self, new_packages, deps):
        to_pkg_hash = self.list_to_hash(new_packages, 'nvrea')
        
        needed_list = []
        
        for pkg in deps:                                   
            for dep, solved_list in pkg.items():
#                if dep == "qffmpeg-libs = 0.4.9-0.16.20080908.el5_5":
#                    import pdb; pdb.set_trace();
                if not self.pkg_exists(solved_list, to_pkg_hash):
                    if len(solved_list) > 0:
                        needed_list.append(solved_list[0]) #grab oldest package
                    else:
                        print "No packages %s" % dep
        
        print "Unsolved deps: %i" % len(needed_list)
        
        from_pkg_hash = self.list_to_hash(self.remote_api.list_packages(self.from_label), 'nvrea')
        
        needed_ids = []
        unsolved_deps = []
        for pkg in needed_list:
            found = self.pkg_exists([pkg], from_pkg_hash)
            if found:
                needed_ids.append(found['id'])
            else:
                unsolved_deps.append(pkg)
        
        if len(needed_ids) > 0:
            print "Adding dependencies: %i" % len(needed_ids)        
            self.remote_api.add_packages(self.to_label, needed_ids)
        if len(unsolved_deps) > 0:
            print "Unresolved dependencies: %i" % len(unsolved_deps)
        
        
                    
    def list_to_hash(self, pkg_list, key):
        pkg_hash = {}
        for pkg in pkg_list:            
            pkg_hash[pkg[key]] = pkg
        return pkg_hash        

            
    def pkg_exists(self, needed_list, pkg_hash):
        """Given a list of packages in [N, V, E, R, A] format, do any of them exist
            in the pkg_hash with key of N-V-R.A  format"""            
        for i in needed_list:
            key = "%s-%s-%s.%s" % (i[0], i[1], i[3], i[4])
            if pkg_hash.has_key(key):
                return pkg_hash[key]
        return False
    
    def diff_packages(self, old, new):
        old_hash = {}
        new_hash = {}
        to_ret = []
        
        for pkg in old:
            old_hash[pkg["id"]] = pkg
        for pkg in new:
            new_hash[pkg["id"]] = pkg        
        id_diff = set(new_hash.keys()) - set(old_hash.keys())        
        for id in id_diff:
            to_ret.append(new_hash[id])        
        return to_ret
        
    
    def clone(self):
        bunch_size = 10
        errata_ids = self.collect(self.errata_to_clone, "advisory_name")
        msg = 'Cloning Errata into %s (%i):    ' % (self.to_label, len(errata_ids))
        pb = ProgressBar(prompt=msg, endTag=' - complete',
                     finalSize=len(errata_ids), finalBarLength=40, stream=sys.stdout)
        pb.printAll(1);
        while(len(errata_ids) > 0):
            errata_set = errata_ids[:bunch_size]
            del errata_ids[:bunch_size]            
            self.remote_api.clone_errata(self.to_label, errata_set)
            pb.addTo(bunch_size)
            pb.printIncrement()
        pb.printComplete()
            
    def collect(self, items, attribute):
        to_ret = []
        for item in items:
            to_ret.append(item[attribute])
        return to_ret

    def repodata(self, label):
        repo_dir = "/var/cache/rhn/repodata/%s" % label
        tmp_dir = tempfile.mkdtemp(suffix="clone-by-date") 
        shutil.copytree(repo_dir, tmp_dir + "/repodata/")
        return tmp_dir
    
    def get_errata(self):
        """ Returns tuple of all available for cloning, and what falls in the date range"""
        available_errata = self.db_api.applicable_errata(self.from_label, self.to_label)
        to_clone = []
        for err in available_errata:
            if err['issue_date'] <= self.to_date:
                to_clone.append(err)
        
        return (to_clone, available_errata)

class RemoteApi:
    """ Class for connecting to the XMLRPC spacewalk interface"""
    
    cache = {}
    
    def __init__(self, server_url, username, password):
        self.client = xmlrpclib.Server(server_url)
        try:
            self.auth_token = self.client.auth.login(username, password)
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString)
        
    def list_channel_labels(self):
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
        to_ret = {}
        for src, dst in label_hash.items():          
            if keys:  
                to_ret[src] = self.get_details(src)
            if values:
                to_ret[dst] = self.get_details(dst)
        return to_ret

    def list_packages(self, label):
        list = self.client.channel.software.listAllPackages(self.auth_token, label)
        #name-ver-rel.arch,
        for pkg in list:
            pkg['nvrea'] =  "%s-%s-%s.%s" % (pkg['name'], pkg['version'], pkg['release'], pkg['arch_label']) 
        return list
    
    def clone_errata(self, to_label, errata_list):
        self.client.errata.cloneAsOriginal(self.auth_token, to_label, errata_list)
    
    def get_details(self, label):
        try:
            return self.client.channel.software.getDetails(self.auth_token, label)
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString + ": " + label)
        
    def add_packages(self, label, package_ids):
        while(len(package_ids) > 0):
            set = package_ids[:20]
            del package_ids[:20]        
            self.client.channel.software.addPackages(self.auth_token, label, package_ids)
            
    def clone_channel(self, original_label, new_label, parent):
        details = {'name': new_label, 'label':new_label, 'summary': new_label}
        if parent and parent != '':
            details['parent_label'] = parent      
        print "Cloning %s to %s with original package set." % (original_label, new_label)
        self.client.channel.software.clone(self.auth_token, original_label, details, True)
        
             

class DBApi:
    """Class for connecting to the spacewalk DB"""    

   
    def __init__(self):
        initCFG('server')
        db_string = CFG.DEFAULT_DB #"rhnsat/rhnsat@rhnsat"
        rhnSQL.initDB(db_string)        
        
    
        
    def applicable_errata(self, from_label, to_label):
        """list of errata that is applicable to be cloned, used db because we 
            need to exclude cloned errata too"""
        h = rhnSQL.prepare("""
                select e.id, e.advisory_name, e.advisory_type, e.issue_date
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
        return h.fetchall_dict()

class UserError(Exception):
    def __init__(self, msg):
        self.msg = msg
    def __str__(self):
        return self.msg    