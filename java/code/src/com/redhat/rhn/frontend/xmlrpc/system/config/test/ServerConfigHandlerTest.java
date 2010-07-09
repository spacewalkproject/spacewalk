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
package com.redhat.rhn.frontend.xmlrpc.system.config.test;

import com.redhat.rhn.common.db.datasource.DataResult;
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
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.dto.ScheduledAction;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigRevisionSerializer;
import com.redhat.rhn.frontend.xmlrpc.system.config.ServerConfigHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * SystemConfigHandlerTest
 * @version $Rev$
 */
public class ServerConfigHandlerTest extends BaseHandlerTestCase {
    private ServerConfigHandler handler = new ServerConfigHandler();
    public void testDeployConfiguration() throws Exception {

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
            handler.deployAll(regularKey, systems, date);

            fail("Shouldn't be permitted to deploy without config deploy capability.");
        }
        catch (Exception e) {
            // Success
        }

        SystemManagerTest.giveCapability(srv1.getId(),
                SystemManager.CAP_CONFIGFILES_DEPLOY, ver);

        handler.deployAll(regularKey, systems, date);

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


    public void testConfigChannels() throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        // Create  global config channels
        ConfigChannel gcc1 = ConfigTestUtils.createConfigChannel(admin.getOrg(),
                ConfigChannelType.global());
        ConfigChannel gcc2 = ConfigTestUtils.createConfigChannel(admin.getOrg(),
                ConfigChannelType.global());

        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());

        List<Number> serverIds = new LinkedList<Number>();
        serverIds.add(srv1.getId());

        List <ConfigChannel> channels = new LinkedList<ConfigChannel>();
        channels.add(gcc1);
        channels.add(gcc2);

        List <String> channelLabels = new LinkedList<String>();
        for (ConfigChannel cc : channels) {
            channelLabels.add(cc.getLabel());
        }
        handler.setChannels(adminKey, serverIds, channelLabels);
        List<ConfigChannel> actual = handler.listChannels(regularKey,
                                    srv1.getId().intValue());
        assertEquals(channels, actual);

        handler.removeChannels(adminKey, serverIds,
                                                channelLabels.subList(0, 1));
        actual = handler.listChannels(regularKey,
                                            srv1.getId().intValue());
        assertEquals(channels.subList(1, channels.size()), actual);

        //test add channels
        handler.addChannels(adminKey, serverIds, channelLabels.subList(0, 1), true);
        actual = handler.listChannels(regularKey,
                srv1.getId().intValue());
        assertEquals(channels, actual);

        assertEquals(1,  handler.removeChannels(adminKey, serverIds,
                                    channelLabels.subList(1, channelLabels.size())));
        assertEquals(1,
                handler.addChannels(adminKey, serverIds, channelLabels.subList(1,
                                                        channelLabels.size()), false));
        actual = handler.listChannels(regularKey, srv1.getId().intValue());
        assertEquals(channels, actual);
    }


    private ConfigRevision createRevision(String path, String contents,
            String group, String owner,
                String perms, boolean isDir,
                Server server, boolean commitToLocal, String selinuxCtx)
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
                        adminKey, server.getId().intValue(),
                        path, isDir, data, commitToLocal);

            ConfigChannel cc = commitToLocal ? server.getLocalOverride() :
                                                     server.getSandboxOverride();
            assertRev(rev, path, contents, group, owner, perms, isDir, cc, start, end,
                    selinuxCtx);

            assertRevNotChanged(rev, server, commitToLocal);

            return rev;
    }

    private void assertRev(ConfigRevision rev, String path, String contents,
                                    String group, String owner,
                                String perms, boolean isDir, ConfigChannel cc,
                                String macroStart, String macroEnd, String selinuxCtx) {
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
                assertEquals(macroStart, rev.getDelimStart());
                assertEquals(macroEnd, rev.getDelimEnd());
            }
            assertEquals(cc,
                        rev.getConfigFile().getConfigChannel());
    }

    private void assertRev(ConfigRevision rev, String path, Server server,
                                                        boolean lookLocal) {
        List<String> paths = new ArrayList<String>(1);
        paths.add(path);
        assertEquals(rev, handler.lookupFileInfo(adminKey,
                                            server.getId().intValue(),
                                                paths, lookLocal).get(0));
    }

    public void testLookupFileInfoNoData() throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        List<String> paths = new LinkedList<String>();
        paths.add("/no/such/file.txt");

        // Should not throw a NullPointerException (anymore):
        handler.lookupFileInfo(adminKey, new Integer(srv1.getId().intValue()),
                paths, true);
    }

    private void assertRevNotChanged(ConfigRevision rev,
                                            Server server, boolean local) {
        assertRev(rev, rev.getConfigFile().getConfigFileName().getPath(),
                                                    server, local);
    }

    public void testAddPath() throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());

        String path = "/tmp/foo/path" + TestUtils.randomString();
        String contents = "HAHAHAHA";

        ConfigRevision rev = createRevision(path, contents,
                                    "group" + TestUtils.randomString(),
                                    "owner" + TestUtils.randomString(),
                                    "777",
                                    false, srv1, true, "unconfined_u:object_r:tmp_t");
        try {
            createRevision(path, contents,
                    "group" + TestUtils.randomString(),
                    "owner" + TestUtils.randomString(),
                    "744",
                    true, srv1, true, "unconfined_u:object_r:tmp_t");
            fail("Can't change the path from file to directory.");
        }
        catch (Exception e) {
            // Can;t change.. Won't allow...
            assertRevNotChanged(rev, srv1, true);
        }

        try {
            createRevision(path + TestUtils.randomString() + "/" , contents,
                    "group" + TestUtils.randomString(),
                    "owner" + TestUtils.randomString(),
                    "744",
                    true, srv1, false, "unconfined_u:object_r:tmp_t");
            fail("Validation error on the path.");
        }
        catch (Exception e) {
            // Can;t change.. Won't allow...
            assertRevNotChanged(rev, srv1, true);
        }
        createRevision(path + TestUtils.randomString(), "",
                "group" + TestUtils.randomString(),
                "owner" + TestUtils.randomString(),
                "744",
                true, srv1, false, "unconfined_u:object_r:tmp_t");
    }

    public void testListFiles() throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());


        for (int j = 0; j < 2; j++) {
            boolean local = j % 2 == 0;

            List<String> paths = new LinkedList<String>();
            Map<String, ConfigRevision> revisions = new HashMap<String, ConfigRevision>();
            setupPathsAndRevisions(srv1, paths, revisions, local);

            List<ConfigFileNameDto> files = handler.listFiles(adminKey,
                                                srv1.getId().intValue(), local);
            for (ConfigFileNameDto dto : files) {
                assertTrue(revisions.containsKey(dto.getPath()));
                ConfigRevision rev = revisions.get(dto.getPath());
                assertEquals(rev.getConfigFileType().getLabel(),
                                        dto.getConfigFileType());
                assertNotNull(dto.getLastModifiedDate());
            }
        }

    }


    /**
     * @param srv1 server
     * @param paths list holder of paths
     * @param revisions list holder of revisions
     * @param local is local revision or sandbox
     */
    private void setupPathsAndRevisions(Server srv1, List<String> paths,
            Map<String, ConfigRevision> revisions, boolean local) {
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
                                                isDir, srv1, local,
                                                "unconfined_u:object_r:tmp_t"));
        }
    }

    public void testRemovePaths() throws Exception {
        UserTestUtils.addProvisioning(admin.getOrg());
        Server srv1 = ServerFactoryTest.createTestServer(regular, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());

        for (int i = 0; i < 2; i++) {
            boolean isLocal = i % 2 == 0;
            List<String> paths = new LinkedList<String>();
            Map<String, ConfigRevision> revisions = new HashMap<String, ConfigRevision>();

            setupPathsAndRevisions(srv1, paths, revisions, isLocal);
            paths.remove(paths.size() - 1);
            handler.deleteFiles(adminKey, srv1.getId().intValue(), paths, isLocal);
            List<ConfigFileNameDto> files = handler.listFiles(adminKey,
                                            srv1.getId().intValue(), isLocal);
            assertEquals(1, files.size());
        }

    }
}
