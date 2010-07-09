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

import com.redhat.rhn.common.util.download.DownloadException;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.xmlrpc.NoSuchKickstartException;
import com.redhat.rhn.manager.kickstart.KickstartManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Render a kickstart file to Anaconda
 *
 * @version $Rev $
 */
public class RenderKickstartFileAction extends Action {

    private static Logger log = Logger.getLogger(RenderKickstartFileAction.class);

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        String url = request.getParameter("ksurl");
        if (url == null) {
            url = (String) request.getAttribute("ksurl");
        }

        if (log.isDebugEnabled()) {
            log.debug("ksurl = " + url + " param: " + request.getAttribute("ksurl"));
        }
        String fileContents = null;
        if (url != null) {
            KickstartHelper helper = new KickstartHelper(request);
            Map params = helper.parseKickstartUrl(url);
            if (params != null) {
                String host = (String) params.get("host");
                KickstartData ksdata = (KickstartData) params.get("ksdata");
                if (log.isDebugEnabled()) {
                    log.debug("execute.host: " + host);
                    log.debug("execute.ksdata: " + ksdata);
                }
                if (host != null && ksdata != null) {
                    try {
                        if (helper.isProxyRequest()) {
                            fileContents = KickstartManager.
                                getInstance().renderKickstart(host, ksdata);
                        }
                        else {
                            fileContents = KickstartManager.
                                getInstance().renderKickstart(ksdata);
                        }
                    }
                    catch (DownloadException de) {
                        fileContents = de.getContent();
                    }
                }
                else {
                    log.error("No kickstart filecontents found for: " + url +
                            " params: " + params + " ksdata: " + ksdata);
                    // send 404 to the user since we don't have a kickstart profile match
                    //response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    throw new NoSuchKickstartException();
                }
                if (log.isDebugEnabled()) {
                    log.debug("fileContents: " + fileContents);
                }

            }
        }
        renderOutput(response, fileContents);
        return null;
    }

    private void renderOutput(HttpServletResponse response, String file)
            throws IOException {
        response.setContentType("text/plain");
        int contentLength = file == null ? 0 : file.getBytes().length;
        response.setContentLength(contentLength);
        if (contentLength > 0) {
            OutputStream out = response.getOutputStream();
            out.write(file.getBytes());
            out.flush();
        }
    }

}
