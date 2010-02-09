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
import com.redhat.rhn.frontend.action.user.ChangeEmailSetupAction;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * ChangeEmailSetupActionTest
 * @version $Rev$
 */
public class ChangeEmailSetupActionTest extends RhnBaseTestCase {

    public void testChangeEmailSetupAction() throws Exception {
        ChangeEmailSetupAction action = new ChangeEmailSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        LocalizationService ls = LocalizationService.getInstance();
        User user = sah.getUser();
        //Test verified
        sah.getRequest().setupAddParameter("uid", "");

        user.setEmail("myemail@somewhere.com");
        UserManager.storeUser(user);

        ActionForward result = sah.executeAction();
        assertEquals("default", result.getName());

        //If we are a satellite, then we should expect yourchangeemail.instructions
        //and message.Update
        assertEquals(ls.getMessage("yourchangeemail.instructions"),
                     sah.getRequest().getAttribute("pageinstructions"));
        assertEquals(ls.getMessage("message.Update"),
                     sah.getRequest().getAttribute("button_label"));
    }
}
