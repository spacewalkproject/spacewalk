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
# test script for testing the dummy oval file creation 
# based on filling the template using python-cheetah
#


import sys
import os

from Cheetah.Template import Template


MOUNT_POINT = "."

fill_data = {
 'timestamp'      : '2006-08-28T17:21:07',
 'ovalnamespace'  : 'oval:com.redhat.rhsa', 
 'ovalid'         : 20060828,
 'ovalversion'    : '207',
 'severity'       : 'important',
 'synopsis' 	  : 'kernel security update',
 'advisory_name'  : 'RHSA-2006:0828',
 'security_impact': 'important',
 'ovalplatforms'  : 'Red Hat Enterprise Linux 4',
 'errata_type'    : 'RHSA',
 'pushcount'      : 01,
 'description' 	  : '**************description here**************',
 'update_date' 	  : '2006-08-28',
 'issue_date'  	  : '2006-08-28',
 'groups' 	  : [],
 'cve' 		  : ['CVE-2006-2860', 'CVE-2006-2861', 'CVE-2006-2862'],
 'bugs' 	  : [{'id' : 19988, 'summary' : 'summary-19988', 'private' : 1},
           	     {'id' : 19989, 'summary' : 'summary-19989', 'private' : 1},
           	     {'id' : 19990, 'summary' : 'summary-19990', 'private' : 1}],
 'ovalcriteria'   : '',
 'ovalrpmtests'   : '',
 'ovalrpmobjects' : '',
 'ovalrpmstates'  : ''
}


def main():
    oval_tmpl = open("errata.oval.tmpl").read()
    oval = Template(oval_tmpl, searchList=[fill_data])
    xml = str(oval).decode("Latin-1", 'ignore').encode("UTF-8", 'ignore')
    
    oval_file_path = os.path.join(MOUNT_POINT, "output.xml")
    f = open(oval_file_path, 'wb')
    f.write(xml)
    f.close()

if __name__ == '__main__':
    sys.exit(main() or 0)
