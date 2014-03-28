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

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.chain.ActionChainHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 *
 * @author bo
 */
public class ActionChainHandlerTest extends BaseHandlerTestCase {
    private final ActionChainHandler ach = new ActionChainHandler();
    private final String chainName = "Quick Brown Fox";
    private Server server;

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
        this.server = ServerFactoryTest.createTestServer(this.admin);
        assertTrue(this.flushAllChains());
    }


    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        ServerFactory.delete(this.server);
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
        assertTrue(this.flushAllChains());
    }


    /**
     * Test package installation schedule.
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
        assertTrue(this.flushAllChains());
    }
}
