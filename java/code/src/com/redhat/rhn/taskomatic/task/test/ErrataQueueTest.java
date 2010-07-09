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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.taskomatic.task.ErrataQueue;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ErrataQueueTest extends BaseTestCaseWithUser {

    // We can run this now that mmccune made ErrataQueue perform OK.
    public void testErrataQueue() throws Exception {

        ErrataQueue eq = new ErrataQueue() {

            // Override this so we only process one errata.
            @SuppressWarnings("unused")
            protected List findCandidates() throws Exception {
                Long eid = ErrataFactoryTest.
                    createTestErrata(user.getOrg().getId()).getId();
                List retval = new LinkedList();
                Map row = new HashMap();
                row.put("errata_id", eid);
                row.put("org_id", user.getOrg().getId());
                retval.add(row);
                System.out.println("Returning one test errata.");
                return retval;
            }

        };
        eq.execute(null, true);
        // Just a simple test to make sure we get here without
        // exceptions.  Better than nothin'
        assertTrue(true);
    }
}
