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
package com.redhat.rhn.common.client.test;

import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.common.client.ClientCertificateDigester;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.io.StringReader;

public class ClientCertificateDigesterTest extends RhnBaseTestCase {

    public void testBuildSystemId() throws Exception {
        ClientCertificate cert = ClientCertificateDigester.buildCertificate(
                    TestUtils.findTestData("systemid.xml"));

        assertNotNull("SystemId is null", cert);

        // hardcoded key from test system
        cert.validate("3050cf46ac0417297e2dd964fdaac1ae");
    }

    public void testBuildSystemIdStream() throws Exception {
        ClientCertificate cert = ClientCertificateDigester.buildCertificate(
                    TestUtils.findTestData("systemid.xml").openStream());

        assertNotNull("SystemId is null", cert);

        // hardcoded key from test system
        cert.validate("3050cf46ac0417297e2dd964fdaac1ae");
    }

    public void testBuildSystemIdReader() throws Exception {
        String data = TestUtils.readAll(TestUtils.findTestData("systemid.xml"));
        StringReader rdr = new StringReader(data);
        ClientCertificate cert =
               ClientCertificateDigester.buildCertificate(rdr);

        assertNotNull("SystemId is null", cert);

        // hardcoded key from test system
        cert.validate("3050cf46ac0417297e2dd964fdaac1ae");
    }

    public void testGetValueByName() throws Exception {
        ClientCertificate cert = ClientCertificateDigester.buildCertificate(
                TestUtils.findTestData("systemid.xml"));

        assertEquals("4AS", cert.getValueByName("os_release"));
        assertEquals("8c9a5c69ea45c9fc850058e9fd457e59",
                cert.getValueByName("checksum"));
        assertEquals("REAL", cert.getValueByName("type"));
        assertEquals("x86_64", cert.getValueByName("architecture"));
        assertEquals("ID-1005691306", cert.getValueByName("system_id"));
        assertEquals("Rat's Hat Linux", cert.getValueByName("operating_system"));
        assertEquals("firefox104", cert.getValueByName("profile_name"));
        assertEquals("jesusr_redhat", cert.getValueByName("username"));

        // test a field which has multiple values
        assertEquals("system_id", cert.getValueByName("fields"));

        // test null
        assertNull(cert.getValueByName(null));

        // test invalid name
        assertNull(cert.getValueByName("invalid name"));
    }

    public void testGetValuesByName() throws Exception {
        ClientCertificate cert = ClientCertificateDigester.buildCertificate(
                TestUtils.findTestData("systemid.xml"));

        assertEquals("4AS", cert.getValuesByName("os_release")[0]);
        assertEquals("8c9a5c69ea45c9fc850058e9fd457e59",
                cert.getValuesByName("checksum")[0]);
        assertEquals("REAL", cert.getValuesByName("type")[0]);
        assertEquals("x86_64", cert.getValuesByName("architecture")[0]);
        assertEquals("ID-1005691306", cert.getValuesByName("system_id")[0]);
        assertEquals("Rat's Hat Linux",
                cert.getValuesByName("operating_system")[0]);
        assertEquals("firefox104", cert.getValuesByName("profile_name")[0]);
        assertEquals("jesusr_redhat", cert.getValuesByName("username")[0]);

        // test fields
        String[] values = cert.getValuesByName("fields");
        assertNotNull(values);
        assertEquals(6, values.length);
        assertEquals("system_id", values[0]);
        assertEquals("os_release", values[1]);
        assertEquals("operating_system", values[2]);
        assertEquals("architecture", values[3]);
        assertEquals("username", values[4]);
        assertEquals("type", values[5]);

        // test null
        assertNull(cert.getValuesByName(null));

        // test invalid name
        assertNull(cert.getValuesByName("invalid name"));
    }
}
