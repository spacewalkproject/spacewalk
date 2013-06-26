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
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * RemoveSlavesAction extends RhnAction
 *
 * @version $Rev: 1 $
 */
public class RemoveSlavesAction extends RhnAction {

    private static final String LIST_NAME = "issSlaveList";
    public static final String DATA_SET = "all";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
                    HttpServletRequest request, HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(
                            "Only satellite admins can modify allowed-slaves");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.slave"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        ActionForward destination = null;
        Set sessionSet = null;

        Long sid = getSid(request);
        if (sid == null) {
            sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl().getLabel());
            request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        }
        else {
            request.setAttribute(ListTagHelper.PARENT_URL,
                            request.getRequestURI() + "?sid=" + sid.toString());
        }

        List<IssSlave> slaves = findSelectedSlaves(sessionSet, sid);

        if (request.getParameter("dispatch") != null) {
            if (!slaves.isEmpty()) {
                destination = handleDispatchAction(mapping, request, slaves);
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
            helper.syncSelections(sessionSet, slaves);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(), request);
        }

        request.setAttribute(DATA_SET, slaves);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);

        return StrutsDelegate.getInstance().forwardParams(mapping.findForward("default"),
                        makeParamMap(request));
    }

    private Long getSid(HttpServletRequest req) {
        String sid = req.getParameter("sid");

        if (sid != null) {
            return Long.parseLong(sid);
        }
        return null;
    }

    private List<IssSlave> findSelectedSlaves(Set sessionSet, Object sidIn) {
        List<IssSlave> slaves = new ArrayList<IssSlave>();

        if (sessionSet != null) {
            Set<String> sids = sessionSet;
            for (String sid : sids) {
                IssSlave aSlave = IssFactory.lookupSlaveById(Long.parseLong(sid));
                slaves.add(aSlave);
            }
        }
        else if (sidIn != null) {
            slaves.add(IssFactory.lookupSlaveById(Long.parseLong(sidIn.toString())));
        }

        return slaves;
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
                    HttpServletRequest request, List<IssSlave> slaves) {
        for (IssSlave slave : slaves) {
            IssFactory.remove(slave);
        }

        ActionMessages msg = new ActionMessages();
        if (slaves.size() == 1) {
            IssSlave slave = slaves.get(0);
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_slave_removed", slave.getSlave()));

        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                            "message.iss_slaves_removed"));
        }
        getStrutsDelegate().saveMessages(request, msg);
        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_SLAVES;
    }

}
