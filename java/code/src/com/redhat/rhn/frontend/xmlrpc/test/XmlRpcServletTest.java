/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.common.LoggingFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.XmlRpcServlet;
import com.redhat.rhn.testing.TestCaseHelper;
import com.redhat.rhn.testing.UserTestUtils;

import com.mockobjects.servlet.MockServletInputStream;

import org.jmock.Expectations;
import org.jmock.integration.junit3.MockObjectTestCase;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class XmlRpcServletTest extends MockObjectTestCase {

    protected void setUp() throws Exception {
        super.setUp();
        try {
            LoggingFactory.clearLogId();
        }
        catch (Exception se) {
            TestCaseHelper.tearDownHelper();
            LoggingFactory.clearLogId();
        }
    }

    protected void tearDown() throws Exception {
        HibernateFactory.closeSession();
        super.tearDown();
    }

    public void doTest(String request, String expectedResponse)
        throws Exception {

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);

        MockServletInputStream input = new MockServletInputStream();
        input.setupRead(request.getBytes());

        HttpServletRequest mockreq = this.mock(HttpServletRequest.class);
        HttpServletResponse mockresp = this.mock(HttpServletResponse.class);

        context().checking(new Expectations() { {
            atLeast(1).of(mockreq).getHeader("SOAPAction");
            will(returnValue(null));
            atLeast(1).of(mockreq).getInputStream();
            will(returnValue(input));
            atLeast(1).of(mockreq).getRemoteAddr();
            will(returnValue("porsche.devel.redhat.com"));
            atLeast(1).of(mockreq).getLocalName();
            will(returnValue("foo.devel.redhat.com"));
            atLeast(1).of(mockreq).getProtocol();
            will(returnValue("http"));
            atLeast(1).of(mockresp).getWriter();
            will(returnValue(pw));
            atLeast(1).of(mockresp).setContentType("text/xml");
        } });

        // ok run servlet
        XmlRpcServlet xrs = new XmlRpcServlet(new MockHandlerFactory(), null);
        xrs.init();
        xrs.doPost(mockreq, mockresp);

        assertEquals(expectedResponse, sw.toString());
    }

    public void testStringReturn() throws Exception {
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>registration.privacyStatement</methodName>" +
               " <params> </params> </methodCall>",
               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><params><param><value><string>This is " +
               "a privacy statement!</string></value></param></params>" +
               "</methodResponse>");
    }

    public void testHashReturn() throws Exception {
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>unittest.login</methodName> <params> " +
               "</params> </methodCall>",
               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><params><param><value><struct><member>" +
               "<name>X-RHN-Server-Id</name><value><string>foo" +
               "</string></value></member><member><name>" +
               "X-RHN-Auth-Server-Time</name><value><string>foo" +
               "</string></value></member><member><name>X-RHN-Auth" +
               "</name><value><string>foo</string></value></member>" +
               "<member><name>X-RHN-Auth-Channels</name><value><string>" +
               "foo</string></value></member><member><name>" +
               "X-RHN-Auth-Expire-Offset</name><value><string>foo" +
               "</string></value></member><member><name>" +
               "X-RHN-Auth-User-Id</name><value><string>foo</string>" +
               "</value></member></struct></value></param></params>" +
               "</methodResponse>");
    }

    public void testWrongNumParams() throws Exception {
        Random rand = new Random();
        int param1 = rand.nextInt();
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>unittest.add</methodName> <params> " +
               "<param><value><i4>" + param1 + "</i4></value></param>" +
               "</params>" +
               "</methodCall>",

               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><fault><value><struct><member><name>" +
               "faultCode</name><value><int>-1</int></value></member>" +
               "<member><name>faultString</name><value><string>" +
               "redstone.xmlrpc.XmlRpcFault: Could not find method: add in class: " +
               "com.redhat.rhn.frontend.xmlrpc.test.UnitTestHandler with params: " +
               "[java.lang.Integer]</string></value></member></struct></value></fault>" +
               "</methodResponse>");
    }

    public void testWithParam() throws Exception {
        Random rand = new Random();
        int param1 = rand.nextInt();
        int param2 = rand.nextInt();
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>unittest.add</methodName> <params> " +
               "<param><value><i4>" + param1 + "</i4></value></param>" +
               "<param><value><i4>" + param2 + "</i4></value></param>" +
               "</params>" +
               "</methodCall>",

               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><params><param><value><i4>" +
               (param1 + param2) + "</i4>" +
               "</value></param></params>" +
               "</methodResponse>");
    }

    public void testFault() throws Exception {
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>unittest.throwFault</methodName> <params> " +
               "</params> </methodCall>",

               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><fault><value><struct><member><name>" +
               "faultCode</name><value><int>1</int></value></member>" +
               "<member><name>faultString</name><value><string>" +
               "redstone.xmlrpc.XmlRpcFault: " +
               "This does not appear to be a valid username.</string>" +
               "</value></member></struct></value></fault>" +
               "</methodResponse>");
    }

    public void testTranslation() throws Exception {
        User user = UserTestUtils.findNewUser("testuser", "testorg");
        doTest("<?xml version=\"1.0\"?> <methodCall> " +
               "<methodName>unittest.getUserLogin</methodName> <params> " +
               "<param><value><i4>" + user.getId() + "</i4></value></param>" +
               "</params>" +
               "</methodCall>",

               "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
               "<methodResponse><params><param><value><string>" +
               user.getLogin() +
               "</string></value></param></params>" +
               "</methodResponse>");
    }

    public void testCtor() {
        // this test makes sure we always have a default ctor
        XmlRpcServlet xrs = new XmlRpcServlet();
        assertNotNull(xrs);
    }
}
