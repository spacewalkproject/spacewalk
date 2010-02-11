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
import os
import sys
from satellite_tools.connection import StreamConnection

if __name__ == '__main__':    
    #s = StreamConnection("https://xmlrpc.rhn.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://rhnxml.back-webdev.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://roadrunner.devel.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://coyote.devel.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://scripts.back-webqa.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://scripts1.back-rdu.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://xmlrpc.rhn.webqa.redhat.com/SAT-DUMP",
    s = StreamConnection("http://satellite.rhn.redhat.com/SAT-DUMP",
    #s = StreamConnection("http://xmlrpc.rhn.webdev.redhat.com/SAT-DUMP",
        )
    systemid = open("systemid-satellite-live").read()
    #systemid = open("systemid-test01-devel").read()
    #systemid = open("/tmp/systemid-test05").read()

    if 0:
        f = s.dump.channel_packages_short(systemid,
            'redhat-advanced-server-i386', 1093541408)
        print f.read()
        sys.exit(0)

    if 0:
        f = s.dump.channels(systemid, ['redhat-advanced-server-i386'])
        print f.read()
        sys.exit(0)

    if 0:
        f = s.dump.channel_families(systemid)
        print f.read()
        sys.exit(0)

    if 0:
        f = s.dump.arches_extra(systemid)
        print f.read()
        sys.exit(0)

    if 0:
        f = s.dump.arches(systemid)
        print f.read()
        sys.exit(0)

    if 1:
        #f = s.dump.packages(systemid, ['rhn-package-16262'])
        #f = s.dump.packages(systemid, ['rhn-package-55530'])
        #f = s.dump.packages(systemid, ['rhn-package-28615'])
        ks_label = 'ks-rhel-x86_64-ws-4'
        #ks_label = 'ks-redhat-advanced-server-i386-qu3'
        f = s.dump.kickstartable_trees(systemid, [ ks_label ])
        fout = open("/tmp/test-dump.xml", "w+")
        while 1:
            buffer = f.read(65536)
            if not buffer:
                break
            print "Read", len(buffer)
            fout.write(buffer)
        f.close()
        fout.close()
        sys.exit(0)

    if 0:
        f = s.dump.blacklist_obsoletes(systemid)
        print f.read()
        f.close()

    if 1:
        f = s.dump.errata(systemid, ['rhn-erratum-1950'])
        #f = s.dump.errata(systemid, ['rhn-erratum-1965'])
        #f = s.dump.errata(systemid, ['rhn-erratum-1401'])
        print f.read()
        f.close()
        sys.exit(0)

    if 1:
        f = s.dump.packages(systemid, ['rhn-package-231787'])
        print f.read()
        f.close()
        sys.exit(0)

    sys.exit(0)

    print os.getpid()
    for i in range(1000):
        print i
        #f = s.dump.arches(systemid)
        f = s.dump.channel_families(systemid)
        #f = s.dump.channels(systemid, ['redhat-advanced-server-i386'])
        f.read()
        f.close()

    #s = StreamConnection("http://coyote.devel.redhat.com/SAT-DUMP-INTERNAL",
    #    xml_dump_version="2.0")
    #f = s.dump.arches()
    #print f.read()

    #f = s.dump.channel_families()
    #print f.read()

    #f = s.dump.channels()
    #print f.read()

