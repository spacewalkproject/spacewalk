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
import com.redhat.rhn.testing.TestUtils;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyException;

/**
 * Helper for the tests.
 * 
 * @version $Rev$
 */
class TestData {

    private TestData() { }

    public static PublicKeyRing readDefaultKeyRing() 
        throws ClassNotFoundException, KeyException, IOException {
        InputStream keyringStream =
            TestUtils.findTestData("webapp-keyring.gpg").openStream();
        return new PublicKeyRing(keyringStream);
    }

    public static String readSignature() throws IOException, ClassNotFoundException {
        return TestUtils.readAll(TestUtils.findTestData("signature.txt"));
    }

    public static String readMessage() throws IOException, ClassNotFoundException {
        return TestUtils.readAll(TestUtils.findTestData("misa-checksum.txt"));
    }
    
    public static String readCert() throws IOException, ClassNotFoundException {
        return TestUtils.readAll(TestUtils.findTestData("misa.cert"));
    }
    
    

}
