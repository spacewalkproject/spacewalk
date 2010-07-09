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
package com.redhat.rhn.frontend.action.multiorg.test;

import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

/**
 * OrgSubscriptionsActionTest
 * @version $Rev: 1 $
 */
public class OrgSystemSubscriptionsActionTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/multiorg/OrgSystemSubscriptions");
        addRequestParameter(RequestContext.ORG_ID, user.getOrg().getId().toString());
        actionPerform();
        assertTrue(getActualForward().contains("oid=" + user.getOrg().getId()));
        assertNotNull(request.getAttribute("org"));
        assertNotNull(request.getAttribute(EntitlementManager.ENTERPRISE_ENTITLED));
        assertNotNull(request.getAttribute(EntitlementManager.MONITORING_ENTITLED));
        assertNotNull(request.getAttribute(EntitlementManager.PROVISIONING_ENTITLED));
        assertNotNull(request.getAttribute(EntitlementManager.VIRTUALIZATION_ENTITLED));
        assertNotNull(request.getAttribute(EntitlementManager.
                VIRTUALIZATION_PLATFORM_ENTITLED));
        DynaActionForm af = (DynaActionForm) getActionForm();
        assertNotNull(af.get(EntitlementManager.ENTERPRISE_ENTITLED));
        assertNotNull(af.get(EntitlementManager.MONITORING_ENTITLED));
        assertNotNull(af.get(EntitlementManager.PROVISIONING_ENTITLED));
        assertNotNull(af.get(EntitlementManager.VIRTUALIZATION_ENTITLED));
    }


    public void testExecuteSubmit() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        setRequestPathInfo("/admin/multiorg/OrgSystemSubscriptions");
        addRequestParameter(RequestContext.ORG_ID, user.getOrg().getId().toString());
        addRequestParameter(EntitlementManager.ENTERPRISE_ENTITLED,
                new Long(1).toString());
        addRequestParameter(EntitlementManager.MONITORING_ENTITLED,
                new Long(0).toString());
        addRequestParameter(EntitlementManager.PROVISIONING_ENTITLED,
                new Long(0).toString());
        addRequestParameter(EntitlementManager.VIRTUALIZATION_ENTITLED,
                new Long(0).toString());
        addRequestParameter(EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED,
                new Long(0).toString());
        addSubmitted();
        actionPerform();
        assertTrue(getActualForward().contains("oid=" + user.getOrg().getId()));
        verifyActionMessage("org.entitlements.syssoft.success");
        assertEquals(1, EntitlementManager.getAvailableEntitlements(
                EntitlementManager.MANAGEMENT, user.getOrg()).longValue());
    }

}

