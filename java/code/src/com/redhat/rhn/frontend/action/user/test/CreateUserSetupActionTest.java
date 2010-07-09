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
package com.redhat.rhn.frontend.action.user.test;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.user.CreateUserSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockDynaActionForm;

/**
 * CreateUserSetupActionTest
 * @version $Rev: 1635 $
 */
public class CreateUserSetupActionTest extends RhnBaseTestCase {

    public void testPerformExecute() throws Exception {
        CreateUserSetupAction action = new CreateUserSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        setupExpectations(sah.getForm(), sah.getUser());
        sah.executeAction();

        // verify the dyna form got the right values we expected.
        sah.getForm().verify();

        //If we're a sat, make sure displaypam was set
        assertEquals("true", sah.getRequest().getAttribute("displaypam"));
    }

    private void setupExpectations(RhnMockDynaActionForm form, User user) {
        form.addExpectedProperty("country", "US");
        form.addExpectedProperty("contact_email", new Boolean(true));
        form.addExpectedProperty("contact_partner", new Boolean(true));
        form.addExpectedProperty("prefix",
            LocalizationService.getInstance().getMessage("user prefix Mr."));
    }
}
