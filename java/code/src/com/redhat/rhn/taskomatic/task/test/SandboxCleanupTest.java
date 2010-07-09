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

import com.redhat.rhn.taskomatic.task.SandboxCleanup;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * SandboxCleanupTest
 * @version $Rev$
 */
public class SandboxCleanupTest extends RhnBaseTestCase {

    /*
     * Again, there isn't much to test here. SandboxCleanup simply runs a few stored procs.
     * Just want to make sure the code at least gets run in a test environment.
     */
    public void testExecute() throws Exception {
        //the default db user doesn't have access to do this in hosted

        SandboxCleanup task = new SandboxCleanup();
        task.execute(null);
    }

}
