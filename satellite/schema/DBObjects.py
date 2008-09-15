#!/usr/bin/python
# Copyright (c) 2005, Red Hat Inc.
#
# $Id: DBObjects.py,v 1.18 2005-07-05 17:56:47 wregglej Exp $
#
# This implements objects useful for comparing database schema
#
import string, md5, cPickle, sys, re
from server import rhnSQL

# ah, python1.  my old and good friend...
from UserDict import UserDict

# are users worth supporting as objects ?
# probably not for v1
#
# note that the base DBObject class doesn't know anything about a database.
class DBObject:
    objNum=1
    knownObjs = []

    # XXX not thread safe
    def __init__(self, uo_row):
	self.name = uo_row['object_name']
	self.type = uo_row['object_type']
	self.owner = uo_row['owner']
	self.uo = uo_row
	self.parent = None
	self.parentName = None
	self.datapoints = None
	DBObject.knownObjs.append([self.name, self.type])

	# self.objNum should corelate directly with all_objects.last_ddl_time
	self.objNum = DBObject.objNum
	DBObject.objNum = DBObject.objNum + 1

    def __str__(self):
	return self.name

    def __cmp__(self, other):
	# why does cmp() behave different between a dict and a UserDict?
	return cmp(UserDict(self.datapoints), UserDict(other.datapoints))

    def drop(self):
	return 'drop %s %s\n/\nshow errors\n' % (self.type, self.name)

    def diff(self, other):
	if not isinstance(self, type(other)):
	    raise TypeError
	if not self.datapoints == other.datapoints:
	    try:
		return self.drop() + '\n' + other.create()
	    except:
		print "%s %s" % (self.type, other.type)
		raise
	return None

    def findDeps(self):
	return {}

    def listObject(self):
	keys = self.datapoints.keys()
	keys.sort()
	values = []
	for key in keys:
	    values.append("'%s'" % (self.datapoints[key],))
	print '%s %s ( %s )' % (self.type, self.name, string.join(values,' '))

# this one doesn't quite look like all the others because there isn't
# a row in all_objects.  fun fun fun.  Thanks Oracle!
#
# saying this derives from DBObject is kinda cheeting, but...
class ConstraintObject(DBObject):
    consHash = {}
    consId = 0
    
    # XXX not thread safe
    # takes schema and db as arguments just for a calling convention.
    # I know, lame.
    def __init__(self, consData):
	uo_row = UserDict({
	    'object_name' : consData['constraint_name'],
	    'object_type' : 'CONSTRAINT',
	})
	uo_row.update(consData)
	DBObject.__init__(self, uo_row)

	self.datapoints = consData
	self.datapoints['owner'] = None
	# we remove constraint name so that datapoints of system
	# generated constraints are comperable.
	del self.datapoints['constraint_name']

	# XXX there's surely a more lightweight way to do this
	md5sum = md5.new()
	for key in self.datapoints.keys():
	    md5sum.update(key)
	    val = self.datapoints[key]
	    if val is None:
		pass
	    elif isinstance(val, type([])) or isinstance(val, type((1,))):
		for x in val:
		    md5sum.update(x)
	    else:
		md5sum.update(val)
	self.md5sum = md5sum.digest()
	if ConstraintObject.consHash.has_key(self.md5sum):
	    self.consId = ConstraintObject.consHash[self.md5sum]
	else:
	    self.consId = ConstraintObject.consId
	    ConstraintObject.consId = ConstraintObject.consId + 1
	    ConstraintObject.consHash[self.md5sum] = self.consId

    def __cmp__(self, other):
	if not isinstance(other, type(self)):
	    raise TypeError
	# not particularly meaningful, but what is?
	return self.consId - other.consId

    def listObject(self):
	initVal = '\t%s %s' % (self.type, self.name)
	columns = self.datapoints['columns']
	val = initVal
	if len(columns) > 0:
	    val = '%s columns( %s )' % (initVal, string.join(columns,' '))
	print val
	keys = self.datapoints.keys()
	keys.sort()
	values = []
	for key in keys:
	    if not key == 'columns':
		values.append("'%s'" % (self.datapoints[key],))
	print '\t\t( %s )' % (string.join(values,' '),)
	    
