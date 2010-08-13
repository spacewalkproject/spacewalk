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
package com.redhat.rhn.frontend.action.systems.sdc;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemNoteDeleteAction
 * @version $Rev: 1 $
 */
public class SystemNoteDeleteAction extends RhnAction {

    private static Logger log = Logger.getLogger(SystemNoteDeleteAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm)form;
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        ActionForward forward = null;

        Long nid = Long.parseLong(request.getParameter("nid"));

        User loggedInUser = rctx.getLoggedInUser();
        Long sid = Long.parseLong(request.getParameter("sid"));
        Server server = SystemManager.lookupByIdAndUser(sid, loggedInUser);
        Note note = SystemManager.lookupNoteByIdAndSystem(loggedInUser, nid, sid);

        Map params = new HashMap();

        if (isSubmitted(daForm)) {
            SystemManager.deleteNote(loggedInUser, sid, nid);
            createSuccessMessage(request, "message.notedeleted", "");
            params.put(RequestContext.SID, request.getParameter(RequestContext.SID));
            forward = strutsDelegate.forwardParams(mapping.findForward("success"),
                    params);
        }
        else {
            setupPageAndFormValues(rctx.getRequest(), daForm, server, note);
            forward =  strutsDelegate.forwardParams(mapping.findForward("default"),
                    params);
        }

        return forward;
    }

    protected void setupPageAndFormValues(HttpServletRequest request,
            DynaActionForm daForm, Server s, Note n) {

        request.setAttribute("system", s);
        request.setAttribute("n", n);
        request.setAttribute("id", n.getId());
        request.setAttribute("server_id", s.getId());
        request.setAttribute("subject", n.getSubject());
        request.setAttribute("note", n.getNote());

        request.setAttribute("sid", s.getId());

        daForm.set("sid", s.getId());
        daForm.set("subject", n.getSubject());
        daForm.set("note", n.getNote());
    }

}
