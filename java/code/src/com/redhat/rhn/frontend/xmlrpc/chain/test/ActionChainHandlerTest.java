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
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.UpgradablePackageListItem;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
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
    private final ActionChainHandler ach = new ActionChainHandler();
    private final String chainName = "Quick Brown Fox";
    private final String scriptSample = "#!/bin/bash\nexit 0;";
    private Server server;
    private Package pkg;
    private Package channelPackage;

    /**
     * Flushes all chains (even if any).
     */
    private Boolean flushAllChains() {
        List<String> chains = new ArrayList<String>();
        for (Map<String, String> chain : this.ach.listChains()) {
            chains.add(chain.get("name"));
        }

        if (!chains.isEmpty()) {
            this.ach.removeChains(chains);
        }

        return this.ach.listChains().isEmpty();
    }


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

        // Clear all the chains
        this.flushAllChains();
    }


    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        ServerFactory.delete(this.server);
        this.flushAllChains();
    }


    /**
     * Test system reboot command schedule.
     *
     * @throws Exception
     */
    public void testAcAddSystemReboot() throws Exception {
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));

        for (Map<String, String> chain : this.ach.listChains()) {
            assertEquals(this.chainName, chain.get("name"));
            assertEquals("1", chain.get("entrycount"));
        }

        assertFalse(this.ach.listChains().isEmpty());
    }


    /**
     * Test package installation schedule.
     * @throws Exception
     */
    public void testAcPackageInstallation() throws Exception {
        List<Integer> packages = new ArrayList<Integer>();
        packages.add(this.channelPackage.getId().intValue());
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getId().intValue(),
                                                packages,
                                                this.chainName));
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
                                       this.chainName);
            fail("Expected exception: " +
                        InvalidParameterException.class.getCanonicalName());
        } catch (InvalidParameterException ex) {
            assertTrue(this.ach.listChains().isEmpty());
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

        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageRemoval(this.adminKey,
                                                this.server.getId().intValue(),
                                                rmPkgs,
                                                this.chainName));
    }

    /**
     * Test list chains.
     */
    public void testAcListChains() {
        String[] names = new String[]{TestUtils.randomString(),
                                      TestUtils.randomString(),
                                      TestUtils.randomString()};
        for (String cName : names) {
            assertEquals(BaseHandler.VALID,
                         this.ach.addSystemReboot(this.adminKey,
                                                  this.server.getId().intValue(),
                                                  cName));
        }

        List<Map<String, String>> chains = this.ach.listChains();
        assertEquals(3, chains.size());

        for (Map<String, String> chain : chains) {
            assertEquals("1", chain.get("entrycount"));
            boolean found = false;
            for (String cName : names) {
                if (cName.equals(chain.get("name"))) {
                    found = true;
                }
            }
            assertEquals(true, found);
        }
    }

    /**
     * Test chain actions content.
     */
    public void testAcChainActionsContent() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));

        for (Map<String, Object> action : this.ach.chainActions(this.chainName)) {
            assertEquals("System reboot", action.get("name"));
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
        assertEquals(true, this.ach.listChains().isEmpty());
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());

        List<String> chainsToRemove = new ArrayList<String>();
        chainsToRemove.add(this.chainName);
        this.ach.removeChains(chainsToRemove);
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test empty list does not remove any chains, schedule does not happening.
     */
    public void testAcRemoveChainsEmpty() {
        assertEquals(true, this.ach.listChains().isEmpty());
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
        List<String> chainsToRemove = new ArrayList<String>();
        assertEquals(BaseHandler.INVALID, this.ach.removeChains(chainsToRemove));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test actions removal.
     */
    public void testAcRemoveActions() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
        List<String> actionsToRemove = new ArrayList<String>();
        actionsToRemove.add((String) ((Map)
                this.ach.chainActions(this.chainName).get(0)).get("name"));
        assertEquals(BaseHandler.VALID,
                     this.ach.removeActions(this.chainName,
                                            actionsToRemove));
        assertEquals(true, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test empty list does not remove any actions, schedule does not happening.
     */
    public void testAcRemoveActionsEmpty() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addSystemReboot(this.adminKey,
                                              this.server.getId().intValue(),
                                              this.chainName));
        List<String> actionsToRemove = new ArrayList<String>();
        assertEquals(BaseHandler.INVALID,
                     this.ach.removeActions(this.chainName,
                                            actionsToRemove));
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test package upgrade.
     */
    public void testAcPackageUpgrade() throws Exception {
        Map info = ErrataCacheManagerTest
                .createServerNeededPackageCache(this.admin, ErrataFactory.ERRATA_TYPE_BUG);
        List<Integer> upgradePackages = new ArrayList<Integer>();
        Server system = (Server) info.get("server");
        /*
        for (UpgradablePackageListItem item :
                PackageManager.upgradable(system.getId(), null)) {
            upgradePackages.add(item.getId().intValue());
        }
        */
        upgradePackages.add(this.pkg.getId().intValue());

        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                system.getId().intValue(),
                                                upgradePackages,
                                                this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test package upgrade with an empty list.
     */
    public void testAcPackageUpgradeEmpty() {
        List<Integer> upgradePackages = new ArrayList<Integer>();
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                this.server.getId().intValue(),
                                                upgradePackages,
                                                "freaking fox"));
        assertEquals(true, this.ach.listChains().isEmpty());
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

        this.ach.addPackageVerify(this.adminKey,
                                  this.server.getId().intValue(),
                                  packages,
                                  chainName);
        //assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test package verification failure.
     */
    public void testAcPackageVerifyFailure() {
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageVerify(this.adminKey,
                                               this.server.getId().intValue(),
                                               new ArrayList<Integer>(),
                                               chainName));
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test schedule remote command.
     */
    public void testAcRemoteCommand() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getId().intValue(),
                                               this.chainName,
                                               "root", "root", 300,
                                               this.scriptSample));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test schedule empty script
     */
    public void testAcRemoteCommandEmpty() {
        assertEquals(BaseHandler.INVALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getId().intValue(),
                                               this.chainName,
                                               "root", "root", 300,
                                               ""));
        assertEquals(true, this.ach.listChains().isEmpty());
    }


    /**
     * Section for the convenient methods, where the same as above,
     * but done by package and host names, instead of the database IDs.
     */

    // Get installed named packages for the existing system
    private List<Map<String, String>> getSystemNamedPackages() {
            List<Map<String, String>> packages = new ArrayList<Map<String, String>>();
        for (Iterator it = PackageManager.systemPackageList(
                this.server.getId(), null).iterator(); it.hasNext();) {
            PackageListItem pkgItm = (PackageListItem) it.next();
            Map<String, String> pmap = new HashMap<String, String>();
            pmap.put("name", pkgItm.getName());
            pmap.put("version", pkgItm.getVersion());
            pmap.put("release", pkgItm.getRelease());
            packages.add(pmap);
        }

        return packages;
    }

    // Get named packages for the existing system
    private List<Map<String, String>> getSystemAvailableNamedPackages() {
        List<Map<String, String>> packages = new ArrayList<Map<String, String>>();
        List<PackageListItem> pkgs = PackageManager.systemAvailablePackages(
                this.server.getId(), null);
        for (PackageListItem pkgItem : pkgs) {
            Map<String, String> pmap = new HashMap<String, String>();
            pmap.put("name", pkgItem.getName());
            pmap.put("version", pkgItem.getVersion());
            pmap.put("release", pkgItem.getRelease());
            packages.add(pmap);
        }

        return packages;
    }

    // Get named packages that can be upgraded against particular system
    private List<Map<String, String>> getUpgradableNamedPackages(Server server) {
        List<Map<String, String>> upgradePackages = new ArrayList<Map<String, String>>();
        for (UpgradablePackageListItem item :
                PackageManager.upgradable(server.getId(), null)) {
            Map<String, String> pmap = new HashMap<String, String>();
            pmap.put("name", item.getName());
            pmap.put("version", item.getVersion());
            pmap.put("release", item.getRelease());
            upgradePackages.add(pmap);
        }

        return upgradePackages;
    }

    // Get named packages that can be removed from the particular system
    private List<Map<String, String>> getRemovableNamedPackages(Server system) {
        List<Map<String, String>> rmPkgs = new ArrayList<Map<String, String>>();
        List<Map> pkgs = SystemManager.installedPackages(system.getId(), true);
        for (int i = 0; i < pkgs.size(); i++) {
            Map<String, String> pkMap = new HashMap<String, String>();
            pkMap.put("name", (String) pkgs.get(i).get("name"));
            pkMap.put("version", (String) pkgs.get(i).get("version"));
            rmPkgs.add(pkMap);
        }

        return rmPkgs;
    }

    // Make upgradable server with an IP (of current system)
    private Server makeUpgradableServer() throws Exception {
        Server system = (Server) ActionChainHandlerTest.reload(
                (Server) ErrataCacheManagerTest.createServerNeededPackageCache(
                        this.admin, ErrataFactory.ERRATA_TYPE_BUG).get("server"));

        Network net = new Network();
        net.setIpaddr(InetAddress.getLocalHost().getHostAddress());
        system.addNetwork(net);
        ServerFactory.save(system);

        return (Server) ActionChainHandlerTest.reload(system);
    }

    /**
     * Test package installation success.
     */
    public void testAcCvPackageInstallByNameAndIP() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getName(),
                                                this.server.getIpAddress(),
                                                this.getSystemAvailableNamedPackages(),
                                                this.chainName));
    }

    public void testAcCvPackageInstallByName() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getName(),
                                                "",
                                                this.getSystemAvailableNamedPackages(),
                                                this.chainName));
    }

    public void testAcCvPackageInstallByIP() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                "",
                                                this.server.getIpAddress(),
                                                this.getSystemAvailableNamedPackages(),
                                                this.chainName));
    }

    /**
     * Test package installation failure.
     */
    public void testAcCvPackageInstallFailure() {
        List<Map<String, String>> packages = new ArrayList<Map<String, String>>();
        // No packages
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getName(),
                                                this.server.getIpAddress(),
                                                packages,
                                                this.chainName));

        Map<String, String> pmap = new HashMap<String, String>();
        pmap.put("name", TestUtils.randomString());
        pmap.put("version", TestUtils.randomString());
        pmap.put("release", TestUtils.randomString());
        packages.add(pmap);

        // Unknown packages
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getName(),
                                                this.server.getIpAddress(),
                                                packages,
                                                this.chainName));
        System.err.println("Chain: " + this.ach.listChains());
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test package removal success.
     */
    public void testAcCvPackageRemove() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageRemoval(this.adminKey,
                                                this.server.getName(),
                                                this.server.getIpAddress(),
                                                this.getRemovableNamedPackages(this.server),
                                                this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test package removal failure because of wrong hostname.
     */
    public void testAcCvPackageRemoveHostnameFailure() {
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageRemoval(this.adminKey,
                                                TestUtils.randomString(),
                                                this.server.getIpAddress(),
                                                this.getRemovableNamedPackages(this.server),
                                                this.chainName));
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test package removal failure because of wrong packages
     */
    public void testAcCvPackageRemovePkgNameFailure() {
        List<Map<String, String>> packages = new ArrayList<Map<String, String>>();
        Map<String, String> pmap = new HashMap<String, String>();
        pmap.put("name", TestUtils.randomString());
        pmap.put("version", TestUtils.randomString());
        pmap.put("release", TestUtils.randomString());
        packages.add(pmap);

        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageRemoval(this.adminKey,
                                                TestUtils.randomString(),
                                                this.server.getIpAddress(),
                                                packages,
                                                this.chainName));
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test named package upgrade.
     * @throws java.lang.Exception
     */
    public void testAcCvPackageUpgrade() throws Exception {
        Server system = this.makeUpgradableServer();
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                system.getName(),
                                                system.getIpAddress(),
                                                this.getUpgradableNamedPackages(system),
                                                this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test named package upgrade by hostname.
     * @throws Exception
     */
    public void testAcCvPackageUpgradeByHost() throws Exception {
        Server system = this.makeUpgradableServer();
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                system.getName(),
                                                "",
                                                this.getUpgradableNamedPackages(system),
                                                this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test named package upgrade by the host IP address.
     * @throws Exception
     */
    public void testAcCvPackageUpgradeByIP() throws Exception {
        Server system = this.makeUpgradableServer();
        assertEquals(BaseHandler.VALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                "",
                                                system.getIpAddress(),
                                                this.getUpgradableNamedPackages(system),
                                                this.chainName));
        assertEquals(false, this.ach.listChains().isEmpty());
        assertEquals(false, this.ach.chainActions(this.chainName).isEmpty());
    }

    /**
     * Test package upgrade failure.
     * @throws java.lang.Exception
     */
    public void testAcCvPackageUpgradeFailure() throws Exception {
        Map info = ErrataCacheManagerTest
                .createServerNeededPackageCache(this.admin, ErrataFactory.ERRATA_TYPE_BUG);
        List<Map<String, String>> upgradePackages = new ArrayList<Map<String, String>>();
        Server system = (Server) info.get("server");

        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageUpgrade(this.adminKey,
                                                system.getName(),
                                                "",
                                                upgradePackages,
                                                this.chainName));
        //assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test package verification by the host name/IP.
     */
    public void testAcCvPackageVerify() {
        this.ach.addPackageVerify(this.adminKey,
                                  this.server.getHostname(),
                                  this.server.getIpAddress(),
                                  this.getSystemNamedPackages(),
                                  chainName);
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test package verification failure.
     */
    public void testAcCvPackageVerifyFailure() {
        this.ach.addPackageVerify(this.adminKey,
                                  this.server.getHostname(),
                                  this.server.getIpAddress(),
                                  new ArrayList<Map<String, String>>(),
                                  chainName);
        assertEquals(true, this.ach.listChains().isEmpty());
    }

    /**
     * Test remote command by both, server name and IP address.
     */
    public void testAcCvRemoteCommand() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getName(),
                                               this.server.getIpAddress(),
                                               this.chainName,
                                               "root", "root", 300,
                                               this.scriptSample));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Scheduling the remote command by the hostname of the target server.
     */
    public void testAcCvRemoteCommandByName() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getName(),
                                               "",
                                               this.chainName,
                                               "root", "root", 300,
                                               this.scriptSample));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Scheduling the remote command by the IP address of the target server.
     */
    public void testAcCvRemoteCommandByIP() {
        assertEquals(BaseHandler.VALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               "",
                                               this.server.getIpAddress(),
                                               this.chainName,
                                               "root", "root", 300,
                                               this.scriptSample));
        assertEquals(false, this.ach.listChains().isEmpty());
    }

    /**
     * Test remote command failure (no script).
     */
    public void testAcCvRemoteCommandFailure() {
        assertEquals(BaseHandler.INVALID,
                     this.ach.addRemoteCommand(this.adminKey,
                                               this.server.getName(),
                                               this.server.getIpAddress(),
                                               this.chainName,
                                               "root", "root", 300,
                                               ""));
        assertEquals(true, this.ach.listChains().isEmpty());
    }
}
