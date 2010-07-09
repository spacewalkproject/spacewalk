#!/usr/bin/python
#
# Copyright (c) 2008 Red Hat, Inc.
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
#
#
#
# $Id$
import os
import sys
import time
import types
import server.importlib.headerSource
import server.importlib.packageImport
import server.importlib.backendOracle
import server.xmlrpc.up2date
from server import rhnSQL, rhnChannel, rhnServer, rhnUser, rhnServerGroup, rhnActivationKey
from server.xmlrpc import registration

def init_db(username, password, dbhost):
    db = "%s/%s@%s" % (username, password, dbhost)
    rhnSQL.initDB(db)

def create_channel_family():
    cf = rhnChannel.ChannelFamily()
    cf.load_from_dict(new_channel_family_dict())
    cf.save()
    return cf

def create_channel(label, channel_family, org_id=None, channel_arch=None):
    vdict = new_channel_dict( label=label, channel_family=channel_family, org_id = org_id, channel_arch=channel_arch )
    c = rhnChannel.Channel()
    c.load_from_dict( vdict )
    c.save()
    return c

def create_new_org():
    "Create a brand new org; return the new org id"
    org_name = "unittest-org-%.3f" % time.time()
    org_password = "unittest-password-%.3f" % time.time()

    org_id = rhnServerGroup.create_new_org(org_name, org_password)
    rhnSQL.commit()
    return (org_id, org_name, org_password)

def _create_server_group(org_id, name, description, max_members):
    "Create a server group; return the server group object"
    s = rhnServerGroup.ServerGroup()
    s.set_org_id(org_id)
    s.set_name(name)
    s.set_description(description)
    s.set_max_members(max_members)
    s.save()
    rhnSQL.commit()
    return s

def create_server_group(params):
    "Create a server group from a dictionary with the params"
    return apply(_create_server_group, (), params)

def fetch_server_group(org_id, name):
    "Load a server group object from the org id and name"
    s = rhnServerGroup.ServerGroup()
    s.load(org_id, name)
    return s

_query_fetch_server_groups = rhnSQL.Statement("""
    select sgm.server_group_id
      from rhnServerGroupMembers sgm,
           rhnServerGroup sg
     where sgm.server_id = :server_id
      and sgm.server_group_id = sg.id
      and sg.group_type is null
""")
def fetch_server_groups(server_id):
    "Return a server's groups"
    h = rhnSQL.prepare(_query_fetch_server_groups)
    h.execute(server_id=server_id)
    groups = map(lambda x: x['server_group_id'], h.fetchall_dict() or [])
    groups.sort()
    return groups

def build_server_group_params(**kwargs):
    "Build params for server groups"
    params = {
        'org_id'        :   'no such org',
        'name'          :   "unittest group name %.3f" % time.time(),
        'description'   :   "unittest group description %.3f" % time.time(),
        'max_members'   :   1001,
    }
    params.update(kwargs)
    return params

def create_new_user(org_id=None, username=None, password=None, roles=None):
    "Create a new user"
    if org_id is None:
        org_id = create_new_org()
    else:
        org_id = lookup_org_id(org_id)
    
    if username is None:
        username = "unittest-user-%.3f" % time.time()
    if password is None:
        password = "unittest-password-%.3f" % time.time()
    if roles is None:
        roles = []
    
    u = rhnUser.User(username, password)
    u.set_org_id(org_id)
    u.save()
    # The password is scrambled now - re-set it
    u.contact['password'] = password
    u.save()
    user_id = u.getid()

    # Set roles
    h = rhnSQL.prepare("""
        select ug.id
          from rhnUserGroupType ugt, rhnUserGroup ug
         where ug.org_id = :org_id
           and ug.group_type = ugt.id
           and ugt.label = :role
    """)
    create_ugm = rhnSQL.Procedure("rhn_user.add_to_usergroup")
    for role in roles:
        h.execute(org_id=org_id, role=role)
        row = h.fetchone_dict()
        if not row:
            raise InvalidRoleError(org_id, role)

        user_group_id = row['id']
        create_ugm(user_id, user_group_id)

    rhnSQL.commit()
    
    return u

def lookup_org_id(org_id):
    "Look up the org id by user name"
    if isinstance(org_id, types.StringType):
        # Is it a user?

        u = rhnUser.search(org_id)
                                                                            
        if not u:
            raise rhnServerGroup.InvalidUserError(org_id)
                                                                            
        return u.contact['org_id']
                                                                            
    t = rhnSQL.Table('web_customer', 'id')
    row = t[org_id]
    if not row:
        raise rhnServerGroup.InvalidOrgError(org_id)
    return row['id']

#class InvalidEntitlementError(Exception):
#    pass

class InvalidRoleError(Exception):
    pass

def listdir(directory):
    directory = os.path.abspath(os.path.normpath(directory))
    if not os.access(directory, os.R_OK | os.X_OK):
        print "Can't access %s." % (directory)
        sys.exit(1)
    if not os.path.isdir(directory):
        print "%s not valid." % (directory)
        sys.exit(1)
    packageList = []
    for f in os.listdir(directory):
        packageList.append("%s/%s" % (directory, f))
    return packageList

def upload_packages( channel_label, directory, org_id = None, username = None, password = None, source = 0 ):
    #1. Get a list of packages
    filelist = listdir(directory)
    package_list = []

    package_from_file = server.importlib.headerSource.createPackageFromFile
    package_import = server.importlib.packageImport.packageImporter

    oracle_backend = server.importlib.backendOracle.OracleBackend()
    oracle_backend.init()

    #2. Turn them into package objects.
    for file in filelist:
        try:
            package = package_from_file( os.path.join( directory, file ), None, org_id, [channel_label], source = source )
            package_list.append(package)
        except:
            print file
            raise
    
    p = package_import( package_list, oracle_backend, source = source )
    p.ignoreUploaded = 1
    p.run()
    if source == 0:
        p.subscribeToChannels()

