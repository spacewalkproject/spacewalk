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
# Converts bugzilla errata to the intermediate format
#
# $Id$

# XXX: RED HAT INTERNAL ONLY!

import string
import re
import os
import codecs  # w/ rhn500, now only need to worry about python 2.3+ server-side...
import htmlentitydefs

from common import rhnFault, CFG, rhnLib
from server.importlib.importLib import Erratum
from server.importlib.backendLib import gmtime

advisory_type_map = {
    'RHSA'  : 'Security Advisory',
    'RHBA'  : 'Bug Fix Advisory',
    'RHEA'  : 'Product Enhancement Advisory',
}

class BugzillaErratum(Erratum):
    # Various mappings
    tagMap = {
        'advisory_type' : 'errata_type',
        'refers_to'     : 'reference',
        # Arrays: require a different mapping
        'channels'      : None,
        'packages'      : None,
        'files'         : None,
        'keywords'      : None,
        'bugs'          : None,
        'cve'           : None,
        # We set them differently
        'advisory'      : None,
        'org_id'        : None,
        'advisory_rel'  : 'revision',
        # Unsupported
        'notes'         : None,
        # Used internally
        'last_modified' : None,
    }

    def populate(self, hash, org_id=None):
        for f in self.keys():
            field = f
            if self.tagMap.has_key(f):
                field = self.tagMap[f]
                if not field:
                    # Unsupported
                    continue
            val = hash[field]
            if f in ('issue_date', 'update_date'):
                if val and isinstance(val, type(1)):
                    # A UNIX timestamp
                    val = gmtime(val)
            elif val:
                # Convert to strings
                val = str(val)
            self[f] = val
        
        # compute advisory (see bug #157222)
        advisory = "%s-%s" % (self['advisory_name'], self['advisory_rel'])
        self['advisory'] = advisory

        self['org_id'] = org_id

        self.__processFiles(hash)
        if hash.has_key('bugs'):
            self['bugs'] = process_bug_list(hash['bugs'])
        elif hash.has_key('idsfixedlist'):
            # Old style
            self['bugs'] = parseBugList(hash['idsfixedlist'])
        else:
            # Bug info not present
            raise rhnFault(50, "Bug information not present", explain=0)

        # parse the cve string
        cves = hash.get('cve') or ''
        self['cve'] = parseCVEs(cves)
 	
        objlist = []
        for obj in hash['keywords']:
            objlist.append({'keyword' : str(obj)})
        self['keywords'] = objlist
        # Unescape stuff
        for field in ['solution', 'topic', 'synopsis', 'description', 
                'refers_to', 'notes']:
            val = self[field]
            if not val:
                continue
            val = html_unescape(val)
            self[field] = val

        # Fix the advisory type
        advtype = self['advisory_type']
        if advisory_type_map.has_key(advtype):
            self['advisory_type'] = advisory_type_map[advtype]
	
        # Figure out who deployed the erratum
        self['erratum_deployed_by'] = hash.get('erratum_deployed_by')

        # packages and channels to be completed later
        return self

    def __processFiles(self, hash):
        self['files'] = files = []

        dict = {}
        for erratum_file in hash['errata_files']:
            md5sum = erratum_file['md5sum']
            ftppath = erratum_file['ftppath']
            # bugzilla:221885, lets be little explict on whats missing
            if not ftppath:
                raise rhnFault(50, \
                      "Missing ftppath entry in erratum hash: %s" % erratum_file)

            if not md5sum:
                raise rhnFault(50, \
                      "Missing md5sum entry in erratum hash: %s" % erratum_file)

            if dict.has_key(ftppath):
                raise rhnFault(50, "Duplicate entry for path %s" % ftppath)
            # Fine
            channels = erratum_file['rhn_channel']
            dict[ftppath] = md5sum
            files.append({
                'md5sum'    : md5sum,
                'filename'  : ftppath,
                'channels'  : channels,
            })

