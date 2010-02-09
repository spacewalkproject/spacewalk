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

import com.redhat.rhn.domain.common.CommonConstants;
import com.redhat.rhn.testing.RhnBaseTestCase;


/**
 * VirtualizationSubscriptionTypeTest
 * @version $Rev$
 */
public class VirtSubscriptionTypeTest extends RhnBaseTestCase {

    public void testLoadVSType() throws Exception {

        assertNotNull(CommonConstants.getVirtSubscriptionLevelFree());
        assertNotNull(CommonConstants.getVirtSubscriptionLevelPlatformFree());
    }
}
