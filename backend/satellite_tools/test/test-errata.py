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
from connection import StreamConnection

if __name__ == '__main__':    
    s = StreamConnection("http://scripts.webqa-colo.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://rhnapp.webdev-colo.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://roadrunner.devel.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://coyote.devel.redhat.com/SAT-DUMP",
        )
    systemid = open("systemid-satellite-live").read()
    f = s.dump.errata(systemid, ["rhn-erratum-1018"])
    print f.read()
    f.close()
