/**
 * Copyright (c) 2014 SUSE
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

package com.redhat.rhn.frontend.xmlrpc.chain.test;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionException;
import com.redhat.rhn.frontend.xmlrpc.chain.ActionChainHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.TestUtils;

import java.net.InetAddress;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 *
 * @author bo
 */
public class ActionChainHandlerTest extends BaseHandlerTestCase {
    private ActionChainHandler ach;
    private static final String CHAIN_NAME = "Quick Brown Fox";
    private static final String SCRIPT_SAMPLE = "#!/bin/bash\nexit 0;";
    private Server server;
    private Package pkg;
    private Package channelPackage;
    private User user;
    private ActionChain actionChain;

    @Override
    public void setUp() throws Exception {
        super.setUp();

        // Provisioning included
        this.server = ServerFactoryTest.createTestServer(
                this.admin, true, ServerConstants.getServerGroupTypeProvisioningEntitled());

        // Network
        Network net = new Network();
        net.setHostname(InetAddress.getLocalHost().getHostName());
        net.setIpaddr(InetAddress.getLocalHost().getHostAddress());
        this.server.addNetwork(net);

        // Run scripts capability
        SystemManagerTest.giveCapability(this.server.getId(), "script.run", new Long(1));

        // Channels
        this.pkg = PackageTest.createTestPackage(this.admin.getOrg());
        Channel channel = ChannelFactoryTest.createBaseChannel(this.admin);
        channel.addPackage(this.pkg);
        // Add package, available to the installation
        this.channelPackage = PackageTest.createTestPackage(this.admin.getOrg());
        channel.addPackage(this.channelPackage);
        this.server.addChannel(channel);

        // Install one package on the server
        InstalledPackage ipkg = new InstalledPackage();
        ipkg.setArch(this.pkg.getPackageArch());
        ipkg.setEvr(this.pkg.getPackageEvr());
        ipkg.setName(this.pkg.getPackageName());
        ipkg.setServer(this.server);
        Set<InstalledPackage> serverPkgs = new HashSet<InstalledPackage>();
        serverPkgs.add(ipkg);
        this.server.setPackages(serverPkgs);

        ServerFactory.save(this.server);
        this.server = (Server) ActionChainHandlerTest.reload(this.server);
        ach = new ActionChainHandler();
        actionChain = ActionChainFactory.createActionChain(CHAIN_NAME, admin);
    }


    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        ServerFactory.delete(this.server);
    }

    /**
     * Test action chain create.
     *
     * @throws java.lang.Exception
     */
    public void testAcCreateActionChain() throws Exception {
        String chainName = TestUtils.randomString();
        assertEquals(true, this.ach.createActionChain(this.adminKey, chainName) > 0);
        assertFalse(ActionChainFactory.getActionChain(chainName) == null);
    }

    /**
     * Test creating an action chain failure on wrong authentication token.
     *
     * @throws java.lang.Exception
     */
    public void testAcCreateActionChainFailureOnInvalidAuth() throws Exception {
        String chainName = TestUtils.randomString();
        try {
            this.ach.createActionChain("", chainName);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
        }
    }

    /**
     * Test creating an action chain failure on an empty chain name.
     *
     * @throws java.lang.Exception
     */
    public void testAcCreateActionChainFailureOnEmptyName() throws Exception {
        String chainName = TestUtils.randomString();
        try {
            this.ach.createActionChain(this.adminKey, "");
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
        }
    }

    /**
     * Test system reboot command schedule.
     *
     * @throws Exception
     */
    public void testAcAddSystemReboot() throws Exception {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);

        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_REBOOT,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }


    /**
     * Test package installation schedule.
     * @throws Exception
     */
    public void testAcPackageInstallation() throws Exception {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(this.channelPackage.getId().intValue());
        assertEquals(true,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getId().intValue(),
                                                packages,
                                                CHAIN_NAME) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_UPDATE,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }

    /**
     * Test package installation schedule.
     *
     * @throws Exception
     */
    public void testAcPackageInstallationFailed() throws Exception {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(0);
        try {
            this.ach.addPackageInstall(this.adminKey,
                                       this.server.getId().intValue(),
                                       packages,
                                       CHAIN_NAME);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertTrue(actionChain.getEntries().isEmpty());
        }
    }

    /**
     * Test package removal.
     *
     * @throws Exception
     */
    public void testAcPackageRemoval() throws Exception {
        List<Map<String, String>> rmPkgs = new ArrayList<Map<String, String>>();
        List<Map> pkgs = SystemManager.installedPackages(this.server.getId(), true);
        for (int i = 0; i < pkgs.size(); i++) {
            Map<String, String> pkMap = new HashMap<String, String>();
            pkMap.put("name", (String) pkgs.get(i).get("name"));
            pkMap.put("version", (String) pkgs.get(i).get("version"));
            rmPkgs.add(pkMap);
        }

        assertEquals(true, this.ach.addPackageRemoval(this.adminKey,
                                                      this.server.getId().intValue(),
                                                      rmPkgs,
                                                      CHAIN_NAME) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_REMOVE,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }

    /**
     * Test package removal failure when empty list of packages is passed.
     *
     * @throws Exception
     */
    public void testAcPackageRemovalFailureOnEmpty() throws Exception {
        try {
            assertEquals(true, this.ach.addPackageRemoval(
                    this.adminKey, this.server.getId().intValue(),
                    new ArrayList<Map<String, String>>(), CHAIN_NAME) > 0);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test package removal failure when list of unknown packages is passed.
     *
     * @throws Exception
     */
    public void testAcPackageRemovalFailureOnUnknownPackages() throws Exception {
        List<Map<String, String>> rmPkgs = new ArrayList<Map<String, String>>();
        Map<String, String> pkMap = new HashMap<String, String>();
        pkMap.put("name", TestUtils.randomString());
        pkMap.put("version", TestUtils.randomString());
        rmPkgs.add(pkMap);

        try {
            assertEquals(true, this.ach.addPackageRemoval(this.adminKey,
                                                          this.server.getId().intValue(),
                                                          rmPkgs,
                                                          CHAIN_NAME) > 0);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test list chains.
     */
    public void testAcListChains() {
        String[] labels = new String[]{
            TestUtils.randomString(),
            TestUtils.randomString(),
            TestUtils.randomString()
        };

        int previousChains = ActionChainFactory.getActionChains().size();
        for (String label : labels) {
            ActionChainFactory.createActionChain(label, admin);
        }

        List<Map<String, Object>> chains = this.ach.listChains();
        assertEquals(labels.length, chains.size() - previousChains);

        for (String label : labels) {
            ActionChain chain = ActionChainFactory.getActionChain(label);
            assertEquals(0, chain.getEntries().size());
        }
    }

    /**
     * Test chain actions content.
     */
    public void testAcChainActionsContent() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);

        for (Map<String, Object> action : this.ach.chainActions(CHAIN_NAME)) {
            assertEquals("System reboot", action.get("label"));
            assertEquals("System reboot", action.get("type"));
            assertEquals(DateFormat.getDateTimeInstance(DateFormat.SHORT,
                                                        DateFormat.SHORT)
                                 .format((Date) action.get("created")),
                         DateFormat.getDateTimeInstance(DateFormat.SHORT,
                                                        DateFormat.SHORT)
                                 .format((Date) action.get("earliest")));
        }
    }

    /**
     * Test chains removal.
     */
    public void testAcRemoveChains() {
        int previousChainCount = this.ach.listChains().size();

        List<String> chainsToRemove = new ArrayList<String>();
        chainsToRemove.add(actionChain.getLabel());
        this.ach.removeChains(this.adminKey, chainsToRemove);
        assertEquals(1, previousChainCount - this.ach.listChains().size());
    }

    /**
     * Test chains removal failure on unauthorized access.
     */
    public void testAcRemoveChainsFailureOnWrongUser() {
        int previousChainCount = this.ach.listChains().size();

        try {
            this.ach.removeChains("", new ArrayList<String>());
            fail("Expected exception: " +
                 InvalidSessionIdException.class.getCanonicalName());
        } catch (InvalidSessionIdException ex) {
            assertEquals(0, previousChainCount - this.ach.listChains().size());
        }
    }

    /**
     * Test chains removal failure when empty list is passed.
     */
    public void testAcRemoveChainsFailureOnEmpty() {
        int previousChainCount = this.ach.listChains().size();

        try {
            this.ach.removeChains(this.adminKey, new ArrayList<String>());
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
            assertEquals(0, previousChainCount - this.ach.listChains().size());
        }
    }

    /**
     * Test chains removal failure when unknown chain is passed.
     */
    public void testAcRemoveChainsFailureOnUnknown() {
        int previousChainCount = this.ach.listChains().size();
        List<String> chainsToRemove = new ArrayList<String>();
        chainsToRemove.add(TestUtils.randomString());

        try {
            this.ach.removeChains(this.adminKey, chainsToRemove);
            fail("Expected exception: " + NoSuchActionException.class.getCanonicalName());
        } catch (NoSuchActionException ex) {
            assertEquals(0, previousChainCount - this.ach.listChains().size());
        }
    }

    /**
     * Test actions removal.
     */
    public void testAcRemoveActions() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        List<String> actionsToRemove = new ArrayList<String>();
        actionsToRemove.add((String) ((Map)
            this.ach.chainActions(CHAIN_NAME).get(0)).get("label"));
        assertEquals(true, this.ach.removeActions(
                this.adminKey, CHAIN_NAME, actionsToRemove) > 0);
        assertEquals(true, this.ach.chainActions(CHAIN_NAME).isEmpty());
    }

    /**
     * Test empty list does not remove any actions, schedule does not happening.
     */
    public void testAcRemoveActionsEmpty() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        List<String> actionsToRemove = new ArrayList<String>();
        try {
            this.ach.removeActions(this.adminKey, CHAIN_NAME, actionsToRemove);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
            assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        }
    }

    /**
     * Test removing action with unauthorized access.
     */
    public void testAcRemoveActionsUnauthorizedEmptyToken() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        List<String> actionsToRemove = new ArrayList<String>();
        try {
            this.ach.removeActions("", CHAIN_NAME, actionsToRemove);
            fail("Expected exception: " +
                 InvalidSessionIdException.class.getCanonicalName());
        } catch (InvalidSessionIdException ex) {
            assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        }
    }

    /**
     * Test removing action with unauthorized access.
     */
    public void testAcRemoveActionsUnauthorizedUnknownToken() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        List<String> actionsToRemove = new ArrayList<String>();
        try {
            this.ach.removeActions(TestUtils.randomString(), CHAIN_NAME, actionsToRemove);
            fail("Expected exception: " +
                 InvalidSessionIdException.class.getCanonicalName());
        } catch (InvalidSessionIdException ex) {
            assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        }
    }

    /**
     * Test removal of the actions on the unknown chain.
     */
    public void testAcRemoveActionsUnknownChain() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        List<String> actionsToRemove = new ArrayList<String>();
        actionsToRemove.add(TestUtils.randomString());
        try {
            this.ach.removeActions(this.adminKey, "", actionsToRemove);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
            assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        }
    }

    /**
     * Test unknown list of actions on certain chain does not remove anything and
     * schedule should not happen.
     */
    public void testAcRemoveActionsUnknownChainActions() {
        assertEquals(true, this.ach.addSystemReboot(this.adminKey,
                                                    this.server.getId().intValue(),
                                                    CHAIN_NAME) > 0);
        List<String> actionsToRemove = new ArrayList<String>();
        actionsToRemove.add(TestUtils.randomString());
        try {
            this.ach.removeActions(this.adminKey, CHAIN_NAME, actionsToRemove);
            fail("Expected exception: " + NoSuchActionException.class.getCanonicalName());
        } catch (NoSuchActionException ex) {
            assertEquals(false, this.ach.chainActions(CHAIN_NAME).isEmpty());
        }
    }

    /**
     * Test package upgrade.
     * @throws java.lang.Exception
     */
    public void testAcPackageUpgrade() throws Exception {
        Map info = ErrataCacheManagerTest
                .createServerNeededPackageCache(this.admin, ErrataFactory.ERRATA_TYPE_BUG);
        List<Integer> upgradePackages = new ArrayList<Integer>();
        Server system = (Server) info.get("server");
        upgradePackages.add(this.pkg.getId().intValue());

        assertEquals(true,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                system.getId().intValue(),
                                                upgradePackages,
                                                CHAIN_NAME) > 0);
        assertEquals(false,
                     this.ach.listChains().isEmpty());
        assertEquals(false,
                     this.ach.chainActions(CHAIN_NAME).isEmpty());

        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_UPDATE, actionChain.getEntries()
                .iterator().next().getAction().getActionType());
    }

    /**
     * Test package upgrade with an empty list.
     */
    public void testAcPackageUpgradeOnEmpty() {
        List<Integer> upgradePackages = new ArrayList<Integer>();
        try {
            this.ach.addPackageUpgrade(this.adminKey,
                                       this.server.getId().intValue(),
                                       upgradePackages,
                                       CHAIN_NAME);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test package upgrade with an empty list.
     */
    public void testAcPackageUpgradeOnUnknown() {
        List<Integer> upgradePackages = new ArrayList<Integer>();
        upgradePackages.add(0);
        try {
            this.ach.addPackageUpgrade(this.adminKey,
                                       this.server.getId().intValue(),
                                       upgradePackages,
                                       CHAIN_NAME);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertTrue(actionChain.getEntries().isEmpty());
        }
    }

    /**
     * Test package verification.
     */
    public void testAcPackageVerify() {
        List<Integer> packages = new ArrayList<Integer>();
        for (Iterator it = PackageManager.systemPackageList(
                this.server.getId(), null).iterator(); it.hasNext();) {
            PackageListItem pli = (PackageListItem) it.next();
            packages.add(pli.getPackageId().intValue());
        }

        assertEquals(true, this.ach.addPackageVerify(this.adminKey,
                                                     this.server.getId().intValue(),
                                                     packages,
                                                     CHAIN_NAME) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_VERIFY, actionChain.getEntries()
                .iterator().next().getAction().getActionType());
    }

    /**
     * Test package verification failure when empty list is passed.
     */
    public void testAcPackageVerifyFailureOnEmpty() {
        try {
            this.ach.addPackageVerify(this.adminKey,
                                      this.server.getId().intValue(),
                                      new ArrayList<Integer>(),
                                      CHAIN_NAME);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test package verification failure when unknown package is verified.
     */
    public void testAcPackageVerifyFailureOnUnknown() {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(0);
        try {
            this.ach.addPackageVerify(this.adminKey,
                                      this.server.getId().intValue(),
                                      packages,
                                      CHAIN_NAME);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        } catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test schedule remote command.
     */
    public void testAcRemoteCommand() {
        assertEquals(true,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getId().intValue(),
                                               CHAIN_NAME,
                                               "root", "root", 300,
                                               ActionChainHandlerTest.SCRIPT_SAMPLE) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_SCRIPT_RUN, actionChain.getEntries()
                .iterator().next().getAction().getActionType());
    }

    /**
     * Test schedule empty script
     */
    public void testAcRemoteCommandOnEmpty() {
        try {
            this.ach.addRemoteCommand(this.adminKey,
                                      this.server.getId().intValue(),
                                      CHAIN_NAME,
                                      "root", "root", 300,
                                      "");
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }
}
