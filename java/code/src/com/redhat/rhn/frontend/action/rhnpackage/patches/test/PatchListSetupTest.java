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
package com.redhat.rhn.frontend.action.rhnpackage.patches.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.rhnpackage.patches.PatchListAction;
import com.redhat.rhn.frontend.action.rhnpackage.patches.PatchListSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

/**
 * PatchListSetupTest
 * @version
 */
public class PatchListSetupTest extends RhnBaseTestCase {
    private Action action = null;

    public void setUp() {
        action = new PatchListSetupAction();
    }

    public void testFoo() {
        System.out.println("We need to figure out how to fix these patch tests");
    }

    public void atestExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("sid", "1000010004");
        Server server = ServerFactory.lookupById(new Long(1000010004));
        sah.getRequest().setupAddParameter("uid", server.getCreator().getId().toString());
        sah.executeAction();


        RhnMockHttpServletRequest request = sah.getRequest();

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");

        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertEquals("removable_patch_list", set.getLabel());

        //now test the PatchListAction

        sah.setUpAction(new PatchListAction());
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("uid", server.getCreator().getId().toString());
        String [] selected = { "407|326", "438|351" };
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        sah.getRequest().setupAddParameter("items_selected", selected);
        sah.executeAction();

        assertFalse(RhnSetDecl.PATCH_REMOVE.get(user).isEmpty());

    }
}
