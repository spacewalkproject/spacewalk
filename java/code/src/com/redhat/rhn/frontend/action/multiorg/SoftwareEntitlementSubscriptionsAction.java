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
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * SoftwareEntitlementSubscriptionsAction
 * @version $Rev$
 */
public class SoftwareEntitlementSubscriptionsAction extends RhnAction implements Listable {

    private static Logger log = Logger.getLogger(
            SoftwareEntitlementSubscriptionsAction.class);
    private static final String ORGS = "orgs";

    private static String makeLabel(HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        Long cfid = ctx.getParamAsLong("cfid");
        return "SoftwareEntitlementSubscriptionsAction" + cfid;
    }


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

        Map params = new HashMap();
        params.put("cfid", cfid);
        ListHelper helper = new ListHelper(this, request, params);
        helper.execute();
        ActionForward retval = mapping.findForward("default");

        if (isSubmitted(dynaForm)) {

            Map <String, String> subsMap = (Map <String, String>)
            request.getSession().getAttribute(makeLabel(request));
            for (String id : subsMap.keySet()) {
                if (request.getParameter(id) != null) {
                    subsMap.put(id, request.getParameter(id));
                }
            }

            String orgClickedStr = request.getParameter("orgClicked");
            if (!StringUtils.isBlank(orgClickedStr)) {
                Long orgId = Long.parseLong(orgClickedStr);
                Org org = OrgFactory.lookupById(orgId);

                ActionErrors ae = updateSubscriptions(org, dynaForm, request,
                        channelFamily, subsMap);

                if (ae != null && ae.size() > 0) {
                    getStrutsDelegate().saveMessages(request, ae);
                }
                else {
                    request.getSession().removeAttribute(makeLabel(request));
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
        else {
            Map<String, String> subsMap = new HashMap<String, String>();
            List <OrgSoftwareEntitlementDto> subs = helper.getDataSet();
            for (OrgSoftwareEntitlementDto sub : subs) {
                if (sub.getMaxPossibleAllocation() > 0) {
                    subsMap.put(sub.getKey(), sub.getMaxMembers().toString());
                }
                if (sub.getMaxPossibleFlexAllocation() > 0) {
                    subsMap.put(sub.getFlexKey(), sub.getMaxFlex().toString());
                }
            }
            request.getSession().setAttribute(makeLabel(request), subsMap);
        }
        request.setAttribute(ORGS,
                request.getSession().getAttribute(makeLabel(request)));
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
        ChannelOverview satelliteOrgOverview = ChannelManager.getEntitlement(
                satelliteOrg.getId(), cf.getId());
        if (satelliteOrgOverview == null) {
            log.error("Default org does not appear to have been allocated entitlement:" +
                    cf.getId());
        }
        request.setAttribute("satelliteOrgOverview", satelliteOrgOverview);
    }

    private void setupEntitlementUsageTotals(HttpServletRequest request,
            Long cfid, Org satelliteOrg, User user) {
        List<ChannelOverview> channelOverviews =
            ChannelManager.getEntitlementForAllOrgs(cfid);

        Long maxMembers = new Long(0);
        Long currMembers = new Long(0);
        Long entitlementRatio = new Long(0);
        Long orgRatio = new Long(0);
        Long entitledOrgs = new Long(0);
        boolean regularAvailable = false;


        long currFlex = 0;
        long maxFlex = 0;
        long flexEntRatio = 0;
        long flexOrgRatio = 0;
        long flexEntitledOrgs = 0;
        boolean flexAvailable = false;

        // don't include default org
        Long orgCount = OrgManager.getTotalOrgCount(user) - 1;
        for (ChannelOverview co : channelOverviews) {
            if (co.getOrgId().equals(satelliteOrg.getId())) {
                flexAvailable = co.getFreeFlex() > 0;
                regularAvailable = co.getFreeMembers() > 0;
                continue;
            }

            currMembers += co.getCurrentMembers();
            maxMembers += co.getMaxMembers();
            currFlex += co.getCurrentFlex();
            maxFlex += co.getMaxFlex();

            if (co.getMaxMembers() > 0) {
                // manually count rather then use list size since max mem can be 0
                entitledOrgs++;
                regularAvailable = true;
            }

            if (co.getMaxFlex() > 0) {
                flexAvailable = true;
                flexEntitledOrgs++;
            }
        }

        try {
            if (maxMembers > 0) {
                entitlementRatio = currMembers * 100 / maxMembers;
            }
            if (maxFlex > 0) {
                flexEntRatio = currFlex * 100 / maxFlex;
            }
            if (orgCount > 0) {
                orgRatio = entitledOrgs * 100 / orgCount;
                flexOrgRatio = flexEntitledOrgs * 100 / orgCount;
            }

        }
        catch (Exception e) {
            //default to 0
        }


        request.setAttribute("orgCount", orgCount);
        request.setAttribute("entitledOrgs", entitledOrgs);
        request.setAttribute("maxMem", maxMembers);
        request.setAttribute("curMem", currMembers);
        request.setAttribute("entRatio", entitlementRatio);
        request.setAttribute("orgRatio", orgRatio);
        if (regularAvailable) {
            request.setAttribute("regularAvailable", Boolean.TRUE);
        }


        request.setAttribute("flexEntitledOrgs", flexEntitledOrgs);
        request.setAttribute("maxFlex", maxFlex);
        request.setAttribute("curFlex", currFlex);
        request.setAttribute("flexEntRatio", flexEntRatio);
        request.setAttribute("flexOrgRatio", flexOrgRatio);
        if (flexAvailable) {
            request.setAttribute("flexAvailable", Boolean.TRUE);
        }
    }

    private ActionErrors updateSubscriptions(Org org, DynaActionForm dynaForm,
            HttpServletRequest request, ChannelFamily channelFamily,
            Map<String, String> subsMap) {

        ActionErrors ae = new ActionErrors();
        long regCount = 0;
        long flexCount = 0;

        if (subsMap.containsKey(OrgSoftwareEntitlementDto.makeFlexKey(org.getId()))) {
            try {
                String flexValue = subsMap.get(
                        OrgSoftwareEntitlementDto.makeFlexKey(org.getId()));
                flexCount = Long.parseLong(flexValue.trim());
            }
            catch (NumberFormatException e) {
                ValidatorError error = new ValidatorError(
                        "softwareEntitlementSubs.invalidInput");
                ae.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            }
        }

        if (subsMap.containsKey(OrgSoftwareEntitlementDto.makeKey(org.getId()))) {
            try {
                String value = subsMap.get(
                        OrgSoftwareEntitlementDto.makeKey(org.getId()));
                regCount = Long.parseLong(value.trim());
            }
            catch (NumberFormatException e) {
                ValidatorError error = new ValidatorError(
                        "softwareEntitlementSubs.invalidInput");
                ae.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            }
        }
        if (ae.size() > 0) {
            return ae;
        }
        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            createErrorMessage(request, "org.entitlements.system.defaultorg", null);
            return null;
        }

        UpdateOrgSoftwareEntitlementsCommand updateCmd = null;
        try {
             updateCmd = new UpdateOrgSoftwareEntitlementsCommand(channelFamily.getLabel(),
                     org, regCount, flexCount);
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

    /**
     * {@inheritDoc}
     */
    public List getResult(RequestContext contextIn) {
        ChannelFamily cf = ChannelFamilyFactory.
                        lookupById(contextIn.getParamAsLong("cfid"));
        List<OrgSoftwareEntitlementDto> entitlementUsage =
                        ChannelManager.listEntitlementsForAllOrgsWithEmptyOrgs(cf,
                                                            contextIn.getLoggedInUser());
        Org satelliteOrg = OrgFactory.getSatelliteOrg();

        for (Iterator <OrgSoftwareEntitlementDto> itr =
                            entitlementUsage.iterator(); itr.hasNext();) {
            OrgSoftwareEntitlementDto dto = itr.next();
            if (satelliteOrg.equals(dto.getOrg())) {
                itr.remove();
            }
        }
        return entitlementUsage;
    }

}