#stolen from backend/server/test/unit-test/test_rhnChannel
def new_channel_dict( **kwargs):
    _counter = 0

    label = kwargs.get('label')
    if label is None:
        label = 'rhn-unittest-%.3f-%s' % (time.time(), _counter)
        _counter = _counter + 1

    release = kwargs.get('release') or 'release-' + label
    os = kwargs.get('os') or 'Unittest Distro'
    if kwargs.has_key('org_id'):
        org_id = kwargs['org_id']
    else:
        org_id = 'rhn-noc'

    vdict = {
        'label'             : label,
        'name'              : kwargs.get('name') or label,
        'summary'           : kwargs.get('summary') or label,
        'description'       : kwargs.get('description') or label,
        'basedir'           : kwargs.get('basedir') or '/',
        'channel_arch'      : kwargs.get('channel_arch') or 'i386',
        'channel_families'  : [ kwargs.get('channel_family') or label ],
        'org_id'            : kwargs.get('org_id'),
        'gpg_key_url'       : kwargs.get('gpg_key_url'),
        'gpg_key_id'        : kwargs.get('gpg_key_id'),
        'gpg_key_fp'        : kwargs.get('gpg_key_fp'),
        'end_of_life'       : kwargs.get('end_of_life'),
        'dists'             : [{
                                'release'   : release,
                                'os'        : os,
                            }],
    }
    return vdict


#stolen from backend/server/tests/unit-test/test_rhnChannel
def new_channel_family_dict( **kwargs):
    _counter = 0

    label = kwargs.get('label')
    if label is None:
        label = 'rhn-unittest-%.3f-%s' % (time.time(), _counter)
        _counter = _counter + 1

    product_url = kwargs.get('product_url') or 'http://rhn.redhat.com'

    vdict = {
        'label'             : label,
        'name'              : kwargs.get('name') or label,
        'product_url'       : product_url,
    }
    return vdict


def new_server(user, org_id):
    serv = rhnServer.Server(user, org_id = org_id)
    #serv.default_description()
    params = build_sys_params_with_username( username=user.contact['login'] )
    
    #print params 
    serv.server['release']      = params['os_release']
    serv.server['os']           = "Unittest Distro"
    serv.server['name']         = params['profile_name']       
    serv.set_arch('i386')
    serv.default_description()
    serv.getid()
    serv.gen_secret()    
    serv.save()
    return serv

def create_user(username, password, email=None, org_id=None, org_password=None):
    #reserved = rhnUser.reserve_user( username, password )
    #newuser = rhnUser.new_user( username, password, email, org_id, org_password )
    u = rhnUser.User( username, password )
    u.set_org_id( org_id )
    u.save()
    u.contact['password'] = password
    u.save()
    return u

class Counter:
    _counter = 0
    def value(self):
        val = self._counter
        self._counter = val + 1
        return val

#def register_product(system_id):
#    product = {
#        "reg_num"           : "0",
#        "state"             : "NC",
#        "country"           : "US",
#        "contact-email"     : "test@email.com",
#        "first_name"        : "testwregglej01first",
#        "last_name"         : "testwregglej01last",
#        "company"           : "test company",
#        "phone"             : "555-555-5555",
#        "fax"               : "555-555-5555",
#        "title"             : "None",
#        "position"          : "Test",
#        "city"              : "Raleigh",
#        "zip"               : "27606",
#        "address1"          : "1111 test address dr.",
#        "address2"          : "",
#        "expires"           : "5555-12-12 2224:55:55"
#    }
#    return registration.Registration().register_product( system_id, product )

#stolen from backend/server/test/unit-test/
def build_sys_params_with_username(**kwargs):
    val = Counter().value()
    rnd_string = "%s%s" % (int(time.time()), val)

    params = {
        'os_release'    : '9',
        'architecture'  : 'i386',
        'profile_name'  : "unittest server " + rnd_string,
        'username'      : 'no such user',
        'password'      : 'no such password',
    }
    params.update(kwargs)
    if params.has_key('token'):
        del params['token']
    return params

def register_system( params ):
    data = registration.Registration().new_system(params)
    sysfile = open("/tmp/systemid", "w+")
    sysfile.write(data)
    sysfile.close()

    return data



def create_activation_key(org_id=None, user_id=None, groups=None, 
        channels=None, entitlement_level=None, note=None, server_id=None):
    if org_id is None:
        need_user = 1
        org_id = create_new_org()
    else:
        need_user = 0

    if user_id is None:
        if need_user:
            u = create_new_user(org_id=org_id)
            user_id = u.getid()
    else:
        u = rhnUser.User("", "")
        u.reload(user_id)

    if groups is None:
        groups = []
        for i in range(3):
            params = build_server_group_params(org_id=org_id)
            sg = create_server_group(params)
            groups.append(sg.get_id())

    if channels is None:
        channels = ['rhel-i386-as-3-beta', 'rhel-i386-as-2.1-beta']

    if entitlement_level is None:
        entitlement_level = 'provisioning_entitled'

    if note is None:
        note = "Test activation key %d" % int(time.time())

    a = rhnActivationKey.ActivationKey()
    a.set_user_id(user_id)
    a.set_org_id(org_id)
    a.set_entitlement_level(entitlement_level)
    a.set_note(note)
    a.set_server_groups(groups)
    a.set_channels(channels)
    a.set_server_id(server_id)
    a.save()
    rhnSQL.commit()

    return a
