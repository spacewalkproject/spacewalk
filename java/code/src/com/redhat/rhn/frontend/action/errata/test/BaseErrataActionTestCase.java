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

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.ActionForward;

/**
 * BaseErrataActionTestCase
 * @version $Rev$
 */
public abstract class BaseErrataActionTestCase extends RhnBaseTestCase {

    /**
     * Make sure when the delete button is hit we go to the proper
     * place.  No DB action occurs.
     * @throws Exception if test fails
     */
    public void testDeleteErrataConfirmPage() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(getAction(), "delete");
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("items_selected",
            new String[] {"10", "20", "30"});
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        sah.setupClampListBounds();
        ActionForward testforward = sah.executeAction("deleteErrata");

        assertEquals("path?lower=10", testforward.getPath());
    }

    public void testSelectAll() throws Exception {
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(getAction());
        ah.setupProcessPagination();

        User user = ah.getUser();
        for (int i = 0; i < 4; i++) {
            createErrata(user);
        }

        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ah.executeAction("selectall");

        //satellite could already have a few unpublished errata
        RhnSet set = RhnSetDecl.ERRATA_TO_DELETE.get(user);
        assertTrue(set.size() >= 4);
    }

    protected abstract RhnSetAction getAction();

    protected abstract Errata createErrata(User user) throws Exception;
}
