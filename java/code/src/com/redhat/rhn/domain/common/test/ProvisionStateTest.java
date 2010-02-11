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

import com.redhat.rhn.domain.common.ProvisionState;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * ProvisionStateTest
 * @version $Rev$
 */
public class ProvisionStateTest extends RhnBaseTestCase {
    
    public void testProvisionState() throws Exception {

        ProvisionState p = new ProvisionState();
        p.setCreated(new Date());
        p.setDescription("Test Description");
        p.setLabel("Test Label " + TestUtils.randomString());
        p.setModified(new Date());
        
        assertNull(p.getId());
        TestUtils.saveAndFlush(p);
        assertNotNull(p.getId());

    }
    
}
