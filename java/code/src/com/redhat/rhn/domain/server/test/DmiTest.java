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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.server.Dmi;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

/**
 * DeviceTest
 * @version $Rev$
 */
public class DmiTest extends RhnBaseTestCase {
    
    public static final String VENDOR = "ZEUS computers";
    public static final String SYSTEM = "1234UKX";
    public static final String PRODUCT = "1234UKX";
    public static final String BIOS_VENDOR = "IBM";
    public static final String BIOS_VERSION = "PDKT28AUS";
    public static final String BIOS_RELEASE = "10/21/1999";
    public static final String ASSET = "(board: CNR780A1K11) (system: 23N7011)";
    public static final String BOARD = "MSI";
    
    public void testServerDmi() throws Exception {
        Dmi dmi = createTestDmi();
        
        Map params = new HashMap();
        params.put("vendor", VENDOR);
        params.put("system", SYSTEM);
        params.put("product", PRODUCT);
        params.put("biosvendor", BIOS_VENDOR);
        params.put("biosversion", BIOS_VERSION);
        params.put("biosrelease", BIOS_RELEASE);
        params.put("asset", ASSET);
        params.put("board", BOARD);
        verifyInDb(dmi.getId(),  params);
        assertEquals(1, TestUtils.removeObject(dmi));
        // can't seem to be able to delete a server, would be nice
        // to be able to clean up after ourselves.
        //assertEquals(1, TestUtils.removeObject(server));
    }
    
  
    private void verifyInDb(Long id, Map params) throws Exception {
        // Now lets manually test to see if the user got updated
        Session session = null;
        Connection c = null;
        ResultSet rs = null;
        PreparedStatement ps = null;
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            assertNotNull(c);
            ps = c.prepareStatement(
                "SELECT * FROM RHNSERVERDMI " +
                "  WHERE ID = " + id);
            rs = ps.executeQuery();
            rs.next();

            assertEquals(id.longValue(), rs.getLong("ID"));
            assertEquals(params.get("vendor"), rs.getString("VENDOR"));
            assertEquals(params.get("system"), rs.getString("SYSTEM"));
            assertEquals(params.get("product"), rs.getString("PRODUCT"));
            assertEquals(params.get("biosvendor"), rs.getString("BIOS_VENDOR"));
            assertEquals(params.get("biosversion"), rs.getString("BIOS_VERSION"));
            assertEquals(params.get("biosrelease"), rs.getString("BIOS_RELEASE"));
            assertEquals(params.get("asset"), rs.getString("ASSET"));
            assertEquals(params.get("board"), rs.getString("BOARD"));
        }
        finally {
            rs.close();
            ps.close();
        }
    }
    
    /**
     * Helper method to create a test Dmi object
     * @return Returns a test Dmi object
     * @throws Exception
     */
    public static Dmi createTestDmi() throws Exception {
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(u);
        assertNotNull(server);
        assertNotNull(server.getId());

        Dmi dmi = new Dmi();
        dmi.setServer(server);
        dmi.setVendor(VENDOR);
        dmi.setSystem(SYSTEM);
        dmi.setProduct(PRODUCT);
        dmi.setBios(BIOS_VENDOR, BIOS_VERSION, BIOS_RELEASE);
        dmi.setAsset(ASSET);
        dmi.setBoard(BOARD);
        
        assertNull(dmi.getId());
        TestUtils.saveAndFlush(dmi);
        assertNotNull(dmi.getId());
        
        return dmi;
    }
    

}
