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
package com.redhat.rhn.frontend.action.rhnpackage.ssm.test;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ServerTestUtils;

import java.util.HashMap;
import java.util.Map;

import junit.framework.TestCase;

/**
 * @version $Revision$
 */
public class SsmActionTestUtils extends TestCase {

    private User user;

    private Package installedPackage1;
    private Package installedPackage2;

    public SsmActionTestUtils(User userIn) {
        this.user = userIn;
    }

    public void initSsmEnvironment() throws Exception {
        // Setup
        Org org = user.getOrg();

        //    Create Test Servers
        Server server1 = ServerTestUtils.createTestSystem(user);
        ServerFactory.save(server1);

        Server server2 = ServerTestUtils.createTestSystem(user);
        ServerFactory.save(server2);

        //    Create Test Packages
        installedPackage1 = PackageTest.createTestPackage(org);
        installedPackage2 = PackageTest.createTestPackage(org);

        //    Associate the servers and packages
        addServerPackageMapping(server1.getId(), installedPackage1);
        addServerPackageMapping(server1.getId(), installedPackage2);

        addServerPackageMapping(server2.getId(), installedPackage1);

        //    Add the servers to the SSM set
        RhnSet ssmSet = RhnSetManager.findByLabel(user.getId(),
            RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        if (ssmSet == null) {
            ssmSet = RhnSetManager.createSet(user.getId(),
                RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        }

        assert ssmSet != null;

        ssmSet.addElement(server1.getId());
        ssmSet.addElement(server2.getId());
        RhnSetManager.store(ssmSet);

        ssmSet = RhnSetManager.findByLabel(user.getId(),
            RhnSetDecl.SYSTEMS.getLabel(), SetCleanup.NOOP);
        assert ssmSet != null;
    }

    public Package getInstalledPackage1() {
        return installedPackage1;
    }

    public Package getInstalledPackage2() {
        return installedPackage2;
    }

    private void addServerPackageMapping(Long serverId, Package packageIn) {
        WriteMode wm = ModeFactory.getWriteMode("test_queries",
            "insert_into_rhnServerPackage_with_arch");

        Map<String, Long> params = new HashMap<String, Long>(4);
        params.put("server_id", serverId);
        params.put("pn_id", packageIn.getPackageName().getId());
        params.put("evr_id", packageIn.getPackageEvr().getId());
        params.put("arch_id", packageIn.getPackageArch().getId());

        int result = wm.executeUpdate(params);

        assert result == 1;
    }


}