# sickness on the part of oracle -- index creation order is _very_
# important, and there's no way to tell what it is except (maybe)
# retrieval order from an unsorted all_indexes (hrm... maybe 
# last_ddl_time) .  Thanks Oracle! we currently handle this using
# self.objNum ; it could be simpler to only care when 2 index have
# the same highest-cardinality [table,column]
#
# also, determining a relationship between an index and a constraint is
# nonobvious.  It seems like a good heuristic is "if the index and the
# constraint have the same name, and the constraint is of type U or P",
# but i have no guarantees :/
class IndexObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  table_name, uniqueness, logging, status
	    from    all_indexes
	    where   owner = :owner
		and index_name = :iname
	""")
	h.execute(owner = self.owner, iname = self.name)
	self.datapoints = h.fetchone_dict()
	self.parentName = self.datapoints['table_name']
	del self.datapoints['table_name']

	h = rhnSQL.prepare("""\
	    select  column_name, column_position, descend
	    from    all_ind_columns
	    where   1=1
		and index_owner = :owner
		and index_name = :iname
		and table_name = :tname
	    order by column_position
	""")
	h.execute(owner = self.owner,
		iname = self.name,
		tname = self.parentName)
	columns = []
	columnsSort = None
	for cname, pos, desc in h.fetchall():
	    columns.append(cname)
	    columnsSort = desc
	if columnsSort == 'DESC':
	    columns.reverse()
	self.datapoints['columns'] = columns

    def create(self):
	str = None
	if self.datapoints['uniqueness']  == 'UNIQUE':
	    str = 'create unique index %s\n' % (self.name, )
	else:
	    str = 'create index %s\n' % (self.name, )
	
	columns = string.join(self.datapoints['columns'],', ')
	str = str + '\ton %s (%s)\n/\nshow errors\n' % \
	    (self.parentName, columns)

	return str
	
    # XXX Right now, this is a placeholder.  It needs to test if
    # this enforces a constraint, and if so, "alter table drop
    # constraint" instead.
    def drop(self):
	DBObject.drop(self)

    def diff(self, other):
	if not isinstance(self, type(other)):
	    raise TypeError
	if not self.datapoints == other.datapoints:
	    return self.drop() + '\n' + other.create()
	return None

    def listObject(self):
	columns = self.datapoints['columns']
	print "\t%s %s columns( %s )" % (self.type, self.name,
		string.join(columns,' '))
	values = []
	keys = self.datapoints.keys()
	keys.sort()
	for key in keys:
	    if not key == 'columns':
		values.append("'%s'" % (self.datapoints[key],))
	print '\t\t( %s )' % (string.join(values, ' '))
    
class LibraryObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  file_spec, status
	    from    all_libraries
	    where   owner = :owner
		and library_name = :lname
	""")
	h.execute(owner = self.owner, lname = self.name)
	self.datapoints = h.fetchone_dict()

    def create(self):
	return "create library %s as '%s'\n/\nshow errors\n" % \
	    (self.name, self.datapoints['file_spec'])

