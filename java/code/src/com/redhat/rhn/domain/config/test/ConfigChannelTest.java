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
package com.redhat.rhn.domain.config.test;

import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ConfigChannelTest
 * @version $Rev: $
 */
public class ConfigChannelTest extends RhnBaseTestCase {

    public void testIsTypeMethods() {
        ConfigChannel cc = ConfigurationFactory.newConfigChannel();
        cc.setConfigChannelType(ConfigChannelType.local());
        assertTrue(cc.isLocalChannel());
        cc.setConfigChannelType(ConfigChannelType.global());
        assertTrue(cc.isGlobalChannel());
        cc.setConfigChannelType(ConfigChannelType.sandbox());
        assertTrue(cc.isSandboxChannel());
    }
}

