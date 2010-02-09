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
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.monitoring.notification.test.FilterTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.monitoring.notification.ActiveFilterListSetupAction;
import com.redhat.rhn.frontend.action.monitoring.notification.ExpiredFilterListSetupAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.Action;

import java.sql.Timestamp;

/**
 * FilterListSetupActionTest
 * @version $Rev: 55327 $
 */
public class FilterListSetupActionTest extends RhnBaseTestCase {
    
    public void testActiveExecute() throws Exception {
        executeAction(new ActiveFilterListSetupAction(), false);
    }

    public void testExpiredExecute() throws Exception {
        executeAction(new ExpiredFilterListSetupAction(), true);
    }
    
    public void executeAction(Action action, boolean expire) throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        // Use the User created by the Helper
        User user = sah.getUser();
        Filter f = FilterTest.createTestFilter(user, "listTest" + 
                TestUtils.randomString());
        if (expire) {
            // Set the start/expire to be now minus some substantial time in the past.
            // Test was previously set to just 6 seconds in the past but would 
            // fail in some cases is the system running the test was out of sync with the
            // database server. (items not showing up as expired)
            f.setStartDate(new Timestamp(System.currentTimeMillis() - 700000000));
            f.setExpiration(new Timestamp(System.currentTimeMillis() - 600000000));
            NotificationFactory.saveFilter(f, user);
            reload(f);
        } 
        else {
            // Set the start/expire to be now plus a while in the future
            f.setStartDate(new Timestamp(System.currentTimeMillis()));
            f.setExpiration(new Timestamp(System.currentTimeMillis() + 200000000));
            NotificationFactory.saveFilter(f, user);
            reload(f);
        }
        sah.setupClampListBounds();
        sah.getRequest().setupAddParameter("active", "false");
        sah.getRequest().setupAddParameter("submitted", "false");
        sah.getRequest().setupAddParameter("newset", (String)null);
        sah.getRequest().setupAddParameter("returnvisit", (String) null);
        sah.executeAction();
        
        RhnMockHttpServletRequest request = sah.getRequest();
        
        RequestContext requestContext = new RequestContext(request);
        
        user = requestContext.getLoggedInUser();
        RhnSet set = (RhnSet) request.getAttribute("set");
        
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertEquals(RhnSetDecl.FILTER_EXPIRE.getLabel(), set.getLabel());
    }
}
