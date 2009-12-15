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

import re

from types import ListType, IntType

from common import log_debug, log_error, rhnFlags, rhnException
from server import rhnSQL
from server.rhnServer import server_kickstart

# the "exposed" functions
__rhnexport__ = ['remove',
                 'update',
                 'refresh_list',
                 'delta',
                 'runTransaction',
                 'verify']

class InvalidDep(Exception):
    pass

_query_insert_attribute_verify_results = rhnSQL.Statement("""
insert into rhnServerActionVerifyResult (
    server_id, action_id,
    package_name_id,
    package_evr_id,
    package_arch_id,
    package_capability_id,
    attribute, size_differs, mode_differs, checksum_differs,
    devnum_differs, readlink_differs, uid_differs,
    gid_differs, mtime_differs
)
values (
      :server_id, :action_id,
      lookup_package_name(:package_name),
      lookup_evr(:epoch, :version, :release),
      lookup_package_arch(:arch),
      lookup_package_capability(:filename),
      :attrib, :test_S, :test_M, :test_5,
      :test_D, :test_L, :test_U,
      :test_G, :test_T
)
""")

_query_insert_missing_verify_results = rhnSQL.Statement("""
insert into rhnServerActionVerifyMissing (
    server_id,
    action_id,
    package_name_id,
    package_evr_id,
    package_arch_id,
    package_capability_id
)
values (
    :server_id,
    :action_id,
    lookup_package_name(:package_name),
    lookup_evr(:epoch, :version, :release),
    lookup_package_arch(:arch),
    lookup_package_capability(:filename)
)
""")

_query_delete_verify_results = rhnSQL.Statement("""
    delete from rhnServerActionVerifyResult
     where server_id = :server_id
       and action_id = :action_id
""")

_query_delete_verify_missing = rhnSQL.Statement("""
    delete from rhnServerActionVerifyMissing
     where server_id = :server_id
       and action_id = :action_id
""")

def verify(server_id, action_id, data={}):
    log_debug(3, action_id)

    if not data or not data.has_key('verify_info'):
        # some data should have been passed back...
        log_error("Insufficient package verify information returned",
            server_id, action_id, data)
        return

    log_debug(4, "pkg verify data", data)

    # Remove old results
    h = rhnSQL.prepare(_query_delete_verify_results)
    h.execute(server_id=server_id, action_id=action_id)

    h = rhnSQL.prepare(_query_delete_verify_missing)
    h.execute(server_id=server_id, action_id=action_id)

    attrib_tests = ['S', 'M', '5', 'D', 'L', 'U', 'G', 'T']
    
    # Store the values for executemany() for the attribute-failures
    verify_attribs = { 'server_id' : [], 'action_id' : [], 'package_name' : [],
        'epoch' : [], 'version' : [], 'release' : [], 'arch' : [], 
        'filename' : [], 'attrib' : [], }
    for test in attrib_tests:
        verify_attribs["test_" + test] = []

    # Store the "missing xxxx" results for executemany()
    missing_files = { 'server_id' : [], 'action_id' : [], 'package_name' : [],
        'epoch' : [], 'version' : [], 'release' : [], 'arch' : [], 
        'filename' : [] }
    

    # Uniquify the packages
    uq_packages = {}

    for package_spec, responses in data['verify_info']:
        package_spec = list(package_spec)
        # Fix the epoch
        if package_spec[3] == '':
            package_spec[3] = None
        package_spec = tuple(package_spec)
        if uq_packages.has_key(package_spec):
            # Been here already
            continue

        # We need to uniquify the file names within a package too
        hash = {}
        for response in responses:
            try:
                dict = _parse_response_line(response, attrib_tests)
            except InvalidResponseLine:
                log_error("packages.verify: (%s, %s): invalid line %s" 
                    % (server_id, action_id, response))
                continue

            hash[dict['filename']] = dict

        # Add the rest of the variables to the dictionaries
        for filename, dict in hash.items():
            dict['server_id'] = server_id
            dict['action_id'] = action_id

            dict['package_name'] = package_spec[0]
            dict['version'] = package_spec[1]
            dict['release'] = package_spec[2]
            dict['epoch'] = package_spec[3]
            dict['arch'] = package_spec[4]

            if not dict.has_key('missing'):                
                _hash_append(verify_attribs, dict)
            else:
                _hash_append(missing_files, dict)

        # This package was visited, store it
        uq_packages[package_spec] = None

    if verify_attribs['action_id']:
        h = rhnSQL.prepare(_query_insert_attribute_verify_results)
        apply(h.executemany, (), verify_attribs)

    if missing_files['action_id']:
        h = rhnSQL.prepare(_query_insert_missing_verify_results)
        apply(h.executemany, (), missing_files)
    
    rhnSQL.commit()

