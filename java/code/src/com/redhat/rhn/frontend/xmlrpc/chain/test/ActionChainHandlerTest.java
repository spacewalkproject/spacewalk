/**
 * Copyright (c) 2014 SUSE LLC
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
/**
 * Copyright (c) 2014 Red Hat, Inc.
 */

package com.redhat.rhn.frontend.xmlrpc.chain.test;

import com.redhat.rhn.common.db.datasource.DataResult;
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
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionChainException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionException;
import com.redhat.rhn.frontend.xmlrpc.chain.ActionChainHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.errata.cache.test.ErrataCacheManagerTest;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.TestUtils;

import java.net.InetAddress;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Test cases for the Action Chain XML-RPC API
 */
public class ActionChainHandlerTest extends BaseHandlerTestCase {

    private ActionChainHandler ach;
    private static final String CHAIN_LABEL = "Quick Brown Fox";
    private static final String SCRIPT_SAMPLE = "#!/bin/bash\nexit 0;";
    private Server server;
    private Package pkg;
    private Package channelPackage;
    private ActionChain actionChain;
    private static final String UNAUTHORIZED_EXCEPTION_EXPECTED =
            "Expected an exception of type " +
                      InvalidSessionIdException.class.getCanonicalName();

    /**
     * {@inheritDoc}
     */
    @SuppressWarnings("deprecation")
    @Override
    public void setUp() throws Exception {
        super.setUp();

        this.server = ServerFactoryTest.createTestServer(this.admin, true);

        // Network
        Network net = new Network();
        net.setHostname(InetAddress.getLocalHost().getHostName());
        net.setIpaddr(InetAddress.getLocalHost().getHostAddress());
        this.server.addNetwork(net);

        // Add capabilities
        SystemManagerTest.giveCapability(this.server.getId(), "script.run", new Long(1));
        SystemManagerTest.giveCapability(this.server.getId(),
                                         SystemManager.CAP_CONFIGFILES_DEPLOY, new Long(2));

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
        actionChain = ActionChainFactory.createActionChain(CHAIN_LABEL, admin);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        ServerFactory.delete(this.server);
    }

    /**
     * Test action chain create.
     * @throws Exception if something bad happens
     */
    public void testAcCreateActionChain() throws Exception {
        String chainName = TestUtils.randomString();
        Integer chainId = this.ach.createChain(this.admin, chainName);
        ActionChain newActionChain = ActionChainFactory.getActionChain(admin, chainName);
        assertNotNull(newActionChain);
        assertEquals(newActionChain.getId().longValue(), chainId.longValue());
    }

    /**
     * Test creating an action chain failure on an empty chain name.
     * @throws Exception if something bad happens
     */
    public void testAcCreateActionChainFailureOnEmptyName() throws Exception {
        try {
            this.ach.createChain(this.admin, "");
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
            // expected
        }
    }

    /**
     * Test system reboot command schedule.
     * @throws Exception if something bad happens
     */
    public void testAcAddSystemReboot() throws Exception {
        assertEquals(true, this.ach.addSystemReboot(this.admin,
                                                    this.server.getId().intValue(),
                                                    CHAIN_LABEL) > 0);

        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_REBOOT,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }

