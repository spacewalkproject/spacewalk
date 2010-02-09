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

package com.redhat.rhn.common.conf.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.net.URL;
import java.util.Iterator;
import java.util.Properties;

public class ConfigTest extends RhnBaseTestCase {
    static final String TEST_KEY = "user";
    static final String TEST_VALUE = "newval";
    private Config c;

    public void setUp() throws Exception {
        URL url = TestUtils.findTestData("conf");
        String path = url.getFile();
        c = new Config();
        c.addPath(path + "/rhn.conf");
        // add everything under /default regardless of extension
        c.addPath(path + "/default");
        c.parseFiles();
    }
    
    /**
     * Test that comments placed after values, such as:
     *     web.property_with_comment = 42 #This shouldn't be part of the value
     * are stripped out and only the value is returned.
     */
    public void testStripComments() {
        assertEquals(42, c.getInt("web.property_with_comment"));
    }
    
    /**
     * define a value in rhn_web.conf with a prefix, call get using the
     * fully qualified property name.
     * define value in rhn_web.conf without a prefix, call get fully qualified.
     */
    public void testGetFullyQualified() {
        assertEquals("this is a property with a prefix",
                     c.getString("web.property_with_prefix"));
        assertEquals("this is a property without a prefix",
                     c.getString("web.without_prefix"));
    }
    
    /**
     * define a value in rhn_web.conf with a prefix, call get using only the
     * property name.
     * define value in rhn_web.conf without a prefix, call get with just prop name.
     */
    public void testGetByPropertyNameOnly() {
        assertEquals("this is a property with a prefix",
                     c.getString("property_with_prefix"));
        assertEquals("this is a property without a prefix",
                     c.getString("without_prefix"));
    }
    
    /**
     * property defined fully qualifed in rhn_web.conf,
     * overridden without prefix in rhn.conf,
     * Accessed fully qualified.
     */
    public void testOverride() throws Exception {
        assertEquals("keep", c.getString("web.to_override"));
    }
    
    /**
     * property defined fully qualifed in rhn_web.conf,
     * overridden without prefix in rhn.conf,
     * Accessed by property name only.
     */
    public void testOverride1() throws Exception {
        assertEquals("keep", c.getString("to_override"));
    }

    /**
     * property defined fully qualifed in rhn_web.conf
     * overridden fully qualfied in rhn.conf.
     * Accessed fully qualified.
     */
    public void testOverride2() throws Exception {
        assertEquals("1", c.getString("web.fq_to_override"));
    }
    
    /**
     * property defined fully qualifed in rhn_web.conf
     * overridden fully qualfied in rhn.conf.
     * Accessed by property name only.
     */
    public void testOverride3() throws Exception {
        assertEquals("1", c.getString("fq_to_override"));
    }
    
    /**
     * property defined without a prefix in rhn_web.conf
     * overridden fully qualfied in rhn.conf.
     * Accessed fully qualified.
     */
    public void testOverride4() {
        assertEquals("overridden",
                c.getString("web.to_override_without_prefix"));
        assertEquals("overridden",
                c.getString("to_override_without_prefix"));
    }
    
    /**
     * property defined without a prefix in rhn_web.conf
     * overridden without a prefix in rhn.conf.
     * Accessed fully qualified.
     */
    public void testOverride5() {
        assertEquals("overridden",
                c.getString("to_override_without_prefix1"));
        assertEquals("overridden",
                c.getString("web.to_override_without_prefix1"));
    }
    
    /**
     * Tests a property with the same name defined in
     * more than one conf file with different prefixes.
     * Accesses the value fully qualfied.
     */
    public void testCollision() {
        assertEquals("10", c.getString("web.collision"));
        assertEquals("12", c.getString("prefix.collision"));
    }
    
