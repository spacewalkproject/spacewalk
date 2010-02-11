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
package com.redhat.rhn.frontend.action.monitoring.notification.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.action.monitoring.notification.MethodsSetupAction;
import com.redhat.rhn.frontend.dto.monitoring.MethodDto;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

/**
 * MethodsSetupActionTest
 * @version $Rev: 1 $
 */
public class MethodsSetupActionTest extends RhnBaseTestCase {
    
    public void testExecute() throws Exception {
        
        MethodsSetupAction action = new MethodsSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.executeAction();
        
        // Remove if not a List SetupAction
        RhnMockHttpServletRequest request = sah.getRequest();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertTrue(dr.iterator().next() instanceof MethodDto);
        
    }
}

