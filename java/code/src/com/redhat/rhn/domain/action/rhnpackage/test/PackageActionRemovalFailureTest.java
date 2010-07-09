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
package com.redhat.rhn.domain.action.rhnpackage.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionRemovalFailure;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.rhnpackage.PackageCapability;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.rhnpackage.test.PackageCapabilityTest;
import com.redhat.rhn.domain.rhnpackage.test.PackageEvrFactoryTest;
import com.redhat.rhn.domain.rhnpackage.test.PackageNameTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

/**
 * PackageActionRemovalFailureTest
 * @version $Rev$
 */
public class PackageActionRemovalFailureTest extends RhnBaseTestCase {

    public void testPackageActionRemovalFailure() throws Exception {
        User usr = UserTestUtils.createUser("testUser",
                                            UserTestUtils.createOrg("testOrg"));
        PackageAction pkgaction = (PackageAction) ActionFactoryTest.createAction(
                                         usr, ActionFactory.TYPE_PACKAGES_VERIFY);
        Server server = ServerFactoryTest.createTestServer(usr);
        PackageName name = PackageNameTest.createTestPackageName();
        PackageEvr evr = PackageEvrFactoryTest.createTestPackageEvr();
        PackageCapability cap = PackageCapabilityTest.createTestCapability();

        PackageActionRemovalFailure failure = new PackageActionRemovalFailure();
        failure.setServer(server);
        failure.setAction(pkgaction);
        failure.setPackageName(name);
        failure.setEvr(evr);
        failure.setCapability(cap);
        failure.setFlags(new Long(1));
        failure.setSense(new Long(1));

        TestUtils.saveAndFlush(failure);

        PackageActionRemovalFailure failure2 = lookupByKey(server, pkgaction, name);
        assertNotNull(failure2);
        assertEquals(failure, failure2);
    }

    /**
     * Helper method to lookup a PackageActionRemovalFailure
     * by Server, PackageAction, and PackageName.
     */
    private PackageActionRemovalFailure lookupByKey(Server s,
                                                   Action a,
                                                   PackageName n) throws Exception {
        Session session = HibernateFactory.getSession();
        String queryname = "PackageActionRemovalFailure.findByKey";
        return (PackageActionRemovalFailure) session.getNamedQuery(queryname)
                .setEntity("server", s).setEntity("action", a).setEntity(
                        "packageName", n).uniqueResult();
    }
}
