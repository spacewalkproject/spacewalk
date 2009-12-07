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
# RHN sanity tests for RPMs
#

import time
import string

from common import RPC_Base, log_debug
from spacewalk.common import rhn_rpm

from server import rhnSQL

#from app.importlib.packageImport import uploadPackages, listChannels
from server.importlib.userAuth import UserAuth

class RHNLint(RPC_Base):
    def __init__(self):
	RPC_Base.__init__(self)        
        self.functions.append('testPackages')

    # perform sanity test of package headers, and send back a report of the results...
    def testPackages(self, login, password, info):
        authobj = auth(login, password)
        info['orgId'] = authobj.org_id
        packages = info.get('packages')

        for package in packages:
            package['header'] = rhn_rpm.headerLoad(package['header'].data)

        # get back dictionaries of lists, key == filename
        results = {}

        log_debug(1, info)
        
        testMD5sums(info, results)
        testObsoletes(info, results)
        testDependencies(info, results)
        
        #log_debug(3, results)

        problems = []
        for problem_package in results.keys():
            problems.append(format_package_problems(problem_package, results[problem_package]))

        return """

rhn-lint RPM Package Tests:
===========================

Problem packages:

%s
""" % string.join(problems, "\n\n")


#======================
# utility functions
#======================

# given a bunch of problems about a package, format them in a reasonable way
def format_package_problems(package, problems):
    return "%s:\n%s\n" % (package, string.join(problems, "\n"))


# A function that formats a UNIX timestamp to the session's format
def gmtime(timestamp):
    ttuple = time.gmtime(timestamp)
    return "%d-%02d-%02d %02d:%02d:%02d" % ttuple[:6]


def auth(login, password):
    # Authorize this user
    authobj = UserAuth()
    authobj.auth(login, password)
    # Check if he's authorized to perform administrative tasks
    authobj.authzOrg({'orgId' : authobj.org_id})
    return authobj


# given header, spit out clean string representation of nvrea'ish stuff
def nvr(header):
    return ("%s-%s-%s" % (header['name'], header['version'], header['release']))

def nvre(header):
    if (header['epoch']):
        epoch_str = ":%s" % header['epoch']
    else:
        epoch_str = ""
        
    return ("%s-%s-%s%s" % (header['name'], header['version'], header['release'], epoch_str))

def nvrea(header):
    return header['nvrea']



#======================================
#  The sanity tests...

# tests if package obsoletes itself
def testObsoletes(info, results):

    packages = info.get('packages')
    
    for package in packages:
        header = package['header']

        # if exists, comes back in a list form
        #if header['obsoletes']:
            
    return

# see if dependencies can be met
# basically, if a package in the set has a REQUIRE, make sure something in the tested channel
# (or the tested channel's parent) can satisfy that requirement.
#
# TODO:  include the information from the other packages in the set?
def testDependencies(info, results):

    packages = info.get('packages')
    channel_labels = info.get('channels')

    #log_debug(1, "channel labels == %s" % str(channel_labels))

    # hacked from rhn/backend/server/rhnServer/rpmdata.py
    # much hackage here to get it running on webdev.  still trying to figure out why this stuff
    # causes ORA-3113 errors under oracle 9i
    statement = """
            select 
                q.package_name,
                q.evr.version version,
                q.evr.release release,
                q.evr.epoch epoch,
                1 preference
            from
                (select 
                    pn.name package_name,
                    pe.evr evr,
                    max(pe.evr) evr2
                from rhnChannel c1,
                    rhnChannel c2,
                    rhnChannelPackage cp,
                    rhnPackage p,
                    rhnPackageName pn,
                    rhnPackageEVR pe
                where c1.label = :channel_label
                    and c2.id in (c1.id, c1.parent_channel)
                    and c2.id = cp.channel_id
                    and cp.package_id = p.id
                    and p.name_id = pn.id
                    and pn.name = :dep
                    and p.evr_id = pe.id
                group by pn.name, pe.evr
                ) q
            union all
            -- provides
            select 
                pn.name package_name,
                pe.evr.version version,
                pe.evr.release release,
                pe.evr.epoch epoch,
                2 preference
            from
                rhnChannel c1,
                rhnChannel c2,
                rhnChannelPackage cp,
                rhnPackageProvides pr,
                rhnPackage p,
                rhnPackageCapability cap,
                rhnPackageName pn,
                rhnPackageEVR pe
             where c1.label = :channel_label
                and c2.id in (c1.id, c1.parent_channel)
                and c2.id = cp.channel_id
                and cp.package_id = p.id
                and cp.package_id = pr.package_id
                and pr.capability_id = cap.id
                and cap.name = :dep
                and p.name_id = pn.id
                and p.evr_id = pe.id
                and pe.evr in (
                    select MAX(pe1.evr)
                    from rhnPackage p1,
                        rhnPackageEvr pe1,
                        rhnChannelPackage cp1
                    where  cp1.channel_id = c2.id
                        and cp1.package_id = p1.id
                        and p1.name_id = pn.id
                        and p1.evr_id = pe1.id
                    )
            union all
            -- files
            select 
                pn.name package_name,
                pe.evr.version version,
                pe.evr.release release,
                pe.evr.epoch epoch,
                3 preference
            from rhnChannel c1,
                rhnChannel c2,
                rhnChannelPackage cp,
                rhnPackageFile f,
                rhnPackage p,
                rhnPackageCapability cap,
                rhnPackageName pn,
                rhnPackageEVR pe
            where c1.label = :channel_label
                and c2.id in (c1.id, c1.parent_channel)
                and c2.id = cp.channel_id
                and cp.package_id = p.id
                and cp.package_id = f.package_id
                and f.capability_id = cap.id
                and cap.name = :dep
                and p.name_id = pn.id
                and p.evr_id = pe.id
                and pe.evr in (
                select MAX(pe1.evr)
                    from rhnPackage p1,
                        rhnPackageEvr pe1,
                        rhnChannelPackage cp1
                    where cp1.channel_id = c2.id
                        and cp1.package_id = p1.id
                        and p1.name_id = pn.id
                        and p1.evr_id = pe1.id
                    )
                    """

    h = rhnSQL.prepare(statement)

    for package in packages:
        header = package['header']
        filename = package['filename']

        if header['requirename'] is not None:
            #log_debug(1, header['requirename'])
            #log_debug(1, header['requireversion'])
            
            for i in range(0, len(header['requirename'])):

                # ignore rpm-internally-satisfied requires...
                if (len(header['requirename'][i]) > 7 and header['requirename'][i][0:7] != 'rpmlib('):

                    #log_debug(1, header['requirename'][i])
                    
                    for channel_label in channel_labels:

                        h.execute(channel_label = str(channel_label), dep = str(header['requirename'][i]))

                        rs = h.fetchall_dict() or []

                        if rs == []:
                            if (not results.has_key(filename)):
                                results[filename] = []

                            results[filename].append("dependency not met in tested channel %s (nor any parent):  %s"
                                                     % (channel_label, header['requirename'][i]))
                            
                        # do we have to worry about REQUIREVERSION here?
                        
                        del rs

    return
    
