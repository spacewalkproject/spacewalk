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

try:
    import json
except ImportError:
    import simplejson as json

import xmlrpclib

try:
    from spacewalk.common.rhnConfig import CFG, initCFG
    from spacewalk.server import rhnSQL
except:
    _LIBPATH = "/usr/share/rhn"
    if _LIBPATH not in sys.path:
        sys.path.append(_LIBPATH)
    from server import rhnSQL
    from common import CFG, initCFG


def main(options):        
    xmlrpc = RemoteApi(options.server, options.username, options.password)
    db = DBApi()
    
    cloners = []
    for list in options.channels:
        tree_cloner = ChannelTreeCloner(list, xmlrpc, db, options.to_date)
        cloners.append(tree_cloner)
        tree_cloner.prepare();
        
    print "\nBy continuing the following will be cloned:"
    for cloner in cloners:                
        cloner.pre_summary()
        print "\n"
    
    if not options.assumeyes:
        txt = "Continue with clone (y/n)?"
        confirm = raw_input(txt)
        while ['y', 'n'].count(confirm.lower()) == 0:
            confirm = raw_input(txt)
        if confirm.lower() == "n":
            print "Cancelling"
            sys.exit(0)
        
    for cloner in cloners:
        cloner.clone()
    



class ChannelTreeCloner:
    def __init__(self, channels, remote_api, db_api, to_date):
        self.remote_api = remote_api
        self.db_api = db_api
        self.channel_map = channels
        self.to_date = to_date
        self.cloners = []

    def validate_channels(self):                
        self.channel_details = self.remote_api.channel_details(self.channel_map)
        self.src_parent = self.find_parent(self.channel_map.keys())
        self.validate_children(self.src_parent, self.channel_map.keys())
        self.dest_parent = self.find_parent(self.channel_map.values())
        self.validate_children(self.dest_parent, self.channel_map.values())         
        return self.channel_details
    
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
        list = self.channel_map.keys()
        list.remove(self.src_parent)
        list.insert(0,self.src_parent)
        return list
        

    def prepare(self):
        self.validate_channels()
        for from_label in self.ordered_labels():
            to_label = self.channel_map[from_label]
            cloner = ChannelCloner(from_label, to_label, self.to_date, self.remote_api, self.db_api)
            self.cloners.append(cloner)
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
        
    def prepare(self):
        self.original_packages = self.remote_api.list_packages(self.to_label)
        self.errata_to_clone, self.available_errata = self.get_errata()        
        
    def pre_summary(self):
        print "%s -> %s  (%i/%i Errata)" %(self.from_label, self.to_label, len(self.errata_to_clone), len(self.available_errata))
    
    def process(self):
        self.clone();
        new_packages = self.remote_api.list_packages(self.to_label)               
        pkg_idiff = self.diff_packages(self.original_packages, new_packages)
        
        print "New packages added: %i" % len(pkg_idiff)
        repo_dir = self.repodata(self.from_label)
        
        deps = []### dep solve on diff
        dep_package_ids = []
        #self.remote_api.add_packages()
        
        
    
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
        errata_ids = self.collect(self.errata_to_clone, "advisory_name")
        while(len(errata_ids) > 0):
            set = errata_ids[:10]
            del errata_ids[:10]
            print "Cloning set:"
            print set
            self.remote_api.clone_errata(self.to_label, set)
            
    def collect(self, items, attribute):
        to_ret = []
        for item in items:
            to_ret.append(item[attribute])
        return to_ret

    def repodata(self, label):
        repo_dir = "/var/cache/rhn/repodata/%s" % label
        tmp_dir = tempfile.mkdtemp(suffix="clone-by-date") + "/repo/"
        shutil.copytree(repo_dir, tmp_dir)
        return tmp_dir
    
    def get_errata(self):
        """ Returns tuple of all available for cloning, and what falls in teh date range"""
        available_errata = self.db_api.applicable_errata(self.from_label, self.to_label)
        to_clone = []
        for err in available_errata:
            if err['issue_date'] <= self.to_date:
                to_clone.append(err)
        
        return (to_clone, available_errata)

class RemoteApi:
    """ Class for connecting to the XMLRPC spacewalk interface"""
    
    def __init__(self, server_url, username, password):
        self.client = xmlrpclib.Server(server_url)
        try:
            self.auth_token = self.client.auth.login(username, password)
        except xmlrpclib.Fault, e:
            raise UserError(e.faultString)
    
    
    def list_channels(self):
        ""
    
    def channel_details(self, label_hash):
        to_ret = {}
        for src, dst in label_hash.items():            
            to_ret[src] = self.get_details(src)
            to_ret[dst] = self.get_details(dst)
        return to_ret

    def list_packages(self, label):
        return self.client.channel.software.listAllPackages(self.auth_token, label)
    
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
             

class DBApi:
    """Class for connecting to the spacewalk DB"""    

   
    def __init__(self):
        initCFG('server')
        db_string = CFG.DEFAULT_DB #"rhnsat/rhnsat@rhnsat"
        rhnSQL.initDB(db_string)        
        
    
        
    def applicable_errata(self, from_label, to_label):
        """list of errata that is applicable to be cloned, used db because we need to exclude cloned errata too"""
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