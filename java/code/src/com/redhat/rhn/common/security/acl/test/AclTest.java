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

package com.redhat.rhn.common.security.acl.test;

import com.redhat.rhn.common.security.acl.Acl;
import com.redhat.rhn.common.security.acl.AclHandler;
import com.redhat.rhn.testing.RhnBaseTestCase;

import com.mockobjects.ExpectationValue;
import com.mockobjects.Verifiable;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.TreeSet;

/*
 * Test for {@link Acl}
 *
 * @version $Rev$
 */
public class AclTest extends RhnBaseTestCase {

    private Acl acl = null;
    private Map context = null;
    private MockAclHandler handler = null;

    /** Constructor
     * @param name test name
     */
    public AclTest(final String name) {
        super(name);
    }

    /** Sets up the acl, handler, and context objects. */
    public void setUp() {
        acl = new Acl();
        context = new HashMap();
        handler = new MockAclHandler();

        acl.registerHandler(handler);
    }

    /** Tears down the acl, handler, and context objects. */
    public void tearDown() {
        acl = null;
        context = null;
        handler = null;
    }

    /* Test single-statement acls.
     * Tests the following, to make sure parser is behaving:
     * <ul>
     *   <li>"handler_zero()"
     *   <li>"handler_zero(true)"
     *   <li>"handler_zero(true,false)"
     *   <li>"handler_zero(true ,false)"
     *   <li>"handler_zero(true , false)"
     *   <li>"handler_zero(true, false)"
     *   <li>"not handler_zero(true)"
     * </ul>
     */
    public void testSimpleAcl() {

        // test parsing with no params. should be false
        handler.setExpected("handler_zero", new String[0]);
        assertFalse(acl.evalAcl(context, "handler_zero()"));
        handler.verify();

        // test parsing with no 1 param. should be true
        handler.setExpected("handler_zero", new String[]{"true"});
        assertTrue(acl.evalAcl(context, "handler_zero(true)"));
        handler.verify();

        // test 2 params with diff spacings
        handler.setExpected("handler_zero",
                new String[]{"true", "false"});
        assertTrue(acl.evalAcl(context, "handler_zero(true,false)"));
        handler.verify();

        handler.setExpected("handler_zero", new String[]{"true", "false"});
        assertTrue(acl.evalAcl(context, "handler_zero(true ,false)"));
        handler.verify();

        handler.setExpected("handler_zero", new String[]{"true", "false"});
        assertTrue(acl.evalAcl(context, "handler_zero(true , false)"));
        handler.verify();

        handler.setExpected("handler_zero", new String[]{"true", "false"});
        assertTrue(acl.evalAcl(context, "handler_zero(true, false)"));
        handler.verify();

        // test negation
        handler.setExpected("handler_zero", new String[]{"true"});
        assertFalse(acl.evalAcl(context, "not handler_zero(true)"));
        handler.verify();
    }

    /* Test expressions connected with Or.
     * Tests the following:
     * <ul>
     *   <li>"handler_zero(false) or handler_one(true)"
     *   <li>"handler_zero(true) or handler_one(false)"
     * </ul>
     */
    public void testMultipleOrStatementsAcl() {
        handler.setExpected("handler_zero", new String[]{"false"});
        handler.setExpected("handler_one", new String[]{"true"});
        assertTrue(acl.evalAcl(context,
                    "handler_zero(false) or handler_one(true)"));
        handler.verify();

        handler.setExpected("handler_zero", new String[]{"true"});
        // handler_one, even though we give it false in evalAcl, is not expected
        // to have an expectation value. handler_one won't get called
        // because handler_zero will return true
        handler.setExpected("handler_one", null);
        assertTrue(acl.evalAcl(context,
                    "handler_zero(true) or handler_one(false)"));
        handler.verify();
    }

