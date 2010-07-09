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

package com.redhat.rhn.frontend.events;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.EventMessage;
import com.redhat.rhn.domain.user.User;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;

/**
 * An event representing an error generated from the web frontend
 *
 * @version $Rev$
 */
public class TraceBackEvent extends BaseEvent implements EventMessage {

    private Throwable throwable;
    private static final String HASHES = "########";

    /**
     * format this message as a string
     *   TODO mmccune - fill out the email properly with the entire
     *                  request values
     * @return Text of email.
     */
    public String toText() {
        StringWriter sw = new StringWriter();
        PrintWriter out = new PrintWriter(sw);
        LocalizationService ls = LocalizationService.getInstance();
        HttpServletRequest request = getRequest();
        User user = getUser();

        if (request != null) {
            out.println(ls.getMessage("traceback message header"));
            out.print(request.getMethod());
            out.print(" ");
            out.println(request.getRequestURI());
            out.println();
            out.print(ls.getMessage("date", getUserLocale()));
            out.print(":");
            out.println(ls.getBasicDate());
            out.print(ls.getMessage("headers", getUserLocale()));
            out.println(":");
            Enumeration e = request.getHeaderNames();
            while (e.hasMoreElements()) {
                String headerName = (String) e.nextElement();
                out.print("  ");
                out.print(headerName);
                out.print(": ");
                out.println(request.getHeader(headerName));
            }
            out.println();
            out.print(ls.getMessage("request", getUserLocale()));
            out.println(":");
            out.println(request.toString());

            if (request.getMethod().equals("POST")) {
                out.print(ls.getMessage("form variables", getUserLocale()));
                out.println(":");
                Enumeration ne = request.getParameterNames();
                while (ne.hasMoreElements()) {
                    String paramName = (String) ne.nextElement();
                    out.print("  ");
                    out.print(paramName);
                    out.print(": ");
                    if (paramName.equals("password")) {
                        out.println(HASHES);
                    }
                    else {
                        out.println(request.getParameter(paramName));
                    }
                }
                out.println();
            }
        }
        else {
            out.print(ls.getMessage("date", getUserLocale()));
            out.print(":");
            out.println(ls.getBasicDate());
            out.println();
            out.print(ls.getMessage("request", getUserLocale()));
            out.println(":");
            out.println("No request information");
            out.println();
        }

        out.println();

        out.print(ls.getMessage("user info"));
        out.println(":");
        if (user != null) {
            out.println(user.toString());
        }
        else {
            out.println(ls.getMessage("no user loggedin", getUserLocale()));
        }
        out.println();
        out.print(ls.getMessage("exception", getUserLocale()));
        out.println(":");
        if (throwable != null) {
            throwable.printStackTrace(out);
        }
        else {
            out.println("no throwable");
        }
        out.close();
        return sw.toString();
    }

    /**
     *
     * @return hashmark string
     */
    public String getHashMarks() {
      return TraceBackEvent.HASHES;
    }

    /**
     * Set the throwable for this event
     * @param tIn Exception to be captured in Event.
     */
    public void setException(Throwable tIn) {
        this.throwable = tIn;
    }
}


