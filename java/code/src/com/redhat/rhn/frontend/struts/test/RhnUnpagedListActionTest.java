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
package com.redhat.rhn.frontend.struts.test;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BadParameterException;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnUnpagedListAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RhnUnpagedListActionTest
 * @version $Rev$
 */
public class RhnUnpagedListActionTest extends RhnBaseTestCase {
    /**
     * Test to make sure we check for the right filter value string
     */
    public void testFilterValue() throws Exception {
        TestListAction tla = new TestListAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(tla);
        sah.setupClampListBounds("zzz");
        sah.executeAction();
        assertNotNull(tla.getListControl().getFilterData());
        assertEquals("zzz", tla.getListControl().getFilterData());

    }

    public class TestListAction extends RhnUnpagedListAction {

        private ListControl lc;

        public final ActionForward execute(ActionMapping mapping,
                ActionForm formIn, HttpServletRequest request,
                HttpServletResponse response) {
            
            RequestContext requestContext = new RequestContext(request);
            StrutsDelegate strutsDelegate = StrutsDelegate.getInstance();

            User user = requestContext.getLoggedInUser();
            lc = new ListControl();
            lc.setFilterColumn("Some column");
            try {
                filterList(lc, request, null);
                fail();
            }
            catch (BadParameterException e) {
                //good, this is what we wanted...
            }
            filterList(lc, request, user);
            
            return strutsDelegate.forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }

        public ListControl getListControl() {
            return lc;
        }
    }
}
