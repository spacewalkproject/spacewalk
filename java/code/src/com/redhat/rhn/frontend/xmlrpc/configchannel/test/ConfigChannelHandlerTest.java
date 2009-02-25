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
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ScheduledAction;
import com.redhat.rhn.frontend.xmlrpc.configchannel.ConfigChannelHandler;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigRevisionSerializer;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigChannelCreationHelper;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

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
                                String perms, boolean isDir, ConfigChannel cc) 
                                        throws ValidatorException {
        Map <String, Object> data = new HashMap<String, Object>();
        data.put("contents", contents);
        data.put(ConfigRevisionSerializer.GROUP, group);
        data.put(ConfigRevisionSerializer.OWNER, owner);
        data.put(ConfigRevisionSerializer.PERMISSIONS, perms);
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
                                    false, cc);
        try {
            createRevision(path, contents, 
                    "group" + TestUtils.randomString(), 
                    "owner" + TestUtils.randomString(),
                    "744",
                    true, cc);
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
                    true, cc);
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
                true, cc);
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
                                                    isDir, cc));                
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
                                    false, cc);
        
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

}
