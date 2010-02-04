#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

from common import log_debug, log_error
from common import rhnException
import rhnSQL
import rpm
import string

# QUERY PACKAGES
# sql query for solving a dep as a package
__packages_with_arch_and_id_sql = """
select distinct
    p.id id,
    pn.name name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    1 preference
from
    rhnPackageEvr pe,
    rhnChannelPackage cp,
    rhnPackage p,
    rhnServerChannel sc,
    rhnPackageName pn,
    rhnPackageArch pa
where 1=1
and pn.name = :dep
and sc.server_id = :server_id
and p.name_id = pn.id
and cp.channel_id = sc.channel_id
and p.id = cp.package_id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
and pe.evr = (
    select MAX(pe1.evr)
    from
        rhnPackageEVR pe1,
        rhnChannelPackage cp1,
        rhnPackage p1,
        rhnServerChannel sc1
    where
        sc1.server_id = :server_id
    and p1.name_id = pn.id
    and sc1.channel_id = cp1.channel_id
    and cp1.package_id = p1.id
    and p1.evr_id = pe1.id
    )
"""
__packages_sql = """
select distinct
    pn.name name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    1 preference
from
    rhnPackageEvr pe,
    rhnChannelPackage cp,
    rhnPackage p,
    rhnServerChannel sc,
    rhnPackageName pn,
    rhnPackageArch pa
where 1=1
and pn.name = :dep
and sc.server_id = :server_id
and p.name_id = pn.id
and cp.channel_id = sc.channel_id
and p.id = cp.package_id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
and pe.evr = (
    select MAX(pe1.evr)
    from
        rhnPackageEVR pe1,
        rhnChannelPackage cp1,
        rhnPackage p1,
        rhnServerChannel sc1
    where
        sc1.server_id = :server_id
    and p1.name_id = pn.id
    and sc1.channel_id = cp1.channel_id
    and cp1.package_id = p1.id
    and p1.evr_id = pe1.id
    )
"""

__packages_all_sql = """
select distinct
    pn.name name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    1 preference
from
    rhnPackageEvr pe,
    rhnChannelPackage cp,
    rhnPackage p,
    rhnServerChannel sc,
    rhnPackageName pn,
    rhnPackageArch pa
where 1=1
and pn.name = :dep
and sc.server_id = :server_id
and p.name_id = pn.id
and cp.channel_id = sc.channel_id
and p.id = cp.package_id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
"""
# QUERY PROVIDES
# sql query for solving a dep as a provide
__provides_sql  = """
select  distinct
    pn.name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    2 preference
from
    rhnServerChannel sc,
    rhnChannelPackage cp,
    rhnPackageProvides pr,
    rhnPackage p,
    rhnPackageCapability cap,
    rhnPackageName pn,
    rhnPackageEVR pe,
    rhnPackageArch pa
where
    sc.server_id = :server_id
and sc.channel_id = cp.channel_id
and cp.package_id = p.id
and cp.package_id = pr.package_id
and pr.package_id = p.id
and pr.capability_id = cap.id
and cap.name = :dep
and p.name_id = pn.id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
-- and this package is the latest one from all the channels
-- this server is subscribed to.
and pe.evr = (
    select MAX(pe1.evr)
    from
        rhnPackage p1,
        rhnPackageEVR pe1,
        rhnServerChannel sc1,
        rhnChannelPackage cp1
    where
        sc1.server_id = :server_id
    and sc1.channel_id = cp1.channel_id
    and cp1.package_id = p1.id
    and p1.name_id = pn.id
    and p1.evr_id = pe1.id
    )
"""

