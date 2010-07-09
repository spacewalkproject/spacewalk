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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.domain.kickstart.KickstartFactory;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Render a kickstart log.
 *
 * @version $Rev $
 */
public class RenderKickstartLogAction extends Action {

    private static final String ORG_TOKEN     = "orgtoken";
    private static final String KS_SESSION_ID = "ksid";

    private static Logger log =
        Logger.getLogger(RenderKickstartLogAction.class);

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
    throws Exception {

        String orgToken       = request.getParameter(ORG_TOKEN);
        String ksSessionIdStr = request.getParameter(KS_SESSION_ID);

        // Both orgToken and ksSessionId are required, otherwise we return a
        // 404.

        if (orgToken == null || ksSessionIdStr == null) {

            if (log.isDebugEnabled()) {
                log.debug(
                    "Invalid arguments: orgToken=" + orgToken + "; " +
                        "ksSessionId=" + ksSessionIdStr);
            }

            // Send a 404 to the user.

            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }

        // The parameters look good.  Now validate the user's org token.
        // we're using this for the SessionSwapException
        SessionSwap.extractData(orgToken);

        // Now, lookup the kickstart session id in the database and retrieve
        // the list of log messages associated with it.

        List logMessages =
            KickstartFactory.lookupGuestKickstartInstallLog(
                new Long(ksSessionIdStr));

        renderResponse(response, logMessages);

        return null;
    }

    private void renderResponse(HttpServletResponse response,
                                List /* <String> */ logMessages)
    throws IOException {

        response.setContentType("text/plain");

        // Compute the content length before we send anything across the wire.

        int contentLength = 0;
        if (logMessages != null) {
            Iterator iter = logMessages.iterator();
            while (iter.hasNext()) {
                String logLine = (String) iter.next();
                contentLength += logLine.length();
            }
        }
        response.setContentLength(contentLength);

        // Now send the actual contents.  In an effort to conserve memory, we
        // do this in a second step.

        if (contentLength > 0) {
            OutputStream out = response.getOutputStream();
            Iterator iter = logMessages.iterator();
            while (iter.hasNext()) {
                String logLine = (String) iter.next();
                out.write(logLine.getBytes());
            }
            out.flush();
        }
    }

}