# test to insure that no package with the same nvre but different md5 sum is in the db...
# basically, complains if someone just resigns a package w/out bumping release
#
# NOTE:  currently, only cares about packages w/ org_id in (null, your_org)
def testMD5sums(info, results):

    packages = info.get('packages')
    
    for package in packages:
        header = package['header']
        filename = package['filename']
        query = """
        select pn.name || '-' || pe.evr.as_vre_simple() nvre, c.checksum md5sum,
               p.org_id org_id, p.build_host buildhost, p.build_time buildtime
          from rhnPackageArch pa, rhnPackageName pn, rhnPackageEVR pe, 
            rhnPackage p, rhnChecksum c
         where pn.name = :name
               and pe.version = :version
               and pe.release = :release
               and pe.epoch %s
               and pn.id = p.name_id
               and pe.id = p.evr_id
               and p.checksum_id = c.id
               and c.checksum != :md5sum
               and (p.org_id is null or p.org_id = :org_id)
               and pa.label = :arch
               and p.package_arch_id = pa.id
               """
        params = { 
            'name':header['name'], 
            'version':header['version'], 
            'release':header['release'], 
            'epoch':header['epoch'], 
            'md5sum':package['md5sum'],
            'org_id':info['org_id'],
            'arch':header['arch'],
        }

        if not header['epoch']:
            epoch_query_str = "is null"
            del params['epoch']
        else:
            epoch_query_str = "= :epoch"

        h = rhnSQL.prepare(query % epoch_query_str)
        apply(h.execute,(),params)

        query_results = h.fetchall_dict()

        if query_results and len(query_results):
            for row in query_results:
                if (row['org_id']):
                    org_str = " in org %s" % row['org_id']
                else:
                    org_str = ''
                    
                if (not results.has_key(filename)):
                    results[filename] = []

                different_fields = []

                if (header['buildhost'] != row['buildhost']):
                    different_fields.append("tested package buildhost:\t%s\ndb package buildhost:\t\t%s" % (header['buildhost'], row['buildhost']))

                if (gmtime(header['buildtime']) != str(row['buildtime'])):
                    different_fields.append("tested package buildtime:\t%s\ndb package buildtime:\t\t%s" % (gmtime(header['buildtime']), row['buildtime']))
                if len(different_fields) > 0:
                    further_info = "It's probably a different/recompiled package:\n%s" % string.join(different_fields, "\n")
                else:
                    further_info = "only MD5 sums differ, packages probably was just resigned"

                results[filename].append("\nAlready found with an md5 sum of %s%s\n%s"
                                         % (row['md5sum'], org_str, further_info))


    return
