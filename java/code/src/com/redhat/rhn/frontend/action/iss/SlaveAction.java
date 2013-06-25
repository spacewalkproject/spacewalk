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

import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.iss.IssFactory;
import com.redhat.rhn.domain.iss.IssMaster;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;


/**
 * SlaveAction extends RhnAction
 * @version $Rev: 1 $
 */
public class SlaveAction extends RhnAction {

    private static final String LIST_NAME = "issMasterList";
    public static final String DATA_SET = "all";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
              new PermissionException("Only satellite admins can work with known masters");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.iss.master"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        RequestContext requestContext = new RequestContext(request);

        Set sessionSet = SessionSetHelper.lookupAndBind(request, getSetDecl()
                .getLabel());
        if (!requestContext.isSubmitted()) {
            sessionSet.clear();
        }

        SessionSetHelper helper = new SessionSetHelper(request);

        if (request.getParameter("dispatch") != null) {
            // if its one of the Dispatch actions handle it..
            helper.updateSet(sessionSet, LIST_NAME);
            if (!sessionSet.isEmpty()) {
                return handleDispatchAction(mapping, requestContext);
            }
            RhnHelper.handleEmptySelection(request);
        }

        List<IssMaster> masters = IssFactory.listAllMasters();
        request.setAttribute(DATA_SET, masters);

        // if its a list action update the set and the selections
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(sessionSet, LIST_NAME, masters);
        }

        // if I have a previous set selections populate data using it
        if (!sessionSet.isEmpty()) {
            helper.syncSelections(sessionSet, masters);
            ListTagHelper.setSelectedAmount(LIST_NAME, sessionSet.size(),
                    request);
        }

        Map params = makeParamMap(request);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(), request);

        return StrutsDelegate.getInstance().forwardParams(
                mapping.findForward("default"), params);
    }

    private ActionForward handleDispatchAction(ActionMapping mapping,
            RequestContext context) {

        return mapping.findForward("confirm");
    }

    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.ISS_MASTERS;
    }

}
