/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.common.cert.test;

import com.redhat.rhn.common.cert.PublicKeyRing;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class PublicKeyRingTest extends RhnBaseTestCase {

    public PublicKeyRingTest(String name) {
        super(name);
    }

    public void testVerification() throws Exception {
        String signature = TestData.readSignature();
        String message = TestData.readMessage();
        PublicKeyRing keyRing = TestData.readDefaultKeyRing();
        assertTrue(keyRing.verifySignature(message, signature));
    }

    public void testTamperedVerification() throws Exception {
        String signature = TestData.readSignature();
        // Tamper with the message
        String message = TestData.readMessage() + "xxx";
        PublicKeyRing keyRing = TestData.readDefaultKeyRing();
        assertTrue(!keyRing.verifySignature(message, signature));
    }
}