    /* Test statements connected with And.
     * Tests the following:
     * <ul>
     *   <li>"handler_zero(false) ; handler_one(true)"
     *   <li>"handler_zero(true,false) ; handler_one(true)"
     * </ul>
     */
    public void testMultipleAndStatementsAcl() {
        handler.setExpected("handler_zero", new String[]{"false"});
        // handler_one, even though we give it false in evalAcl, is not expected
        // to have an expectation value. handler_one won't get called
        // because handler_zero will return true
        handler.setExpected("handler_one", null);
        assertFalse(acl.evalAcl(context,
                    "handler_zero(false) ; handler_one(true)"));
        handler.verify();


        handler.setExpected("handler_zero", new String[]{"true", "false"});
        handler.setExpected("handler_one", new String[]{"true"});
        assertTrue(acl.evalAcl(context,
                    "handler_zero(true,false) ; handler_one(true)"));
        handler.verify();
    }

    /* Test statements connected with And and Or.
     * Tests the following:
     * <ul>
     *   <li>"handler_zero(true) or handler_one(false) ; handler_two(true)"
     * </ul>
     */
    public void testCompoundAcl() {

        handler.setExpected("handler_zero", new String[]{"true"});
        // handler_one, even though we give it false in evalAcl, is not expected
        // to have an expectation value. handler_one won't get called
        // because handler_zero will return true
        handler.setExpected("handler_one", null);
        handler.setExpected("handler_two", new String[]{"true"});

        assertTrue(acl.evalAcl(context,
            "handler_zero(true) or handler_one(false) ; handler_two(true)"));

        handler.verify();
    }


    /* Test bad handler.
     */
    public void testBadHandler() {
        try {
            acl.evalAcl(null, "handler_does_not_exist(true)");
            fail("expected to fail");
        }
        catch (IllegalArgumentException e) {
            // good
        }
    }

    /* Test bad syntax.
     */
    public void testBadSyntax() {
        try {
            acl.evalAcl(null, "handler_zero(true) and handler_zero(true)");
            fail("expected to fail");
        }
        catch (IllegalArgumentException e) {
            // good
        }
    }

    /* Test bad syntax.
     */
    public void test() {
        try {
            acl.evalAcl(null, null);
            fail("expected to fail");
        }
        catch (IllegalArgumentException e) {
            // good
        }
    }

    /** Makes sure that method names are properly converted to acl handler
     *  names.
     *  Tests the following:
     *  <table>
     *  <tr>
     *      <td>method name</td><td>acl handler name</td>
     *      <td>aclTheQuickBrownFoxJumpedOverTheLazyDog</td>
     *      <td>the_quick_brown_fox_jumped_over_the_lazy_dog</td>
     *  </tr>
     *  <tr>
     *      <td>method name</td><td>acl handler name</td>
     *      <td>aclTestXMLFile</td><td>test_xml_file</td>
     *      <td>aclTestX</td><td>test_x</td>
     *      <td>aclTestXML</td><td>test_xml</td>
     *  </tr>
     *  </table>
     */
    public void testMethodNameToAclName() {
        acl.registerHandler(new MockAclHandlerWithFunkyNames());

        /** Each of the following should call the expected method
         *  from MockAclHandlerWithFunkyNames and return true */
        assertTrue(acl.evalAcl(context,
                    "the_quick_brown_fox_jumped_over_the_lazy_dog()"));
        assertTrue(acl.evalAcl(context, "test_xml_file()"));
        assertTrue(acl.evalAcl(context, "test_x()"));
        assertTrue(acl.evalAcl(context, "test_xml()"));
        assertTrue(acl.evalAcl(context, "xml_test()"));
    }

    public void testRegisterByClass() {
        acl.registerHandler(MockAclHandlerWithFunkyNames.class);
        assertTrue(acl.evalAcl(context, "xml_test()"));
    }

    public void testBadRegisterByClass() {
        try {
            acl.registerHandler(Object.class);
            fail("Expected call to fail");
        }
        catch (IllegalArgumentException e) {
            // good.
        }
    }

    public void testRegisterByString() {
        acl.registerHandler(MockAclHandlerWithFunkyNames.class.getName());
        assertTrue(acl.evalAcl(context, "xml_test()"));
    }

    public void testBadRegisterByString() {
        try {
            acl.registerHandler("Bubba");
            fail("Expected call to fail");
        }
        catch (IllegalArgumentException e) {
            // good.
        }
    }

