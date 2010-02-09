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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartInstallType;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartInstallTypeTest
 * @version $Rev$
 */
public class KickstartInstallTypeTest extends RhnBaseTestCase {

    public void testKsInstallType() throws Exception {
        Long testid = new Long(1);
        String query = "KickstartInstallType.findById";
        
        KickstartInstallType kit1 = (KickstartInstallType)
                                    TestUtils.lookupFromCacheById(testid, query);
        assertNotNull(kit1);
        assertEquals(kit1.getId(), testid);
        
        KickstartInstallType kit2 = (KickstartInstallType)
                                    TestUtils.lookupFromCacheById(testid, query);
        assertEquals(kit1.getLabel(), kit2.getLabel());
    }

}
