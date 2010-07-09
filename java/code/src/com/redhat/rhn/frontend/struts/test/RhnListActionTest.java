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
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * RhnListActionTest - test RhnListAction code.
 * @version $Rev: 55033 $
 */
public class RhnListActionTest extends RhnBaseTestCase {

    /**
     * Test to make sure we check for the right filter value string
     */
    public void testFilterValue() throws Exception {
        TestListAction tla = new TestListAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(tla);
        sah.setupClampListBounds("zzz");
        sah.executeAction();
        assertNotNull(tla.getPageControl().getFilterData());
        assertEquals("zzz", tla.getPageControl().getFilterData());

    }

    public class TestListAction extends RhnListAction {

        private PageControl pc;

        public final ActionForward execute(ActionMapping mapping,
                ActionForm formIn, HttpServletRequest request,
                HttpServletResponse response) {

            RequestContext requestContext = new RequestContext(request);

            User user = requestContext.getLoggedInUser();
            pc = new PageControl();
            pc.setFilterColumn("Some column");
            try {
                clampListBounds(pc, request, null);
                fail();
            }
            catch (BadParameterException e) {
                //good, this is what we wanted...
            }
            clampListBounds(pc, request, user);

            return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }

        public PageControl getPageControl() {
            return pc;
        }
    }
}
