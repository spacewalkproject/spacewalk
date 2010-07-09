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

import com.redhat.rhn.domain.server.ServerArch;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ServerArchTest
 * @version $Rev$
 */
public class ServerArchTest extends RhnBaseTestCase {

    /**
     * Simple test to make sure we can lookup ServerArchs from
     * the db. Turn on hibernate.show_sql to make sure hibernate
     * is only going to the db once.
     * @throws Exception HibernateException
     */
    public void testServerArch() throws Exception {

        String testname = "alpha-redhat-linux";

        ServerArch s1 = ServerFactory.lookupServerArchByLabel(testname);
        ServerArch s2 = ServerFactory.lookupServerArchByLabel(s1.getLabel());

        assertNotNull(s1.getArchType());
        assertEquals(s1.getName(), s2.getName());
    }
}
