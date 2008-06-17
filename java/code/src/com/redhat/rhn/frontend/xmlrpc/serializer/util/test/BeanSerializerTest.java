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
package com.redhat.rhn.frontend.xmlrpc.serializer.util.test;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.BeanSerializer;
import com.redhat.rhn.frontend.xmlrpc.serializer.util.SerializerHelper;

import java.io.StringWriter;
import java.io.Writer;

import junit.framework.TestCase;
import redstone.xmlrpc.XmlRpcSerializer;


/**
 * BeanSerializerTest
 * @version $Rev$
 */
public class BeanSerializerTest extends TestCase {
    private BeanSerializer serializer;
    private TestBean bean;
    private XmlRpcSerializer builtInSerializer;
    

    public void setUp() throws Exception {
        serializer = new BeanSerializer();
        bean = new TestBean();
        builtInSerializer = new XmlRpcSerializer();
    }

    private String processSerializer() throws Exception {
        Writer output = new StringWriter();
        serializer.serialize(bean, output, new SerializerHelper(builtInSerializer));
        String beanOut = output.toString();
        
        assertTrue("Cannot find <struct> in [" + beanOut.trim() + "]",
                                        beanOut.trim().startsWith("<struct>"));
        
        assertTrue("Cannot find </struct> in [" + beanOut.trim() + "]", 
                                           beanOut.trim().endsWith("</struct>"));
        
        return beanOut;
    }
    
    /**
     * Quick method to assert a property is property constructed bean 
     * @param map the map obtained by mapifying a bean
     * @param name the key name 
     * @param value the  value.
     * @param flag true if a properties existence is to be asserted 
     *                              false otherwise.
     */    
    private void assertProperty(String name, Object value, boolean flag)
        throws Exception {

        String beanOut = processSerializer();
        Writer output = new StringWriter(); 
        builtInSerializer.serialize(value, output);
        
        String nameTag = "<name>" + StringUtil.debeanify(name) + "</name>";
        String valueTag = output.toString();
        if (flag) {
            String msg = "Cannot find property with tag [" + nameTag + "]" +
                                    " in bean [" + beanOut + "]";
            assertTrue(msg, beanOut.indexOf(nameTag) > -1);
            
            msg = "Cannot find property value with Value-> [" + valueTag + "]" +
                                                       " in bean [" + beanOut + "]";
            assertTrue(msg, beanOut.indexOf(valueTag) > -1);            
        }
        else {
            String msg = "COULD find property with tag [" + nameTag + "]" +
                                                   " in bean [" + beanOut + "]";            
            assertFalse(msg, beanOut.indexOf(nameTag) > -1);
        }
    }
    
    /**
     * Test the case where includes and excludes are null, 
     * implying all properties (except the non null ones) of the bean are available
     * @throws Exception if bean utils has trouble processing the bean.
     */
    public void testBaseCase() throws Exception {
        assertProperty("fieldWierdo", TestBean.DEFAULT_VALUE, true);
        assertProperty("fieldNull", "", false);
    }

    public void testIncludes() throws Exception {
        serializer.include("fieldA");
        serializer.include("fieldWierdo");
        serializer.include("fieldNull");
        
        assertProperty("fieldWierdo", TestBean.DEFAULT_VALUE, true);
        assertProperty("fieldA", TestBean.DEFAULT_VALUE, true);
        assertProperty("fieldNull", "", false);
        assertProperty("fieldB", "", false);
        assertProperty("fieldC", "", false);
    }
    
    public void testExcludes() throws Exception {
        serializer.exclude("fieldA");
        serializer.exclude("fieldWierdo");
        serializer.exclude("fieldNull");
        
        
        assertProperty("fieldC", TestBean.DEFAULT_VALUE, true);
        assertProperty("fieldB", TestBean.DEFAULT_VALUE, true);        

        assertProperty("fieldA", "", false);
        assertProperty("fieldWierdo", "", false);
    }    
    
    public void testCombo() throws Exception {
        serializer.include("fieldA");
        serializer.exclude("fieldA");
        // we included fieldA and then excluded fieldA so map must be empty
        // include always takes precedence over exclude.
        String out = processSerializer();
        assertEquals("<struct></struct>\n", out);
    }
}
