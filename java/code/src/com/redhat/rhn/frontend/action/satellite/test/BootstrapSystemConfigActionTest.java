/**
 * Copyright (c) 2013 SUSE
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
package com.redhat.rhn.frontend.action.satellite.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.action.satellite.BootstrapSystemConfigAction;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import servletunit.HttpServletRequestSimulator;

import javax.servlet.http.HttpServletRequest;

/**
 * Tests BootstrapSystemConfigAction.
 */
public class BootstrapSystemConfigActionTest extends RhnMockStrutsTestCase {

    /**
     * Sets up a request.
     * @throws Exception if things go wrong
     * @see com.redhat.rhn.testing.RhnMockStrutsTestCase#setUp()
     */
    public void setUp() throws Exception {
        super.setUp();
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/config/BootstrapSystems");
    }

    /**
     * Tests disabling and enabling bootstrap discovery.
     * @throws Exception if things go wrong
     */
    public void testDisableEnableBootstrapDiscovery() throws Exception {
        actionPerform();

        assertEquals(200, getMockResponse().getStatusCode());

        addRequestParameter(BootstrapSystemConfigAction.DISABLE, "submitted");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        actionPerform();

        assertTrue(getMockResponse().getStatusCode() == 200);
        HttpServletRequest request = getRequest();
        String userOrgName = user.getOrg().getName();
        assertEquals(userOrgName,
            request.getAttribute(BootstrapSystemConfigAction.CURRENT_ORG));
        assertNull(request.getAttribute(BootstrapSystemConfigAction.ENABLED_ORG));
        assertEquals(true, request.getAttribute(BootstrapSystemConfigAction.DISABLED));
        assertEquals(false,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_CURRENT_ORG));
        assertEquals(false,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_OTHER_ORG));

        clearRequestParameters();
        addRequestParameter(BootstrapSystemConfigAction.ENABLE, "submitted");
        addRequestParameter(BootstrapSystemConfigAction.SKIP_FILE_CHECKS, "true");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        actionPerform();

        assertEquals(200, getMockResponse().getStatusCode());
        request = getRequest();
        assertEquals(userOrgName,
            request.getAttribute(BootstrapSystemConfigAction.CURRENT_ORG));
        assertEquals(userOrgName,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_ORG));
        assertEquals(false, request.getAttribute(BootstrapSystemConfigAction.DISABLED));
        assertEquals(true,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_CURRENT_ORG));
        assertEquals(false,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_OTHER_ORG));
    }

    /**
     * Test enabling bootstrap from a different Org.
     * @throws Exception if things go wrong
     */
    public void testBootstrapDifferentOrg() throws Exception {
        addRequestParameter(BootstrapSystemConfigAction.DISABLE, "submitted");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        actionPerform();

        clearRequestParameters();
        addRequestParameter(BootstrapSystemConfigAction.ENABLE, "submitted");
        addRequestParameter(BootstrapSystemConfigAction.SKIP_FILE_CHECKS, "true");
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        request.setMethod(HttpServletRequestSimulator.POST);
        actionPerform();

        String userOrgName = user.getOrg().getName();
        clearRequestParameters();

        // ensure we use a different Org now
        setUp();
        request.setMethod(HttpServletRequestSimulator.GET);
        actionPerform();

        assertEquals(200, getMockResponse().getStatusCode());
        HttpServletRequest request = getRequest();
        assertEquals(user.getOrg().getName(),
            request.getAttribute(BootstrapSystemConfigAction.CURRENT_ORG));
        assertEquals(userOrgName,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_ORG));
        assertEquals(false, request.getAttribute(BootstrapSystemConfigAction.DISABLED));
        assertEquals(false,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_CURRENT_ORG));
        assertEquals(true,
            request.getAttribute(BootstrapSystemConfigAction.ENABLED_FOR_OTHER_ORG));
    }
}
