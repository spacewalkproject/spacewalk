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
import com.redhat.rhn.domain.server.Device;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * DeviceTest
 * @version $Rev$
 */
public class DeviceTest extends RhnBaseTestCase {

    public static final String DESCRIPTION = "Test Device";
    public static final String DEVICE = "device";
    public static final String PROP_ONE = "Zeus Vendor";
    public static final String PROP_TWO = "prop2";
    public static final String PROP_THREE = "prop3";
    public static final String PROP_FOUR = "prop4";
    public static final String DRIVER = "Test Driver";

    public void testDevice() throws Exception {
        Device hd = createTestDevice();

        assertNotNull(hd);

        TestUtils.saveAndFlush(hd);
        verifyInDb(hd.getId(),  "Zeus Vendor");
        assertEquals(1, TestUtils.removeObject(hd));
    }

    private void verifyInDb(Long id, String value) throws Exception {
        // Now lets manually test to see if the user got updated
        Session session = null;
        Connection c = null;
        ResultSet rs = null;
        PreparedStatement ps = null;
        String rawValue = null;
        try {
            session = HibernateFactory.getSession();
            c = session.connection();
            assertNotNull(c);
            ps = c.prepareStatement(
                "SELECT PROP1 FROM RHNDEVICE " +
                "  WHERE ID = " + id);
            rs = ps.executeQuery();
            rs.next();
            rawValue = rs.getString("PROP1");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            rs.close();
            ps.close();
        }

        assertNotNull(rawValue);
        assertEquals(value, rawValue);
    }

    public static Device createTestDevice() throws Exception {
        Device hd = new Device();
        User u = UserTestUtils.findNewUser("testUser", "testOrg");
        Server server = ServerFactoryTest.createTestServer(u);

        hd.setServer(server);
        hd.setBus(Device.BUS_PCI);
        hd.setDescription(DESCRIPTION);
        hd.setDeviceClass(Device.CLASS_AUDIO);
        hd.setDetached(new Long(1));
        hd.setDevice(DEVICE);
        hd.setDriver(DRIVER);
        hd.setPcitype(new Long(10));
        hd.setProp1(PROP_ONE);
        hd.setProp2(PROP_TWO);
        hd.setProp3(PROP_THREE);
        hd.setProp4(PROP_FOUR);

        assertNull(hd.getId());
        TestUtils.saveAndFlush(hd);
        assertNotNull(hd.getId());

        return hd;

    }
}
