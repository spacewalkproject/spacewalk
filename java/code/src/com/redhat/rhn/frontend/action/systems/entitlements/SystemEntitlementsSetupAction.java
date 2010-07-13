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
package com.redhat.rhn.frontend.action.systems.entitlements;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemListSetupAction;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.acl.AclManager;
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
 * @version $Rev$
 */
public class SystemEntitlementsSetupAction extends BaseSystemListSetupAction {

    private static Logger log = Logger.getLogger(SystemEntitlementsSetupAction.class);

    public static final String SHOW_COMMANDS = "showCommands";

    public static final String SHOW_MONITORING = "showMonitoring";
    public static final String SHOW_MANAGEMENT_ASPECTS = "showManagementAspects";
    public static final String SHOW_UPDATE_ASPECTS = "showUpdateAspects";

    public static final String SHOW_UNENTITLED = "showUnentitled";

    public static final String SHOW_ADDON_ASPECTS = "showAddOnAspects";

    public static final String ADDON_ENTITLEMENTS = "addOnEntitlements";
    public static final String ADDON_ENTITLEMENT = "addOnEntitlement";

    public static final String UPDATE_COUNTS_MESSAGE = "updateCountsMessage";
    public static final String MANAGEMENT_COUNTS_MESSAGE = "managementCountsMessage";
    public static final String PROVISION_COUNTS_MESSAGE = "provisioningCountsMessage";
    public static final String VIRTUALIZATION_COUNTS_MESSAGE =
        "virtualizationCountsMessage";
    public static final String VIRTUALIZATION_PLATFORM_COUNTS_MESSAGE =
        "virtualizationPlatformCountsMessage";

    public static final String MONITORING_COUNTS_MESSAGE = "monitoringCountsMessage";

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
    protected DataResult getDataResult(User user, PageControl pc, ActionForm formIn) {
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
        User user = rctx.getLoggedInUser();

        log.debug("show: " + (request.getAttribute(SHOW_NO_SYSTEMS) == null));
        if (request.getAttribute(SHOW_NO_SYSTEMS) == null) {
            log.debug("adding show commands ..");
            request.setAttribute(SHOW_COMMANDS, Boolean.TRUE);
        }

        List addOnEntitlements = new ArrayList();
        if (log.isDebugEnabled()) {
            log.debug("user.getOrg().getEnts: " + user.getOrg().getEntitlements());
        }

        // Virt is an addon to update so just check to make sure we
        // have virt.  This is different from provisioning and monitoring
        if (user.getOrg().hasEntitlement(OrgFactory.getEntitlementVirtualization())) {
            log.debug("Adding virt-entitled droplist entry");
            addOnEntitlements.add(lvl10n(EntitlementManager.VIRTUALIZATION_ENTITLED,
                    EntitlementManager.VIRTUALIZATION_ENTITLED));
            request.setAttribute(SHOW_ADDON_ASPECTS, Boolean.TRUE);
        }
        if (user.getOrg().hasEntitlement(
                OrgFactory.getEntitlementVirtualizationPlatform())) {
            log.debug("Adding virt-host-entitled droplist entry");
            addOnEntitlements.add(lvl10n(
                    EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED,
                    EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED));
            request.setAttribute(SHOW_ADDON_ASPECTS, Boolean.TRUE);
        }

        if (user.getOrg().hasEntitlement(OrgFactory.getEntitlementEnterprise())) {
            setIfSlotsAvailable(SHOW_MANAGEMENT_ASPECTS,
                    request, user,
                    EntitlementManager.MANAGEMENT);



            if (user.getOrg().hasEntitlement(OrgFactory.getEntitlementMonitoring()) &&
                    hasMonitoringAcl(user, request)) {
                addOnEntitlements.add(lvl10n("monitoring_entitled",
                        EntitlementManager.MONITORING_ENTITLED));
                request.setAttribute(SHOW_MONITORING, Boolean.TRUE);
                request.setAttribute(SHOW_ADDON_ASPECTS, Boolean.TRUE);
            }

            if (user.getOrg().hasEntitlement(OrgFactory.getEntitlementProvisioning())) {
                addOnEntitlements.add(lvl10n("provisioning_entitled",
                        EntitlementManager.PROVISIONING_ENTITLED));
                request.setAttribute(SHOW_ADDON_ASPECTS, Boolean.TRUE);
            }
        }

        log.debug("addonents.size(): " + addOnEntitlements.size());
        if (addOnEntitlements.size() > 0) {
            log.debug("sorting list");
            Collections.sort(addOnEntitlements);
            request.setAttribute(ADDON_ENTITLEMENTS, addOnEntitlements);
            DynaActionForm form = (DynaActionForm)formIn;
            form.set(ADDON_ENTITLEMENT,
                    ((LabelValueBean) addOnEntitlements.get(0)).getValue());
        }
        setupCounts(request, user);

        setIfSlotsAvailable(SHOW_UPDATE_ASPECTS,
                request, user,
                EntitlementManager.UPDATE);


        setupCounts(request, user);



        return forward;
    }

