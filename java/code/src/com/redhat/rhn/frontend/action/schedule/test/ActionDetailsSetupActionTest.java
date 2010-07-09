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

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.schedule.ActionDetailsSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * UserPrefSetupActionTest
 * @version $Rev: 1635 $
 */
public class ActionDetailsSetupActionTest extends RhnBaseTestCase {

    public void testPerformExecute() throws Exception {
        ActionDetailsSetupAction action = new ActionDetailsSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        User user = sah.getUser();
        Action a1 = ActionFactoryTest.createAction(user, ActionFactory.TYPE_REBOOT);
        a1.setSchedulerUser(user);
        sah.getRequest().setupAddParameter("aid", a1.getId().toString());


        sah.executeAction();
        // verify the dyna form got the right values we expected.
        assertNotNull(sah.getRequest().getAttribute("actionname"));
        assertNotNull(sah.getRequest().getAttribute("actiontype"));
        assertNotNull(sah.getRequest().getAttribute("scheduler"));
        assertNotNull(sah.getRequest().getAttribute("earliestaction"));
        assertNotNull(sah.getRequest().getAttribute("actionnotes"));

    }

}
