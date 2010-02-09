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
package com.redhat.rhn.frontend.nav.test;

import com.redhat.rhn.frontend.nav.NavNode;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import org.apache.commons.beanutils.MethodUtils;

import java.lang.reflect.Field;
import java.util.List;

/**
 * NavNodeTest
 * @version $Rev$
 */
public class NavNodeTest extends RhnBaseTestCase {

    private NavNode node;

    public void setUp() {
        node = new NavNode();
        TestUtils.disableLocalizationLogging();
    }

    public void testAddNode() {
        for (int i = 0; i < 10; i++) {
            NavNode n = new NavNode();
            n.setName(Integer.toString(i));
            node.addNode(n);
        }

        List list = node.getNodes();
        for (int i = 0; i < 10; i++) {
            NavNode n = (NavNode) list.get(i);
            assertEquals(Integer.toString(i), n.getName());
        }
    }

    // Some reflection trickery here to verify that we set the
    // localized key at the right time.
    public void testLocalizedName() throws Exception {
        NavNode n1 = new NavNode();
        String randName = TestUtils.randomString();
        n1.setName(randName);
        node.addNode(n1);

        NavNode n2 = (NavNode) node.getNodes().get(0);
        assertEquals("**" + randName + "**", n2.getName());
        Class c = n2.getClass();
        Field[] fields = c.getDeclaredFields();
        String privateValue = null;
        for (int i = 0; i < fields.length; i++) {
            if (fields[i].getName().equals("name")) {
                fields[i].setAccessible(true);
                privateValue = (String) fields[i].get(n1);
            }
        }
        assertEquals(randName, privateValue);
        
    }
    
    public void testEscapedName() {
        NavNode theNode = new NavNode();
        String random = TestUtils.randomString();
        String name = random + "&you";
        String escapedName = random + "&amp;you";
        //it localizes the name too
        String expected = "**" + escapedName + "**";
        
        theNode.setName(name);
        assertEquals(expected, theNode.getName());
    }
    
    
    public void testAddUrls() {
        for (int i = 0; i < 10; i++) {
            node.addURL(Integer.toString(i));
        }

        List list = node.getURLs();
        for (int i = 0; i < 10; i++) {
            String n = (String) list.get(i);
            assertEquals(Integer.toString(i), n);
        }
    }

    public void testExceptionCase() {
        boolean flag = false;
        try {
            node.getPrimaryURL();
            flag = true;
        }
        catch (IndexOutOfBoundsException ioobe) {
            assertFalse(flag);
        }
    }

    public void testToString() {
        assertNotNull(node.toString());
    }

    public void testStringSetters()
        throws Exception {
        String[] methods = { "Label", "Name", "Acl",
                "PermFailRedirect", "ActiveImage", "InactiveImage", "OnClick",
                "DynamicChildren" };

        for (int i = 0; i < methods.length; i++) {
            verifyStringSetterMethod(methods[i]);
        }
    }

    public void testBooleanSetters()
        throws Exception {
        String[] methods = { "Dominant", "Invisible", "OverrideSidenav",
                "ShowChildrenIfActive" };

        for (int i = 0; i < methods.length; i++) {
            verifyBooleanSetterMethod(methods[i]);
        }
    }

    private void verifyStringSetterMethod(String methodname)
        throws Exception {
        Object[] args = { "value" };
        MethodUtils.invokeMethod(node, "set" + methodname, args);
        String rc = (String) MethodUtils.invokeMethod(node, "get" + methodname,
                null);
        assertEquals("value", rc);
    }

    private void verifyBooleanSetterMethod(String methodname)
        throws Exception {
        Object[] args = { Boolean.TRUE };
        MethodUtils.invokeMethod(node, "set" + methodname, args);
        Boolean rc = (Boolean) MethodUtils.invokeMethod(node, "get" +
                methodname, null);
        assertTrue(rc.booleanValue());
    }

    public void tearDown() {
        node = null;
    }
}
