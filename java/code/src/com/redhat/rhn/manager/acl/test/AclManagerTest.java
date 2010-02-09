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
package com.redhat.rhn.manager.acl.test;

import com.redhat.rhn.common.security.acl.AclHandler;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import com.mockobjects.servlet.MockHttpServletRequest;

/**
 * AclManagerTest
 * @version $Rev$
 */
public class AclManagerTest extends RhnBaseTestCase {
    
    public void testHasAcl() {
        
        MockHttpServletRequest request = TestUtils.getRequestWithSessionAndUser();
        String singleTrue = "true_test()";
        String multipleTrue = "first_true_acl(); second_true_acl()";
        String singleFalse = "false_test()";
        String multipleFalse = "first_false_acl(); second_false_acl()";
        String lastFalse = "first_true_acl(); second_true_acl(); first_false_acl()";
        String oneFalse = "first_true_acl(); first_false_acl(); second_true_acl()";
        String singleFoo = "is_foo(foo)";
        String doubleFoo = "is_foo(foo); is_foo(foo)";
        String fooPlus = "true_test(); is_foo(foo)";
        String notFoo = "is_foo(notfoo)";
        String invalid = "flkas";
        String mixinFoo = MockFooAclHandler.class.getName();
        String mixinMultiple = MockMultipleAclHandler.class.getName();
        String mixinBoolean = BooleanAclHandler.class.getName();
        
        
        assertTrue(AclManager.hasAcl(singleTrue, request, mixinBoolean));
        assertTrue(AclManager.hasAcl(multipleTrue, request, mixinMultiple));
        assertFalse(AclManager.hasAcl(singleFalse, request, mixinBoolean));
        assertFalse(AclManager.hasAcl(multipleFalse, request, mixinMultiple));
        assertFalse(AclManager.hasAcl(lastFalse, request, mixinMultiple));
        assertFalse(AclManager.hasAcl(oneFalse, request, mixinMultiple));
        assertTrue(AclManager.hasAcl(singleFoo, request, mixinFoo));
        assertTrue(AclManager.hasAcl(doubleFoo, request, mixinFoo));
        assertTrue(AclManager.hasAcl(fooPlus, request, mixinFoo + "," + mixinBoolean));
        assertFalse(AclManager.hasAcl(notFoo, request, mixinFoo));
        
        try {
            AclManager.hasAcl(invalid, request, mixinBoolean);
            fail(); //should never get here
        }
        catch (Exception e) {
            //no op
        }
        
        try {
            AclManager.hasAcl(oneFalse, request, invalid);
            fail(); //should never get here
        }
        catch (Exception e) {
            //no op
        }
    }

    public static class MockFooAclHandler implements AclHandler {

        public MockFooAclHandler() {
            super();
        }

        public boolean aclIsFoo(Object ctx, String[] params) {
            return (params[0].equals("foo"));
        }
    }

    public static class MockMultipleAclHandler implements AclHandler {

        public MockMultipleAclHandler() {
            super();
        }

        public boolean aclFirstTrueAcl(Object ctx, String[] params) {
            return true;
        }

        public boolean aclFirstFalseAcl(Object ctx, String[] params) {
            return false;
        }

        public boolean aclSecondFalseAcl(Object ctx, String[] params) {
            return false;
        }

        public boolean aclSecondTrueAcl(Object ctx, String[] params) {
            return true;
        }
    }
    
    public static class BooleanAclHandler implements AclHandler {
        /**
         * Always returns true.
         * @param ctx ignored
         * @param params ignored
         * @return true
         */
        public boolean aclTrueTest(Object ctx, String[] params) {
            return true;
        }
        
        /**
         * Always returns false.
         * @param ctx ignored
         * @param params ignored
         * @return false
         */
        public boolean aclFalseTest(Object ctx, String[] params) {
            return false;
        }
    }
}