# cryin' shame check constraints and triggers don't fit in this 
# class.
class SourceObject(DBObject):
    def __init__(self, uo_row):
 	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  line, text
	    from    all_source
	    where   owner = :owner
		and name = :name
		and type = :type
	""")
	h.execute(owner = self.owner, name = self.name, type = self.type)
	self.code = {}
	# it'd be kinda nice to be able to generate deps based on this,
	# but _ick_.
	for line, text in h.fetchall():
	    self.code[line] = text

	self.datapoints = {
	    'name': self.name,
	    'code': self.code
	}

    def create(self):
	str = 'create or replace\n'
	keys = self.code.keys()
	keys.sort()
	for key in keys:
	    str = '%s%s' % (str, self.code[key])
	str = str + '/\nshow errors\n'
	return str

    def findDeps(self):
	retDict = { self.name : [self.parentName] }
	names = []
	dps = string.upper("%s" % (self.code,))
	for name,type in DBObject.knownObjs:
	    if not string.find(dps,name) == -1:
		retDict[self.name].append(name)
	return retDict

    def listObject(self):
	m = md5.new()
	keys = self.datapoints['code'].keys()
	keys.sort()
	for key in keys:
	    m.update(self.datapoints['code'][key])
	hexdigest = string.join(map(lambda a: "%02x" % (ord(a),), m.digest()),'')
	print '%s %s ( %s )' % (self.type, self.name, hexdigest)

class SequenceObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  min_value, max_value, increment_by, cycle_flag,
		    order_flag, cache_size, last_number
	    from    all_sequences
	    where   sequence_owner = :owner
		and sequence_name = :sname
	""")
	h.execute(owner = self.owner, sname = self.name)
	self.datapoints = h.fetchone_dict()
	self.last_number = self.datapoints['last_number']
	del self.datapoints['last_number']
		
    def create(self):
	str = 'create sequence %s\n' % (self.name,)
	if self.datapoints['increment_by'] != 1:
	    str = str + '\tincrement by %s\n' % (self.datapoints['increment_by'],)
	if self.datapoints['min_value'] != 1:
	    str = str + '\tminvalue %s\n' % (self.datapoints['min_value'],)
	# ugly kludge...
	if '%s' % (self.datapoints['max_value'],) != '%s' % (float(1e+27),):
	    str = str + '\tmaxvalue %s\n' % (self.datapoints['max_value'],)
	if self.datapoints['cycle_flag'] != 'N':
	    str = str + '\tcycle\n'
	if self.datapoints['cache_size'] != 20:
	    str = str + '\tcache %s\n' % (self.datapoints['cache_size'],)
	if self.datapoints['order_flag'] != 'N':
	    str = str + '\torder\n'
	str = str + '/\nshow errors\n'
	return str

class SynonymObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  table_owner, table_name
	    from    all_synonyms
	    where   owner = :owner
		and synonym_name = :sname
	""")
	h.execute(owner = self.owner, sname = self.name)
	self.datapoints = h.fetchone_dict()
	self.parentName = self.datapoints['table_name']
	self.tableOwner = self.datapoints['table_owner']
	# ick, but this has to be done.
	del self.datapoints['table_owner']

    def create(self):
	return 'create synonym %s for %s.%s\n/\nshow errors\n' % (
	    self.name,
	    self.tableOwner,
	    self.datapoints['table_name']
	)
    
class ConstrainableObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)

    # findConstraints finds all the constraints for this object
    def _findConstraints(self):

	retval = {}
	# I don't think we can easily get a table and a view
	# with the same name, so i'm ignoring that possibility
	# and as such not caring about constraint types
	
	# r_owner taken out to make diffing against AOL's schema easier
	h = rhnSQL.prepare("""\
	    select  owner,
		    constraint_name, constraint_type,
		    -- r_owner,
		    r_constraint_name,
		    search_condition, delete_rule,
		    table_name
	    from    all_constraints
	    where   owner = :owner
		and table_name = :tname
	""")
	h.execute(owner = self.owner, tname = self.name)
	retvalItem = None
	for cons_row in h.fetchall_dict() or []:
	    name = cons_row['constraint_name']
	    retvalItem = cons_row
	    # owner taken out to make diffing against AOL easier
	    i = rhnSQL.prepare("""\
		select	column_name --, owner
		from	all_cons_columns
		where	owner = :owner
		    and table_name = :tname
		    and constraint_name = :cname
		order by position
	    """)
	    i.execute(owner = self.owner, tname = self.name, cname = name)
	    columns = i.fetchall()
	    if not len(columns) == 0:
		retvalItem['columns'] = reduce(lambda x,y: x+y, columns)
	    else:
		retvalItem['columns'] = []
	    co = ConstraintObject(retvalItem)
	    retval[co.consId] = co
	    
	self.datapoints['constraints'] = retval

class ViewObject(ConstrainableObject):
    def __init__(self, uo_row):
	ConstrainableObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  view_name, text_length, text,
		    type_text_length, type_text,
		    oid_text_length, oid_text,
		    view_type_owner, view_type
	    from    all_views
	    where   owner = :owner
		and view_name = :vname
	""")
	h.execute(owner = self.owner, vname = self.name)
	self.datapoints = h.fetchone_dict()

	self._findConstraints()

    def __cmp__(self, other):
	if not isinstance(other, type(self)):
	    raise TypeError

	dp1 = self.datapoints
	c1 = dp1['constraints']
	del dp1['constraints']

	dp2 = other.datapoints
	c2 = dp2['constraints']
	del dp2['constraints']

	# these should always have the same keys
	compKeys = dp1.keys()
	for compKey in compKeys:
	    retval = cmp(dp1[compKey],dp2[compKey])
	    if not retval == 0:
		return retval
	# if we get here, everything but constraints have been checked

	# is uniqifing this worth the trouble?
	realConsIdMap = {}
	for consId in c1.keys() + c2.keys():
	    if not realConsIdMap.has_key(consId):
		realConsIdMap[consId] = 1
	consIds = realConsIdMap.keys()
	del realConsIdMap
	    
	for consId in consIds:
	    if not c1.has_key(consId) and c2.has_key(consId):
		return -1
	    elif c1.has_key(consId) and not c2.has_key(consId):
		return 1
	    else:
		cmpVal = c1[consId].__cmp__(c2[consId])
		if not cmpVal == 0:
		    return cmpVal
		if not c1[consId].name == c2[consId].name:
		    print 'WARNING: constraint on %s has different names\n\t(%s, %s)' % (self.name, c1[consId].name, c2[consId].name)
	return 0
	
    def create(self):
	return 'create or replace view %s as %s\n/\nshow errors\n' % \
	    ( self.name, self.datapoints['text'] )

