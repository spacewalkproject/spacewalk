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

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerNoteFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemNoteEditAction
 * @version $Rev: 1 $
 */
public class SystemNoteEditAction extends RhnAction {

    private static Logger log = Logger.getLogger(SystemNoteEditAction.class);

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        String forwardName = "default";

        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm)form;
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        ActionForward forward = null;
        Map params = new HashMap();

        Long nid = null;
        if (!(request.getParameter("nid") == null)) {
            nid = Long.parseLong(request.getParameter("nid"));
        }

        Note note = new Note();
        User loggedInUser = rctx.getLoggedInUser();
        Long sid = rctx.getRequiredParam(RequestContext.SID);
        Server server = SystemManager.lookupByIdAndUser(sid, loggedInUser);

        if (nid != null) {
            request.setAttribute("id", nid);
            note = SystemManager.lookupNoteByIdAndSystem(loggedInUser, nid, sid);
        }

        params.put(RequestContext.SID, request.getParameter(RequestContext.SID));
        forward = strutsDelegate.forwardParams(mapping.findForward("default"),
                params);

        if (isSubmitted(daForm)) {
            ActionErrors errors = new ActionErrors();

            if (daForm.getString("subject").length() > 80) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.note.subjecttoolong"));
            }

            if (daForm.getString("subject").length() == 0) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.note.subjecttooshort"));
            }

            if (daForm.getString("note").length() > 4000) {
                errors.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("edit.note.notetoolong"));
            }

            note.setSubject(daForm.getString("subject"));
            note.setNote(daForm.getString("note"));

            if (rctx.hasParam("create_button")) {
                if (errors.isEmpty()) {
                    createSuccessMessage(request, "message.notecreated", "");
                    note.setCreator(loggedInUser);
                    server.addNote(note);
                }
            }
            else {
                if (errors.isEmpty()) {
                        createSuccessMessage(request, "message.noteupdated", "");
                }
            }
            if (!errors.isEmpty()) {
                addErrors(request, errors);
                forward = strutsDelegate.forwardParams(mapping.findForward("error"),
                        params);
            }
            else {
                ServerNoteFactory.save(note);
                forward = strutsDelegate.forwardParams(mapping.findForward("success"),
                        params);
            }
        }

        setupPageAndFormValues(rctx.getRequest(), daForm, server, note);
        return forward;
    }

    protected void setupPageAndFormValues(HttpServletRequest request,
            DynaActionForm daForm, Server s, Note n) {

        request.setAttribute("system", s);
        request.setAttribute("n", n);
        request.setAttribute("id", n.getId());
        request.setAttribute("server_id", s.getId());

        daForm.set("subject", n.getSubject());
        daForm.set("note", n.getNote());
    }

}
