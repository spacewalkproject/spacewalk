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

import com.redhat.rhn.domain.monitoring.notification.Criteria;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.MatchType;
import com.redhat.rhn.domain.monitoring.notification.NotificationFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.monitoring.ModifyFilterCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.hibernate.HibernateException;

import java.util.Calendar;
import java.util.Iterator;

/**
 * FilterTest
 * @version $Rev: 52080 $
 */
public class FilterTest extends BaseTestCaseWithUser {

    public void testLookup() throws Exception {

        String desc = "someDesc" + TestUtils.randomString();
        Filter testFilter = createTestFilter(user, desc);
        // Specifically want to test the
        // NotificationFactory's lookup method.
        Long id = testFilter.getId();
        flushAndEvict(testFilter);
        testFilter = NotificationFactory.lookupFilter(id, user);
        assertNotNull(testFilter.getOrg());
        assertNotNull(testFilter.getUser());
        assertNotNull(testFilter.getType());
        assertNotNull(testFilter.getLastUpdateDate());
        assertEquals(desc, testFilter.getDescription());
    }

    public void testRecurring() throws Exception {
        String desc = "recur333" + TestUtils.randomString();
        Filter testFilter = createTestFilter(user, desc);
        testFilter.setRecurring(Boolean.TRUE);
        testFilter.setRecurringDuration(new Long(2));
        testFilter.setRecurringDurationType(new Long(Calendar.YEAR));
        testFilter.setRecurringFrequency(new Long(Calendar.WEEK_OF_YEAR));
        NotificationFactory.saveFilter(testFilter, user);
        testFilter = (Filter) reload(testFilter);
        assertEquals(new Long(Calendar.WEEK_OF_YEAR),
                testFilter.getRecurringFrequency());
        assertEquals(new Long(Calendar.YEAR),
                testFilter.getRecurringDurationType());
    }

    public void testCriteria() throws HibernateException {
        String desc = "someDesc" + TestUtils.randomString();
        Filter testFilter = createTestFilter(user, desc);

        Criteria probe = testFilter.addCriteria(MatchType.PROBE, "42");
        Criteria scout = testFilter.addCriteria(MatchType.SCOUT, "43");

        NotificationFactory.saveFilter(testFilter, user);
        testFilter = (Filter) reload(testFilter);
        assertEquals(desc, testFilter.getDescription());
        assertEquals(2, testFilter.getCriteria().size());
        checkCriteria(testFilter, probe);
        checkCriteria(testFilter, scout);

        // Now remove the criteria
        testFilter.getCriteria().clear();
        NotificationFactory.saveFilter(testFilter, user);
        testFilter = (Filter) reload(testFilter);
        assertEquals(0, testFilter.getCriteria().size());
    }

    public void testEmailAddresses() throws HibernateException {
        String desc = "email" + TestUtils.randomString();
        String addr1 = "addr1@example.com";
        String addr2 = "addr2@example.com";
        Filter filter = createTestFilter(user, desc);
        filter.getEmailAddresses().add(addr1);
        filter.getEmailAddresses().add(addr2);
        NotificationFactory.saveFilter(filter, user);
        filter = (Filter) reload(filter);
        assertEquals(2, filter.getEmailAddresses().size());
        assertContains(filter.getEmailAddresses(), addr1);
        assertContains(filter.getEmailAddresses(), addr2);

        filter.getEmailAddresses().remove(addr1);
        NotificationFactory.saveFilter(filter, user);
        System.out.println(filter);
        filter = (Filter) reload(filter);
        assertEquals(1, filter.getEmailAddresses().size());
        assertContains(filter.getEmailAddresses(), addr2);
    }

    private void checkCriteria(Filter filter, Criteria crit) {
        Criteria actual = null;
        for (Iterator i = filter.getCriteria().iterator(); i.hasNext();) {
            actual = (Criteria) i.next();
            if (actual.getMatchType().equals(crit.getMatchType())) {
                break;
            }
        }

        assertNotNull(actual);
        assertNotSame(crit, actual);
        assertEquals(crit.getValue(), actual.getValue());
    }

    /**
     * Create a test Filter
     * @param userIn
     * @param desc
     * @return Filter that was created
     */
    public static Filter createTestFilter(User userIn, String desc) {
        ModifyFilterCommand cmd = new ModifyFilterCommand(userIn);
        cmd.setDescription(desc);
        String type = NotificationFactory.FILTER_TYPE_ACK.getName();
        cmd.setFilterType(type);
        cmd.storeFilter();
        Filter testFilter = cmd.getFilter();
        assertNotNull(testFilter.getOrg());
        assertNotNull(testFilter.getUser());
        assertNotNull(testFilter.getType());
        assertNotNull(testFilter.getExpiration());
        assertNotNull(testFilter.getStartDate());
        assertEquals(type, testFilter.getType().getName());
        return testFilter;
    }
}

