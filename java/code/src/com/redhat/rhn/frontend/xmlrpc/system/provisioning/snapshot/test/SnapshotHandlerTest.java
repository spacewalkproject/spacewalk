/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.frontend.xmlrpc.system.provisioning.snapshot.test;

import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageNevra;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.xmlrpc.system.provisioning.snapshot.SnapshotHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.testing.ServerGroupTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SnapshotHandlerTest
 * @version $Rev$
 */
public class SnapshotHandlerTest extends BaseHandlerTestCase {

    private SnapshotHandler handler = new SnapshotHandler();

    private ServerSnapshot generateSnapshot(Server server) {
        ServerSnapshot snap = new ServerSnapshot();
        snap.setServer(server);
        snap.setOrg(server.getOrg());
        snap.setReason("blah");
        return snap;
    }

    public void testListSnapshots() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server);
        ServerGroup grp = ServerGroupTestUtils.createEntitled(server.getOrg());
        snap.addGroup(grp);

        TestUtils.saveAndFlush(snap);
        Map dateInfo = new HashMap();
        List<ServerSnapshot> list = handler.listSnapshots(adminKey,
                server.getId().intValue(), dateInfo);
        assertContains(list, snap);
        assertContains(snap.getGroups(), grp);

    }

    public  void testListSnapshotPackages() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server);
        Package pack = PackageTest.createTestPackage();
        PackageNevra packN = new PackageNevra();
        packN.setArch(pack.getPackageArch());
        packN.setEvr(pack.getPackageEvr());
        packN.setName(pack.getPackageName());
        snap.getPackages().add(packN);
        TestUtils.saveAndFlush(packN);
        TestUtils.saveAndFlush(snap);
        Set<PackageNevra> list = handler.listSnapshotPackages(adminKey,
                snap.getId().intValue());
         assertContains(list, packN);
    }

    public void testDeleteSnapshot() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server);
        TestUtils.saveAndFlush(snap);

        handler.deleteSnapshot(adminKey, snap.getId().intValue());
        Map dateInfo = new HashMap();
        List<ServerSnapshot> list = handler.listSnapshots(adminKey,
                server.getId().intValue(), dateInfo);
        assertTrue(list.size() == 0);

    }

    public void testDeleteSnapshots() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true);
        ServerSnapshot snap = generateSnapshot(server);
        generateSnapshot(server);
        generateSnapshot(server);
        generateSnapshot(server);
        generateSnapshot(server);
        TestUtils.saveAndFlush(snap);

        Map dateInfo = new HashMap();
        handler.deleteSnapshots(adminKey, server.getId().intValue(), dateInfo);
        List<ServerSnapshot> list = handler.listSnapshots(adminKey,
                server.getId().intValue(), dateInfo);
        assertTrue(list.size() == 0);
    }
}
