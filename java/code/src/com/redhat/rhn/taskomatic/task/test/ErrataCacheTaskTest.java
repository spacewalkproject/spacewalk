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

import com.redhat.rhn.taskomatic.task.ErrataCacheTask;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.commons.lang.time.StopWatch;

/**
 * ErrataCacheTaskTest
 * @version $Rev$
 */
public class ErrataCacheTaskTest extends RhnBaseTestCase {

    public void aTestExecute() throws Exception {
        StopWatch sw = new StopWatch();

        ErrataCacheTask ect = new ErrataCacheTask();
        
        sw.start();
        ect.execute(null);
        sw.stop();
        System.out.println("ErrataCacheTask took [" + sw.getTime() + "]");
    }
    
    public void testNothing() {
        assertTrue(true);
    }
}
