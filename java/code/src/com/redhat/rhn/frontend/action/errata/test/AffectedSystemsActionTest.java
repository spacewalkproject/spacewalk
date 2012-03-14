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
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.action.common.test.RhnSetActionTest;
import com.redhat.rhn.frontend.action.errata.AffectedSystemsAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

/**
 * AffectedSystemsActionTest
 * @version $Rev$
 */
public class AffectedSystemsActionTest extends MockObjectTestCase {

    public void testApply() throws Exception {
        AffectedSystemsAction action = new AffectedSystemsAction();
        ActionForward forward = new ActionForward("test", "path", true);
        RhnMockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
        RhnMockDynaActionForm form = new RhnMockDynaActionForm();

        //No systems selected
        Mock mapping = mock(ActionMapping.class, "mapping");
        mapping.expects(once())
               .method("findForward")
               .with(eq("default"))
               .will(returnValue(forward));

        request.setupAddParameter("items_selected", (String[])null);
        request.setupAddParameter("items_on_page", (String[])null);
        addPagination(request);
        request.setupAddParameter("filter_string", "");
        request.setupAddParameter("eid", "12345");

        ActionForward sameForward = action.applyErrata((ActionMapping)mapping.proxy(),
                form, request, response);
        assertEquals("path?lower=10&eid=12345", sameForward.getPath());
        mapping.verify();

        //With systems selected
        mapping.expects(once())
               .method("findForward")
               .with(eq("confirm"))
               .will(returnValue(forward));

        request.setupAddParameter("items_selected", "123456");
        request.setupAddParameter("items_on_page", (String[])null);
        request.setupAddParameter("eid", "54321");

        sameForward = action.applyErrata((ActionMapping)mapping.proxy(),
                form, request, response);
        assertEquals("path?eid=54321", sameForward.getPath());
        mapping.verify();
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
        AffectedSystemsAction action = new AffectedSystemsAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupProcessPagination();

        User user = ah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);

        Errata errata = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());

        for (int i = 0; i < 4; i++) {
            Server server = ServerFactoryTest.createTestServer(user, true);
            ErrataFactoryTest.updateNeedsErrataCache(
                    ((Package)errata.getPackages().iterator().next()).getId(),
                    server.getId(), errata.getId());
        }

        ah.getRequest().setupAddParameter("eid", errata.getId().toString());
        ah.getRequest().setupAddParameter("eid", errata.getId().toString()); //stupid mock
        ah.getRequest().setupAddParameter("items_on_page", (String[])null);
        ah.getRequest().setupAddParameter("items_selected", (String[])null);
        ah.executeAction("selectall");

        RhnSetActionTest.verifyRhnSetData(ah.getUser().getId(),
                SetLabels.AFFECTED_SYSTEMS_LIST, 4);
    }

}