def process_bug_list(bugs):
    ret = []
    h = {}
    for bug in bugs:
        if not (bug.has_key('id') and bug.has_key('summary')):
            raise rhnFault(50, "Invalid bug entry %s" % str(bug), explain=0)
        bug_id = int(bug['id'])
        if h.has_key(bug_id):
            # Duplicate bug
            raise rhnFault(50, "Duplicate bug in the bug list: %s" % bug_id,
                explain=0)
        h[bug_id] = None
        bug_summary = bug['summary']
        ret.append({
            'bug_id'    : bug_id,
            'summary'   : bug_summary,
        })
    return ret

def parseBugList(idsfixedlist):
    hash = {}
    list = []
    for entry in idsfixedlist:
        x = string.split(entry, '-', 1)
        x[0] = int(x[0])
        if hash.has_key(x[0]):
            # Duplicate bug
            raise rhnFault(50, "Duplicate bug in the bug list: %s" % x[0],
                explain=0)
        hash[x[0]] = None
        if len(x) == 1:
            x.append(None)
        else:
            x[1] = string.strip(x[1])
        list.append({
            'bug_id'    : x[0],
            'summary'   : x[1],
        })
    return list

def parseCVEs(cves):
    list = []

    list = re.findall("((?:CVE|CAN)-\d\d\d\d-\d\d\d\d)", cves)
    
    return list

def split_md5sum(csums):
    md5s = []
    for x in csums:
            if x == '': continue
            parts = string.split(x, ' ')
            new_parts = []
            for i in parts:
                    if i == '': continue
                    if i == ' ': continue
                    new_parts.append(string.strip(i))
            md5s.append(new_parts)
    return md5s

def html_unescape(text):
    def unesc_number(o):
        return chr(int(o.group("number")))
    def unesc_entity(o):
        val = o.group("entity")
        if htmlentitydefs.entitydefs.has_key(val):
            return htmlentitydefs.entitydefs[val]
        return "&%s;" % val
    if not text:
        return text
    text = re.sub("&#(?P<number>[0-9][0-9]);", unesc_number, text)
    return re.sub("&(?P<entity>[A-Za-z0-9]*);", unesc_entity, text)



