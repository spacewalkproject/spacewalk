/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;

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
                KickstartSession session = (KickstartSession) params.get("session");
                if (host != null && ksdata != null) {
                    if (session != null) {
                        fileContents = generateFile(host, ksdata, session);
                    }
                    else {
                        fileContents = generateFile(host, ksdata);
                    }
                }
                else {
                    log.error("No kickstart filecontents found for: " + url + 
                            " params: " + params + " ksdata: " + ksdata);
                    // send 404 to the user since we don't have a kickstart profile match
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
                if (log.isDebugEnabled()) {
                    log.debug("fileContents: " + fileContents);
                }
                
            }
        }
        renderOutput(response, fileContents);
        return null;
    }
    
    private String generateFile(String host, KickstartData ksdata) {
        return ksdata.getFileData(host, null);
    }

    private String generateFile(String host, KickstartData ksdata, 
            KickstartSession session) {
        return ksdata.getFileData(host, session);
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