    /**
     * Test package installation schedule.
     * @throws Exception if something bad happens
     */
    public void testAcPackageInstallation() throws Exception {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(this.channelPackage.getId().intValue());
        assertEquals(true,
                     this.ach.addPackageInstall(this.admin,
                                                this.server.getId().intValue(),
                                                packages,
                                                CHAIN_LABEL) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_UPDATE,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }

    /**
     * Test package installation schedule.
     * @throws Exception if something bad happens
     */
    public void testAcPackageInstallationFailed() throws Exception {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(0);
        try {
            this.ach.addPackageInstall(this.admin,
                                       this.server.getId().intValue(),
                                       packages,
                                       CHAIN_LABEL);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        }
        catch (InvalidPackageException ex) {
            assertTrue(actionChain.getEntries().isEmpty());
        }
    }

    /**
     * Test package removal.
     * @throws Exception if something bad happens
     */
    public void testAcPackageRemoval() throws Exception {
        List<Integer> packagesToRemove = new ArrayList<Integer>();
        packagesToRemove.add(this.pkg.getId().intValue());
        assertEquals(true, this.ach.addPackageRemoval(this.admin,
                                                      this.server.getId().intValue(),
                                                      packagesToRemove,
                                                      CHAIN_LABEL) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_REMOVE,
                     actionChain.getEntries().iterator().next()
                             .getAction().getActionType());
    }

    /**
     * Test package removal failure when empty list of packages is passed.
     * @throws Exception if something bad happens
     */
    public void testAcPackageRemovalFailureOnEmpty() throws Exception {
        try {
            assertEquals(true, this.ach.addPackageRemoval(
                    this.admin, this.server.getId().intValue(),
                    new ArrayList<Integer>(), CHAIN_LABEL) > 0);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test package removal failure when list of unknown packages is passed.
     * @throws Exception if something bad happens
     */
    public void testAcPackageRemovalFailureOnUnknownPackages() throws Exception {
        List<Integer> packagesToRemove = new ArrayList<Integer>();
        packagesToRemove.add(0);

        try {
            assertEquals(true, this.ach.addPackageRemoval(this.admin,
                                                          this.server.getId().intValue(),
                                                          packagesToRemove,
                                                          CHAIN_LABEL) > 0);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        }
        catch (InvalidPackageException ex) {
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

        int previousChains = ActionChainFactory.getActionChains(this.admin).size();
        for (String label : labels) {
            ActionChainFactory.createActionChain(label, admin);
        }

        List<Map<String, Object>> chains = this.ach.listChains(this.admin);
        assertEquals(labels.length, chains.size() - previousChains);

        for (String label : labels) {
            ActionChain chain = ActionChainFactory.getActionChain(this.admin, label);
            assertEquals(0, chain.getEntries().size());
        }
    }

    /**
     * Test chain actions content.
     */
    public void testAcChainActionsContent() {
        assertEquals(true, this.ach.addSystemReboot(this.admin,
                                                    this.server.getId().intValue(),
                                                    CHAIN_LABEL) > 0);

        for (Map<String, Object> action : this.ach.listChainActions(this.admin,
                                                                    CHAIN_LABEL)) {
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
    public void testAcRemoveChain() {
        int previousChainCount = this.ach.listChains(this.admin).size();
        this.ach.deleteChain(this.admin, actionChain.getLabel());
        assertEquals(1, previousChainCount - this.ach.listChains(this.admin).size());
    }

    /**
     * Test chains removal failure when empty chain is passed.
     */
    public void testAcRemoveChainsFailureOnEmpty() {
        int previousChainCount = this.ach.listChains(this.admin).size();
        try {
            this.ach.deleteChain(this.admin, "");
            fail("Expected exception: " +
                 NoSuchActionChainException.class.getCanonicalName());
        }
        catch (NoSuchActionChainException ex) {
            assertEquals(0, previousChainCount - this.ach.listChains(this.admin).size());
        }
    }

    /**
     * Test chains removal failure when unknown chain is passed.
     */
    public void testAcRemoveChainsFailureOnUnknown() {
        int previousChainCount = this.ach.listChains(this.admin).size();
        try {
            this.ach.deleteChain(this.admin, TestUtils.randomString());
            fail("Expected exception: " +
                 NoSuchActionChainException.class.getCanonicalName());
        }
        catch (NoSuchActionChainException ex) {
            assertEquals(0, previousChainCount - this.ach.listChains(this.admin).size());
        }
    }

    /**
     * Test actions removal.
     */
    public void testAcRemoveActions() {
        assertEquals(true, this.ach.addSystemReboot(this.admin,
                                                    this.server.getId().intValue(),
                                                    CHAIN_LABEL) > 0);
        assertEquals(false, this.ach.listChainActions(
                this.admin, CHAIN_LABEL).isEmpty());
        assertEquals(true, this.ach.removeAction(
                this.admin, CHAIN_LABEL,
                ((Long) ((Map) this.ach.listChainActions(this.admin, CHAIN_LABEL).get(0))
                .get("id")).intValue()) > 0);
        assertEquals(true, this.ach.listChainActions(this.admin, CHAIN_LABEL).isEmpty());
    }

    /**
     * Test empty list does not remove any actions, schedule does not happening.
     */
    public void testAcRemoveActionsEmpty() {
        assertEquals(true,
                     this.ach.addSystemReboot(this.admin,
                                              this.server.getId().intValue(),
                                              CHAIN_LABEL) > 0);
        try {
            this.ach.removeAction(this.admin, CHAIN_LABEL, 0);
            fail("Expected exception: " +
                 NoSuchActionException.class.getCanonicalName());
        }
        catch (NoSuchActionException ex) {
            assertEquals(false,
                         this.ach.listChainActions(this.admin, CHAIN_LABEL).isEmpty());
        }
    }

    /**
     * Test removal of the actions on the unknown chain.
     */
    public void testAcRemoveActionsUnknownChain() {
        assertEquals(true, this.ach.addSystemReboot(this.admin,
                                                    this.server.getId().intValue(),
                                                    CHAIN_LABEL) > 0);
        try {
            this.ach.removeAction(this.admin, "", 0);
            fail("Expected exception: " +
                 NoSuchActionChainException.class.getCanonicalName());
        }
        catch (NoSuchActionChainException ex) {
            assertEquals(false, this.ach.listChainActions(
                    this.admin, CHAIN_LABEL).isEmpty());
        }
    }

    /**
     * Test unknown list of actions on certain chain does not remove anything
     * and schedule should not happen.
     */
    public void testAcRemoveActionsUnknownChainActions() {
        assertEquals(true, this.ach.addSystemReboot(this.admin,
                                                    this.server.getId().intValue(),
                                                    CHAIN_LABEL) > 0);
        try {
            this.ach.removeAction(this.admin, CHAIN_LABEL, 0);
            fail("Expected exception: " + NoSuchActionException.class.getCanonicalName());
        }
        catch (NoSuchActionException ex) {
            assertEquals(false, this.ach.listChainActions(
                    this.admin, CHAIN_LABEL).isEmpty());
        }
    }

    /**
     * Test package upgrade.
     * @throws Exception if something bad happens
     */
    @SuppressWarnings("unchecked")
    public void testAcPackageUpgrade() throws Exception {
        Map<String, Object> info =
                ErrataCacheManagerTest.createServerNeededPackageCache(this.admin,
                        ErrataFactory.ERRATA_TYPE_BUG);
        List<Integer> upgradePackages = new ArrayList<Integer>();
        Server system = (Server) info.get("server");
        upgradePackages.add(this.pkg.getId().intValue());

        assertEquals(true,
                     this.ach.addPackageUpgrade(this.admin,
                                                system.getId().intValue(),
                                                upgradePackages,
                                                CHAIN_LABEL) > 0);
        assertEquals(false,
                     this.ach.listChains(this.admin).isEmpty());
        assertEquals(false,
                     this.ach.listChainActions(this.admin, CHAIN_LABEL).isEmpty());

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
            this.ach.addPackageUpgrade(this.admin,
                                       this.server.getId().intValue(),
                                       upgradePackages,
                                       CHAIN_LABEL);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
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
            this.ach.addPackageUpgrade(this.admin,
                                       this.server.getId().intValue(),
                                       upgradePackages,
                                       CHAIN_LABEL);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        }
        catch (InvalidPackageException ex) {
            assertTrue(actionChain.getEntries().isEmpty());
        }
    }

    /**
     * Test package verification.
     */
    @SuppressWarnings("unchecked")
    public void testAcPackageVerify() {
        DataResult<PackageListItem> packageListItems =
                PackageManager.systemPackageList(this.server.getId(), null);
        List<Integer> packages = new ArrayList<Integer>();
        for (PackageListItem packageListItem : packageListItems) {
            packages.add(packageListItem.getPackageId().intValue());
        }

        assertEquals(true, this.ach.addPackageVerify(this.admin,
                                                     this.server.getId().intValue(),
                                                     packages,
                                                     CHAIN_LABEL) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_PACKAGES_VERIFY, actionChain.getEntries()
                .iterator().next().getAction().getActionType());
    }

    /**
     * Test package verification failure when empty list is passed.
     */
    public void testAcPackageVerifyFailureOnEmpty() {
        try {
            this.ach.addPackageVerify(this.admin,
                                      this.server.getId().intValue(),
                                      new ArrayList<Integer>(),
                                      CHAIN_LABEL);
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
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
            this.ach.addPackageVerify(this.admin,
                                      this.server.getId().intValue(),
                                      packages,
                                      CHAIN_LABEL);
            fail("Expected exception: " + InvalidPackageException.class.getCanonicalName());
        }
        catch (InvalidPackageException ex) {
            assertEquals(0, actionChain.getEntries().size());
        }
    }

    /**
     * Test schedule remote command.
     */
    public void testAcRemoteCommand() {
        assertEquals(true,
                     this.ach.addScriptRun(this.admin,
                                           this.server.getId().intValue(),
                                           CHAIN_LABEL,
                                           "root", "root", 300,
                                           ActionChainHandlerTest.SCRIPT_SAMPLE) > 0);
        assertEquals(1, actionChain.getEntries().size());
        assertEquals(ActionFactory.TYPE_SCRIPT_RUN, actionChain.getEntries()
                .iterator().next().getAction().getActionType());
    }

    /**
     * Test schedule on precise time.
     */
    public void testAcScheduleOnTime() {
        assertEquals(new Integer(1),
                     this.ach.scheduleChain(this.admin, CHAIN_LABEL, new Date()));
    }

    /**
     * Test schedule on precise time.
     */
    public void testAcScheduleOnTimeFailureNoChain() {
        try {
            this.ach.scheduleChain(this.admin, "", new Date());
            fail("Expected exception: " +
                 NoSuchActionChainException.class.getCanonicalName());
        }
        catch (NoSuchActionChainException ex) {
            //expected
        }
    }

    /**
     * Deploy configuration.
     */
    public void testAcDeployConfiguration() {
        List<Integer> revisions = new ArrayList<Integer>();
        revisions.add(ConfigTestUtils.createConfigRevision(
                this.admin.getOrg()).getId().intValue());

        assertEquals(new Integer(BaseHandler.VALID),
                     this.ach.addConfigurationDeployment(this.admin,
                                                         CHAIN_LABEL,
                                                         this.server.getId().intValue(),
                                                         revisions));
    }

    /**
     * Deploy configuration should fail if no chain label has been passed.
     */
    public void testAcDeployConfigurationFailureNoChain() {
        List<Integer> revisions = new ArrayList<Integer>();
        revisions.add(ConfigTestUtils.createConfigRevision(
                this.admin.getOrg()).getId().intValue());

        try {
            this.ach.addConfigurationDeployment(this.admin, "",
                                                this.server.getId().intValue(),
                                                revisions);
            fail("Expected exception: " +
                 NoSuchActionChainException.class.getCanonicalName());
        }
        catch (NoSuchActionChainException ex) {
            //expected
        }
    }

    /**
     * Rename an action chain.
     */
    public void testAcRenameActionChain() {
        assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        assertEquals(new Integer(1),
                     this.ach.renameChain(
                             this.admin, CHAIN_LABEL, TestUtils.randomString()));
        assertEquals(false, actionChain.getLabel().equals(CHAIN_LABEL));
    }

    /**
     * Rename an action chain should fail when renaming to the same label.
     */
    public void testAcRenameActionChainFailureOnSameLabel() {
        assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        try {
            assertEquals(new Integer(1),
                         this.ach.renameChain(this.admin, CHAIN_LABEL, CHAIN_LABEL));
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
            assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        }
    }

    /**
     * Rename an action chain should fail when previous label is missing.
     */
    public void testAcRenameActionChainFailureOnEmptyPreviousLabel() {
        assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        try {
            assertEquals(new Integer(1),
                         this.ach.renameChain(this.admin, "", CHAIN_LABEL));
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
            assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        }
    }

    /**
     * Rename an action chain should fail when new label is missing.
     */
    public void testAcRenameActionChainFailureOnEmptyNewLabel() {
        assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        try {
            assertEquals(new Integer(1),
                         this.ach.renameChain(this.admin, CHAIN_LABEL, ""));
            fail("Expected exception: " +
                 InvalidParameterException.class.getCanonicalName());
        }
        catch (InvalidParameterException ex) {
            assertEquals(true, actionChain.getLabel().equals(CHAIN_LABEL));
        }
    }
}