#    def diff(self, other):
#	if not isinstance(other, type(self)):
#	    raise TypeError
#	diffs = 0
#	for key in self.datapoints.keys():
#	    if self.datapoints[key] != other.datapoints[key]:
#		diffs = diffs + 1
#	if not diffs == 0:
#	    return '%s%s\n' % ( self.drop(), other.create() )
#	return None

    def listObject(self):
	keys = self.datapoints.keys()
	keys.sort()
	values = []
	for key in keys:
	    if not key in ['text','constraints']:
		values.append("'%s'" % (self.datapoints[key],))
	m = md5.new()
	m.update(self.datapoints['text'])
	hd = string.join(map(lambda a: "%02x" % (ord(a),), m.digest()),'') 
	values.append("'%s'" % (hd,))
	print '%s %s ( %s )' % (self.type, self.name, string.join(values,' '))
	keys = self.datapoints['constraints'].keys()
	keys.sort()
	for key in keys:
	    self.datapoints['constraints'][key].listObject()

class TableObject(ConstrainableObject):
    def __init__(self, uo_row):
	ConstrainableObject.__init__(self, uo_row)
	# self.parentName = None
	h = rhnSQL.prepare("""\
	    select  ltrim(rtrim(cache)) cache
	    from    all_tables
	    where   owner = :owner
		and table_name = :tname
	""")
	h.execute(owner = self.owner, tname = self.name)
	self.datapoints = h.fetchone_dict()

	self._findConstraints()
	self.datapoints['indices'] = {}

	self.datapoints['columns'] = []
	h = rhnSQL.prepare("""\
	    select  column_id, column_name,
		    data_type, data_length, data_default,
		    nullable
	    from    all_tab_columns
	    where   owner = :owner
		and table_name = :tname
	    order by column_id
	""")
	h.execute(owner = self.owner, tname = self.name)
	for cid, cname, data_type, data_length, data_default, nullable in \
		h.fetchall():
	    crow = {
		'column_name': cname,
		'data_type': data_type,
		'data_length': data_length,
		'data_default': data_default,
		'nullable': nullable
	    }
	    self.datapoints['columns'].append(crow)

    def hasIndex(self, index):
	return self.datapoints['indices'].has_key(index.objNum)

    def addIndex(self, index):
	if not isinstance(index, IndexObject):
	    raise TypeError
	if not self.name == index.parentName:
	    raise ValueError, 'index claims different parent (%s, %s)' % \
		(self.name, index.parentName)
	# if it already exists, we just silently NOP
	if not self.hasIndex(index):
	    self.datapoints['indices'][index.objNum] = index

    def create(self):
	return "create table %s;\n" % (self.name, )

    def findDeps(self):
	h = rhnSQL.prepare("""\
	    select distinct
		    uc1.table_name
	    from    all_constraints uc0,
		    all_constraints uc1
	    where   1=1
		and uc0.owner = :owner
		and uc0.table_name = :tname
		and uc0.r_constraint_name = uc1.constraint_name
		and uc1.owner = :owner
	""")
	h.execute(owner = self.owner, tname = self.name)
	depsDict = { self.name : [] }
	for table_name in h.fetchall():
	    depsDict[self.name].append(table_name[0])
	#indices = self.datapoints['indices']
	#for index in indices.keys():
	#    if not depsDict.has_key(indices[index].name):
	#	depsDict[indices[index].name] = []
	#    depsDict[indices[index].name].append(self.name)
	return depsDict

    def listObject(self):
	print "%s %s" % (self.type, self.name)
	columns = []
	columnDicts = {}
	for column in self.datapoints['columns']:
	    columns.append(column['column_name'])
	    columnDicts[column['column_name']] = column
	columns.sort()
	for column in columns:
	    sys.stdout.write("\tCOLUMN %s (" % (column,))
	    fields = columnDicts[column].keys()
	    fields.sort()
	    for field in fields:
		if not columnDicts[column][field] == column:
		    cdata = " '%s'" % (columnDicts[column][field],)
		    cdata = re.sub(r'\s+\'$','',cdata)
		    cdata = re.sub('\n\'$','',cdata)
		    sys.stdout.write(cdata)
	    print " )"
	keys = self.datapoints['constraints'].keys()
	keys.sort()
	for key in keys:
	    self.datapoints['constraints'][key].listObject()
	keys = self.datapoints['indices'].keys()
	keys.sort()
	for key in keys:
	    self.datapoints['indices'][key].listObject()

