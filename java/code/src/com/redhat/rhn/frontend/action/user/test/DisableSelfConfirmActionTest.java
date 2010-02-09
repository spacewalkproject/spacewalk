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

import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.action.user.DisableSelfConfirmAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * DisableSelfConfirmActionTest
 * @version $Rev$
 */
public class DisableSelfConfirmActionTest extends RhnBaseTestCase {
    
    public void testExecute() throws Exception {
        DisableSelfConfirmAction action = new DisableSelfConfirmAction();
        ActionHelper ah = new ActionHelper();
        ActionForward af;
        
        ah.setUpAction(action, "default");
        af = ah.executeAction();
        assertEquals("default", af.getName());
        
        //successfully disabled
        ah.setUpAction(action, "logout");
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);
        af = ah.executeAction();
        assertEquals("logout", af.getName());
        
        //already disabled, changing test to reflect
        // new functionality.  We no longer throw a
        // StateChangeException, we simply go logout.
        // This really isn't going to be an issue because
        // how can you really disable yourself if you
        // are already disabled.  If this happens we probably
        // have bigger issues.
        ah.setUpAction(action, "logout");
        assertFalse(ah.getUser().isDisabled());
        ah.getForm().set(RhnAction.SUBMITTED, Boolean.TRUE);

        UserFactory.getInstance().disable(ah.getUser(), ah.getUser());
        af = ah.executeAction();
        assertEquals("logout", af.getName());
    }

}
