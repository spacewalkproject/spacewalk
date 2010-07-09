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
package com.redhat.rhn.common.errors.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.errors.PermissionExceptionHandler;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.frontend.events.TraceBackAction;
import com.redhat.rhn.frontend.events.TraceBackEvent;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.TestUtils;

import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.config.ExceptionConfig;
import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

import java.util.Vector;

/**
 * PermissionExceptionHandlerTest
 * @version $Rev$
 */
public class PermissionExceptionHandlerTest extends MockObjectTestCase {

    private TraceBackAction tba;

    public void setUp() {
        tba = new TraceBackAction();
        MessageQueue.registerAction(tba, TraceBackEvent.class);
        MessageQueue.startMessaging();
    }

    public void testExecute() throws Exception {

        /*
         * Turn off logging and tracebacks Logging complains and sends warnings
         * (expected) Tracebacks will get sent to root@localhost
         */
        Logger log = Logger.getLogger(PermissionExceptionHandler.class);
        Level orig = log.getLevel();
        log.setLevel(Level.OFF);
        Config c = Config.get();
        String mail = c.getString("web.traceback_mail", "");
        try {
            c.setString("web.traceback_mail", "jesusr@redhat.com");

            PermissionException ex = new PermissionException("Simply a test");

            Mock mapping = mock(ActionMapping.class, "mapping");
            mapping.expects(once()).method("getInputForward").withNoArguments()
                    .will(returnValue(new ActionForward()));

            RhnMockHttpServletRequest request = TestUtils
                    .getRequestWithSessionAndUser();
            request.setupGetHeaderNames(new Vector().elements());
            request.setupGetMethod("POST");
            request.setupGetRequestURI("http://localhost:8080");
            request.setupGetParameterNames(new Vector().elements());

            RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
            response.setExpectedSetStatusCalls(1);
            RhnMockDynaActionForm form = new RhnMockDynaActionForm();

            PermissionExceptionHandler peh = new PermissionExceptionHandler();

            peh.execute(ex, new ExceptionConfig(), (ActionMapping) mapping
                    .proxy(), form, request, response);
            assertEquals(ex, request.getAttribute("error"));
            mapping.verify();
            response.verify();
        }
        finally {
            // Turn tracebacks and logging back on
            Thread.sleep(1000); // wait for message to be sent
            c.setString("web.traceback_mail", mail);
            log.setLevel(orig);
        }
    }

    protected void tearDown() {
        MessageQueue.stopMessaging();
        MessageQueue.deRegisterAction(tba, TraceBackEvent.class);
    }
}