    /**
     * Tests a property with the same name defined in
     * more than one conf file with different prefixes.
     * Accesses the value without a prefix.  This will look through the
     * predefined prefix order to find the value.
     */
    public void testPrefixOrder() {
        assertEquals("10", c.getString("collision"));
    }

    public void testGetStringArray1Elem() throws Exception {
        String[] elems = c.getStringArray("prefix.array_one_element");
        assertEquals(1, elems.length);
        assertEquals("some value", elems[0]);
    }

    public void testGetStringArrayNull() throws Exception {
        String[] elems = c.getStringArray("find.this.entry.b****");
        assertNull(elems);
    }

    /**
     * define a boolean value in rhn_prefix.conf, call getBoolean.
     * Test true, false, 1, 0, y, n, foo, 10 
     */
    public void testGetBoolean() throws Exception {
        boolean b = c.getBoolean("prefix.boolean_true");
        assertTrue(b);
        
        assertFalse(c.getBoolean("prefix.boolean_false"));
        
        assertTrue(c.getBoolean("prefix.boolean_1"));
        assertFalse(c.getBoolean("prefix.boolean_0"));
        
        assertTrue(c.getBoolean("prefix.boolean_y"));
        assertTrue(c.getBoolean("prefix.boolean_Y"));
        assertFalse(c.getBoolean("prefix.boolean_n"));
        
        assertTrue(c.getBoolean("prefix.boolean_on"));
        assertFalse(c.getBoolean("prefix.boolean_off"));
        
        assertTrue(c.getBoolean("prefix.boolean_yes"));
        assertFalse(c.getBoolean("prefix.boolean_no"));
        
        assertFalse(c.getBoolean("prefix.boolean_foo"));
        assertFalse(c.getBoolean("prefix.boolean_10"));
        assertFalse(c.getBoolean("prefix.boolean_empty"));
        assertFalse(c.getBoolean("prefix.boolean_not_there"));
        
        assertTrue(c.getBoolean("prefix.boolean_on"));
        assertFalse(c.getBoolean("prefix.boolean_off"));
    }
    
    public void testGetIntWithDefault() {
        // lookup a non existent value
        assertEquals(1000, c.getInt("value.doesnotexist", 1000));
        
        // lookup an existing value
        assertEquals(100, c.getInt("prefix.int_100", 1000));
    }

    /**
     * define an integer value in rhN_prefix.conf, call getInt.
     * Test -10, 0, 100, y 
     */
    public void testGetInt() throws Exception {
        int i = c.getInt("prefix.int_minus10");
        assertEquals(-10, i);
        assertEquals(0, c.getInt("prefix.int_zero"));
        assertEquals(100, c.getInt("prefix.int_100"));
        
        boolean flag = false;
        try {
            c.getInt("prefix.int_y");
            flag = true;
        }
        catch (NumberFormatException nfe) {
            assertFalse(flag);
        }
    }
    
    public void testGetInteger() throws Exception {
        assertEquals(new Integer(-10), c.getInteger("prefix.int_minus10"));
        assertEquals(new Integer(0), c.getInteger("prefix.int_zero"));
        assertEquals(new Integer(100), c.getInteger("prefix.int_100"));
        assertNull(c.getInteger(null));
        assertEquals(c.getInt("prefix.int_100"),
                c.getInteger("prefix.int_100").intValue());
        
        boolean flag = false;
        try {
            c.getInteger("prefix.int_y");
            flag = true;
        }
        catch (NumberFormatException nfe) {
            assertFalse(flag);
        }
    }

    /**
     * define comma separated value in rhn_prefix.conf,
     * call using StringArrayElem, verify all values are in array.
     */
    public void testGetStringArrayMultElem() throws Exception {
        String[] elems = c.getStringArray("prefix.comma_separated");
        assertEquals(5, elems.length);
        assertEquals("every", elems[0]);
        assertEquals("good", elems[1]);
        assertEquals("boy", elems[2]);
        assertEquals("does", elems[3]);
        assertEquals("fine", elems[4]);
    }
    