__provides_all_sql  = """
select  distinct
    pn.name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    2 preference
from
    rhnServerChannel sc,
    rhnChannelPackage cp,
    rhnPackageProvides pr,
    rhnPackage p,
    rhnPackageCapability cap,
    rhnPackageName pn,
    rhnPackageEVR pe,
    rhnPackageArch pa
where
    sc.server_id = :server_id
and sc.channel_id = cp.channel_id
and cp.package_id = p.id
and cp.package_id = pr.package_id
and pr.package_id = p.id
and pr.capability_id = cap.id
and cap.name = :dep
and p.name_id = pn.id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
"""
# QUERY FILES
# sql query for solving a dependency as a file provide
__files_sql = """
select distinct
    pn.name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    3 preference
from
    rhnServerChannel sc,
    rhnChannelPackage cp,
    rhnPackageFile f,
    rhnPackage p,
    rhnPackageCapability cap,
    rhnPackageName pn,
    rhnPackageEVR pe,
    rhnPackageArch pa
where
    sc.server_id = :server_id
and sc.channel_id = cp.channel_id
and cp.package_id = p.id
and cp.package_id = f.package_id
and f.capability_id = cap.id
and cap.name = :dep
and p.name_id = pn.id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
-- and this package is the latest one from all the channels
-- this server is subscribed to.
and pe.evr = (
    select MAX(pe1.evr)
    from
        rhnPackage p1,
        rhnPackageEVR pe1,
        rhnServerChannel sc1,
        rhnChannelPackage cp1
    where
        sc1.server_id = :server_id
    and sc1.channel_id = cp1.channel_id
    and cp1.package_id = p1.id
    and p1.name_id = pn.id
    and p1.evr_id = pe1.id
    )
"""


__files_all_sql = """
select distinct
    pn.name,
    pe.evr.version version,
    pe.evr.release release,
    pe.evr.epoch epoch,
    pa.label arch,
    3 preference
from
    rhnServerChannel sc,
    rhnChannelPackage cp,
    rhnPackageFile f,
    rhnPackage p,
    rhnPackageCapability cap,
    rhnPackageName pn,
    rhnPackageEVR pe,
    rhnPackageArch pa
where
    sc.server_id = :server_id
and sc.channel_id = cp.channel_id
and cp.package_id = p.id
and cp.package_id = f.package_id
and f.capability_id = cap.id
and cap.name = :dep
and p.name_id = pn.id
and p.evr_id = pe.id
and p.package_arch_id = pa.id
"""

class SolveDependenciesError(Exception):
    def __init__(self, deps=None, packages=None, *args, **kwargs):
        apply(Exception.__init__, (self, ) + args, kwargs)
        self.deps = deps
        self.packages = packages

class InvalidLimitField(SolveDependenciesError):
    pass

class InvalidLimitOperator(SolveDependenciesError):
    pass

class InvalidLimit(SolveDependenciesError):
    pass

class IncompleteLimitInfo(SolveDependenciesError):
    pass

class MakeEvrError(SolveDependenciesError):
    pass

def __single_query(server_id, deps, query):
    """ Now run one of those queries and return the results. """
    ret = {}
    # first prepare the statement
    h = rhnSQL.prepare(query)
    for dep in deps:
        h.execute(server_id = server_id, dep = dep)
        data = h.fetchall() or []
        ret[dep] = map(lambda a: a[:4], data)
    return ret

def __single_query_with_arch_and_id(server_id, deps, query):
    """ Run one of the queries and return the results along with the arch. """
    ret = {}
    h = rhnSQL.prepare(query)
    for dep in deps:
        h.execute(server_id = server_id, dep = dep)
        data = h.fetchall() or []
        ret[dep] = map(lambda a: a[:6], data)
    return ret

