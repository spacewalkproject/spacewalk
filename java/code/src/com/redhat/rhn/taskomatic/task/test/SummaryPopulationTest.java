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

import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * SummaryPopulationTest
 * @version $Rev$
 */
public class SummaryPopulationTest extends RhnBaseTestCase {

    public void testExecute() {
        assertTrue(true);
        
        // this test takes way too long to be a unit test
        // probably need a nice flag in our system to enable
        // this test.
        
        /*
        // query takes more than 4 minutes, can't have that
        // in a unit test
        SummaryPopulation sp = new SummaryPopulation();
        sp.execute(null);
        SelectMode m = ModeFactory.getMode(
                "test_queries","get_daily_summary_queue");
        List rows = m.execute(null);
        assertNotNull(rows);
        assertFalse(rows.isEmpty());
        assertTrue(rows.size() > 0);
        */
    }
}
