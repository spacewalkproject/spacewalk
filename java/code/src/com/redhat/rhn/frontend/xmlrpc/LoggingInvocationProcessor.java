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
package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.translation.Translator;
import com.redhat.rhn.domain.session.InvalidSessionIdException;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;

import java.util.List;

import redstone.xmlrpc.XmlRpcInvocation;
import redstone.xmlrpc.XmlRpcInvocationInterceptor;

/**
 * LoggingInvocationProcessor extends the marquee-xmlrpc library to allow
 * us to log method calls.
 * @version $Rev$
 */
public class LoggingInvocationProcessor implements XmlRpcInvocationInterceptor {
    private static Logger log = Logger.getLogger(LoggingInvocationProcessor.class);
    private static ThreadLocal caller = new ThreadLocal();

    private static ThreadLocal timer = new ThreadLocal() {
        protected synchronized Object initialValue() {
            return new StopWatch();
        }
    };

    /**
     * {@inheritDoc}
     */
    public boolean before(XmlRpcInvocation invocation) {

        // we start the timing and return true so processing
        // continues.
        // NOTE: as of commons-lang 2.1 we must reset before
        // starting.
        getStopWatch().reset();
        getStopWatch().start();

        List arguments = invocation.getArguments();
        // HACK ALERT!  We need the caller, would be better in
        // the postProcess, but that works for ALL methods except
        // logout.  So we do it here.
        if ((arguments != null) && (arguments.size() > 0)) {
            String arg = (String) Translator.convert(
                    arguments.get(0), String.class);
            if (potentialSessionKey(arg)) {
                setCaller(getLoggedInUser(arg));
            }
        }

        return true;
    }

    /**
     * {@inheritDoc}
     */
    public Object after(XmlRpcInvocation invocation, Object returnValue) {
        StringBuffer buf = new StringBuffer();
        try {
            buf.append("REQUESTED FROM: ");
            buf.append("*callerIp*"); // TODO: what happened to the caller's IP
            buf.append(" CALL: ");
            buf.append(invocation.getHandlerName());
            buf.append(".");
            buf.append(invocation.getMethodName());
            buf.append("(");

            processArguments(invocation.getHandlerName(),
                             invocation.getMethodName(),
                             invocation.getArguments(),
                             buf);

            buf.append(") CALLER: (");
            buf.append(getCaller());
            buf.append(") TIME: ");

            getStopWatch().stop();

            buf.append(getStopWatch().getTime() / 1000.00);
            buf.append(" seconds");

            log.info(buf.toString());
        }
        catch (RuntimeException e) {
            log.error("postProcess error", e);
        }

        return returnValue;
    }

    /**
     * {@inheritDoc}
     */
    public void onException(XmlRpcInvocation invocation, Throwable exception) {
        StringBuffer buf = new StringBuffer();
        try {
            buf.append("REQUESTED FROM: ");
            buf.append("*callerIp*"); // TODO: what happened to the caller's IP
            buf.append(" CALL: ");
            buf.append(invocation.getHandlerName());
            buf.append(".");
            buf.append(invocation.getMethodName());
            buf.append("(");

            processArguments(invocation.getHandlerName(),
                             invocation.getMethodName(),
                             invocation.getArguments(),
                             buf);

            buf.append(") CALLER: (");
            buf.append(getCaller());
            buf.append(") TIME: ");

            getStopWatch().stop();

            buf.append(getStopWatch().getTime() / 1000.00);
            buf.append(" seconds");

            log.error(buf.toString(), exception);
        }
        catch (RuntimeException e) {
            log.error("postProcess error", e);
        }
    }

    private void processArguments(String handler, String method,
                                  List arguments, StringBuffer buf) {

        // bug 199130: don't log password :)
        if ("auth.login".equals(handler + "." + method)) {
            if (arguments != null && arguments.size() > 0) {
                String arg = (String) Translator.convert(
                        arguments.get(0), String.class);

                buf.append(arg);
                buf.append(", ********");
            }
        }
        else {
            if (arguments != null) {
                int size = arguments.size();
                for (int i = 0; i < size; i++) {
                    String arg = (String) Translator.convert(
                            arguments.get(i), String.class);

                    buf.append(arg);

                    if ((i + 1) < size) {
                        buf.append(", ");
                    }
                }
            }
        }
    }

    /**
     * If the key is a sessionKey, we'll return the username, otherwise we'll
     * return (unknown).
     * @param key potential sessionKey.
     * @return  username, (Invalid Session ID), or (unknown);
     */
    private String getLoggedInUser(String key) {
        try {
            User user = BaseHandler.getLoggedInUser(key);
            if (user != null) {
                return user.getLogin();
            }
        }
        catch (LookupException le) {
            // do nothing
        }

        catch (InvalidSessionIdException e) {
            return "(Invalid Session ID)";
        }

        catch (Exception e) {
            log.error("problem with getting logged in user for logging", e);
        }

        return "(unknown)";
    }

    /**
     * Returns true if the given key contains an 'x' which is the separator
     * character in the session key.
     * @param key Potential key candidate.
     * @return true if the given key contains an 'x' which is the separator
     * character in the session key.
     */
    private boolean potentialSessionKey(String key) {
        if (key == null || key.equals("")) {
            return false;
        }

        // Get the id
        String[] keyParts = StringUtils.split(key, 'x');

        // make sure the id is numeric and can be made into a Long
        if (!StringUtils.isNumeric(keyParts[0])) {
            return false;
        }

        return true;
    }

    private static StopWatch getStopWatch() {
        return (StopWatch) timer.get();
    }

    private static String getCaller() {
        String c = (String) caller.get();
        if (c == null) {
            return "none";
        }

        return c;
    }

    private static void setCaller(String c) {
        caller.set(c);
    }
}
