/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.audit;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DownloadAction;

import com.redhat.rhn.domain.audit.ScapFactory;
import com.redhat.rhn.domain.audit.XccdfTestResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.audit.scap.file.ScapResultFile;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * ScapDownloadAction
 */
public class ScapDownloadAction extends DownloadAction {
/*
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        response.setHeader("Content-

        try {
            OutputStream

        request.setAttribute("testResult", testResult);
        request.setAttribute("system", server);

        request.setAttribute(ListTagHelper.PARENT_URL,
                request.getRequestURI() + "?sid=" + sid + "&xid=" + xid);
        SdcHelper.ssmCheck(request, sid, user);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
*/
    @Override
    protected StreamInfo getStreamInfo(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        Logger log = Logger.getLogger(ScapDownloadAction.class);
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        Long sid = context.getRequiredParam("sid");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        Long xid = context.getRequiredParam("xid");
        XccdfTestResult testResult = ScapFactory.lookupTestResultByIdAndSid(xid,
                server.getId());
        String filename = context.getRequiredParamAsString("name");
        ScapResultFile file = new ScapResultFile(testResult, filename);

        log.debug("Serving " + file);
        if (!file.getHTML()) {
            response.setHeader("Content-Disposition", "attachment; filename=" + filename);
        }
        return file;
    }

}
