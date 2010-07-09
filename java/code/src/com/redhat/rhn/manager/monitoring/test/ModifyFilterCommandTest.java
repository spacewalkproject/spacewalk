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
package com.redhat.rhn.manager.monitoring.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.notification.Criteria;
import com.redhat.rhn.domain.monitoring.notification.Filter;
import com.redhat.rhn.domain.monitoring.notification.MatchType;
import com.redhat.rhn.manager.monitoring.ModifyFilterCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.hibernate.HibernateException;

public class ModifyFilterCommandTest extends BaseTestCaseWithUser {

    private ModifyFilterCommand cmd;

    public void setUp() throws Exception {
        super.setUp();
        makeCommand();
    }

    public void tearDown() throws Exception {
        cmd = null;
        super.tearDown();
    }

    public void testStartEndDate() {
        assertTrue(cmd.getFilter().getExpiration().after(
                cmd.getFilter().getStartDate()));
    }

    public void testAllProbeStates() throws HibernateException {
        cmd.updateStates(MonitoringConstants.PROBE_STATES);
        cmd.storeFilter();

        Filter filter = (Filter) reload(cmd.getFilter());
        int criteria = 0;
        if (filter.getCriteria() != null) {
            criteria = filter.getCriteria().size();
        }
        assertEquals(0, criteria);
    }

    public void testRegexMatch() throws HibernateException {
        checkMatch("[a-z]", Boolean.TRUE, MatchType.REGEX_CASE);
        makeCommand();
        checkMatch("[0-9]", Boolean.FALSE, MatchType.REGEX);
    }

    public void testGetScope() {
        // Make sure that ModifyFilterCommand.getScope
        // does not get fooled by non-scope criteria
        cmd.updateMatch("[a-z]", Boolean.FALSE);
        cmd.updateScope(MatchType.PROBE, new String[] { "0" });
        assertEquals(MatchType.PROBE.getScope(), cmd.getScope());
    }

    private void checkMatch(String re, Boolean matchCase, MatchType matchType)
      throws HibernateException {
        cmd.updateMatch(re, matchCase);
        cmd.storeFilter();

        Filter filter = (Filter) reload(cmd.getFilter());
        assertEquals(1, filter.getCriteria().size());
        Criteria c = (Criteria) filter.getCriteria().iterator().next();
        assertEquals(matchType, c.getMatchType());
        assertEquals(re, c.getValue());
    }

    private void makeCommand() {
        cmd = new ModifyFilterCommand(user);
        cmd.setDescription("probeStates" + TestUtils.randomString());
    }

}