    public void testGetStringArrayWhitespace() {
        String[] elems = c.getStringArray("prefix.comma_no_trim");
        assertEquals(5, elems.length);
        assertEquals("every", elems[0]);
        assertEquals(" good ", elems[1]);
        assertEquals(" boy ", elems[2]);
        assertEquals(" does", elems[3]);
        assertEquals("fine", elems[4]);
    }

    public void testSetBoolean() throws Exception {
        boolean oldValue = c.getBoolean("prefix.boolean_true");
        c.setBoolean("prefix.boolean_true", Boolean.FALSE.toString());
        assertFalse(c.getBoolean("prefix.boolean_true"));
        assertEquals("0", c.getString("prefix.boolean_true"));
        c.setBoolean("prefix.boolean_true", new Boolean(oldValue).toString());
    }

    public void testSetString() throws Exception {
        String oldValue = c.getString("to_override");
        c.setString("to_override", "newValue");
        assertEquals("newValue", c.getString("to_override"));
        c.setString("to_override", oldValue);
    }

    public void testGetUndefinedInt() throws Exception {
        int zero = c.getInt("Undefined_config_variable");
        assertEquals(0, zero);
    }
    
    public void testGetUndefinedString() {
        assertNull(c.getString("Undefined_config_variable"));
    }
    
    public void testNewValue() {
        String key = "newvalue" + TestUtils.randomString();
        c.setString(key, "somevalue");
        assertNotNull(c.getString(key));
    }
    
    public void testGetUndefinedBoolean() {
        assertFalse(c.getBoolean("Undefined_config_variable"));
    }
    
    /**
     * property defined in conf file whose prefix is not a member
     * of the prefix order. Access property fully qualified, then
     * unqualified.
     */
    public void testUnprefixedProperty() {
        assertEquals("thirty-three", c.getString("prefix.foo"));
        assertNull(c.getString("foo"));
    }
    
    public void testNamespaceProperties() throws Exception {
        Properties prop = c.getNamespaceProperties("web");
        assertTrue(prop.size() >= 8);
        for (Iterator i = prop.keySet().iterator(); i.hasNext();) {
            String key = (String)i.next();
            assertTrue(key.startsWith("web"));
        }
    }
    
    public void testBug154517IgnoreRpmsave() {
        assertNull(c.getString("bug154517.conf.betternotfindme"));
        assertNull(c.getString("betternotfindme"));
    }
    
    /**
     * Before implementing the code behind this test if a config entry had this:
     * 
     * web.some_configvalue = 
     * 
     * you would get back ""
     */
    public void testDefaultValueQuoteQuote() {
        Config.get().setString("somevalue8923984", "");
        assertNull(Config.get().getString("somevalue8923984"));
        String somevalue = Config.get().getString("somevalue8923984", 
                "xmlrpc.rhn.redhat.com");
        assertNotNull(somevalue);
        assertFalse(somevalue.equals(""));
        assertTrue(somevalue.equals("xmlrpc.rhn.redhat.com"));
    }
    public void testForNull() {
        assertNull(c.getString(null));
        assertNull(c.getInteger(null));
        assertEquals(0, c.getInt(null));
        assertFalse(c.getBoolean(null));
        assertNull(c.getStringArray(null));
    }
    
    public void testForEscapedPound() {
        assertEquals("http://server.com/create/#foobar",
                c.getString("web.escaped_pound"));
        assertEquals("http://server.com/create/#foobar",
                c.getString("web.escaped_pound_with_comment"));
        assertEquals("I want this # to appear as a # sign but not the following:",
                c.getString("web.escaped_multi"));
        assertEquals("",
                c.getString("web.pound_at_beginning"));
        assertEquals("this_value_",
                c.getString("web.pound_at_end"));
        assertEquals("this_value_#",
                c.getString("web.escaped_pound_at_end"));
    }
}
