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
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.org.UpdateOrgSystemEntitlementsCommand;

/**
 * SystemEntitlementOrgsAction
 */
public class SystemEntitlementOrgsAction extends RhnAction {

    private Logger log = Logger.getLogger(this.getClass());

    /** ${@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm form,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
        throws Exception {

        DynaActionForm dynaForm = (DynaActionForm) form;
        RequestContext ctx = new RequestContext(request);

        String entitlementLabel = request.getParameter("label");
        Entitlement e = EntitlementManager.getByName(entitlementLabel);
        User user = ctx.getLoggedInUser();
        request.setAttribute("entname", e.getHumanReadableLabel());
        //Get and store values submitted
        if (isSubmitted(dynaForm)) {
            String orgClickedStr = request.getParameter("orgClicked");
            Long orgId = Long.parseLong(orgClickedStr);
            Org org = OrgFactory.lookupById(orgId);
            String newCount = request.getParameter("newCount_" + orgClickedStr);

            if (newCount != null && !StringUtils.isEmpty(newCount)) {
                ActionErrors errors = updateSubscriptions(
                    org, request, e,
                    newCount);

                if (errors != null && errors.size() > 0) {
                    getStrutsDelegate().saveMessages(request, errors);
                }
                else {
                    createSuccessMessage(request,
                        "softwareEntitlementSubs.successMessage",
                        org.getName());
                }
            }
        }

        //Render the data from database
        DataList<Map> result =
            OrgManager.allOrgsSingleEntitlementWithEmptyOrgs(entitlementLabel);
        Org satelliteOrg = OrgFactory.getSatelliteOrg();

        //remove default org
        for (Iterator<Map> itr = result.iterator(); itr.hasNext();) {
            Map row = itr.next();
            if (satelliteOrg.getId().equals(row.get("orgid"))) {
                itr.remove();
                break;
            }
        }

        request.setAttribute("egntname", entitlementLabel);
        request.setAttribute("enthuman", e.getHumanReadableLabel());
        request.setAttribute("pageList", result);
        request.setAttribute("parentUrl", request.getRequestURI() +
            "?label=" + entitlementLabel);

        //Calculate System Wide Sat usage
        Long orgCount = OrgManager.getTotalOrgCount(user) - 1;
        Long maxEnt = new Long(0);
        Long curEnt = new Long(0);
        Long alloc = new Long(0);

        DataList satEntCounts = OrgManager.getSatEntitlementUsage(entitlementLabel);
        Map row = (Map) satEntCounts.get(0);

        if (row.get("total") != null) {
          maxEnt = ((Long) row.get("total")).longValue();
        }
        if (row.get("curr") != null) {
          curEnt = ((Long) row.get("curr")).longValue();
        }
        if (row.get("alloc") != null) {
          alloc = ((Long) row.get("alloc")).longValue();
        }

        Long ratio = new Long(0);
        if (orgCount != 0) {
          ratio = alloc * 100 / orgCount;
        }

        request.setAttribute("maxEnt", maxEnt);
        request.setAttribute("curEnt", curEnt);
        request.setAttribute("alloc", alloc);
        request.setAttribute("orgsnum", orgCount);
        request.setAttribute("ratio", ratio);


        return mapping.findForward("default");
    }

    private ActionErrors updateSubscriptions(Org org,
                                             HttpServletRequest request,
                                             Entitlement ent,
                                             String newCount) {

        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            createErrorMessage(request, "org.entitlements.system.defaultorg", null);
            return null;
        }

        ActionErrors errors = new ActionErrors();

        //Validate if its a numeric value
        if (!StringUtils.isNumeric(newCount)) {
            ValidatorError error = new ValidatorError(
                "softwareEntitlementSubs.invalidInput");
            errors.add(
                RhnValidationHelper.validatorErrorToActionErrors(
                    error));
            return errors;
        }

        Long count;
        try {
            count = Long.parseLong(newCount);
            if (count < 0) {
                throw new NumberFormatException();
            }
        }
        catch (NumberFormatException numEx) {
            ValidatorError error = new ValidatorError(
                "softwareEntitlementSubs.invalidInput");
            errors.add(RhnValidationHelper.validatorErrorToActionErrors(error));
            return errors;
        }

        // Store/update db
        UpdateOrgSystemEntitlementsCommand updateCmd = new
            UpdateOrgSystemEntitlementsCommand(ent, org, count);
        ValidatorError ve = updateCmd.store();
        if (ve != null) {
            errors.add(RhnValidationHelper.
                validatorErrorToActionErrors(ve));
        }

        return errors;
    }
}
