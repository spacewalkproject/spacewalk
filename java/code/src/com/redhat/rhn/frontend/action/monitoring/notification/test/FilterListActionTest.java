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

import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.test.FilterTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.action.monitoring.notification.FilterListAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

import java.util.Date;

/**
 * FilterListActionTest
 * @version $Rev: 55327 $
 */
public class FilterListActionTest extends RhnBaseTestCase {
    private Action action = null;
    private ActionHelper sah;
    private Date oldDate;
    private Filter f;

    public void setUp() throws Exception {
        super.setUp();
        action = new FilterListAction();
        sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();
        sah.getRequest().setRequestURL("foo");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("items_on_page", (String)null);
        f = FilterTest.createTestFilter(sah.getUser(), "listTest" +
                TestUtils.randomString());
        oldDate = f.getExpiration();
        sah.getRequest().setupAddParameter("items_selected",
                new String[] {f.getId().toString()});

    }

    public void testExpire() throws Exception {

        ActionForward testforward = sah.executeAction("operateOnSelectedSet");
        assertEquals("path?lower=10", testforward.getPath());
        assertNotNull(sah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertFalse(f.getExpiration().equals(oldDate));
        assertTrue(f.getExpiration().before(new Date()));
        assertTrue(f.getStartDate().before(new Date()));
    }

    public void testSelectAll() throws Exception {
        sah.executeAction("selectall");
        RhnSet set = RhnSetDecl.FILTER_EXPIRE.get(sah.getUser());
        assertTrue(set.getElements().size() > 0);
    }

}
