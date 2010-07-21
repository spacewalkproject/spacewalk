/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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
package com.redhat.satellite.search.config.tests;

import com.redhat.satellite.search.config.Configuration;

import java.io.BufferedReader;
import java.io.StringReader;
import java.util.List;
import java.util.Map;

import junit.framework.TestCase;


/**
 * ConfigurationTest
 * @version $Rev$
 */
public class ConfigurationTest extends TestCase {
    
    private Configuration config;
    
    @Override
    protected void setUp() throws Exception {
        StringBuilder builder = new StringBuilder();
        builder.append("search.boolean=true\n");
        builder.append("search.index_work_dir=/tmp/search-server-test\n");
        builder.append("search.rpc_port=2828\n");
        builder.append("search.list=item1,item2, item3\n");
        builder.append("db_user=rhnsat\n");
        builder.append("search.rpc_handlers=");
        builder.append(
             "index:com.redhat.satellite.search.rpc.handlers.IndexHandler\n\n");
        StringReader sr = new StringReader(builder.toString());
        config = new Configuration(new BufferedReader(sr));
    }
    
    public void testGetValue() {
        assertEquals("bar", config.getString("foo", "bar"));
        assertEquals(
                "index:com.redhat.satellite.search.rpc.handlers.IndexHandler",
                config.getString("search.rpc_handlers", ""));
        assertNull(config.getString(null, null));
        assertEquals("", config.getString(null, ""));
    }
    
    public void testGetValueAsInt() {
        assertEquals(2828, config.getInt("search.rpc_port"));
        assertEquals(2828, config.getInt("search.rpc_port", 0));
        assertEquals(10, config.getInt("search.nothere", 10));
        assertEquals(10, config.getInt(null, 10));
        try {
            config.getInt("search.rpc_handlers", 0);
            fail("getValueAsInt didn't throw exception");
        }
        catch (Exception e) {
            // expected
        }
    }
    
    public void testGetValuesAsMap() {
        assertNull(config.getMap("search.notthere"));
        assertNull(config.getMap(null));

        Map<String, String> map = config.getMap("search.rpc_handlers");
        assertNotNull(map);
        assertEquals("com.redhat.satellite.search.rpc.handlers.IndexHandler",
                map.get("index"));
        
        map = config.getMap("search.rpc_port");
        assertNotNull(map);
        assertTrue(map.keySet().isEmpty());
    }
    
    public void testGetValues() {
        assertNotNull(config.getList("search.notthere"));
        assertTrue(config.getList("search.notthere").isEmpty());
        assertNotNull(config.getList(null));
        assertTrue(config.getList(null).isEmpty());
        
        List<String> list = config.getList("search.list");
        assertNotNull(list);
        assertEquals(3, list.size());
        assertEquals("item1", list.get(0));
        assertEquals("item2", list.get(1));
        assertEquals(" item3", list.get(2));
    }
    
    public void testTranslation() {
        assertNull(config.getString("db_user"));
        assertEquals("rhnsat", config.getString("search.connection.username"));
    }
    
    public void testGetBoolean() {
        assertTrue(config.getBoolean("search.boolean"));
        config.setBoolean("search.boolean", "false");
        assertFalse(config.getBoolean("search.boolean"));
    }
    
    public void testGetDefaultConfig() {
        String confDir = System.getProperty("rhn.config.dir");
        if (confDir == null || "".equals(confDir)) {
            confDir = "/etc/rhn";
        }
        assertEquals(confDir + "/rhn.conf",
                     Configuration.getDefaultConfigFilePath());
    }
    
    public void testSetString() {
        config.setString("search.stringvalue", "foobar");
        assertEquals("foobar", config.getString("search.stringvalue"));
    }
    
    public void testGetDouble() {
        config.setString("search.double", ".30");
        assertEquals(0.0, config.getDouble("better.not.be.a.double"));
        assertEquals(.30, config.getDouble("search.double"));
        
        config.setString("search.double", "30");
        assertEquals(30.0, config.getDouble("search.double"));
        
        config.setString("search.double", "");
        assertEquals(0.0, config.getDouble("search.double"));
    }
}
