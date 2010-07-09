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
import com.redhat.rhn.common.errors.BadParameterExceptionHandler;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.frontend.action.common.BadParameterException;
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
 * BadParameterExceptionHandlerTest
 * @version $Rev$
 */
public class BadParameterExceptionHandlerTest extends MockObjectTestCase {

    private TraceBackAction tba;

    public void setUp() throws Exception {
        tba = new TraceBackAction();
        MessageQueue.registerAction(tba, TraceBackEvent.class);
        MessageQueue.startMessaging();
    }


    public void testExecute() throws Exception {

        /*
         * Turn off logging and tracebacks
         * Logging complains and sends warnings (expected)
         * Tracebacks will get sent to root@localhost
         */
        Logger log = Logger.getLogger(BadParameterExceptionHandler.class);
        Level origLevel = log.getLevel();
        log.setLevel(Level.OFF);
        Config c = Config.get();
        String mail = c.getString("web.traceback_mail");
        try {
            c.setString("web.traceback_mail", "jesusr@redhat.com");

            BadParameterException ex =
                new BadParameterException("Invalid test parameter");

            Mock mapping = mock(ActionMapping.class, "mapping");
            mapping.expects(once()).method("getInputForward").withNoArguments()
                    .will(returnValue(new ActionForward()));

            // mockup a dumb ass Enumeration class for the Mock request
            // jmock RULES!
            RhnMockHttpServletRequest request = TestUtils
                    .getRequestWithSessionAndUser();
            request.setupGetHeaderNames(new Vector().elements());
            request.setupGetMethod("POST");
            request.setupGetRequestURI("http://localhost:8080");
            request.setupGetParameterNames(new Vector().elements());
            RhnMockHttpServletResponse response = new RhnMockHttpServletResponse();
            RhnMockDynaActionForm form = new RhnMockDynaActionForm();

            BadParameterExceptionHandler bpeh = new BadParameterExceptionHandler();

            bpeh.execute(ex, new ExceptionConfig(), (ActionMapping) mapping
                    .proxy(), form, request, response);
            mapping.verify();
        }
        finally {
            // Turn tracebacks and logging back on
            // wait for message to be sent
            int tries = 0;
            Thread.sleep(1000);
            while (MessageQueue.getMessageCount() != 0 && tries  < 10) {
                Thread.sleep(100);
                tries++;
            }
            // don't bother resetting it if it were already missing.
            // Blame mmccune for change getString to return freakin null.
            if (mail != null) {
                c.setString("web.traceback_mail", mail);
            }
            log.setLevel(origLevel);
        }
    }

    protected void tearDown() {
        MessageQueue.stopMessaging();
        MessageQueue.deRegisterAction(tba, TraceBackEvent.class);
    }

}
