/**
 * Copyright (c) 2013 Red Hat, Inc.
 * All Rights Reserved.
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
 *
 */
package com.redhat.rhn.frontend.action.iss;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.db.datasource.DataList;
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
 * IssMasterAction extends RhnAction
 *
 * @version $Rev: 1 $
 */
public class IssRemoveSlavesAction extends RhnAction {

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

        Map params = makeParamMap(request);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        Set sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl().getLabel());
        List<IssSlave> slaves = findSelectedSlaves(sessionSet);

        SessionSetHelper helper = new SessionSetHelper(request);

        if (request.getParameter("dispatch") != null) {
            if (!sessionSet.isEmpty()) {
                return handleDispatchAction(mapping, request, sessionSet, slaves);
            }
            RhnHelper.handleEmptySelection(request);
        }

        DataList<IssSlave> result = new DataList<IssSlave>(slaves);

        // if I have a previous set selections populate data using it
        if (!sessionSet.isEmpty()) {
            helper.syncSelections(sessionSet, result);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(), request);
        }

        request.setAttribute(DATA_SET, result);
        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);

        return StrutsDelegate.getInstance().forwardParams(mapping.findForward("default"),
                        params);
    }

    private List<IssSlave> findSelectedSlaves(Set sessionSet) {
        Set<String> sids = (Set<String>) sessionSet;
        List<IssSlave> slaves = new ArrayList<IssSlave>();
        for (String sid : sids) {
            IssSlave aSlave = IssFactory.lookupSlaveById(Long.parseLong(sid));
            slaves.add(aSlave);
        }
        return slaves;
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
                    HttpServletRequest request,
                    Set sessionSet,
                    List<IssSlave> slaves) {
        for (IssSlave slave : slaves) {
            IssFactory.remove(slave);
        }

        ActionMessages msg = new ActionMessages();
        msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                "message.iss_slaves_removed"));
        getStrutsDelegate().saveMessages(request, msg);
        sessionSet.clear();
        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_SLAVES;
    }

}