class TriggerObject(DBObject):
    def __init__(self, uo_row):
	DBObject.__init__(self, uo_row)
	h = rhnSQL.prepare("""\
	    select  trigger_type, triggering_event, table_owner,
		    base_object_type, table_name, column_name,
		    referencing_names, when_clause, status, action_type,
		    trigger_body
	    from    all_triggers
	    where   owner = :owner
		and trigger_name = :tname
	""")
	h.execute(owner = self.owner, tname = self.name)
	self.datapoints = h.fetchone_dict()

    def findDeps(self):
	retDict = { self.name : [self.datapoints['table_name']] }
	names = []
	for name,type in DBObject.knownObjs:
	    names.append(name)
	dps = string.upper(self.datapoints['trigger_body'])
	for name in names:
	    if not string.find(dps,name) == -1:
		retDict[self.name].append(name)
	return retDict

# this object never knows about the db, so it's pickleable.
class SchemaData:
    def __init__(self, owner):
        self.objects = {
	    'FUNCTION' : {},
	    'INDEX' : {},
	    'LIBRARY' : {},
	    'PACKAGE' : {},
	    'PACKAGE BODY' : {},
	    'PROCEDURE' : {},
	    'SEQUENCE' : {},
	    'SYNONYM' : {},
	    'TABLE' : {},
	    'TRIGGER' : {},
	    'TYPE' : {},
	    'TYPE BODY' : {},
	    'VIEW' : {}
	}
	self.deps = {}
	self.owner = owner

    def has_key(self, key): return self.objects.has_key(key)
    def __getitem__(self, key):	return self.objects[key]
    def keys(self): return self.objects.keys()

    def setDB(self, database):
	self.database = database

    def addDBObject(self, dbObj):
	if not isinstance(dbObj, DBObject):
	    raise TypeError

	# handle indices and triggers as child objects of tables,
	# and build a list of them until the parent shows up
	if isinstance(dbObj, IndexObject):
	    if self.objects['TABLE'].has_key(dbObj.parentName):
		self.objects['TABLE'][dbObj.parentName].addIndex(dbObj)
		return
	    if not self.objects['INDEX'].has_key(dbObj.parentName):
		self.objects['INDEX'][dbObj.parentName] = []
	    self.objects['INDEX'][dbObj.parentName].append(dbObj)
	elif isinstance(dbObj, TriggerObject):
	    if self.objects['TABLE'].has_key(dbObj.parentName):
		self.objects['TABLE'][dbObj.parentName].addTrigger(dbObj)
		return
	    if not self.objects['TRIGGER'].has_key(dbObj.parentName):
		self.objects['TRIGGER'][dbObj.parentName] = []
	    self.objects['TRIGGER'][dbObj.parentName].append(dbObj)
	elif isinstance(dbObj, TableObject):
	    if self.objects['INDEX'].has_key(dbObj.name):
		for idx in self.objects['INDEX'][dbObj.name]:
		    dbObj.addIndex(idx)
		del self.objects['INDEX'][dbObj.name]
	    if self.objects['TRIGGER'].has_key(dbObj.name):
		for trg in self.objects['TRIGGER'][dbObj.name]:
		    dbObj.addTrigger(trg)
		del self.objects['TRIGGER'][dbObj.name]
	    self.objects[dbObj.type][dbObj.name] = dbObj
	else:
	    self.objects[dbObj.type][dbObj.name] = dbObj

    def findDeps(self):
	# we're assuming object names are unique here.  If users get added
	# to the equation, this'll break bigtime.
	deps = {}
	for objType in self.objects.keys():
	    for objName in self.objects[objType].keys():
		if objName is None:
		    continue
		try:
		    tmpDeps = self.objects[objType][objName].findDeps()
		except:
		    print objType
		    print objName
		    print self.objects[objType].keys()
		    print self.objects[objType][objName]
		    raise
		for tmpObjName in tmpDeps.keys():
		    if not deps.has_key(tmpObjName):
			deps[tmpObjName] = tmpDeps[tmpObjName]
			continue;
		    objDeps = {}
		    for x in deps[tmpObjName]:
			objDeps[x] = 1
		    for x in tmpDeps[tmpObjName]:
			objDeps[x] = 1
		    deps[tmpObjName] = objDeps.keys()
	self.deps = deps

