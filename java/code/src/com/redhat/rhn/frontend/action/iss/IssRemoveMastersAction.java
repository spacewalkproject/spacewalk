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

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssOrgCatalogue;
import com.redhat.rhn.frontend.struts.RequestContext;
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
public class IssRemoveMastersAction extends RhnAction {

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

        RequestContext requestContext = new RequestContext(request);
        Map params = makeParamMap(request);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        Set sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl().getLabel());
        List<IssOrgCatalogue> masters = findSelectedMasters(sessionSet);

        SessionSetHelper helper = new SessionSetHelper(request);

        if (request.getParameter("dispatch") != null) {
            if (!sessionSet.isEmpty()) {
                return handleDispatchAction(mapping, requestContext, sessionSet, masters);
            }
            RhnHelper.handleEmptySelection(request);
        }

        DataList<IssOrgCatalogue> result = new DataList<IssOrgCatalogue>(masters);

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

    private List<IssOrgCatalogue> findSelectedMasters(Set sessionSet) {
        Set<String> mids = (Set<String>) sessionSet;
        List<IssOrgCatalogue> masters = new ArrayList<IssOrgCatalogue>();
        for (String mid : mids) {
            IssOrgCatalogue aMaster = IssFactory.lookupMasterById(Long.parseLong(mid));
            masters.add(aMaster);
        }
        return masters;
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
                    RequestContext context, Set sessionSet, List<IssOrgCatalogue> masters) {
        for (IssOrgCatalogue master : masters) {
            IssFactory.remove(master);
        }

        sessionSet.clear();
        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_MASTERS;
    }

}
