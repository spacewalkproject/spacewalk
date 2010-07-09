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
package com.redhat.rhn.domain.monitoring.notification.test;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.monitoring.notification.Method;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.monitoring.ModifyMethodCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * MethodTest
 * @version $Rev$
 */
public class MethodTest extends BaseTestCaseWithUser {

    // See BZ https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=191430
    public void testDefaultScheduleId() {
        Method m = new Method();
        assertEquals(new Long(1), m.getScheduleId());
    }

    public void testFormat() {
        assertNotNull(NotificationFactory.FORMAT_DEFAULT);
    }

    public void testRequiredFields() {
        ModifyMethodCommand mmc = new ModifyMethodCommand(user);
        mmc.setType(NotificationFactory.TYPE_EMAIL);
        ValidatorError ve = mmc.storeMethod(user);
        assertNotNull(ve);
    }

    public void testCreateMethod() throws Exception {
        ModifyMethodCommand mmc = createTestMethodCommand(user);
        // Now assert things got stored properly
        Method m = mmc.getMethod();
        m = (Method) reload(m);
        assertNotNull(m.getId());
        assertNotNull(m.getMethodName());
        assertNotNull(m.getType());
        assertNotNull(m.getFormat());
        assertNotNull(m.getContactGroup());
        assertNotNull(m.getContactGroup().getId());
        assertEquals(new Long(1), m.getScheduleId());
        // See BZ: 208277.  Need to test the assocation between the Method
        // and the ContactGroup
        assertEquals(m.getContactGroup().getContactGroupName(), m.getMethodName());
    }

    public void testEmptyEmail() throws Exception {
        ModifyMethodCommand mmc = createTestMethodCommand(user);
        mmc.setType(NotificationFactory.TYPE_PAGER);
        mmc.setEmail(null);
        ValidatorError e = mmc.storeMethod(user);
        assertNotNull(e);
    }


    public void testLookupById() throws Exception {
        ModifyMethodCommand mmc = createTestMethodCommand(user);
        Method m = mmc.getMethod();
        Long id = m.getId();
        flushAndEvict(m);
        m = NotificationFactory.lookupMethod(id, user);
        assertNotNull(m);
        assertNotNull(m.getId());
        assertEquals(m.getId(), id);

    }

    public void testLookupUsersMethods() throws Exception {
        assertEquals(0, user.getNotificationMethods().size());
        ModifyMethodCommand mmc = createTestMethodCommand(user);
        flushAndEvict(mmc.getMethod());
        user = (User) reload(user);
        assertEquals(1, user.getNotificationMethods().size());
    }

    public void testLookupByNameAndUser() throws Exception {
        ModifyMethodCommand mmc = createTestMethodCommand(user);
        Method m = mmc.getMethod();
        Long id = m.getId();
        flushAndEvict(m);
        m = NotificationFactory.lookupMethodByNameAndUser(m.getMethodName(), user.getId());
        assertNotNull(m);
        assertNotNull(m.getId());
        assertEquals(m.getId(), id);
        assertNotNull(NotificationFactory.lookupContactGroupByName(m.getMethodName()));

    }

    public static ModifyMethodCommand createTestMethodCommand(User userIn) {
        ModifyMethodCommand mmc = new ModifyMethodCommand(userIn);
        assertNotNull(mmc.getMethod().getUser());
        mmc.setMethodName("testMethodName");
        mmc.setType(NotificationFactory.TYPE_EMAIL);
        mmc.setEmail("someEmailTest@redhat.com");
        mmc.storeMethod(userIn);
        return mmc;

    }
}
