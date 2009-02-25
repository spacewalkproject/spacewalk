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
package com.redhat.rhn.frontend.action.schedule.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.schedule.ScheduledActionAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.Globals;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

/**
 * ScheduledActionActionTestCase
 * @version $Rev$
 */
public abstract class ScheduledActionActionTestCase extends MockObjectTestCase {
    
    public void testArchive() throws Exception {
        ScheduledActionAction action = getAction();
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RequestContext requestContext = new RequestContext(request);
        Server s = ServerFactoryTest.createTestServer(requestContext.getLoggedInUser());
        
        request.setupAddParameter("items_selected", s.getId().toString());
        request.setupAddParameter("items_on_page", (String)null);
        addPagination(request);
        
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();
        
        ActionForward forward = new ActionForward("default", "path", false);
        Mock mapping = mock(ActionMapping.class, "mapping");
        mapping.expects(once())
               .method("findForward")
               .with(eq("default"))
               .will(returnValue(forward));
        
        ActionForward same = action.archiveAction((ActionMapping)mapping.proxy(), form,
                request, response);
        assertEquals("path?lower=10", same.getPath());
        mapping.verify();
        ActionMessages msgs = (ActionMessages) request.getSession()
                                                      .getAttribute(Globals.MESSAGE_KEY);
        ActionMessage msg = (ActionMessage) msgs.get(ActionMessages.GLOBAL_MESSAGE).next();
        assertEquals("message.actionArchived", msg.getKey());
    }
    
    private void addPagination(RhnMockHttpServletRequest r) {
        r.setupAddParameter("First", "someValue");
        r.setupAddParameter("first_lower", "10");
        r.setupAddParameter("Prev", "0");
        r.setupAddParameter("prev_lower", "");
        r.setupAddParameter("Next", "20");
        r.setupAddParameter("next_lower", "");
        r.setupAddParameter("Last", "");
        r.setupAddParameter("last_lower", "20");
        r.setupAddParameter("lower", "10");
    }
    
    public void testSelectAll() throws Exception {
        ScheduledActionAction action = getAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();
        
        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        
        for (int i = 0; i < 4; i++) {
            Action a = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
            createServerAction(user, a);
        }
        
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ah.executeAction("selectall");
        
        //satellite could already have some actions
        RhnSet set = RhnSetFactory.lookupByLabel(user.getId(), getListName(),
            SetCleanup.NOOP);
        assertTrue(set.size() >= 4);
    }
    
    protected abstract ScheduledActionAction getAction();
    
    protected abstract void createServerAction(User user, Action action) throws Exception;
    
    protected abstract String getListName();
}
