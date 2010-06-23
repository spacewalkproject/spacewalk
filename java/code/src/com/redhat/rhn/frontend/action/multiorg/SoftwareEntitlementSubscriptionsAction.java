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
package com.redhat.rhn.frontend.action.multiorg;

import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.OrgSoftwareEntitlementDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;


/**
 * SoftwareEntitlementSubscriptionsAction
 * @version $Rev$
 */
public class SoftwareEntitlementSubscriptionsAction extends RhnAction {

    private static Logger log = Logger.getLogger(
            SoftwareEntitlementSubscriptionsAction.class);    
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {        
        
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        User user = ctx.getLoggedInUser();
        
        Long cfid = ctx.getParamAsLong("cfid");
        ChannelFamily channelFamily = ChannelFamilyFactory.lookupById(cfid);
        
        // custom channel, redirect to entitlement page
        Long max = channelFamily.getMaxMembers(OrgFactory.getSatelliteOrg());
        if (max == null) {
            return mapping.findForward("unlimited");
        }
        
        ActionForward retval = getStrutsDelegate().forwardParam(mapping.findForward(
            "default"), "cfid", cfid.toString());

        if (isSubmitted(dynaForm)) {
            String orgClickedStr = request.getParameter("orgClicked");
            String newCountStr = request.getParameter("newCount_" + orgClickedStr);

            if (newCountStr != null && !StringUtils.isEmpty(newCountStr)) {                
                Long orgId = Long.parseLong(orgClickedStr);
                Org org = OrgFactory.lookupById(orgId);
                
                ActionErrors ae = updateSubscriptions(org, dynaForm, request,
                        channelFamily, newCountStr);

                if (ae != null && ae.size() > 0) {
                    getStrutsDelegate().saveMessages(request, ae);
                }
                else {
                    createSuccessMessage(request,
                            "softwareEntitlementSubs.successMessage", org.getName());
                    retval = getStrutsDelegate().forwardParam(
                            mapping.findForward("success"), "cfid",
                            cfid.toString());
                }
            }
            else {
                log.debug("Ignoring form submit (likely a page change)");
            }
        }
        
        setupFormValues(request, user, cfid, channelFamily);

        return retval;
    }

    private void setupFormValues(HttpServletRequest request, User user,
            Long cfid, ChannelFamily channelFamily) {
        Org satelliteOrg = OrgFactory.getSatelliteOrg();
        
        setupOrgEntitlementUsageList(request, user, satelliteOrg, channelFamily);
        setupEntitlementUsageTotals(request, cfid, satelliteOrg, user);
        
        request.setAttribute("channelFamily", channelFamily);
    }

    /*
     * Build the master list of *all* orgs and their usage of this entitlement:
     */
    private void setupOrgEntitlementUsageList(HttpServletRequest request,
            User user, Org satelliteOrg, ChannelFamily cf) {
        
        List<OrgSoftwareEntitlementDto> entitlementUsage = 
                        ChannelManager.listEntitlementsForAllOrgsWithEmptyOrgs(cf, user);
        
        for (Iterator <OrgSoftwareEntitlementDto> itr =
            entitlementUsage.iterator(); itr.hasNext();) {
            OrgSoftwareEntitlementDto dto = itr.next();
            if (satelliteOrg.equals(dto.getOrg())) {
                itr.remove();
            }
        }

        ChannelOverview satelliteOrgOverview = ChannelManager.getEntitlement(
                satelliteOrg.getId(), cf.getId());
        if (satelliteOrgOverview == null) {
            log.error("Default org does not appear to have been allocated entitlement:" +
                    cf.getId());
        }
        request.setAttribute("pageList", entitlementUsage);
        request.setAttribute("parentUrl", request.getRequestURI());
        request.setAttribute("satelliteOrgOverview", satelliteOrgOverview);

    }

    private void setupEntitlementUsageTotals(HttpServletRequest request,
            Long cfid, Org satelliteOrg, User user) {
        List<ChannelOverview> channelOverviews = 
            ChannelManager.getEntitlementForAllOrgs(cfid);
        
        Long entitlementsMaxMembers = new Long(0);
        Long entitlementsCurrentMembers = new Long(0);
        Long entitlementRatio = new Long(0);
        Long orgRatio = new Long(0);
        Long entitledOrgs = new Long(0);
        // don't include default org
        Long orgCount = OrgManager.getTotalOrgCount(user) - 1;

        for (ChannelOverview co : channelOverviews) {
            if (co.getOrgId().equals(satelliteOrg.getId())) {
                continue;
            }
            entitlementsCurrentMembers += co.getCurrentMembers();

            entitlementsMaxMembers += co.getMaxMembers();
            if (co.getMaxMembers() > 0) {
                // manually count rather then use list size since max mem can be 0
                entitledOrgs++;
            }
        }
        
        try {
            entitlementRatio = entitlementsCurrentMembers * 100 / entitlementsMaxMembers;
        } 
        catch (Exception e) {
            //default to 0
        }
        
        try {
            orgRatio = entitledOrgs * 100 / orgCount;
        } 
        catch (Exception e) {
            //default to 0
        }
        
        request.setAttribute("orgCount", orgCount);
        request.setAttribute("entitledOrgs", entitledOrgs);
        request.setAttribute("maxMem", entitlementsMaxMembers);        
        request.setAttribute("curMem", entitlementsCurrentMembers);
        request.setAttribute("entRatio", entitlementRatio);
        request.setAttribute("orgRatio", orgRatio);
    }

    private ActionErrors updateSubscriptions(Org org, DynaActionForm dynaForm, 
            HttpServletRequest request, ChannelFamily channelFamily, String newCountStr) {

        ActionErrors ae = new ActionErrors();
        Long newCount = null;
        try {
            newCount = Long.parseLong(newCountStr.trim());
        }
        catch (NumberFormatException e) {
            ValidatorError error = new ValidatorError(
                    "softwareEntitlementSubs.invalidInput");
            ae.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            return ae;
        }
        if (newCount < 0) {
            ValidatorError error = new ValidatorError(
                "softwareEntitlementSubs.invalidInput");
            ae.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            return ae;
        }

        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            createErrorMessage(request, "org.entitlements.system.defaultorg", null);
            return null;
        }

        UpdateOrgSoftwareEntitlementsCommand updateCmd = null;
        try {
             updateCmd = new UpdateOrgSoftwareEntitlementsCommand(channelFamily.getLabel(), 
                     org, newCount, 0L);
        }
        catch (IllegalArgumentException e) {
            ValidatorError error = new ValidatorError(
                "softwareEntitlementSubs.noEntitlementsAvailable");
            ae.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            return ae;
        }
        
        ValidatorError ve = updateCmd.store();
        if (ve != null) {
            ae.add(RhnValidationHelper
                    .validatorErrorToActionErrors(ve));
        }
        
        return ae;

    }

}
