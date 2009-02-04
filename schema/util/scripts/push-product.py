#!/usr/bin/python

import exceptions

error_on_dupes = 1
config_file = "products.csv"
action = None

class DuplicateItemError(exceptions.Exception):
    def __init__(self, type, label, quantity)
	self.args = args

# this one's completely abstract.
class MapTable:
    def delete(self, **kw):
	h = db.parse(self.deleteQuery)
	args = {}
	for key in self.deleteArgs:
	    args[key] = kw[key]
	apply(h.execute,args,None)

    def insert(self, **kw):
	h = db.parse(self.insertQuery)
	args = {}
	for key in self.insertArgs:
	    args[key] = kw[key]
	apply(h.execute,args,None)

    def has_key(self, **kw):
	h = db.parse(self.hkQuery)
	args = {}
	for key in self.hkArgs:
	    args[key] = kw[key]
	apply(h.execute,args,None)

class ChannelFamilyMap(MapTable):
    def __init__(self):
	self.deleteQuery = """\
	    delete  from rhnServiceChannelFamilyMap
	    where   product_id = (
			select	product_id
			from	rh_product
			where	item_code = :product
		    )
		    and family_id = (
		        select	product_id
		        from	rhnChannelFamily
		        where	label = :label
		    )
		"""
	self.deleteArgs = ['product','label']
	    
	self.insertArgs = """\
	    insert into rhnServiceChannelFamilyMap (
		    product_id, family_id, quantity
		) (
		    select  rp.product_id,
			    cf.id,
			    :quantity
		    from    rhnChannelFamily cf,
			    rh_product rp
		    where   rp.item_code = :product
			and cf.label = :label
		)
	    """
	self.insertArgs = ['product','label','quantity']
	
	self.hkQuery = """\
	    select  1
	    from    rhnServiceChannelFamilyMap
	    where   product_id = (
			select  product_id
			from    rh_product
			where   item_code = :product
		    )
		    and family_id = (
			select  product_id
			from    rhnChannelFamily
			where   label = :label
		    )
	    """
	self.hkArgs = ['product','label']

class ServerGroupMap(MapTable):
    def __init__(self):
	self.deleteQuery = """\
	    delete  from rhnServiceServerGroupMap
	    where   product_id = (
			select	product_id
			from	rh_product
			where	item_code = :product
		    )
		    and group_type = (
			select	id
			from	rhnServerGroupType
			where	label = :label
		    )
	    """
	self.deleteArgs = ['product','label']

	self.insertQuery = """\
	    insert into rhnServiceServerGroupMap (
		    product_id, group_type, quantity, paid
		) (
		    select  rp.product_id,
			    sgt.id,
			    :quantity,
			    :paid
		    from    rh_product rp,
			    rhnServerGroupType sgt
		    where   sgt.label = :label
			and rp.item_code = :product
		)
	    """
	self.insertArgs = ['product','label','quantity','paid']

	self.hkQuery = """\
	    select  1
	    from    rhnServiceServerGroupMap
	    where   product_id = (
			select	product_id
			from	rh_product
			where	item_code = :product
		    )
		    and group_type = (
			select	id
			from	rhnServerGroupType sgt
			where	sgt.label = :label
	    """
	self.hkArgs = ['product','label']

class UserGroupMap(MapTable):
    def __init__(self):
	self.deleteQuery = """\
	    delete  from rhnServiceUserGroupMap
	    where   product_id = (
			select	product_id
			from	rh_product
			where	item_code = :product
		    )
		    and group_type = (
			select	id
			from	rhnUserGroupType
			where	label = :label
		    )
	    """
	self.deleteArgs = ['product','label']

	self.insertQuery = """\
	    insert into rhnServiceUserGroupMap (
		    product_id, group_type, quantity, paid
		) (
		    select  rp.product_id,
			    ugt.id,
			    :quantity,
			    :paid
		    from    rh_product rp,
			    rhnUserGroupType ugt
		    where   ugt.label = :label
			and rp.item_code = :product
		)
	    """
	self.insertArgs = ['product','label','quantity','paid']

	self.hkQuery = """\
	    select  1
	    from    rhnServiceUserGroupMap
	    where   product_id = (
			select	product_id
			from	rh_product
			where	item_code = :product
		    )
		    and group_type = (
			select	id
			from	rhnUserGroupType ugt
			where	ugt.label = :label
	    """
	self.hkArgs = ['product','label']

class Service:
    types = {
	'user_group': {
		'obj': None,
    		'missing': 'error',
	    	'labels': []
	    }
	'server_group': {
		'obj': None,
		'missing': 'error',
		'labels': []
	    },
	'channel_family': {
		'obj': None,
		'missing': 'warning',
		'labels' : []
	    }
    }
    firstRun = 0

    def populateTypes(self):
	# XXX this needs to get labels for everything from the db
	# and I don't have DB code yet
	pass
	
    def __init__(self, type, label, quantity, paid=None):
	if Service.firstRun == 0:
	    self.populateTypes()
	    Service.firstRun = 1

	if not type in Service.types.keys():
	    raise ValueError
	self.type = type

	if not label in Service.types[type]['labels']:
	    if Service.types[type]['missing'] != 'warning':
		raise InvalidLabel(type, label)
	    else:
		print "Warning: %s %s does not exist" % (type, label)
	    self.insertable = False
	else:
	    self.insertable = True
	self.label = label
	
	self.quantity = quantity

    def insert(self):
	creator = Service.types[self.type]['obj']
	creator.populate(self)

class Product:
    def __init__(self, item_code):
	self.item_code = item_code
	self.server_groups = []
	self.user_groups = []
	self.channel_families = []

    def setServerGroup(self, group_label, quantity):
	if error_on_dupes != 0 and self.server_groups.has_key(group_label):
	    raise 
	self.server_groups[group_label] = quantity

    def setUserGroup(self, group_label, quantity):
	self.user_groups[group_label] = quantity

    def setChannelFamily(self, family_label, quantity):
	self.channel_families[family_label] = quantity

if __name__ == "__main__":
    parseArgs()
    readConfig()
    doAction()

    # the plan:
    # a Product has several services.  We read the config file and make a map
    #   of all of the services for all products.  Then we look for the one(s)
    #   we're asked to poll, we update them, and then we repoll the users.
    # XXX we need to be able to repoll the users for multiple products at once.
    # XXX status/pct complete messages would be nice.
    

