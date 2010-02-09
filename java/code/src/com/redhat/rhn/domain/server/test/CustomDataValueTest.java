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

import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.test.CustomDataKeyTest;
import com.redhat.rhn.domain.server.CustomDataValue;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * CustomDataValueTest
 * @version $Rev$
 */
public class CustomDataValueTest extends RhnBaseTestCase {

    public void testCustomDataValue() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        Server server = ServerFactoryTest.createTestServer(user);
        
        CustomDataKey key = CustomDataKeyTest.createTestCustomDataKey(user);
        CustomDataValue val = createTestCustomDataValue(user, key, server);   
        
        CustomDataValue val2 = server.getCustomDataValue(key);
        
        assertNotNull(val2);
        assertEquals(val.getValue(), val2.getValue());
        assertEquals(val.getCreator(), val2.getCreator());
        assertEquals(val.getKey(), val2.getKey());
        
        CustomDataValue val3 = server.getCustomDataValue(null);
        assertNull(val3);
        //try an undefined key
        CustomDataKey key2 = CustomDataKeyTest.createTestCustomDataKey(user);
        val3 = server.getCustomDataValue(key2);
        assertNull(val3);
    }
    
    public static CustomDataValue createTestCustomDataValue(User user,
            CustomDataKey key, Server server) {
        CustomDataValue val = new CustomDataValue();
        val.setCreator(user);
        val.setKey(key);
        val.setServer(server);
        val.setValue("Test value");
        
        TestUtils.saveAndFlush(val);
        
        return val;
    }
}
