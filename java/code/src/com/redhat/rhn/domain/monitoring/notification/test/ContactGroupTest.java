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

import com.redhat.rhn.domain.monitoring.notification.ContactGroup;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * ContactGroupTest
 * @version $Rev: 52080 $
 */
public class ContactGroupTest extends BaseTestCaseWithUser {

    private ContactGroup cg;
    
    @Override
    public void setUp() throws Exception {
        // TODO Auto-generated method stub
        super.setUp();
        cg = NotificationFactory.createContactGroup(user);
        cg.setContactGroupName("testName" + TestUtils.randomString());
        NotificationFactory.saveContactGroup(user, cg);
        cg = (ContactGroup) reload(cg);

    }

    public void testLookup() throws Exception {
        Org testOrg = user.getOrg();
        assertNotNull(testOrg.getContactGroups());
        assertTrue(testOrg.getContactGroups().size() > 0);
        cg = (ContactGroup) testOrg.getContactGroups().toArray()[0];
        assertNotNull(cg.getContactGroupName());
    }
    
    
    public void testCreate() throws Exception {
        assertNotNull(cg.getId());
        assertNotNull(cg.getAckWait());
        assertNotNull(cg.getContactGroupName());
        assertNotNull(cg.getCustomerId());
        assertNotNull(cg.getNotificationFormatId());
        assertNotNull(cg.getRotateFirst());
        assertNotNull(cg.getStrategyId());
        assertNotNull(NotificationFactory.
                lookupContactGroupByName(cg.getContactGroupName()));
    }


}

