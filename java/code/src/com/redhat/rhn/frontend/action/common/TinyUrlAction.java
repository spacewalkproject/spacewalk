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
package com.redhat.rhn.frontend.action.common;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * TinyUrlAction - action to perform internal redirect to Kickstart download files
 * @version $Rev$
 */
public class TinyUrlAction extends RhnAction {

    private static Logger log = Logger.getLogger(TinyUrlAction.class);

    public static final String TY_TOKEN = "tytoken";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        String token = request.getParameter(TY_TOKEN);
        if (log.isDebugEnabled()) {
            log.debug("token: " + token);
            Enumeration e = request.getParameterNames();
            while (e.hasMoreElements()) {
                String name = (String) e.nextElement();
                log.debug("param.name: " + name + " val: " +
                        request.getParameter(name));
            }
        }

        TinyUrl turl = CommonFactory.lookupTinyUrl(token);
        if (turl != null) {
            if (log.isDebugEnabled()) {
                log.debug("turl: " + turl.getUrl());
            }
            request.setAttribute("ksurl", turl.getUrl());
            if (log.isDebugEnabled()) {
                log.debug("ksurl in request attribute before we call include: " +
                        request.getAttribute("ksurl"));
            }
            request.getRequestDispatcher("/kickstart/DownloadFile.do").
                forward(request, response);
            if (log.isDebugEnabled()) {
                log.debug("include() called ...");
            }
        }
        else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
        return null;
    }

}
