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

package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.MethodNotFoundException;
import com.redhat.rhn.common.util.MethodNotStaticException;
import com.redhat.rhn.common.util.MethodUtil;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

public class MethodUtilTest extends RhnBaseTestCase {

    private static final String TEST_STRING = "Test ";
    
    // Must be public so that invokeStaticMethod can access it.
    public static String staticMethod(Integer number) {
        return TEST_STRING + number;
    }
    
    // Must be public so that invokeStaticMethod can access it.
    // Non-static so that invokeStaticMethod should fail when calling it.
    public String nonStaticMethod(Integer number) {
        return TEST_STRING + number;
    }

    // Must be public so that callMethod can access it.
    public String nonStaticMethod(Integer number, Integer num2) {
        return TEST_STRING + number + " " + num2;
    }

    // Must be public so that callMethod can access it.
    // This test assumes that we have a translation to go from String to
    // boolean.  The translator should convert 'Y' to true, and everything else
    // to false.
    public String nonStaticMethod(boolean b) {
        return TEST_STRING + b;
    }

    public void testInvokeStatic() throws Exception {
        String teststr = (String)MethodUtil.
                                 invokeStaticMethod(MethodUtilTest.class,
                                                    "staticMethod",
                                                    new Object[] {new Integer(1)});
        assertEquals(TEST_STRING + 1, teststr);
    }

    public void testInvokeNonStatic() throws Exception {
        try {
            MethodUtil.invokeStaticMethod(MethodUtilTest.class,
                                          "nonStaticMethod",
                                          new Object[] {new Integer(1)});
            fail("Should have received an Exception");
        }
        catch (MethodNotStaticException e) {
            // expected.
        }
    }

    public void testCallMethod() throws Exception {
        String teststr = (String)MethodUtil.callMethod(this, "nonStaticMethod",
                                                new Object[] {new Integer(1)});
        assertEquals(TEST_STRING + 1, teststr);
    }
    
    public void testCallMethod2Params() throws Exception {
        String teststr = (String)MethodUtil.callMethod(this, "nonStaticMethod",
                                 new Object[] {new Integer(1), new Integer(2)});
        assertEquals(TEST_STRING + 1 + " " + 2, teststr);
    }

    public void testCallMethodDoesntExist() throws Exception {
        try {
            MethodUtil.callMethod(this, "nonStaticMethod",
                  new Object[] {new Integer(1), new Integer(2), new Integer(3)});
            fail("Method shouldn't exist to be called");
        }
        catch (MethodNotFoundException e) {
            String expected = "Could not find method called: nonStaticMethod " +
                    "in class: com.redhat.rhn.common.util.test.MethodUtilTest " +
                    "with params: [type: java.lang.Integer, value: 1, type: " +
                    "java.lang.Integer, value: 2, type: java.lang.Integer, value: 3]";
            
            assertEquals(expected, e.getMessage());
        }
    }

    public void testCallMethodWithTranslate() throws Exception {
        String teststr = (String)MethodUtil.callMethod(this, "nonStaticMethod",
                new Object[] {"Y"});
        assertEquals(TEST_STRING + true, teststr);
    }
    
    public void testCallNewMethod() {
        assertNotNull(MethodUtil.getClassFromConfig("java.lang.Object"));
        assertNotNull(MethodUtil.getClassFromConfig(
                "com.redhat.rhn.domain.channel.Channel"));
        assertNotNull(MethodUtil.getClassFromConfig(
                TestChannel.class.getName()));
        
        try {
            assertNotNull(MethodUtil.getClassFromConfig(TestUtils.randomString()));
            fail("Should not get here");
        } 
        catch (Exception e) {
            // do nothing ...
        }
    }
    
}
