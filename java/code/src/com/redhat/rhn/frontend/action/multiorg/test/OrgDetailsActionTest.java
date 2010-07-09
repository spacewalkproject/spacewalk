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
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import org.apache.struts.action.DynaActionForm;

/**
 * OrgDetailsActionTest
 * @version $Rev: 1 $
 */
public class OrgDetailsActionTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addRole(RoleFactory.SAT_ADMIN);
        addRequestParameter("oid", user.getOrg().getId().toString());
        setRequestPathInfo("/admin/multiorg/OrgDetails");
        actionPerform();
        DynaActionForm form = (DynaActionForm) getActionForm();
        assertNotNull(form.get("orgName"));
        assertNotNull(form.get("id"));
        assertNotNull(form.get("users"));
        assertNotNull(form.get("systems"));
        assertNotNull(form.get("actkeys"));
        assertNotNull(form.get("ksprofiles"));
        assertNotNull(form.get("groups"));
        assertNotNull(form.get("cfgchannels"));

    }
}

