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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.domain.server.CPUArch;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * CPUArchTest
 * @version $Rev$
 */
public class CPUArchTest extends RhnBaseTestCase {

    /**
     * Simple test to make sure we can lookup CPUArchs from
     * the db. Turn on hibernate.show_sql to make sure hibernate
     * is only going to the db once.
     * @throws Exception HibernateException
     */
    public void testCPUArch() throws Exception {

        String testname = "sun4u";
        String invalid = "foobar4me";

        CPUArch c1 = ServerFactory.lookupCPUArchByName(testname);
        CPUArch c2 = ServerFactory.lookupCPUArchByName(c1.getName());
        CPUArch c3 = ServerFactory.lookupCPUArchByName(invalid);

        assertNull(c3);
        assertNotNull(c1.getCreated());
        assertEquals(c1.getLabel(), c2.getLabel());
    }
}
