/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.Iterator;
import java.util.List;

/**
 * KickstartWizardCommandTest
 * @version $Rev$
 */
public class KickstartWizardCommandTest extends BaseTestCaseWithUser {
    
    public void testWizTrees() throws Exception {
        
        Channel c = ChannelFactoryTest.createTestChannel(user);
        assertNull(c.getParentChannel());
        KickstartableTree tree  = KickstartableTreeTest.createTestKickstartableTree(c);
        tree.setOrg(null);
        tree.setChannel(c);
        TestUtils.saveAndFlush(tree);
        TestUtils.saveAndFlush(c);
        
        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        List trees = cmd.getKickstartableTrees();
        assertNotNull(trees);
        assertTrue(trees.size() > 0);
        boolean foundBaseTree = false;
        Iterator i = trees.iterator();
        while (i.hasNext()) {
            KickstartableTree t = (KickstartableTree) i.next();
            if (t.getChannel().getParentChannel() == null) {
                foundBaseTree = true;
            }
        }
        assertTrue("Didnt find any trees that are from a basechannel.", foundBaseTree);
        
        
        assertNotNull(cmd.getKickstartableTree(tree.getId()));
    }

}
