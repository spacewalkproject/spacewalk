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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.action.schedule.CompletedSystemsSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * CompletedSystemsSetupActionTest
 * @version $Rev$
 */
public class CompletedSystemsSetupActionTest extends RhnBaseTestCase {
    private CompletedSystemsSetupAction action;
    private ActionHelper sah;

    public void setUp() throws Exception {
        action = new CompletedSystemsSetupAction();
        sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
    }

    public void testPerformExecute() throws Exception {
        Action a1 = ActionFactoryTest.createAction(sah.getUser(),
                ActionFactory.TYPE_REBOOT);
        Long actionId = a1.getId();


        sah.getRequest().setupAddParameter("aid", actionId.toString());
        sah.executeAction();

        String name = (String) sah.getRequest().getAttribute("actionname");
        Action a2 = (Action)sah.getRequest().getAttribute("action");

        assertNotNull(sah.getRequest().getAttribute("pageList"));
        assertNotNull(sah.getRequest().getAttribute("user"));
        assertNotNull(name);
        assertEquals("RHN-JAVA Test Action", name);
        assertNotNull(a2);
        assertEquals(actionId, a2.getId());
    }

    public void testBadParameterException() throws Exception {
        sah.getRequest().setupAddParameter("aid", (String)null);
        try {
            sah.executeAction();
            fail("Should've thrown a BadParameterException");
        }
        catch (BadParameterException bae) {
            assertTrue(true);
        }
    }

    public void testLookupException() throws Exception {
        sah.getRequest().setupAddParameter("aid", "-99");

        try {
            sah.executeAction();
            fail("Should've thrown a LookupException");
        }
        catch (LookupException le) {
            assertTrue(true);
        }
    }
}