    public void testStringArrayConstructor() {
        Acl localAcl = new Acl(new String[]{MockAclHandler.class.getName(),
            MockAclHandlerWithFunkyNames.class.getName()});

        // make sure we can call an acl handler from each class
        assertTrue(localAcl.evalAcl(context, "handler_zero(true)"));
        assertTrue(localAcl.evalAcl(context, "xml_test()"));
    }

    public void testGetAclHandlerNames() {
        Acl localAcl = new Acl();
        localAcl.registerHandler(MockAclHandler.class.getName());
        TreeSet ts = localAcl.getAclHandlerNames();
        ts.contains("handler_zero");
        ts.contains("handler_one");
        ts.contains("handle_two");
    }


    // HELPER CLASSES

    /* Mock AclHandler that can be used to check that the Acl class
     * is parsing parameters correctly.
     * If no parameters are given to this AclHandler, its
     * {@link #handleAcl} method returns false. If the
     * first parameter equals "true", then handleAcl() returns true.
     */
   public static class MockAclHandler implements AclHandler, Verifiable {
       private Map expected = null;

       public MockAclHandler() {
           reset();
       }
       private void reset() {
           expected = new HashMap();
           expected.put("handler_zero",
                   new ExpectationValue("handler_zero params"));
           expected.put("handler_one",
                   new ExpectationValue("handler_one params"));
           expected.put("handler_two",
                   new ExpectationValue("handler_two params"));

           // defer verifying until verify() is called
           // otherwise, calling setActual() might throw an Exception,
           // which we don't want because then we won't get our
           // assert exceptions
           Collection expectedValues = expected.values();
           Iterator iter = expectedValues.iterator();
           while (iter.hasNext()) {
               ExpectationValue exp = (ExpectationValue)iter.next();
               exp.setFailOnVerify();
           }
       }
       /** Set the parameters expected to be given a handler upon
        * a call to evalAcl. These get reset with {@link #verify}
        * is called. */
       public void setExpected(String handlerName, String[] params) {
           if (params != null) {
               ExpectationValue exp =
                   (ExpectationValue)expected.get(handlerName);
               exp.setExpected(Arrays.asList(params));
           }
       }
       public boolean aclHandlerZero(Object ctx, String[] params) {
           return handlerDelegate("handler_zero", ctx, params);
       }
       public boolean aclHandlerOne(Object ctx, String[] params) {
           return handlerDelegate("handler_one", ctx, params);
       }
       public boolean aclHandlerTwo(Object ctx, String[] params) {
           return handlerDelegate("handler_two", ctx, params);
       }

       private boolean handlerDelegate(
               String name, Object ctx, String[] params) {
           ExpectationValue exp = (ExpectationValue)expected.get(name);
           exp.setActual(Arrays.asList(params));

           if (params.length == 0) {
               return false;
           }

           if (params[0].equals("true")) {
               return true;
           }

           return false;

       }

       /** Call to verify that the expected parameters match
        * the parameters given to the handler when Acl calls handleAcl.
        * The expectation values get reset when this is called.
        */
       public void verify() {
           Collection expectedValues = expected.values();
           Iterator iter = expectedValues.iterator();
           while (iter.hasNext()) {
               ExpectationValue exp = (ExpectationValue)iter.next();
               exp.verify();
           }
           reset();
       }
   }

   /** A handler class with a variety of names to test that method names
    *  get converted to acl names correctly.
    */
   public static class MockAclHandlerWithFunkyNames implements AclHandler {
       public boolean aclTheQuickBrownFoxJumpedOverTheLazyDog(
               Object ctx, String[] params) {
           return true;
       }
       public boolean aclTestXMLFile(Object ctx, String[] params) {
           return true;
       }
       public boolean aclTestX(Object ctx, String[] params) {
           return true;
       }
       public boolean aclTestXML(Object ctx, String[] params) {
           return true;
       }
       public boolean aclXMLTest(Object ctx, String[] params) {
           return true;
       }
   }
}
