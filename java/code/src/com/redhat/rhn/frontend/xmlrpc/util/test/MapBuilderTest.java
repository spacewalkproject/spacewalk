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
package com.redhat.rhn.frontend.xmlrpc.util.test;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.frontend.xmlrpc.util.MapBuilder;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.commons.beanutils.BeanUtils;

import java.util.Map;

/**
 * 
 * MapBuilderTest
 * @version $Rev$
 */
public class MapBuilderTest extends RhnBaseTestCase {
    private MapBuilder builder;
    private TestBean bean;
    
    public void setUp() {
        builder = new MapBuilder();
        bean = new TestBean();
    }
    /**
     * Quick method to assert a property in a mapified bean 
     * @param map the map obtained by mapifying a bean
     * @param name the beanfied key name 
     * @param value beanified value.
     * @param flag true if a properties existence is to be assert 
     *                              false orhterwise.
     */
    private void assertMethod(Map map, String name, String value, boolean flag) {
        if (flag) {
            assertTrue("Cannot find property with Name [" + name + "]" ,
                                    map.containsKey(StringUtil.debeanify(name)));
            assertEquals(value, map.get(StringUtil.debeanify(name)));
            
        }
        else {
            assertFalse("COULD find property with Name [" + name + "]" ,
                    map.containsKey(StringUtil.debeanify(name)));
        }
    }
    /**
     * Test the case where includes and excludes are null
     * @throws Exception if bean utils has trouble processing the bean.
     */
    public void testBaseCase() throws Exception {
        Map map = builder.mapify(bean);
        Map properties = BeanUtils.describe(bean);
        assertEquals(properties.size(), map.size());
        assertMethod(map, "fieldWierdo", TestBean.DEFAULT_VALUE, true);
        assertMethod(map, "fieldNull", "", true);
    }
    
    
    
    public void testIncludes() {
        builder.include("fieldA");
        builder.include("fieldWierdo");
        builder.include("fieldNull");
        Map map = builder.mapify(bean);
        assertMethod(map, "fieldWierdo", TestBean.DEFAULT_VALUE, true);
        assertMethod(map, "fieldA", TestBean.DEFAULT_VALUE, true);
        assertMethod(map, "fieldNull", "", true);
        assertMethod(map, "fieldB", "", false);
        assertMethod(map, "fieldC", "", false);
    }
    
    public void testExcludes() {
        builder.exclude("fieldA");
        builder.exclude("fieldWierdo");
        builder.exclude("fieldNull");
        Map map = builder.mapify(bean);
        
        assertMethod(map, "fieldC", TestBean.DEFAULT_VALUE, true);
        assertMethod(map, "fieldB", TestBean.DEFAULT_VALUE, true);        

        assertMethod(map, "fieldA", "", false);
        assertMethod(map, "fieldWierdo", "", false);
    }    
    
    public void testCombo() {
        builder.include("fieldA");
        builder.exclude("fieldA");
        Map map = builder.mapify(bean);
        // we included fieldA and then excluded fieldA so map must be empty
        // include always takes precedence over exclude.
        assertTrue(map.isEmpty());
    }
}