# Exception raised when an invalid line is found
class InvalidResponseLine(Exception):
    pass

def _parse_response_line(response, tests):
    # Parses a single line of output from rpmverify
    # Returns a dictionary of values that can be plugged into the SQL query

    # response looks like:
    # 'S.5....T c /usr/share/rhn/up2date_client/iutil.pyc'
    # or
    # '....L...   /var/www/html'
    # or
    # 'missing    /usr/include/curl/types.h'
    # or
    # 'missing  c /var/www/html/index.html'
    #
    #
    #   or something like S.5....T.   /usr/lib/anaconda-runtime/boot/boot.msg
    # with the last line being a . or a C, depending on selinux context
    # see #155952
    #  
    
    res_re = re.compile("^(?P<ts>[\S]+)\s+(?P<attr>[cdglr]?)\s* (?P<filename>[\S]+)$")

    m = res_re.match(response)

    if not m:
        raise InvalidResponseLine

    ts, attr, filename = m.groups()
    # clean up attr, as it can get slightly fudged in the 

    if ts == 'missing':
        return { 'filename': filename, 'missing': None }

    # bug 155952: SELinux will return an extra flag
    # FIXME: need to support the extra selinux context flag
    # I think this is just being paranoid, but to avoid changing schema for 
    # bug 155952 we going to remove the 9th char if we get it
    # ahem, ignore the last flag if we 9 chars
    if len(ts) < len(tests):
        raise InvalidResponseLine

    if not filename:
        raise InvalidResponseLine    
    
    dict = { 
        'attrib' : attr, 
        'filename' : filename,
    }
    # Add the tests
    for i in range(len(tests)):
        val = ts[i]
        t_name = tests[i]
        if val == t_name:
            val = 'Y'
        elif val == '.':
            val = 'N'
        elif val != '?':
            raise InvalidResponseLine
        dict["test_" + t_name] = val

    return dict


def _hash_append(dst, src):
    # Append the values of src to dst
    for k, list in dst.items():
        list.append(src[k])

def update(server_id, action_id, data={}):
    log_debug(3, server_id, action_id)

    action_status = rhnFlags.get('action_status')

    if action_status == 3:
        # Action failed
        kickstart_state = 'failed'
        next_action_type = None
    else:
        kickstart_state = 'deployed'

        #This is horrendous, but in order to fix it I would have to change almost all of the
        #actions code, which we don't have time to do for the 500 beta. --wregglej
        try: 
            ks_session_type = server_kickstart.get_kickstart_session_type(server_id, action_id)
        except rhnException, re:
            ks_session_type = None

        if ks_session_type is None:
            next_action_type = "None"            
        elif ks_session_type == 'para_guest':
            next_action_type = 'kickstart_guest.initiate'
        else:
            next_action_type = 'kickstart.initiate'

    log_debug(4, "next_action_type: %s" % next_action_type)
    
    #More hideous hacked together code to get around our inflexible actions "framework".
    #If next_action_type is "None", we're assuming that we're *not* in a kickstart session
    #at this point, so we don't want to update a non-existant kickstart session.
    #I feel so dirty.  --wregglej
    if next_action_type != "None":
        server_kickstart.update_kickstart_session(server_id, action_id,
            action_status, kickstart_state=kickstart_state,
            next_action_type=next_action_type)

        _mark_dep_failures(server_id, action_id, data)

def remove(server_id, action_id, data={}):
    log_debug(3, action_id, data.get('name'))
    _mark_dep_failures(server_id, action_id, data)


_query_delete_dep_failures = rhnSQL.Statement("""
    delete from rhnActionPackageRemovalFailure
    where server_id = :server_id and action_id = :action_id
""")
_query_insert_dep_failures = rhnSQL.Statement("""
    insert into rhnActionPackageRemovalFailure (
        server_id, action_id, name_id, evr_id, capability_id,
        flags, suggested, sense)
    values (
        :server_id, :action_id, LOOKUP_PACKAGE_NAME(:name),
        LOOKUP_EVR(:epoch, :version, :release), 
        LOOKUP_PACKAGE_CAPABILITY(:needs_name, :needs_version),
        :flags, LOOKUP_PACKAGE_NAME(:suggested, :ignore_null), :sense)
""")

