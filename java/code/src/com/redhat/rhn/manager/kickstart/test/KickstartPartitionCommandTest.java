/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.manager.kickstart.KickstartPartitionCommand;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

/**
 * KickstartPartitionCommandTest - test for KickstartDetailsCommand
 * @version $Rev$
 */
public class KickstartPartitionCommandTest extends BaseTestCaseWithUser {

   
    public void testKickstartPartitionCommand() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithChannel(user.getOrg());      
        assertEquals(0, k.getPartitions().size());
        KickstartFactory.saveKickstartData(k);
        
        KickstartPartitionCommand cmd = new KickstartPartitionCommand(k.getId(), user);
        
        String partitions = "partition /boot --fstype=ext3 --size=200\n" +
            "partition swap --size=2000\n" + 
            "partition pv.01 --size=1000 --grow\n" +
            "volgroup myvg pv.01\n" + 
            "logvol / --vgname=myvg --name=rootvol --size=1000 --grow\n";

        assertNull(cmd.parsePartitions(partitions));
        String parts = cmd.populatePartitions();
        assertNotNull(parts);
        assertNotNull(cmd);
        assertNull(cmd.store());
        assertEquals(3, k.getPartitions().size());
        
    }

    public void testLVMSwapPartitions() throws Exception {
        KickstartData k = KickstartDataTest.createKickstartWithChannel(user.getOrg());      
        KickstartFactory.saveKickstartData(k);
        
        KickstartPartitionCommand cmd = new KickstartPartitionCommand(k.getId(), user);
        String partitions = "partition swap.01 --size=5150 --ondisk=sda\n" +
            "partition /boot --fstype=ext3 --size=200\n" + 
            "partition swap.02 --size=8888 --ondisk=sda\n" + 
            "partition pv.01 --size=1000 --grow\n" + 
            "volgroup myvg pv.01\n" + 
            "logvol / --vgname=myvg --name=rootvol --size=2112 --grow\n";
        
        assertNull(cmd.parsePartitions(partitions));
        assertNull(cmd.store());
        k = (KickstartData) reload(k);
        assertTrue(cmd.populatePartitions().
                indexOf("partition swap.02 --size=8888 --ondisk=sda") >= 0);
        assertTrue(k.getPartitions().size() > 0);
            
    }

    
}
