/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnPostMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * OrgCreateActionTest - test org create
 * @version $Rev: 119601 $
 */
public class OrgCreateActionTest extends RhnPostMockStrutsTestCase {

    public void testExecuteSubmit() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addPermanentRole(RoleFactory.SAT_ADMIN);
        TestUtils.saveAndFlush(user);
        addSubmitted();
        addRequestParameter("orgName", "neworg" + TestUtils.randomString());
        addRequestParameter("login", "newlogin" + TestUtils.randomString());
        addRequestParameter("email", "test@redhat.com");
        addRequestParameter("desiredpassword", "password");
        addRequestParameter("desiredpasswordConfirm", "password");
        addRequestParameter("firstNames", "firstname");
        addRequestParameter("lastName", "lastname");
        addRequestParameter("prefix", "Mr.");
        setRequestPathInfo("/admin/multiorg/OrgCreate");
        actionPerform();
        verifyActionMessage("org.create.success");
    }

    public void testEmptyFields() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addPermanentRole(RoleFactory.SAT_ADMIN);
        TestUtils.saveAndFlush(user);
        addSubmitted();
        setRequestPathInfo("/admin/multiorg/OrgCreate");
        actionPerform();
        String[] errors =  {"errors.required", "errors.required",
                "errors.required", "errors.required", "errors.required", "errors.required"};
        verifyActionErrors(errors);
    }

    public void testCreateDupeUser() throws Exception {
        user.getOrg().addRole(RoleFactory.SAT_ADMIN);
        user.addPermanentRole(RoleFactory.SAT_ADMIN);
        TestUtils.saveAndFlush(user);
        addSubmitted();
        addRequestParameter("orgName", "neworg" + TestUtils.randomString());
        addRequestParameter("login", user.getLogin());
        addRequestParameter("email", "test@redhat.com");
        addRequestParameter("desiredpassword", "password");
        addRequestParameter("desiredpasswordConfirm", "password");
        addRequestParameter("firstNames", "firstname");
        addRequestParameter("lastName", "lastname");
        addRequestParameter("prefix", "Mr.");
        setRequestPathInfo("/admin/multiorg/OrgCreate");
        actionPerform();
        verifyActionErrors(new String[]{"error.login_already_taken"});
    }

    // This had better fail if there are any organizations already!
    public void testCreateFirstSatUser() {
        setRequestPathInfo("/newlogin/CreateFirstUser");
        RhnMockDynaActionForm f = new RhnMockDynaActionForm("orgCreateForm");
        f.set("orgName", "testOrg" + TestUtils.randomString());
        f.set("login", "testUser" + TestUtils.randomString());
        f.set("email", "foobar@redhat.com");
        f.set("firstNames", "Test fname");
        f.set("lastName", "Test lname");
        f.set("desiredpassword", "password");
        f.set("desiredpasswordConfirm", "password");
        f.set("prefix", "Mr.");
        setActionForm(f);
        actionPerform();
        assertTrue(getActualForward().startsWith("/errors/Permission.do"));
    }

}