class Schema:
    objectTypeHandlers = {
	'FUNCTION' : SourceObject,
	'INDEX' : IndexObject,
	'LIBRARY' : LibraryObject,
	'PACKAGE' : SourceObject,
	'PACKAGE BODY' : SourceObject,
	'PROCEDURE' : SourceObject,
	'SEQUENCE' : SequenceObject,
	'SYNONYM' : SynonymObject,
	'TABLE' : TableObject,
	'TRIGGER' : TriggerObject,
	'TYPE' : SourceObject,
	'TYPE BODY' : SourceObject,
	'VIEW' : ViewObject
    }

    cmpTypes = [ 'FUNCTION', 'LIBRARY', 'PACKAGE', 'PACKAGE BODY',
	'PROCEDURE', 'SEQUENCE', 'SYNONYM', 'TABLE', 'TYPE',
	'TYPE BODY', 'VIEW' ]

    def __init__(self, owner=None):
	if owner is None:
	    owner = self.__guessOwner()
	self.owner = owner
	self.data = SchemaData(owner)

    def populateFromDB(self):
	self.data.setDB(rhnSQL.database())
	h = rhnSQL.prepare("""\
	    select  rownum, uo.*
	    from    all_objects uo
	    where   owner = :owner
	    order by last_ddl_time
	""")
	h.execute(owner = self.owner)
	for row in h.fetchall_dict() or []:
	    makeObj = Schema.objectTypeHandlers[row['object_type']]
	    if not makeObj is None:
		o = makeObj(row)
		if not o is None:
		    self.data.addDBObject(o)

    def populateFromPickleString(self, s):
	d = cPickle.loads(s)
	if not isinstance(d, SchemaData):
	    raise TypeError
	self.data = d

    def populateFromPickleFile(self, f):
	d = cPickle.load(f)
	if not isinstance(d, SchemaData):
	    raise TypeError, d
	self.data = d

    def pickleToFile(self, f):
	cPickle.dump(self.data, f)

    def pickleToString(self):
	return cPickle.dumps(self.data)

    def listObjects(self):
	cmpTypes = Schema.cmpTypes
	cmpTypes.sort()
	for cmpType in cmpTypes:
	    objNames = self.data[cmpType].keys()
	    objNames.sort()
	    for objName in objNames:
		self.data[cmpType][objName].listObject()
	
    def __cmp_helper(self, other, maxErrors = 0):
	if not isinstance(other, type(self)):
	    raise TypeError
	cmpMap = {}
	for cmpType in Schema.cmpTypes:
	    objNames = self.data[cmpType].keys() + \
		other.data[cmpType].keys()
	    objMap = {}
	    for objName in objNames:
		if objMap.has_key(objName):
		    continue

		obj1 = None
		if self.data[cmpType].has_key(objName):
		    obj1 = self.data[cmpType][objName]
		obj2 = None
		if other.data[cmpType].has_key(objName):
		    obj2 = other.data[cmpType][objName]
		objMap[objName] = [ obj1, obj2 ]
	    cmpMap[cmpType] = objMap
	retlist = []
	errors = 0
	for cmpType in self.cmpTypes:
	    objLists = cmpMap[cmpType]
	    for objName in objLists.keys():
		retval = {
		    'value' : 0,
		    'message' : None,
		    'name' : objName,
		    'type' : cmpType,
		    'diff' : None
		}
		objList = objLists[objName]
		if objList[0] is None:
		    retval = {
			'value' : 1,
			'message' : '%s does not contain %s "%s"' % \
			    ( self.data.database, objList[1].type, objName ),
			'name' : objName,
			'type' : cmpType,
			'diff' : objList[1].drop()
		    }
		elif objList[1] is None:
		    retval = {
			'value' : 1,
			'message' : '%s does not contain %s "%s"' % \
			    ( other.data.database, objList[0].type, objName ),
			'name' : objName,
			'type' : cmpType,
			'diff' : objList[0].create()
		    }
		else:
		    retvalNum = cmp(objList[0],objList[1])
		    if not retvalNum == 0:
			try:
			    retval = {
				'value' : retvalNum,
				'message' : '%s "%s" is not the same' % \
				    ( objList[0].type, objName ),
				'name' : objName,
				'type' : cmpType,
				'diff' : objList[0].diff(objList[1])
			    }
			except:
			    print cmpType
			    raise 
		retlist.append(retval)
		if not retval == 0:
		    errors = errors + 1
		    if errors == maxErrors:
			return retlist
	return retlist

    def __guessOwner(self):
	sql = """\
	    select distinct ao.owner owner
	    from    all_objects ao,
		    user_objects uo
	    where   uo.object_id = ao.object_id
	"""
	h = rhnSQL.prepare(sql)
	h.execute()
	row = h.fetchone_dict()
	if row is None:
	    raise "could not guess database owner"
	return row['owner']

    def __cmp__(self, other):
	retlist = self.__cmp_helper(other, 1)
	# we're guaranteed that the last thing on the list is the first error
	return retlist[len(retlist)-1]['value']

    def cmpList(self, other):
	return self.__cmp_helper(other)

    def diff(self, other):
	if not isinstance(other, type(self)):
	    print 'not the same type'
	else:
	    print 'same type'

    def listDeps(self):
	self.data.findDeps()
	return self.data.deps

if __name__ == '__main__':
    if not len(sys.argv) == 3:
	raise ValueError
    print 'making foo'
    foo = Schema()
    rhnSQL.initDB(sys.argv[1])
    foo.populateFromDB()
    fooString = foo.pickleToString()
    print 'making bar'
    bar = Schema()
    rhnSQL.initDB(sys.argv[2])
    bar.populateFromDB()
    barString = bar.pickleToString()

    print 'deleting objects'
    del foo
    del bar

    print 'reading foo'
    foo = Schema()
    foo.populateFromPickleString(fooString)
    print 'reading bar'
    bar = Schema()
    bar.populateFromPickleString(barString)

    print 'done making objects.  Comparing now.'

    from pprint import pprint
    cmplist = foo.cmpList(bar)
    newcmplist = []
    for cmp in cmplist:
	if not cmp['value'] == 0:
	    newcmplist.append(cmp)
    pprint(newcmplist)