def make_evr(nvre):
    """ IN: 'e:name-version-release' or 'name-version-release:e'
        OUT: {'name':name, 'version':version, 'release':release, 'epoch':epoch }
    """
    epoch = ''
    name = ''
    version = ''
    release = ''
    list = None
    ret = None    

    #There is an epoch
    if string.find(nvre, ':') != -1:
        holder = string.split(nvre, ':')
        
        #holder[0] has the n,v,r,a
        if string.find(holder[0], '-') != -1:
            holder[0] = string.split(holder[0], '-')
            ret = {
                'name'      :   holder[0][0],
                'version'   :   holder[0][1],
                'release'   :   holder[0][2],
                'epoch'     :   holder[1]
            }
            return ret
        elif string.find(holder[1], '-') != -1:
            holder[1] = string.split(holder[1], '-')
            ret = {
                'name'      :   holder[1][0],
                'version'   :   holder[1][1],
                'release'   :   holder[1][2],
                'epoch'     :   holder[0]
            }
            return ret
        else:
            raise rhnException.rhnFault(err_code = 21, 
                                         err_text = "NVRE is missing name, version, or release.")
    elif string.find(nvre, '-') != -1:
        nvre = string.split(nvre, '-')
        ret = {
            'name'      :   nvre[0],
            'version'   :   nvre[1],
            'release'   :   nvre[2],
            'epoch'     :   None
        }
        return ret
    else:
        return MakeEvrError(message = "NVRE is missing name, version, or release.")

#
# Interfaces
#