    /**
     * @param request
     * @param user
     */
    private void setIfSlotsAvailable(String aspectName,
            HttpServletRequest request,
            User user,
            Entitlement ent) {
        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(ent,
                user.getOrg());
        if (sg != null) {
            if (sg.getMaxMembers() == null) {
                request.setAttribute(aspectName, Boolean.TRUE);
            }
            else {
                long available = sg.getMaxMembers().longValue() -
                sg.getCurrentMembers().longValue();
                if (available > 0) {
                    request.setAttribute(aspectName, Boolean.TRUE);
                }
            }


            if (sg.getMaxMembers() == null || sg.getMaxMembers().longValue() > 0) {
                request.setAttribute(SHOW_UNENTITLED, Boolean.TRUE);
            }
        }
    }

    private boolean hasMonitoringAcl(User user, HttpServletRequest request) {
        return  (request.getAttribute(SHOW_MONITORING) != null) ||
        (AclManager.hasAcl("show_monitoring();", user,
                "com.redhat.rhn.common.security.acl.MonitoringAclHandler",
                null));
    }


    private void setupCounts(HttpServletRequest request, User user) {
        setupCountsMessage(request, user,
                EntitlementManager.MANAGEMENT,
                MANAGEMENT_COUNTS_MESSAGE);

        setupCountsMessage(request, user,
                EntitlementManager.PROVISIONING,
                PROVISION_COUNTS_MESSAGE);

        setupCountsMessage(request, user, EntitlementManager.VIRTUALIZATION,
                VIRTUALIZATION_COUNTS_MESSAGE);

        setupCountsMessage(request, user, EntitlementManager.VIRTUALIZATION_PLATFORM,
                VIRTUALIZATION_PLATFORM_COUNTS_MESSAGE);

        if (hasMonitoringAcl(user, request)) {
            setupCountsMessage(request, user,
                    EntitlementManager.MONITORING,
                    MONITORING_COUNTS_MESSAGE);
        }

        setupCountsMessage(request, user,
                EntitlementManager.UPDATE,
                UPDATE_COUNTS_MESSAGE);
    }

    private void setupCountsMessage(HttpServletRequest request,
            User user,
            Entitlement ent,
            String requestId) {

        long total = 0, current = 0, available = 0;

        EntitlementServerGroup sg = ServerGroupFactory.lookupEntitled(ent,
                user.getOrg());
        if (sg != null) {

            if (sg.getMaxMembers() == null) {
                current = sg.getCurrentMembers().longValue();

                LocalizationService service  = LocalizationService.getInstance();
                String  unlimitedKey =
                    "systementitlements.jsp.entitlement_counts_message_unlimited";

                String message = service.getMessage(unlimitedKey,
                        new Object[] {
                        String.valueOf(current)});
                request.setAttribute(requestId, message);
                return;
            }

            total = sg.getMaxMembers().longValue();
            current = sg.getCurrentMembers().longValue();
            available = total - current;
        }

        String message = getEntitlementsCountsMessage(total, current, available);
        request.setAttribute(requestId, message);
    }

    /**
     * @param total
     * @param current
     * @param available
     * @return
     */
    private String getEntitlementsCountsMessage(long total, long current, long available) {
        String  countsMessage = "systementitlements.jsp.entitlement_counts_message_";
        if (current == 1 && available == 1) {
            countsMessage += "1";
        }
        else if (current == 1) {
            countsMessage += "2";
        }
        else if (available == 1) {
            countsMessage += "3";
        }
        else {
            countsMessage += "4";
        }
        LocalizationService service  = LocalizationService.getInstance();
        String message = service.getMessage(countsMessage,
                new Object[] {String.valueOf(current),
                String.valueOf(available),
                String.valueOf(total)});
        return message;
    }
}
