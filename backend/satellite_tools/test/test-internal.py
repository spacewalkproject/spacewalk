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
import sys
from spacewalk.satellite_tools.connection import StreamConnection

if __name__ == '__main__':    
    #s = StreamConnection("http://scripts.back-webqa.redhat.com/SAT-DUMP-INTERNAL",
    s = StreamConnection("http://rhnxml.back-webdev.redhat.com/SAT-DUMP-INTERNAL",
    #s = StreamConnection("http://roadrunner.devel.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://coyote.devel.redhat.com/SAT-DUMP-INTERNAL",
        )

    if 1:
        f = s.dump.channels(['redhat-advanced-server-i386'], '20040301000000',
            '20040415000000')
        print f.read()
        f.close()
        sys.exit(0)

    if 0:
        f = s.dump.kickstartable_trees(['ks-redhat-advanced-server-i386-qu3'])
        #f = s.dump.kickstartable_trees(['rhel-i386-as-3'])
        print f.read()
        f.close()
        sys.exit(0)

    if 1:
        f = s.dump.get_ks_file('ks-redhat-advanced-server-i386',
            'images/boot.img')
        print f.read()
        f.close()
        sys.exit(0)

    if 1:
        f = s.dump.packages_short(['rhn-package-16262'])
        print f.read()
        f.close()
    
    if 0:
        f = s.dump.packages(['rhn-package-16262'])
        print f.read()
        f.close()

    if 0:
        f = s.dump.blacklist_obsoletes()
        print f.read()
        f.close()

    if 0:
        f = s.dump.errata(['rhn-erratum-1547'])
        print f.read()
        f.close()

    if 0:
        f = s.dump.get_rpm('rhn-package-16262')
        open("/tmp/xxx.rpm", "w+").write(f.read())
        f.close()

    sys.exit(0)

    #print os.getpid()
    #for i in range(1000):
        #print i
        #f = s.dump.arches(systemid)
        #f = s.dump.channel_families(systemid)
        #f = s.dump.channels(systemid, ['redhat-advanced-server-i386'])
        #f.read()
        #f.close()

    #s = StreamConnection("http://coyote.devel.redhat.com/SAT-DUMP-INTERNAL",
    #    xml_dump_version="2.0")
    #f = s.dump.arches()
    #print f.read()

    #f = s.dump.channel_families()
    #print f.read()

    #f = s.dump.channels()
    #print f.read()


