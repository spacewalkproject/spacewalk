#!/usr/bin/python
from __future__ import generators

import sys, string, exceptions, os, re

sys.path.append('/var/www/rhns/')
from server import rhnSQL

from objlib import *
from parfile import *
	    
# we init the DB, and then we initialize a schema object.
# the constructor grabs the user we're running as, and uses that to search for
# objects.  Any time it finds an object, it adds it to the list of known
# dependencies.  If that owners object doesn't happen to already be known, it
# calls back to the Schema to add another owner.

if __name__ == '__main__':
    if len(sys.argv) != 4:
	raise ValueError,"Usage: ./find-objects.py rhnuser/rhnuser@webdev ~/devel/rhn/sql/ ~/devel/rhn/sql/export/"
    connect_info = sys.argv[1]
    top_dir = os.path.realpath(os.path.expanduser(sys.argv[2]))
    output_dir = os.path.realpath(os.path.expanduser(sys.argv[3]))
    print "connect_info: %s\ntop_dir: %s\noutput_dir: %s\n" % (connect_info, top_dir, output_dir)

    # obviuously, this needs more logic...
    os.mkdir(output_dir)

    db = Session()
    db.initDB(connect_info)

    s = Schema(db)
    parfiles = {}

    # if we depend on things we can't 
    blacklist_deps = [
	DBDependency('WEB','WEB_CONTACT'),
	DBDependency('WEB','WEB_CUSTOMER'),
	DBDependency('RHN','RHNSERVER'),
	DBDependency('RHN','RHNBLACKLISTOBSOLETES'),
	DBDependency('RHN','RHNPACKAGENAME'),
	DBDependency('RHN','RHNPACKAGEEVR'),
	DBDependency('RHN','RHNCHANNELFAMILY'),
	DBDependency('RHN','RHNCHANNEL'),
	DBDependency('RHN','RHNFILE'),
    ]

    print "Writing dump parfiles"
    # mark everything data or nodata
    for owner in s.each_owner():
	for o in owner.each_object():
	    o.probe_for_data(top_dir)

	    for dep in blacklist_deps:
		if owner.depends_on(o, dep):
		    o.datafile = None

	    if owner.type == 'nodata' and not o.datafile is None:
		owner.type = 'data'
	print "marked %s as %s" % (owner.name, owner.type)

    for owner in s.each_owner():
	pfkey = (owner.name, owner.type)
	if not parfiles.has_key(pfkey):
	    hasdata = { 'data': True, 'nodata': False }
	    pf = ParfileGroup(owner.name, output_dir)
	    parfiles[pfkey] = pf
	if owner.type != 'data':
	    print "%s does not need data, skipping objects" % (owner.name,)
	    continue
	print "%s needs data, adding objects" % (owner.name,)
	for o in owner.each_object():
	    if o.datafile:
		parfiles[pfkey].append(o)

    # not sure if we actually need copy here or not, since we del from it
    for pfkey, pf in parfiles.copy().items():
	pf.write()
	del parfiles[pfkey]
