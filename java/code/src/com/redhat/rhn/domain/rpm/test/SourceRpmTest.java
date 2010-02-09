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
package com.redhat.rhn.domain.rpm.test;

import com.redhat.rhn.domain.rpm.SourceRpm;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * SourceRpmTest
 * @version $Rev$
 */
public class SourceRpmTest extends RhnBaseTestCase {

    /**
     * Simple test to make sure we can create SourceRpms and
     * commit them to the db.
     * @throws Exception
     */
    public void testSourceRpm() throws Exception {
        SourceRpm srpm = createTestSourceRpm();
        assertNotNull(srpm);
        //make sure we got commited to the db.
        assertNotNull(srpm.getId());
    }
    
    /**
     * Create a test SourceRpm.
     * @return Returns a commited SourceRpm object.
     * @throws Exception
     */
    public static SourceRpm createTestSourceRpm() throws Exception {
        SourceRpm s = new SourceRpm();
        s.setName(TestUtils.randomString());
        TestUtils.saveAndFlush(s);
        return s;
    }
}
