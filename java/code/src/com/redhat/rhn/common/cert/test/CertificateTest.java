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

import com.redhat.rhn.common.cert.Certificate;
import com.redhat.rhn.common.cert.CertificateFactory;
import com.redhat.rhn.common.cert.PublicKeyRing;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.jdom.JDOMException;

import java.io.IOException;
import java.net.URL;

public class CertificateTest extends RhnBaseTestCase {

    public CertificateTest(String name) {
        super(name);
    }
    
    public void testParseGoodCertificate() throws Exception {
        Certificate cert = readCertificate();
        assertEquals("RHN-SATELLITE-001", cert.getProduct());
        assertEquals("Mihai Ibanescu", cert.getOwner());
        assertEquals("2006-06-07 00:00:00", cert.getIssued());
        assertEquals("2007-06-07 00:00:00", cert.getExpires());
        assertEquals("12345", cert.getSlots());
        assertEquals("1000", cert.getProvisioningSlots());
        assertEquals("5000", cert.getMonitoringSlots());
        assertEquals("4.1", cert.getSatelliteVersion());
        assertEquals("2", cert.getGeneration());
        assertEquals(14, cert.getChannelFamilies().size());
        assertEquals("1075", cert.getChannelFamily("rhel-ws-extras").getQuantity());
        assertEquals("25", cert.getChannelFamily("rhn-proxy").getQuantity());
        String signature = TestData.readSignature();
        assertEquals(signature, cert.getSignature());
    }
    
    public void testCertificateAsChecksumString() 
        throws JDOMException, IOException, Exception {
        Certificate cert = readCertificate();
        String expected = TestData.readMessage();
        assertEquals(expected, cert.asChecksumString());
    }
    
    public void testCertNotExpired() throws JDOMException, IOException, Exception {
        Certificate cert = this.readCertificate("shughes-test.cert");
        assertFalse(cert.isExpired());
    }

    public void testCertificateVerification() throws Exception {
        PublicKeyRing keyRing = TestData.readDefaultKeyRing();
        Certificate cert = readCertificate();
        assertTrue(cert.verifySignature(keyRing));
    }
    
    public void testVirtCertificateVerification() throws Exception {
        PublicKeyRing keyRing = TestData.readDefaultKeyRing();
        Certificate cert = readCertificate("shughes-virt-test.cert");
        assertTrue(cert.verifySignature(keyRing));
    }
    
    public void xxxxNewCertificateVerification() throws Exception {
        PublicKeyRing keyRing = TestData.readDefaultKeyRing();
        Certificate cert = readCertificate2();
        assertTrue(cert.verifySignature(keyRing));
    }
    
    public void testToString() throws Exception {
        Certificate cert = readCertificate();
        String expected = TestData.readCert();
        assertEquals(expected, cert.asXmlString());
    }
    
    private Certificate readCertificate() throws Exception, JDOMException, IOException {
        return this.readCertificate("misa.cert");
    }

    private Certificate readCertificate(String certName) 
            throws Exception, JDOMException, IOException {
        URL url = TestUtils.findTestData(certName);
        Certificate cert = CertificateFactory.read(url);
        return cert;
    }

    // test to figure out why sigs are failing in bouncy castle
    private Certificate readCertificate2() throws Exception, JDOMException, IOException {
        URL url = TestUtils.findTestData("shughes-test.cert.bad");
        Certificate cert = CertificateFactory.read(url);
        return cert;
    }


}
