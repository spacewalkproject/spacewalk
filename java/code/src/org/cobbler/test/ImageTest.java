/**
 * Copyright (c) 2013 SUSE LLC
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

package org.cobbler.test;

import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import org.cobbler.CobblerConnection;
import org.cobbler.Image;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Tests Image.
 */
public class ImageTest extends BaseTestCaseWithUser {

    /** Image name used by setUp(). */
    private static final String EXPECTED_NAME = "test";

    /** File name used by setUp(). */
    private static final String EXPECTED_FILE = "dummy.file";

    /** Image type used by setUp(). */
    private static final String EXPECTED_TYPE = Image.TYPE_ISO;

    /** The connection. */
    private CobblerConnection connection;

    /** The image. */
    private Image image;

    /**
     * Sets up a connection and image.
     * @throws Exception in case anything goes wrong
     */
    public void setUp() throws Exception {
        super.setUp();
        MockConnection.clear();
        connection = CobblerXMLRPCHelper.getConnection(user.getLogin());
        image = Image.create(connection, EXPECTED_NAME, EXPECTED_TYPE, EXPECTED_FILE);
        assertNotNull(image);
    }

    /**
     * Removes the image created by setUp().
     * @throws Exception in case anything goes wrong
     */
    public void tearDown() throws Exception {
        assertTrue(image.remove());
        super.tearDown();
    }

    /**
     * Test image creation.
     */
    public void testCreate() {
        assertEquals(EXPECTED_NAME, image.getName());
        assertEquals(EXPECTED_TYPE, image.getType());
        assertEquals(EXPECTED_FILE, image.getFile());
    }

    /**
     * Test lookup by name.
     */
    public void testLookupByName() {
        assertEquals(image, Image.lookupByName(connection, EXPECTED_NAME));
    }

    /**
     * Test lookup by id.
     */
    public void testLookupById() {
        assertEquals(image, Image.lookupById(connection, image.getId()));
    }

    /**
     * Test image list.
     */
    public void testList() {
        List<Image> result = Image.list(connection);
        assertEquals(1, result.size());
        assertContains(result, image);
    }

    /**
     * Test setter and getter for image type.
     */
    public void testSetGetType() {
        String expected = Image.TYPE_DIRECT;
        image.setType(expected);
        assertEquals(expected, image.getType());
        assertImageKeyEquals(expected, Image.TYPE);
    }

    /**
     * Test setter and getter for image file.
     */
    public void testSetGetFile() {
        String expected = TestUtils.randomString();
        image.setFile(expected);
        assertEquals(expected, image.getFile());
        assertImageKeyEquals(expected, Image.FILE);
    }

    /**
     * Check in MockConnection that the current image has a certain value
     * corresponding to a key.
     * @param expected the expected value for key
     * @param key the key
     */
    @SuppressWarnings("unchecked")
    private void assertImageKeyEquals(String expected, String key) {
        HashMap<String, Object> criteria = new HashMap<String, Object>();
        criteria.put("uid", image.getId());
        List<Map<String, Object>> result = (List<Map<String, Object>>) connection
            .invokeMethod("find_image", criteria);
        assertEquals(expected, result.get(0).get(key));
    }
}
