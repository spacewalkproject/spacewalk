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
package com.redhat.rhn.testing;

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.DistChannelMap;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnpackage.test.PackageManagerTest;

import java.util.HashSet;
import java.util.Set;


/**
 * ChannelTestUtils
 * @version $Rev$
 */
public class ChannelTestUtils {
    public static final int VIRT_INDEX = 1; 
    public static final int TOOLS_INDEX = 0;
    
    private ChannelTestUtils() {
    }
    
    /**
     * Create test base channel 
     * @param creator of channel
     * @return Channel created
     * @throws Exception if error
     */
    public static Channel createBaseChannel(User creator) throws Exception {
        Channel retval = ChannelFactoryTest.createBaseChannel(creator);
        retval = (Channel) TestUtils.reload(retval);
        return retval;
    }

    /**
     * Create test channel
     * @param user who creates
     * @return Channel created
     * @throws Exception foo
     */
    public static Channel createTestChannel(User user) throws Exception {
        return ChannelFactoryTest.createTestChannel(user);
    }

    
    /** Create a child channel of the passed in base channel
     * 
     * @param user who's org owns channel 
     * @param baseChannel to use as parent
     * @return Channel child created
     * @throws Exception while creating
     */
    public static Channel createChildChannel(User user, Channel baseChannel) 
        throws Exception {
        if (baseChannel == null) {
            throw new NullPointerException("baseChannel is null");
        }
        if (!baseChannel.isBaseChannel()) {
            throw new IllegalArgumentException("baseChannel is not a base channel");
        }
    
        Channel retval = ChannelFactoryTest.createTestChannel(user);
        retval.setParentChannel(baseChannel);
        ChannelFactory.save(retval);
        return retval;
    }
    
    /** 
     * Setup a Base Channel with 2 child channels (rhn-tools and rhel-virt) to be 
     * able to do virt stuff.   
     * @param user u
     * @param baseChannel bc
     * @return Channel[] array containing rhn-tools[0] and rhel-virt[1] 
     * @throws Exception thrown if error
     */
    public static Channel[] setupBaseChannelForVirtualization(User user, 
            Channel baseChannel) throws Exception {
        // Channels
        Channel rhnTools = 
            ChannelTestUtils.createChildChannel(user, baseChannel);

        PackageManagerTest.addPackageToChannel(
                ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME, rhnTools);
        PackageManagerTest.addPackageToChannel(
                ChannelManager.RHN_VIRT_HOST_PACKAGE_NAME, rhnTools);
        PackageManagerTest.addPackageToChannel(
                ConfigDefaults.get().getKickstartPackageName(), rhnTools);

        
        Channel rhelVirt = 
            ChannelTestUtils.createChildChannel(user, baseChannel);
        ChannelTestUtils.addDistMapToChannel(rhelVirt, ChannelManager.VT_OS_PRODUCT,
                TestUtils.randomString());

        PackageManagerTest.addPackageToChannel(
                ChannelManager.VIRT_CHANNEL_PACKAGE_NAME, rhelVirt);
        
        Channel[] retval = new Channel[2];
        retval[TOOLS_INDEX] = rhnTools;
        retval[VIRT_INDEX] = rhelVirt;
        return retval;
    }

    /**
     * Add a dist channel map for the given channel.
     * 
     * @param c Channel
     * @param os Poorly named in the db, actually a product name.
     * @param release Poorly named, actually a RHEL version.
     */
    public static void addDistMapToChannel(Channel c, String os, String release) {
        DistChannelMap dcm = new DistChannelMap();
        dcm.setChannel(c);
        dcm.setChannelArch(c.getChannelArch());
        dcm.setOs(os);
        dcm.setRelease(release);
        Set maps = new HashSet();
        maps.add(dcm);
        c.setDistChannelMaps(maps);
        ChannelFactory.save(c);
        TestUtils.saveAndFlush(dcm);
    }

    /**
     * Add a test DistChannelMap to the specified channel.
     * @param c Channel to add a DistChannelMap to.
     */
    public static void addDistMapToChannel(Channel c) {
        addDistMapToChannel(c, "Red Hat Unit Test" + TestUtils.randomString(), 
                TestUtils.randomString());
    }

}
