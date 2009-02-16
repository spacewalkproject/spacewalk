/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.UnpublishedErrataSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

/**
 * UnpublishedErrataSetupActionTest
 * @version $Rev$
 */
public class UnpublishedErrataSetupActionTest extends RhnBaseTestCase {
    private UnpublishedErrataSetupAction action;
    
    public void setUp() {
        action = new UnpublishedErrataSetupAction();
    }
    
    public void testExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.executeAction();
        
        
        RhnMockHttpServletRequest request = sah.getRequest();
        User user = new RequestContext(request).getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");
        
        assertNotNull(request.getAttribute("pageList"));
        assertEquals(user, request.getAttribute("user"));
        assertNotNull(set);
        assertEquals("errata_to_delete", set.getLabel());
    }
}
