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
package com.redhat.rhn.frontend.xmlrpc.configchannel.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionAction;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileState;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ScheduledAction;
import com.redhat.rhn.frontend.xmlrpc.configchannel.ConfigChannelHandler;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigRevisionSerializer;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigChannelCreationHelper;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ConfigChannelHandlerTest
 * @version $Rev$
 */
public class ConfigChannelHandlerTest extends BaseHandlerTestCase {
    private ConfigChannelHandler handler = new ConfigChannelHandler();
    private static final String LABEL = "LABEL" + TestUtils.randomString();
    private static final String NAME = "NAME" + TestUtils.randomString();
    private static final String DESCRIPTION = "DESCRIPTION" + TestUtils.randomString();

    public void testCreate() {
        try {
            handler.create(regularKey, LABEL, NAME, DESCRIPTION);
            String msg = "Needs to be a config admin.. perm error not detected.";
            fail(msg);
        }
        catch (Exception e) {
            //Cool perm error!
        }
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);
        assertEquals(LABEL, cc.getLabel());
        assertEquals(NAME, cc.getName());
        assertEquals(DESCRIPTION, cc.getDescription());
        assertEquals(admin.getOrg(), cc.getOrg());
        
        try {
            cc = handler.create(adminKey, LABEL + "/", NAME, DESCRIPTION);
            String msg = "Invalid character / not detected:(";
            fail(msg);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            //Cool invalid check works!..
        }
    }
    
    
    public void testUpdate() {
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);
        String newName = NAME + TestUtils.randomString();
        String desc = DESCRIPTION + TestUtils.randomString();
        try {
            handler.update(regularKey, LABEL, newName, desc);
            String msg = "Needs to be a config admin/have access.. " +
                            "perm error not detected.";
            fail(msg);
        }
        catch (Exception e) {
            //Cool perm error!
        }
        cc = handler.update(adminKey, LABEL, newName, desc);
        assertEquals(LABEL, cc.getLabel());
        assertEquals(newName, cc.getName());
        assertEquals(desc, cc.getDescription());
        assertEquals(admin.getOrg(), cc.getOrg());
        try {
            String name = RandomStringUtils.randomAlphanumeric(
                    ConfigChannelCreationHelper.MAX_NAME_LENGTH + 1);
            cc = handler.update(adminKey, LABEL, name, DESCRIPTION);
            String msg = "Max length reached for name- not detected :(";
            fail(msg);
        }
        catch (Exception e) {
            System.out.println(e.getMessage());
            //Cool invalid check works!..
        }
    }
    
    public void testListGlobal() throws Exception {
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(admin.getOrg());
        ConfigTestUtils.giveUserChanAccess(regular, cc);
        List<ConfigChannelDto> list = handler.listGlobals(regularKey);
        assertTrue(contains(cc, list));
    }

    public void testLookupGlobal() throws Exception {
        List<String> channelLabels = new LinkedList<String>();
        List<ConfigChannel> channels = new LinkedList<ConfigChannel>();
        
        for (int i = 0; i < 10; i++) {
            ConfigChannel cc = ConfigTestUtils.createConfigChannel(admin.getOrg());
            ConfigTestUtils.giveUserChanAccess(regular, cc);
            channels.add(cc);
            channelLabels.add(cc.getLabel());
        }

        List<ConfigChannel> list = handler.lookupChannelInfo(regularKey,
                                                                    channelLabels);
        assertEquals(channels, list);
    }

    public void testGetDetailsByLabel() throws Exception {
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(admin.getOrg());

        ConfigTestUtils.giveUserChanAccess(regular, cc);

        ConfigChannel channel = handler.getDetails(regularKey, cc.getLabel());
        
        assertEquals(channel, cc);
    }
    
    public void testGetDetailsById() throws Exception {
        ConfigChannel cc = ConfigTestUtils.createConfigChannel(admin.getOrg());

        ConfigTestUtils.giveUserChanAccess(regular, cc);
    
        ConfigChannel channel = handler.getDetails(regularKey, cc.getId().intValue());
    
        assertEquals(channel, cc);
    }
    
    public void testDelete() {
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);
        List<String> labels = new LinkedList<String>();
        labels.add(cc.getLabel());
        List <ConfigChannel> channels = handler.lookupChannelInfo(adminKey, labels);
        assertEquals(1, channels.size());
        handler.deleteChannels(adminKey, labels);
        try {
            handler.lookupChannelInfo(adminKey, labels);
            fail("Lookup exception not raised!");
        }
        catch (LookupException e) {
            // Cool could not find the item!..
        }
     }    

    /**
     * Checks if a given config channel is present in a list.
     * @param cc Config channel  
     * @param list list of type COnfigChannelDto
     * @return true if the List contains it , false other wise
     */
    private boolean contains(ConfigChannel cc, List<ConfigChannelDto> list) {
        for (ConfigChannelDto dto : list) {
            if (dto.getLabel().equals(cc.getLabel())) {
                return true;
            }
        }
        return false;
    }    

    private ConfigRevision createRevision(String path, String contents, 
                            String group, String owner, 
                            String perms, boolean isDir, 
                            ConfigChannel cc, String selinuxCtx) 
                                        throws ValidatorException {
        Map <String, Object> data = new HashMap<String, Object>();
        data.put("contents", contents);
        data.put(ConfigRevisionSerializer.GROUP, group);
        data.put(ConfigRevisionSerializer.OWNER, owner);
        data.put(ConfigRevisionSerializer.PERMISSIONS, perms);
        data.put(ConfigRevisionSerializer.SELINUX_CTX, selinuxCtx);
        String start = "#@";
        String end = "@#";
        if (!isDir) {
            data.put(ConfigRevisionSerializer.MACRO_START, start);
            data.put(ConfigRevisionSerializer.MACRO_END, end);
        }
        
        ConfigRevision rev = handler.createOrUpdatePath(
                            adminKey, cc.getLabel(), path, isDir, data);

        assertEquals(path, rev.getConfigFile().getConfigFileName().getPath());
        assertEquals(contents, rev.getConfigContent().getContentsString());
        assertEquals(group, rev.getConfigInfo().getGroupname());
        assertEquals(owner, rev.getConfigInfo().getUsername());
        assertEquals(perms, String.valueOf(rev.getConfigInfo().getFilemode()));
        assertEquals(selinuxCtx, rev.getConfigInfo().getSelinuxCtx());
        if (isDir) {
            assertEquals(ConfigFileType.dir(), rev.getConfigFileType());
        }
        else {
            assertEquals(ConfigFileType.file(), rev.getConfigFileType());
            assertEquals(start, rev.getDelimStart());
            assertEquals(end, rev.getDelimEnd());
        }
        assertEquals(cc, rev.getConfigFile().getConfigChannel());        
        
        assertRevNotChanged(rev, cc);
        
        return rev;
    }
    
    private void assertRev(ConfigRevision rev, String path, ConfigChannel cc) {
        List<String> paths = new ArrayList<String>(1);
        paths.add(path);
        assertEquals(rev, handler.lookupFileInfo(adminKey, cc.getLabel(), paths).get(0));
        
    }
    
    private void assertRevNotChanged(ConfigRevision rev, ConfigChannel cc) {
        assertRev(rev, rev.getConfigFile().getConfigFileName().getPath(), cc);
    }
    
    public void testAddPath() throws Exception {
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);
                
        String path = "/tmp/foo/path" + TestUtils.randomString();
        String contents = "HAHAHAHA";
        
        ConfigRevision rev = createRevision(path, contents, 
                                    "group" + TestUtils.randomString(), 
                                    "owner" + TestUtils.randomString(),
                                    "777",
                                    false, cc, "unconfined_u:object_r:tmp_t");
        try {
            createRevision(path, contents, 
                    "group" + TestUtils.randomString(), 
                    "owner" + TestUtils.randomString(),
                    "744",
                    true, cc, "unconfined_u:object_r:tmp_t");
            fail("Can't change the path from file to directory.");
        }
        catch (Exception e) {
            // Can;t change.. Won't allow...
            assertRevNotChanged(rev, cc);
        }
        
        try {
            createRevision(path + TestUtils.randomString() + "/" , contents, 
                    "group" + TestUtils.randomString(), 
                    "owner" + TestUtils.randomString(),
                    "744",
                    true, cc, "unconfined_u:object_r:tmp_t");
            fail("Validation error on the path.");
        }
        catch (Exception e) {
            // Can;t change.. Won't allow...
            assertRevNotChanged(rev, cc);
        }        
        createRevision(path + TestUtils.randomString(), "", 
                "group" + TestUtils.randomString(), 
                "owner" + TestUtils.randomString(),
                "744",
                true, cc, "unconfined_u:object_r:tmp_t");
    }
    
    public void testListFiles() {
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);

        List<String> paths = new LinkedList<String>();
        Map<String, ConfigRevision> revisions = new HashMap<String, ConfigRevision>();

        setupPathsAndRevisions(cc, paths, revisions);
        
        List<ConfigFileDto> files = handler.listFiles(adminKey, LABEL);
        for (ConfigFileDto dto : files) {
            assertTrue(revisions.containsKey(dto.getPath()));
            ConfigRevision rev = revisions.get(dto.getPath());
            assertEquals(rev.getConfigFileType().getLabel(), dto.getType());
            assertNotNull(dto.getModified());
        }
    }

    /**
     * @param cc the channel
     * @param paths a list holder for paths
     * @param revisions a holder of revisions
     */
    private void setupPathsAndRevisions(ConfigChannel cc, List<String> paths,
            Map<String, ConfigRevision> revisions) {
        String path = "/tmp/foo/path/";
        for (int i = 0; i < 10; i++) {
            boolean isDir = i % 2 == 0;
            String newPath = path + TestUtils.randomString();
            String contents = isDir ? "" : TestUtils.randomString();
            paths.add(newPath);
            revisions.put(newPath, createRevision(newPath,
                                                    contents,  
                                                    "group" + TestUtils.randomString(), 
                                                    "owner" + TestUtils.randomString(),
                                                    "744",
                                                    isDir, cc, 
                                                    "unconfined_u:object_r:tmp_t"));
        }
    }
    
    public void testRemovePaths() throws Exception {
        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);
        List<String> paths = new LinkedList<String>();
        Map<String, ConfigRevision> revisions = new HashMap<String, ConfigRevision>();
        
        setupPathsAndRevisions(cc, paths, revisions);
        paths.remove(paths.size() - 1);
        handler.deleteFiles(adminKey, LABEL, paths);
        List<ConfigFileDto> files = handler.listFiles(adminKey, LABEL);
        assertEquals(1, files.size());
    }
    
    public void testScheduleFileComparisons() throws Exception {
        Server server = ServerFactoryTest.createTestServer(admin, true);

        ConfigChannel cc = handler.create(adminKey, LABEL, NAME, DESCRIPTION);

        // create a config file
        String path = "/tmp/foo/path" + TestUtils.randomString();
        String contents = "HAHAHAHA";
        ConfigRevision rev = createRevision(path, contents, 
                                    "group" + TestUtils.randomString(), 
                                    "owner" + TestUtils.randomString(),
                                    "777",
                                    false, cc, "unconfined_u:object_r:tmp_t");
        
        DataResult dr = ActionManager.recentlyScheduledActions(admin, null, 30);
        int preScheduleSize = dr.size();
        
        // schedule file comparison action
        List<Integer> serverIds = new ArrayList<Integer>();
        serverIds.add(server.getId().intValue());
        
        Integer actionId = handler.scheduleFileComparisons(adminKey, LABEL, path, 
                serverIds);
              
        // was the action scheduled?
        dr = ActionManager.recentlyScheduledActions(admin, null, 30);
        assertEquals(1, dr.size() - preScheduleSize);
        assertEquals(
                "Show differences between profiled config files and deployed config files", 
                ((ScheduledAction)dr.get(0)).getTypeName());
        assertEquals(actionId, new Integer(
                ((ScheduledAction)dr.get(0)).getId().intValue()));
    }

    public void testChannelExists() {
        handler.create(adminKey, LABEL, NAME, DESCRIPTION);
        
        int validChannel = handler.channelExists(adminKey, LABEL);
        int invalidChannel = handler.channelExists(adminKey, "dummy");
        
        assertEquals(validChannel, 1);
        assertEquals(invalidChannel, 0);
    }
    
    
    public void testDeployAllSystems()  throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        
        // Create  global config channels
        ConfigChannel gcc1 = ConfigTestUtils.createConfigChannel(admin.getOrg(),
                ConfigChannelType.global());
        ConfigChannel gcc2 = ConfigTestUtils.createConfigChannel(admin.getOrg(),
                ConfigChannelType.global());
        
        Long ver = new Long(2);
        
        // gcc1 only 
        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                    ServerConstants.getServerGroupTypeProvisioningEntitled());

        srv1.subscribe(gcc1);
        srv1.subscribe(gcc2);
        
        ServerFactory.save(srv1);

        Set <ConfigRevision> revisions = new HashSet<ConfigRevision>();
        
        ConfigFile g1f1 = gcc1.createConfigFile(
                ConfigFileState.normal(), "/etc/foo1");
        revisions.add(ConfigTestUtils.createConfigRevision(g1f1));
        
        ConfigurationFactory.commit(gcc1);

        ConfigFile g1f2 = gcc1.createConfigFile(
                ConfigFileState.normal(), "/etc/foo2");
        revisions.add(ConfigTestUtils.createConfigRevision(g1f2));
        ConfigurationFactory.commit(gcc2);

        ConfigFile g2f2 = gcc2.createConfigFile(
                ConfigFileState.normal(), "/etc/foo4");
        revisions.add(ConfigTestUtils.createConfigRevision(g2f2));
        ConfigurationFactory.commit(gcc2);

        ConfigFile g2f3 = gcc2.createConfigFile(
                ConfigFileState.normal(), "/etc/foo3");
        revisions.add(ConfigTestUtils.createConfigRevision(g2f3));
        ConfigurationFactory.commit(gcc2);

        
        // System 1 - both g1f1 and g1f2 should deploy here
        List<Number> systems  = new ArrayList<Number>();
        systems.add(srv1.getId());
        Date date = new Date();

        try {
            // validate that system must have config deployment capability
            // in order to deploy config files... (e.g. rhncfg* pkgs installed)
            handler.deployAllSystems(regularKey, gcc1.getLabel(), date);

            fail("Shouldn't be permitted to deploy without config deploy capability.");
        }
        catch (Exception e) {
            // Success
        }

        SystemManagerTest.giveCapability(srv1.getId(),
                SystemManager.CAP_CONFIGFILES_DEPLOY, ver);

        handler.deployAllSystems(regularKey, gcc1.getLabel(), date);
        
        DataResult<ScheduledAction> actions = ActionManager.
                                    recentlyScheduledActions(regular, null, 1);
        ConfigAction ca = null;
        for (ScheduledAction action : actions) {
            if (ActionFactory.TYPE_CONFIGFILES_DEPLOY.getName().
                    equals(action.getTypeName())) {
                ca = (ConfigAction)ActionManager.lookupAction(regular,
                                                    action.getId().longValue());
            }
        }
        assertNotNull(ca);
        assertEquals(revisions.size(), ca.getConfigRevisionActions().size());
        for (ConfigRevisionAction cra : ca.getConfigRevisionActions()) {
            assertTrue(revisions.contains(cra.getConfigRevision()));
        }
        
    }

}
