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
package com.redhat.rhn.frontend.xmlrpc.kickstart.keys.test;

import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.CryptoKeyDto;
import com.redhat.rhn.frontend.xmlrpc.kickstart.keys.CryptoKeysHandler;
import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;
import com.redhat.rhn.frontend.xmlrpc.test.XmlRpcTestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.lang.RandomStringUtils;

import java.util.List;

/**
 * Test cases for the {@link CryptoKeysHandler}.
 *
 * @version $Revision$
 */
public class CryptoKeysHandlerTest extends BaseHandlerTestCase {

    public void testListAllKeys() throws Exception {
        // Setup
        User otherOrg = UserTestUtils.findNewUser();
        CryptoKey key = CryptoTest.createTestKey(otherOrg.getOrg());
        KickstartFactory.saveCryptoKey(key);
        flushAndEvict(key);

        // Test
        CryptoKeysHandler handler = new CryptoKeysHandler();

        List allKeys = handler.listAllKeys(
                XmlRpcTestUtils.getSessionKey(otherOrg));

        // Verify
        assertNotNull(allKeys);
        assertEquals(allKeys.size(), 1);

        CryptoKeyDto dto = (CryptoKeyDto)allKeys.get(0);
        assertEquals(key.getDescription(), dto.getDescription());
        assertEquals(key.getOrg().getId(), dto.getOrgId());
    }

    public void testCreate() throws Exception {
        // Setup
        String description = "CryptoKeysHandler.testCreate-Description";
        String content = MD5Crypt.md5Hex(RandomStringUtils.random(28));

        // Test
        CryptoKeysHandler handler = new CryptoKeysHandler();
        handler.create(regularKey, description, "GPG", content);

        // Verify
        CryptoKey cryptoKey =
            KickstartFactory.lookupCryptoKey(description, regular.getOrg());

        assertNotNull(cryptoKey);
        assertEquals(cryptoKey.getDescription(), description);
        assertEquals(cryptoKey.getCryptoKeyType().getLabel(), "GPG");
        assertEquals(cryptoKey.getKeyString(), content);
    }

    public void testDelete() throws Exception {
        // Setup
        CryptoKey key = CryptoTest.createTestKey(regular.getOrg());
        KickstartFactory.saveCryptoKey(key);
        assertNotNull(KickstartFactory.lookupCryptoKeyById(key.getId(), key.getOrg()));
        flushAndEvict(key);

        // Test
        CryptoKeysHandler handler = new CryptoKeysHandler();
        handler.delete(regularKey, key.getDescription());

        // Verify
        CryptoKey deletedKey =
            KickstartFactory.lookupCryptoKeyById(key.getId(), key.getOrg());
        assertNull(deletedKey);
    }

    public void testGetDetails() throws Exception {
        // Setup
        CryptoKey key = CryptoTest.createTestKey(regular.getOrg());
        KickstartFactory.saveCryptoKey(key);
        assertNotNull(KickstartFactory.lookupCryptoKeyById(key.getId(), key.getOrg()));
        flushAndEvict(key);

        // Test
        CryptoKeysHandler handler = new CryptoKeysHandler();
        CryptoKey cryptoKey = handler.getDetails(regularKey, key.getDescription());

        // Verify
        assertNotNull(cryptoKey);
        assertEquals(cryptoKey.getDescription(), cryptoKey.getDescription());
        assertEquals(cryptoKey.getCryptoKeyType().getLabel(),
                     cryptoKey.getCryptoKeyType().getLabel());
        assertEquals(cryptoKey.getKeyString(), cryptoKey.getKeyString());
    }

}
