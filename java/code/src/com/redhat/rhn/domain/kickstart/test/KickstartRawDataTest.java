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

import com.redhat.rhn.common.util.FileUtils;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartRawData;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartCloneCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerDistroCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.cobbler.Distro;

import java.util.SortedSet;
import java.util.TreeSet;

/**
 * @version $Rev$
 */
public class KickstartRawDataTest extends BaseTestCaseWithUser {
    
    private KickstartableTree tree;
    private KickstartRawData ksdata;
    private String fileContents = "test kickstart file\n";
    
    public void setUp() throws Exception {
        super.setUp();
        user.addRole(RoleFactory.ORG_ADMIN);
        tree = KickstartableTreeTest.createTestKickstartableTree();
        CobblerDistroCreateCommand cmd = new CobblerDistroCreateCommand(tree);
        ksdata = createRawData(user, "boring" + TestUtils.randomString(), tree, 
                fileContents,
                KickstartVirtualizationType.XEN_PARAVIRT);

    }

    public void testLookupAndSaveKickstartRawData() throws Exception {
                
        ((KickstartRawData) ksdata).setData(fileContents);
        CobblerProfileCreateCommand cmd = new CobblerProfileCreateCommand(ksdata);
        cmd.store();
        
        KickstartFactory.saveKickstartData(ksdata);
        String contents = FileUtils.readStringFromFile(ksdata.getCobblerFileName());
        assertEquals(fileContents, contents);
        
        
        
        long id = ksdata.getId();
        KickstartRawData checker = (KickstartRawData) KickstartFactory.
                    lookupKickstartDataByIdAndOrg(user.getOrg(), id);
        
        assertEquals(fileContents, checker.getData());
        // Setting to null zeros out in memory but 
        // re-calling getData() will re-load it off disk.
        checker.setData(null);
        assertEquals(fileContents, checker.getData());
    }
    
    public void testDeepCopy() throws Exception {
        ((KickstartRawData) ksdata).setData(fileContents);
        CobblerProfileCreateCommand cmd = new CobblerProfileCreateCommand(ksdata);
        cmd.store();
        
        KickstartFactory.saveKickstartData(ksdata);
        System.out.println("KSData111.label: " + ksdata.getLabel());
        System.out.println("KSData111.id: " + ksdata.getId());
        KickstartCloneCommand ccmd = new KickstartCloneCommand(ksdata.getId(), 
                user, TestUtils.randomString());
        ccmd.store();
        KickstartRawData clone = (KickstartRawData) ccmd.getClonedKickstart();
        clone = (KickstartRawData) ksdata.deepCopy(user, TestUtils.randomString());
        assertNotNull(clone);
        assertEquals(clone.getData(), ksdata.getData());
    }
    
    public void testEditActualFile() throws Exception {
        String newContents = TestUtils.randomString() + "\n";
        FileUtils.writeStringToFile(newContents, ksdata.getCobblerFileName());
        ksdata.setData(null);
        assertEquals(newContents, ksdata.getData());
    }
    
    public void testEditExisting() throws Exception {
        String newContents = TestUtils.randomString() + "\n";
        ksdata.setData(newContents);
        KickstartFactory.saveKickstartData(ksdata);
        String written = FileUtils.readStringFromFile(ksdata.getCobblerFileName());
        assertEquals(newContents, written);
    }

    public static KickstartRawData createRawData(User user, 
            String label, 
            KickstartableTree tree,
            String contents,
                String virtType) {
        KickstartBuilder builder = new KickstartBuilder(user);
        KickstartRawData data = builder.createRawData(label, tree, contents,
                                   virtType);
        assertNotNull(data);
        assertEquals(label, data.getLabel());
        assertEquals(virtType, 
        data.getKickstartDefaults().getVirtualizationType().getLabel());
        assertEquals(tree, data.getKickstartDefaults().getKstree());
        assertEquals(user.getOrg(), data.getOrg());
        
        SortedSet<KickstartCommand> optionsSet = new TreeSet<KickstartCommand>();
        data.setCustomOptions(optionsSet);

        Distro d = Distro.lookupById(CobblerXMLRPCHelper.getConnection("test"),
                data.getKickstartDefaults().getKstree().getCobblerId());
        org.cobbler.Profile.create(CobblerXMLRPCHelper.getConnection("test"),
                data.getLabel(), d);

        
        return data;
    }


}