# Test code:
if __name__ == '__main__':
    err = {
        'fulladvisory': 'RHSA-2001:169-10', 
        'type': 'RHSA', 
        'revision': 10, 
        'idsfixedlist': [], 
        'obsoletes': '', 
        'cve': 'CAN-2002-0044 CAN-2001-0890, CVE-2000-0001', # space or comma seperated, use re's to extract
        'synopsis': 'Updated Mailman packages available', 
        'cross': 'RHSA-2001:168 RHSA-2001:170', 
        'rpmlist': 'Red Hat Powertools 7.0:\012\012SRPMS:\012ftp://updates.redhat.com/7.0/en/powertools/SRPMS/mailman-2.0.8-0.7.0.src.rpm\012\012alpha:\012ftp://updates.redhat.com/7.0/en/powertools/alpha/mailman-2.0.8-0.7.0.alpha.rpm\012\012i386:\012ftp://updates.redhat.com/7.0/en/powertools/i386/mailman-2.0.8-0.7.0.i386.rpm\012\012Red Hat Powertools 7.1:\012\012SRPMS:\012ftp://updates.redhat.com/7.1/en/powertools/SRPMS/mailman-2.0.8-1.src.rpm\012\012alpha:\012ftp://updates.redhat.com/7.1/en/powertools/alpha/mailman-2.0.8-1.alpha.rpm\012\012i386:\012ftp://updates.redhat.com/7.1/en/powertools/i386/mailman-2.0.8-1.i386.rpm\012\012', 
        'release_date': '', 
        'author': '', 
        'idsfixed': [], 
        'md5list': ['5c0035f2b55edfaae6aa2f0aded1908a 7.0/en/powertools/SRPMS/mailman-2.0.8-0.7.0.src.rpm\012', '98b8f4d6d142c8b6b72fd93dd43be6a6 7.0/en/powertools/alpha/mailman-2.0.8-0.7.0.alpha.rpm\012', '9a897b9b69fb2a547846b02ba0b46886 7.0/en/powertools/i386/mailman-2.0.8-0.7.0.i386.rpm\012', '7247f28d0c41f0844f13dfc594ea0ccf 7.1/en/powertools/SRPMS/mailman-2.0.8-1.src.rpm\012', '841f778f07ef0464019c348f58eaa358 7.1/en/powertools/alpha/mailman-2.0.8-1.alpha.rpm\012', '23d42ac2e45b24de1e051cdc2855d32a 7.1/en/powertools/i386/mailman-2.0.8-1.i386.rpm\012'], 
        'issue_date': '2001-12-11', 
        'update_date': '2001-12-20', 
        'ftp_files': [], 
        'id': 322, 
        'packages': ['mailman-2.0.8-0.7.0', 'mailman-2.0.8-1'], 
        'keywords': ['cross-site', 'scripting'], 
        'package_path': '/mnt/redhat/beehive/updates/powertools', 
        'references': 'http://cve.mitre.org/cgi-bin/cvename.cgi?name=CAN-2001-0884\012http://mail.python.org/pipermail/mailman-announce/2001-November/000031.html\012http://www.cert.org/advisories/CA-2000-02.html\012http://www.cgisecurity.org/advisory/7.txt', 
        'errata_files': {}, 
        'depends': [], 
        'topic': "Updated Mailman packages are now available for Red Hat PowerTools 7 and\0127.1.  These updates fix cross-site scripting bugs which might allow another\012server to be used to gain a user's private information from a server\012running Mailman.", 'solution': 'Before applying this update, make sure all previously released errata\012relevant to your system have been applied.\012\012To update all RPMs for your particular architecture, run:\012\012rpm -Fvh [filenames]\012\012where [filenames] is a list of the RPMs you wish to upgrade.  Only those\012RPMs which are currently installed will be updated.  Those RPMs which are\012not installed but included in the list will not be updated.  Note that you\012can also use wildcards (*.rpm) if your current directory *only* contains the\012desired RPMs.\012\012Please note that this update is also available via Red Hat Network.  Many\012people find this an easier way to apply updates.  To use Red Hat Network,\012launch the Red Hat Update Agent with the following command:\012\012up2date\012\012This will start an interactive process that will result in the appropriate\012RPMs being upgraded on your system.', 
        'ftp_path': '', 
        'relarchlist': ['Red Hat Powertools 7.0 - alpha, i386\012', 'Red Hat Powertools 7.1 - alpha, i386'], 
        'package_map': ['7.0 alpha mailman-2.0.8-0.7.0.alpha.rpm\012', '7.0 i386 mailman-2.0.8-0.7.0.i386.rpm\012', '7.1 alpha mailman-2.0.8-1.alpha.rpm\012', '7.1 i386 mailman-2.0.8-1.i386.rpm\012', '7.0 SRPMS mailman-2.0.8-0.7.0.src.rpm\012', '7.1 SRPMS mailman-2.0.8-1.src.rpm\012', '7.0 alpha mailman-2.0.8-0.7.0\012', '7.0 alpha mailman-2.0.8-1\012', '7.0 i386 mailman-2.0.8-0.7.0\012', '7.0 i386 mailman-2.0.8-1\012', '7.1 alpha mailman-2.0.8-0.7.0\012', '7.1 alpha mailman-2.0.8-1\012', '7.1 i386 mailman-2.0.8-0.7.0\012', '7.1 i386 mailman-2.0.8-1'], 
        'reporter': 4, 
        'description': 'A server running Mailmain versions prior to 2.0.8 will send certain\012user-modifiable data to clients without escaping embedded tags.  This data\012may contain scripts which will then be executed by an unwary client,\012possibly transmitting private information to a third party.\012\012The Common Vulnerabilities and Exposures project (cve.mitre.org) has\012assigned the name CAN-2001-0884 to this issue.', 
        'errata_id': 169, 
        'product': 'Red Hat Powertools'
    }

    e = BugzillaErratum()
    e.populate(err)
    print e['cve']
