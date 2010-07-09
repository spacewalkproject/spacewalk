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

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionResult;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.Iterator;
import java.util.Set;

/**
 * PackageActionTest
 * @version $Rev$
 */
public class PackageActionTest extends RhnBaseTestCase {
    private static Logger log = Logger.getLogger(PackageActionTest.class);


    /**
     * Test fetching a PackageAction
     * @throws Exception
     */
    public void testLookupPackageAction() throws Exception {

        Action newA = ActionFactoryTest.createAction(UserTestUtils.createUser("testUser",
                UserTestUtils.createOrg("testOrg")), ActionFactory.TYPE_PACKAGES_VERIFY);
        assertNotNull(newA.getId());
        assertTrue(newA instanceof PackageAction);
        PackageAction p = (PackageAction) newA;
        assertNotNull(p.getDetails());
        assertEquals(p.getDetails().size(), 1);
        PackageActionDetails firstDetail =
            (PackageActionDetails) p.getDetails().toArray()[0];

        /**
         * Make sure PackageEvr was set & committed correctly
         */
        Set details = p.getDetails();
        Iterator ditr = details.iterator();
        while (ditr.hasNext()) {
            PackageActionDetails detail = (PackageActionDetails) ditr.next();
            assertNotNull(detail.getEvr().getId());
        }

        User user = UserTestUtils.findNewUser("TEST USER", "TEST ORG");
        Server testserver = ServerFactoryTest.createTestServer(user);

        PackageActionResult result = new PackageActionResult();
        result.setServer(testserver);
        result.setDetails(firstDetail);
        result.setResultCode(new Long(42));
        result.setCreated(new Date());
        result.setModified(new Date());

        firstDetail.addResult(result);

        ActionFactory.save(p);

        PackageAction p2 = (PackageAction) ActionFactory.lookupById(p.getId());

        assertNotNull(p2.getDetails());
        assertEquals(p2.getDetails().size(), 1);
        assertNotNull(p2.getDetails().toArray()[0]);
        firstDetail = (PackageActionDetails) p2.getDetails().toArray()[0];
        assertNotNull(firstDetail.getResults());
        assertEquals(firstDetail.getResults().size(), 1);

    }

    public void testCreatePackageUpdateAction() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");

        PackageAction testAction = (PackageAction)ActionFactoryTest.createAction(usr,
                ActionFactory.TYPE_PACKAGES_UPDATE);
        PackageActionDetailsTest.createTestDetailsWithNvre(usr, testAction);
        ActionFactory.save(testAction);
        flushAndEvict(testAction);

        /**
         * Get action back out of db and make sure it committed correctly
         */
        Action same = ActionFactory.lookupById(testAction.getId());
        assertTrue(same instanceof PackageAction);
        PackageAction sameAction = (PackageAction) same;

        assertNotNull(sameAction.getDetails());
        assertEquals(sameAction.getDetails().size(), 2);
        assertNotNull(sameAction.getDetails().toArray()[0]);
        assertNotNull(sameAction.getDetails().toArray()[1]);
        assertEquals(sameAction.getName(), testAction.getName());
        assertEquals(sameAction.getId(), testAction.getId());
    }

    public void testCreatePackageUpdateActionWithName() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");

        PackageAction testAction = (PackageAction)ActionFactoryTest.createAction(usr,
                ActionFactory.TYPE_PACKAGES_UPDATE);
        PackageActionDetailsTest.createTestDetailsWithName(usr, testAction);
        ActionFactory.save(testAction);
        flushAndEvict(testAction);
        /**
         * Get action back out of db and make sure it committed correctly
         */
        Action same = ActionFactory.lookupById(testAction.getId());
        assertTrue(same instanceof PackageAction);
        PackageAction sameAction = (PackageAction) same;

        assertNotNull(sameAction.getDetails());
        assertEquals(sameAction.getDetails().size(), 2);
        assertNotNull(sameAction.getDetails().toArray()[0]);
        assertNotNull(sameAction.getDetails().toArray()[1]);
        assertEquals(sameAction.getName(), testAction.getName());
        assertEquals(sameAction.getId(), testAction.getId());
    }

    public void testCreatePackageRemoveAction() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Server srvr = ServerFactoryTest.createTestServer(user);

        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(10));
        sa.setServer(srvr);
        log.debug("Creating PackageRemoveAction.");
        PackageAction pra = (PackageAction) ActionFactory.createAction(
                    ActionFactory.TYPE_PACKAGES_REMOVE);
        pra.setOrg(user.getOrg());
        pra.setName("Package Removal");
        pra.addServerAction(sa);
        sa.setParentAction(pra);
        log.debug("Committing PackageRemoveAction.");
        ActionFactory.save(pra);

        PackageAction result = (PackageAction)
            ActionFactory.lookupById(pra.getId());

        assertEquals(pra, result);
    }

}
