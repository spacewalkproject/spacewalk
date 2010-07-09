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
package com.redhat.rhn.domain.channel.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ReleaseChannelMap;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;


/**
 * ReleaseChannelMapTest
 * @version $Rev$
 */
public class ReleaseChannelMapTest extends BaseTestCaseWithUser {

    private final String PRODUCT = "RHEL";
    private final String VERSION = "5Server";
    private final String RELEASE = "5.0.0";

    public void testCreate() throws Exception {
        Channel c = ChannelFactoryTest.createTestChannel(user);
        ReleaseChannelMap rcm = new ReleaseChannelMap();
        rcm.setChannel(c);
        rcm.setChannelArch(c.getChannelArch());
        rcm.setProduct(PRODUCT);
        rcm.setVersion(VERSION);
        rcm.setRelease(RELEASE);
        TestUtils.saveAndReload(rcm);
    }

}
