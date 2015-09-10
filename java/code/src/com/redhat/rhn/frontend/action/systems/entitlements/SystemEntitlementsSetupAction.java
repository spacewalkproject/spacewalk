/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemListSetupAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.apache.struts.util.LabelValueBean;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemEntitlementsSetupAction
 */
public class SystemEntitlementsSetupAction extends BaseSystemListSetupAction {

    private static Logger log = Logger.getLogger(SystemEntitlementsSetupAction.class);

    public static final String SHOW_COMMANDS = "showCommands";

    public static final String ADDON_ENTITLEMENTS = "addOnEntitlements";
    public static final String ADDON_ENTITLEMENT = "addOnEntitlement";

    public static final String MANAGEMENT_COUNTS_MESSAGE = "managementCountsMessage";
    public static final String VIRTUALIZATION_COUNTS_MESSAGE =
        "virtualizationCountsMessage";

    /**
     * {@inheritDoc}
     */
    @Override
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.SYSTEM_ENTITLEMENTS;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    protected DataResult<SystemOverview> getDataResult(User user, PageControl pc,
            ActionForm formIn) {
        return SystemManager.getSystemEntitlements(user, pc);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        ActionForward forward = super.execute(mapping, formIn, request, response);
        RequestContext rctx = new RequestContext(request);
        User user = rctx.getCurrentUser();

        log.debug("show: " + (request.getAttribute(SHOW_NO_SYSTEMS) == null));
        if (request.getAttribute(SHOW_NO_SYSTEMS) == null) {
            log.debug("adding show commands ..");
            request.setAttribute(SHOW_COMMANDS, Boolean.TRUE);
        }

        List<LabelValueBean> addOnEntitlements = new ArrayList<LabelValueBean>();

        log.debug("Adding virt-entitled droplist entry");
        addOnEntitlements.add(lvl10n(EntitlementManager.VIRTUALIZATION_ENTITLED,
                EntitlementManager.VIRTUALIZATION_ENTITLED));

        log.debug("addonents.size(): " + addOnEntitlements.size());
        if (addOnEntitlements.size() > 0) {
            log.debug("sorting list");
            Collections.sort(addOnEntitlements);
            request.setAttribute(ADDON_ENTITLEMENTS, addOnEntitlements);
            DynaActionForm form = (DynaActionForm)formIn;
            form.set(ADDON_ENTITLEMENT, addOnEntitlements.get(0).getValue());
        }
        setupCounts(request, user);

        return forward;
    }

    private void setupCounts(HttpServletRequest request, User user) {
        setupCountsMessage(request, user,
                EntitlementManager.MANAGEMENT,
                MANAGEMENT_COUNTS_MESSAGE);

        setupCountsMessage(request, user, EntitlementManager.VIRTUALIZATION,
                VIRTUALIZATION_COUNTS_MESSAGE);
    }

    private void setupCountsMessage(HttpServletRequest request, User user, Entitlement ent,
            String requestId) {
        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(ent, user.getOrg());
        if (sg != null) {
            LocalizationService service = LocalizationService.getInstance();
            String unlimitedKey =
                    "systementitlements.jsp.entitlement_counts_message";

            String message = service.getMessage(unlimitedKey,
                new Object[] {String.valueOf(sg.getCurrentMembers())});

            request.setAttribute(requestId, message);
        }
    }
}
