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
package com.redhat.rhn.frontend.xmlrpc.test;

import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.LoggingInvocationProcessor;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.io.StringWriter;
import java.io.Writer;
import java.util.Arrays;

import redstone.xmlrpc.XmlRpcInvocation;

/**
 * LoggingInvocationProcessorTest
 * @version $Rev$
 */
public class LoggingInvocationProcessorTest extends RhnBaseTestCase {

    private LoggingInvocationProcessor lip;
    private Writer writer;
    
    public void setUp() throws Exception {
        super.setUp();
        lip = new LoggingInvocationProcessor();
        writer = new StringWriter();
    }

    public void testPreProcess() {
        String[] args = {"username", "password"};
        
        boolean rc = lip.before(new XmlRpcInvocation(10, "handler",
                "method", null, Arrays.asList(args), writer));
        
        assertTrue(rc);
    }
    
    public void testPreProcessWithXmlArg() {
        String[] args = {"<?xml version=\"1.0\"?><somestuff>foo</somestuff>",
                "password"};

        boolean rc = lip.before(new XmlRpcInvocation(10, "handler",
                "method", null, Arrays.asList(args), writer));
        
        assertTrue(rc);
    }
    
    public void testPreProcessWithValidSession() {
        // create a web session indicating a logged in user.
        WebSession s = WebSessionFactory.createSession();
        assertNotNull(s);
        WebSessionFactory.save(s);
        assertNotNull(s.getId());
        
        String[] args = {s.getKey()};

        boolean rc = lip.before(new XmlRpcInvocation(10, "handler",
                "method", null, Arrays.asList(args), writer));
        
        assertTrue(rc);
    }
    
    public void testPreProcessWithInvalidSession() {
        String[] args = {"12312312xFFFFFABABABFFFCD01"};

        boolean rc = lip.before(new XmlRpcInvocation(10, "handler",
                    "method", null, Arrays.asList(args), writer));
        assertTrue(rc);
    }
    
    public void testPostProcess() {
        String[] args = {"<?xml version=\"1.0\"?><somestuff>foo</somestuff>",
                "password"};

        Object rc = lip.after(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer), "returnthis");
        assertEquals("returnthis", rc);
        assertEquals("", writer.toString());
    }
    
    public void testPostProcessValidSession() {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        // create a web session indicating a logged in user.
        WebSession s = WebSessionFactory.createSession();
        s.setWebUserId(user.getId());
        assertNotNull(s);
        WebSessionFactory.save(s);
        assertNotNull(s.getId());
        
        String[] args = {s.getKey()};
        
        lip.before(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer));
        Object rc = lip.after(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer), "returnthis");
        assertEquals("returnthis", rc);
        assertEquals("", writer.toString());
    }
    
    public void testPostProcessInvalidSession() {
        String[] args = {"12312312xFFFFFABABABFFFCD01"};
        
        lip.before(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer));
        Object rc = lip.after(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer), "returnthis");
        assertEquals("returnthis", rc);
        assertEquals("", writer.toString());
    }
    
    public void testPostProcessWhereFirstArgHasNoX() {
        String[] args = {"abcdefghijklmnopqrstuvwyz", "password"};

        Object rc = lip.after(new XmlRpcInvocation(10, "handler", "method",
                null, Arrays.asList(args), writer), "returnthis");
        assertEquals("returnthis", rc);
        assertEquals("", writer.toString());
    }

    public void testAuthLogin() {
        String[] args = {"user", "password"};

        Object rc = lip.after(new XmlRpcInvocation(10, "auth", "login",
                null, Arrays.asList(args), writer), "returnthis");
        assertEquals("returnthis", rc);
        assertEquals("", writer.toString());
    }
}
