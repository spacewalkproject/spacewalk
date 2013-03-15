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

package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.domain.server.Crash;
import com.redhat.rhn.domain.server.CrashFactory;
import com.redhat.rhn.domain.server.CrashNote;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.system.CrashManager;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * CrashNoteDeleteAction
 * @version $Rev$
 */
public class CrashNoteDeleteAction extends RhnAction {

    public static final String SID = "sid";
    public static final String CRASH = "crash";
    public static final String CRASH_ID = "crid";
    public static final String CRASH_NOTE_ID = "cnid";
    public static final String SUBJECT = "subject";
    public static final String NOTE  = "note";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        DynaActionForm daForm = (DynaActionForm) form;
        User loggedInUser = rctx.getCurrentUser();
        Server server = rctx.lookupAndBindServer();

        Long crashId = rctx.getRequiredParam(CRASH_ID);
        Crash crash = CrashManager.lookupCrashByUserAndId(loggedInUser, crashId);

        Long crNoteId = null;
        String crNoteIdStr = request.getParameter(CRASH_NOTE_ID);
        if (!StringUtils.isBlank(crNoteIdStr)) {
            crNoteId = Long.parseLong(request.getParameter(CRASH_NOTE_ID));
        }

        CrashNote crashNote = null;
        if (crNoteId != null) {
            crashNote = CrashManager.lookupCrashNoteByIdAndCrash(crNoteId, crash);
        }

        Map<String, Object> params = new HashMap<String, Object>();
        params.put(RequestContext.SID, request.getParameter(RequestContext.SID));
        params.put(CRASH_ID, crashId);
        ActionForward forward = getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);

        if (isSubmitted(daForm)) {
            forward = getStrutsDelegate().forwardParams(mapping.findForward("success"),
                      params);
            CrashFactory.delete(crashNote);
        }

        request.setAttribute(CRASH_ID, crash.getId());
        request.setAttribute(CRASH, crash);
        request.setAttribute(SID, crash.getServer().getId());
        request.setAttribute(SUBJECT, crashNote.getSubject());
        request.setAttribute(NOTE, crashNote.getNote());
        request.setAttribute(CRASH_NOTE_ID, crashNote.getId());
        return forward;
    }
}
