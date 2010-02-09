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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.frontend.action.errata.CreateSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * CreateSetupActionTest
 * @version $Rev$
 */
public class CreateSetupActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        
        CreateSetupAction action = new CreateSetupAction();
        ActionHelper sah = new ActionHelper();
        
        sah.setUpAction(action);
        sah.executeAction();
        
        assertNotNull(sah.getRequest().getAttribute("advisoryTypes"));
        assertNotNull(sah.getForm().get("advisoryRelease"));
    }
}