# simple one type queries
def find_package_with_arch(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query_with_arch_and_id(server_id, deps, __packages_with_arch_and_id_sql)

def find_by_packages(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __packages_sql)
def find_by_packages_all(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __packages_all_sql)

def find_by_provides(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __provides_sql)
def find_by_provides_all(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __provides_all_sql)

def find_by_files(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __files_sql)
def find_by_files_all(server_id, deps):
    log_debug(4, server_id, deps)
    return __single_query(server_id, deps, __files_all_sql)

def solve_dependencies_with_limits(server_id, deps, version, all = 0, limit_operator=None, limit = None):
    """ This version of solve_dependencies allows the caller to get all of the packages that solve a dependency and limit
        the packages that are returned to those that match the criteria defined by limit_operator and limit. This version
        of the function also returns the architecture label of the package[s] that get returned.

        limit_operator can be any of: '<', '<=', '==', '>=', or '>'.
        limit is a a string of the format [epoch:]name-version-release
        deps is a list of filenames that the packages that are returned must provide.
        version is the version of the client that is calling the function.

        Indexes for the tuple
        entry_index = 0
        preference_index = 1

        Indexes for the list of package fields.
        name_index = 0
        version_index = 1
        release_index = 2
        epoch_index = 3
    """
    #Containers used while the packages get categorized, sorted, and filtered.
    packages_all = {}
    package_list = []

    #List of fields in a package. Corresponds to the keys for the dictionary that holds the package information.
    nvre = ['name','version','release','epoch','arch']

    #Make sure there are no duplicate dependencies.
    deplist = []
    for dep in deps:
        if dep not in deplist:
            deplist.append(dep)

    statement = "%s UNION ALL %s UNION ALL %s" % (__packages_all_sql, __provides_all_sql, __files_all_sql)
    h = rhnSQL.prepare(statement)

    # prepare return value
    packages = {}

    for dep in deplist:
        dict = {}
        
        #Retrieve the package information from the database.
        h.execute(server_id = server_id, dep=dep)
        
        #Get a list of dictionaries containing row data.
        rs = h.fetchall_dict() or [] #rs = [{},{},... ]

        #Each package gets a list that may contain multiple versions of a package
        for record in rs:
            if packages_all.has_key(record['name']):
                packages_all[record['name']].append(record)
            else:
                packages_all[record['name']] = [record]

        #sort all the package lists so the most recent version is first
        for pl in packages_all.keys():
            
            packages_all[pl].sort(cmp_evr)
            package_list = package_list + packages_all[pl]
       
        package_list.reverse()
        #Use the limit* parameters to filter out packages you don't want. 
        if limit_operator != None and limit != None:
            keep_list = []

            try:
                limit = make_evr(limit)
            except:
                raise
  
            for package in package_list:
                try:
                    keep = test_evr(package, limit_operator,  limit)
                except:
                    raise

                if keep:
                    keep_list.append(package)
 
            package_list = keep_list

        
        list_of_tuples = []
        for p in package_list:
            if p['epoch'] == None:
                p['epoch'] = ""

            entry = []

            map(lambda f, e = entry, p = p: e.append(p[f]), nvre)

            #Added for readability
            name_key = entry[0]
        
            if all == 0: 
                #NOTE: Remember that the values in dict are tuples that look like (entry, preference).
                #NOTE, Part Deux: the '<=' was a '<' originally. I changed it because if two packages
                #with the same preference but different versions came through, the second package was being used.
                #The changes I made above make it so that at this point the packages are sorted from highest nvre 
                #to lowest nvre. Selecting the second package was causing the earlier package to be 
                #returned, which is bad.
                if dict.has_key(name_key) and dict[name_key][1] <= p['preference']:
                    # Already have it with a lower preference
                    continue            
                # The first time we see this package.
                dict[name_key] = (entry, p['preference'])
            else:               
                name_key = entry[ 0 ]
                newtuple = (entry, p['preference'])
                list_of_tuples.append(newtuple)

        if all == 0:
            # attempt to avoid giving out the compat-* packages if there are other candidates
            if len(dict) > 1:
                matches = dict.keys()
        
                # check we have at least one non- "compat-*" package name
                compats = filter(lambda a: a[:7] == "compat-", matches)
        
                if len(compats) > 0 and len(compats) < len(matches): # compats and other things
                    for p in compats: # delete all references to a compat package for this dependency
                        del dict[p]
                # otherwise there's nothing much we can do (no compats or only compats)
        
            # and now return these final results ordered by preferece
            list_of_tuples = dict.values()
        else:
            #filter out compats
            if len(list_of_tuples) > 1:
                filterstring = "compat-"
                len_filter = len(filterstring)
                tup_keep = []
                for tup in list_of_tuples:
                    if tup[0][0][:len_filter] != filterstring:
                        tup_keep.append(tup)
                list_of_tuples = tup_keep

        list_of_tuples.sort(lambda a, b: cmp(a[1], b[1]))
        packages[dep] = map(lambda x: x[0], list_of_tuples)
        
    # v2 clients are done
    if version > 1:
        return packages
    
    # v1 clients expect a list as a result
    result = []
    # Return the results in order (not that anyone would care)
    for dep in deplist:
        if not packages[dep]:
            # Unresolved dependency; skip it
            continue
        # consider only the first one for each dep
        r = packages[dep][0]
        # Avoid sending the same result back multiple times
        if all == 0:
            if r not in result:
                result.append(r)
        else:
            result.append(r)
    return result

def solve_dependencies_arch(server_id, deps, version):
    """ Does the same thing as solve_dependencies, but also returns the architecture label with the package info.
        IN:
           server_id := id info of the server
           deps := list of filenames that are needed by the caller
           version := version of the client

        OUT:
           Dictionary with key values being the filnames in deps and the values being a list of lists of package info.
           Example :=  {'filename1'    :   [['name', 'version', 'release', 'epoch', 'architecture'],
                                            ['name2', 'version2', 'release2', 'epoch2', 'architecture2']]}

        Indexes for the tuple stored as the value in dict
        entry_index = 0
        preference_index = 1

        indexes for the list nvre
        name_index = 0
        version_index = 1
        release_index = 2
        epoch_index = 3
    """
    #list of the keys to the values in each row of the recordset.
    nvre = ['name', 'version', 'release', 'epoch', 'arch']

    # first, uniquify deps
    deplist = []
    for dep in deps:
        if dep not in deplist:
            deplist.append(dep)
    
    # SQL statement.  It is a union of 3 statements: 
    #  - Lookup by package name
    #  - Lookup by provides
    #  - Lookup by file name
    statement = "%s UNION ALL %s UNION ALL %s" % (
        __packages_sql, __provides_sql, __files_sql)
    h = rhnSQL.prepare(statement)

    # prepare return value
    packages = {}

    # Iterate through the dependency problems
    for dep in deplist:
        dict = {}               #Each value will be a tuple like (list, preference)
        h.execute(server_id = server_id, dep = dep)
        rs = h.fetchall_dict() or []

        if not rs: # test shortcut
            log_error("Unable to solve dependency", server_id, dep)
            packages[dep] = []
            continue
        
        for p in rs:
            if p['epoch'] == None:
                p['epoch'] = ""

            entry = []

            map(lambda f, e = entry, p = p: e.append(p[f]), nvre)

            #Exists for readability
            name_key = entry[0]

            if dict.has_key(name_key) and dict[name_key][1] < p['preference']:
                # Already have it with a lower preference
                continue            
            # The first time we see this package.
            dict[name_key] = (entry, p['preference'])

        # attempt to avoid giving out the compat-* packages if there are other candidates
        if len(dict) > 1:
            matches = dict.keys()
        
            # check we have at least one non- "compat-*" package name
            compats = filter(lambda a: a[:7] == "compat-", matches)
        
            if len(compats) > 0 and len(compats) < len(matches): # compats and other things
                for p in compats: # delete all references to a compat package for this dependency
                    del dict[p]
            # otherwise there's nothing much we can do (no compats or only compats)
        
        # and now return these final results ordered by preferece
        list_of_tuples = dict.values()
        list_of_tuples.sort(lambda a, b: cmp(a[1], b[1]))
        packages[dep] = map(lambda x: x[0], list_of_tuples)
        
    # v2 clients are done
    if version > 1:
        return packages
    
    # v1 clients expect a list as a result
    result = []
    # Return the results in order (not that anyone would care)
    for dep in deplist:
        if not packages[dep]:
            # Unresolved dependency; skip it
            continue
        # consider only the first one for each dep
        r = packages[dep][0]
        # Avoid sending the same result back multiple times
        if r not in result:
            result.append(r)
    return result

def solve_dependencies(server_id, deps, version):
    """ The unchanged version of solve_dependencies. 
        IN: 
           server_id := id info of the server
           deps := list of filenames that are needed by the caller
           version := version of the client

        OUT:
           Dictionary with key values being the filnames in deps and the values being a list of lists of package info.
           Example :=  {'filename1'    :   [['name', 'version', 'release', 'epoch'], 
                                            ['name2', 'version2', 'release2', 'epoch2']]}    
    """
    # first, uniquify deps
    deplist = []
    for dep in deps:
        if dep not in deplist:
            deplist.append(dep)

    # SQL statement.  It is a union of 3 statements:
    #  - Lookup by package name
    #  - Lookup by provides
    #  - Lookup by file name

    statement = "%s UNION ALL %s UNION ALL %s" % (
        __packages_sql, __provides_sql, __files_sql)
    h = rhnSQL.prepare(statement)

    # prepare return value
    packages = {}
    # Iterate through the dependency problems
    for dep in deplist:
        dict = {}
        h.execute(server_id = server_id, dep = dep)
        rs = h.fetchall_dict() or []
        if not rs: # test shortcut
            log_error("Unable to solve dependency", server_id, dep)
            packages[dep] = []
            continue

        for p in rs:
            if p['epoch'] == None:
                p['epoch'] = ""
            entry = []
            map(lambda f, e = entry, p = p: e.append(p[f]),
                ['name', 'version', 'release', 'epoch'])
            if dict.has_key(entry[0]) and dict[entry[0]][1] < p['preference']:
                # Already have it with a lower preference
                continue
            # The first time we see this package.
            dict[entry[0]] = (entry, p['preference'])
        # attempt to avoid giving out the compat-* packages if there are other candidates
        if len(dict) > 1:
            matches = dict.keys()
            # check we have at least one non- "compat-*" package name
            compats = filter(lambda a: a[:7] == "compat-", matches)
            if len(compats) > 0 and len(compats) < len(matches): # compats and other things
                for p in compats: # delete all references to a compat package for this dependency
                    del dict[p]
            # otherwise there's nothing much we can do (no compats or only compats)
        # and now return these final results ordered by preferece
        l = dict.values()
        l.sort(lambda a, b: cmp(a[1], b[1]))
        packages[dep] = map(lambda x: x[0], l)

    # v2 clients are done
    if version > 1:
        return packages
    
    # v1 clients expect a list as a result
    result = []
    # Return the results in order (not that anyone would care)
    for dep in deplist:
        if not packages[dep]:
            # Unresolved dependency; skip it
            continue
        # consider only the first one for each dep
        r = packages[dep][0]
        # Avoid sending the same result back multiple times
        if r not in result:
            result.append(r)
    return result



def cmp_evr(pkg1, pkg2):
    """ Intended to be passed to a list object's sort().
        In: {'epoch': 'value', 'version':'value', 'release':'value'}
    """
    pkg1_epoch = pkg1['epoch']
    pkg1_version = pkg1['version']
    pkg1_release = pkg1['release']

    pkg2_epoch = pkg2['epoch']
    pkg2_version = pkg2['version']
    pkg2_release = pkg2['release']

    if pkg1_epoch is not None:
        pkg1_epoch = str(pkg1_epoch)
    elif pkg1_epoch == '':
        pkg1_epoch = None

    if pkg2_epoch is not None:
        pkg2_epoch = str(pkg2_epoch)
    elif pkg1_epoch == '':
        pkg1_epoch = None

    return rpm.labelCompare((pkg1_epoch, pkg1_version, pkg1_release),
                             (pkg2_epoch, pkg2_version, pkg2_release))

def test_evr(evr, operator, limit):
    """ Check to see if evr is within the limit.
        IN: evr = { 'epoch' : value, 'version':value, 'release':value }
            operator can be any of: '<', '<=', '==', '>=', '>'
            limit = { 'epoch' : value, 'version':value, 'release':value }
        OUT: 
           1 or 0
    """
    good_operators = ['<', '<=', '==', '>=', '>']

    if not operator in good_operators:
        raise rhnException.rhnFault(err_code = 21, 
                                     err_text = "Bad operator passed into test_evr.")

    evr_epoch = evr['epoch']
    evr_version = evr['version']
    evr_release = evr['release']

    limit_epoch = limit['epoch']
    limit_version = limit['version']
    limit_release = limit['release']

    if evr_epoch is not None:
        evr_epoch = str(evr_epoch)
    elif evr_epoch == '':
        evr_epoch = None

    if limit_epoch is not None:
        limit_epoch = str(limit_epoch)
    elif limit_epoch == '':
        limit_epoch = None

    ret = rpm.labelCompare((evr_epoch, evr_version, evr_release ),\
                            (limit_epoch, limit_version, limit_release))

    return check_against_operator(ret, operator)


def check_against_operator(ret, operator):
    if ret == -1:
        if operator in (">", ">=", "=="):
            return 0
        if operator in ("<", "<="):
            return 1
    if ret == 0:
        if operator in (">", "<"):
            return 0
        if operator in (">=", "<=", "=="):
            return 1
    if ret == 1:
        if operator in ("<", "<=", "=="):
            return 0
        if operator in (">", ">="):
            return 1
    return 0

##### DEVEL NOTES
# This faster query for solvind dependencies that refer to package
# names causes Oracle 9i (all versions) to segfault badly. We
# therefore use a slower query that has the drawback of effectively
# double selecting the same data and then filtering it to obtain the
# correct response.
##__packages_sql = """
##select 
##    q.name,
##    q.evr.version version,
##    q.evr.release release,
##    q.evr.epoch epoch,
##    1 preference
##from
##    ( select 
##          pn.name name, 
##          max(pe.evr) evr
##      from
##          rhnServerChannel sc,
##          rhnChannelPackage cp,
##          rhnPackage p,
##          rhnPackageName pn,
##          rhnPackageEVR pe
##      where
##          sc.server_id = :server_id
##      and sc.channel_id = cp.channel_id
##      and cp.package_id = p.id
##      and p.name_id = pn.id
##      and pn.name = :dep
##      and p.evr_id = pe.id
##      group by pn.name
##    ) q
##"""