def _mark_dep_failures(server_id, action_id, data):
    if not data:
        log_debug(4, "Nothing to do")
        return
    failed_deps = data.get('failed_deps')
    if not failed_deps:
        log_debug(4, "No failed deps")
        return

    if not isinstance(failed_deps, ListType):
        # Not the right format
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "wrong type %s" % (server_id, action_id, type(failed_deps)))
        return

    inserts = {}
    for f in ( 'server_id', 'action_id', 
            'name', 'version', 'release', 'epoch',
            'needs_name', 'needs_version', 'ignore_null',
            'flags', 'suggested', 'sense'):
        inserts[f] = []
    

    for failed_dep in failed_deps:
        try:
            pkg, needs_pkg, flags, suggested, sense = _check_dep(server_id,
                action_id, failed_dep)
        except InvalidDep:
            continue

        inserts['server_id'].append(server_id)
        inserts['action_id'].append(action_id)
        inserts['name'] .append(pkg[0])
        inserts['version'].append(pkg[1])
        inserts['release'].append(pkg[2])
        inserts['epoch'].append(None)
 
        inserts['needs_name'].append(needs_pkg[0])
        inserts['needs_version'].append(needs_pkg[1])

        inserts['flags'].append(flags)
        inserts['suggested'].append(suggested)
        inserts['ignore_null'].append(1)
        inserts['sense'].append(sense)
        
    h = rhnSQL.prepare(_query_delete_dep_failures)
    rowcount = h.execute(server_id=server_id, action_id=action_id)
    log_debug(5, "Removed old rows", rowcount)

    h = rhnSQL.prepare(_query_insert_dep_failures)

    rowcount = h.execute_bulk(inserts)
    log_debug(5, "Inserted rows", rowcount)

def _check_dep(server_id, action_id, failed_dep):
    log_debug(5, failed_dep)
    if not failed_dep:
        return
    if not isinstance(failed_dep, ListType):
        # Not the right format
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep type error: %s" % (
            server_id, action_id, type(failed_dep)))
        raise InvalidDep

    # This is boring, but somebody's got to do it
    if len(failed_dep) < 5:
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep: not enough entries: %s" % (
            server_id, action_id, len(failed_dep)))
        raise InvalidDep

    pkg, needs_pkg, flags, suggested, sense = failed_dep[:5]

    if not isinstance(pkg, ListType) or len(pkg) < 3:
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep: bad package spec %s (type %s, len %s)" % (
            server_id, action_id, pkg, type(pkg), len(pkg)))
        raise InvalidDep
    pkg = map(str, pkg[:3])
    
    if not isinstance(needs_pkg, ListType) or len(needs_pkg) < 2:
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep: bad needs package spec %s (type %s, len %s)" % (
            server_id, action_id, needs_pkg, type(needs_pkg), 
            len(needs_pkg)))
        raise InvalidDep
    needs_pkg = map(str, needs_pkg[:2])

    if not isinstance(flags, IntType):
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep: bad flags type %s" % (server_id, action_id, type(flags)))
        raise InvalidDep

    if not isinstance(sense, IntType):
        log_error("action_extra_data.packages.remove: server %s, action %s: "
            "failed dep: bad sense type %s" % (server_id, action_id, type(sense)))
        raise InvalidDep
    
    return pkg, needs_pkg, flags, str(suggested), sense

def refresh_list(server_id, action_id, data={}):
    if not data:
        return
    log_error("action_extra_data.packages.refresh_list: Should do something "
        "useful with this data", server_id, action_id, data)

def delta(server_id, action_id, data={}):
    if not data:
        return
    log_error("action_extra_data.packages.delta: Should do something "
        "useful with this data", server_id, action_id, data)

def runTransaction(server_id, action_id, data={}):
    log_debug(3, action_id)
    
    # If it's a kickstart-related transaction, mark the kickstart session as
    # completed
    action_status = rhnFlags.get('action_status')
    ks_session_id = _next_kickstart_step(server_id, action_id, action_status)

    # Cleanup package profile
    server_kickstart.cleanup_profile(server_id, action_id, ks_session_id,
        action_status)
    
    _mark_dep_failures(server_id, action_id, data)

# Determine the next step to be executed in the kickstart code
def _next_kickstart_step(server_id, action_id, action_status):
    if action_status == 3: # Failed
        # Nothing more to do here
        return server_kickstart.update_kickstart_session(server_id, 
            action_id, action_status, kickstart_state='complete', 
            next_action_type=None)

    # Fetch kickstart session id
    ks_session_id = server_kickstart.get_kickstart_session_id(server_id, 
        action_id)
    
    if ks_session_id is None:
        return server_kickstart.update_kickstart_session(server_id, 
            action_id, action_status, kickstart_state='complete', 
            next_action_type=None)

    # Get the current server profile
    server_profile = server_kickstart.get_server_package_profile(server_id)
        
    server_kickstart.schedule_config_deploy(server_id, action_id, 
        ks_session_id, server_profile=server_profile)
    return ks_session_id
