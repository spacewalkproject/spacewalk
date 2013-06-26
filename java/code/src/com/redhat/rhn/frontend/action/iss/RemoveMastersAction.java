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
package com.redhat.rhn.frontend.action.iss;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * RemoveMastersAction extends RhnAction
 *
 * @version $Rev: 1 $
 */
public class RemoveMastersAction extends RhnAction {

    private static final String LIST_NAME = "issMasterList";
    public static final String DATA_SET = "all";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(
                            "Only satellite admins can remove known masters");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.slave"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        ActionForward destination = null;
        Set sessionSet = null;

        Long mid = getMid(request);
        if (mid == null) {
            sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl().getLabel());
            request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        }
        else {
            request.setAttribute(ListTagHelper.PARENT_URL,
                            request.getRequestURI() + "?mid=" + mid.toString());
        }

        List<IssMaster> masters = findSelectedMasters(sessionSet, mid);

        if (request.getParameter("dispatch") != null) {
            if (!masters.isEmpty()) {
                destination = handleDispatchAction(mapping, request, sessionSet, masters);
                if (sessionSet != null) {
                    sessionSet.clear();
                }
                return destination;
            }
            RhnHelper.handleEmptySelection(request);
        }

        // if I have a previous set selections populate data using it
        if (sessionSet != null && !sessionSet.isEmpty()) {
            SessionSetHelper helper = new SessionSetHelper(request);
            helper.syncSelections(sessionSet, masters);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(), request);
        }

        request.setAttribute(DATA_SET, masters);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);

        return StrutsDelegate.getInstance().forwardParams(mapping.findForward("default"),
                        makeParamMap(request));
    }

    private Long getMid(HttpServletRequest req) {
        String mid = req.getParameter("mid");

        if (mid != null) {
            return Long.parseLong(mid);
        }
        return null;
    }

    private List<IssMaster> findSelectedMasters(Set sessionSet, Long midIn) {
        List<IssMaster> masters = new ArrayList<IssMaster>();

        if (sessionSet != null) {
            Set<String> mids = sessionSet;
            for (String mid : mids) {
                IssMaster aMaster = IssFactory.lookupMasterById(Long.parseLong(mid));
                masters.add(aMaster);
            }
        }
        else if (midIn != null) {
            masters.add(IssFactory.lookupMasterById(Long.parseLong(midIn.toString())));
        }

        return masters;
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
                    HttpServletRequest request,
                    Set sessionSet,
                    List<IssMaster> masters) {
        for (IssMaster master : masters) {
            IssFactory.remove(master);
        }

        ActionMessages msg = new ActionMessages();
        if (masters.size() == 1) {
            IssMaster master = masters.get(0);
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_master_removed", master.getLabel()));

        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_masters_removed"));
        }
        getStrutsDelegate().saveMessages(request, msg);
        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_MASTERS;
    }

}
