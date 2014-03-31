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
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Network;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.server.Capability;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.chain.ActionChainHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.TestUtils;
import java.net.InetAddress;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
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
    private Server server;
    private Package pkg;

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
        this.server = ServerFactoryTest.createTestServer(this.admin, true);

        // Network
        Network net = new Network();
        net.setHostname(InetAddress.getLocalHost().getHostName());
        net.setIpaddr(InetAddress.getLocalHost().getHostAddress());
        this.server.addNetwork(net);

        // Run scripts capability
        Set<Capability> caps = new HashSet<Capability>();
        Capability c = new Capability();
        c.setName("script.run");
        caps.add(c);
        this.server.setCapabilities(caps);

        // Channels
        this.pkg = PackageTest.createTestPackage(this.admin.getOrg());
        Channel channel = ChannelFactoryTest.createBaseChannel(this.admin);
        channel.addPackage(this.pkg);
        // Add package, available to the installation
        channel.addPackage(PackageTest.createTestPackage(this.admin.getOrg()));
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
        List<PackageListItem> pkgs = PackageManager.systemAvailablePackages(
                this.server.getId(), null);
        for (PackageListItem pkgItem : pkgs) {
            packages.add(pkgItem.getId().intValue());
        }

        packages.add(this.pkg.getId().intValue());
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
        assertEquals(BaseHandler.INVALID,
                     this.ach.addPackageInstall(this.adminKey,
                                                this.server.getId().intValue(),
                                                packages,
                                                this.chainName));
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
}
