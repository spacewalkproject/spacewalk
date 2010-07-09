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

package com.redhat.rhn.frontend.xmlrpc.kickstart.profile.keys.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.keys.KeysHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import java.util.List;

/**
 *  Test cases for the KeysHandler.
 */
public class KeysHandlerTest extends BaseHandlerTestCase {

    private KeysHandler handler = new KeysHandler();
    private ActivationKeyManager manager = ActivationKeyManager.getInstance();

    public void testGetActivationKeys() throws Exception {

        // setup test ...
        ActivationKey activationKey1 = manager.createNewActivationKey(admin, "Test");
        ActivationKey activationKey2 = manager.createNewActivationKey(admin, "Test");
        ActivationKey activationKey3 = manager.createNewActivationKey(admin, "Test");

        KickstartData ks  = KickstartDataTest.createKickstartWithProfile(admin);
        ks.getDefaultRegTokens().add(activationKey1.getToken());
        ks.getDefaultRegTokens().add(activationKey2.getToken());
        KickstartFactory.saveKickstartData(ks);

        // execute api under test
        List<ActivationKey> keys = handler.getActivationKeys(adminKey, ks.getLabel());

        // verify results ...
        assertEquals(keys.size(), 2);

        boolean found1 = false, found2 = false, found3 = false;
        for (ActivationKey key : keys) {
            if (key.getId() == activationKey1.getId()) {
                found1 = true;
            }

            if (key.getId() == activationKey2.getId()) {
                found2 = true;
            }

            if (key.getId() == activationKey3.getId()) {
                found3 = true;
            }
        }
        assertTrue(found1);
        assertTrue(found2);
        assertFalse(found3);
    }

    public void testAddActivationKey() throws Exception {

        // setup test ...
        ActivationKey activationKey1 = manager.createNewActivationKey(admin, "Test");
        ActivationKey activationKey2 = manager.createNewActivationKey(admin, "Test");

        KickstartData ks  = KickstartDataTest.createKickstartWithProfile(admin);
        List<ActivationKey> keys = handler.getActivationKeys(adminKey, ks.getLabel());
        KickstartFactory.saveKickstartData(ks);
        int keySizeInitial = keys.size();

        // execute api under test
        handler.addActivationKey(adminKey, ks.getLabel(), activationKey1.getKey());
        handler.addActivationKey(adminKey, ks.getLabel(), activationKey2.getKey());

        // verify results ...
        keys = handler.getActivationKeys(adminKey, ks.getLabel());

        assertEquals(keySizeInitial, 0);
        assertEquals(keys.size(), 2);

        boolean found1 = false, found2 = false;
        for (ActivationKey key : keys) {
            if (key.getId() == activationKey1.getId()) {
                found1 = true;
            }

            if (key.getId() == activationKey2.getId()) {
                found2 = true;
            }
        }
        assertTrue(found1);
        assertTrue(found2);
    }

    public void testRemoveActivationKey() throws Exception {

        // setup test ...
        ActivationKey activationKey1 = manager.createNewActivationKey(admin, "Test");
        ActivationKey activationKey2 = manager.createNewActivationKey(admin, "Test");

        KickstartData ks  = KickstartDataTest.createKickstartWithProfile(admin);
        ks.getDefaultRegTokens().add(activationKey1.getToken());
        ks.getDefaultRegTokens().add(activationKey2.getToken());
        KickstartFactory.saveKickstartData(ks);
        int keySizeInitial = ks.getDefaultRegTokens().size();

        // execute api under test
        handler.removeActivationKey(adminKey, ks.getLabel(), activationKey1.getKey());

        // verify results ...
        List<ActivationKey> keys = handler.getActivationKeys(adminKey, ks.getLabel());

        assertEquals(keySizeInitial, 2);
        assertEquals(keys.size(), 1);

        boolean found1 = false, found2 = false;
        for (ActivationKey key : keys) {
            if (key.getId() == activationKey1.getId()) {
                found1 = true;
            }

            if (key.getId() == activationKey2.getId()) {
                found2 = true;
            }
        }
        assertFalse(found1);
        assertTrue(found2);
    }

}
