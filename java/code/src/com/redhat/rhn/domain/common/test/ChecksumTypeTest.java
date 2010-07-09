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
package com.redhat.rhn.domain.common.test;

import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * ArchTypeTest
 * @version $Rev$
 */
public class ChecksumTypeTest extends RhnBaseTestCase {

    public void testChecksumType() throws Exception {

        Long testid = new Long(1);
        String query = "ChecksumType.findById";

        ChecksumType at1 = (ChecksumType) TestUtils.lookupFromCacheById(testid, query);
        assertNotNull(at1);
        assertEquals(at1.getId(), testid);

        ChecksumType at2 = (ChecksumType) TestUtils.lookupFromCacheById(at1.getId(), query);
        assertEquals(at1.getLabel(), at2.getLabel());

        ChecksumType at3 = (ChecksumType) TestUtils.lookupFromCacheById(at1.getId(), query);
    }

}
