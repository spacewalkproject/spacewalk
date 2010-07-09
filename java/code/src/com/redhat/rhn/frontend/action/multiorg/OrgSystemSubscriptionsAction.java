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
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgEntitlementDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.org.OrgManager;
import com.redhat.rhn.manager.org.UpdateOrgSystemEntitlementsCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.LinkedList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgSubscriptionsAction extends RhnAction - Class representation of the table ###TABLE###.
 * @version $Rev: 1 $
 */
public class OrgSystemSubscriptionsAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        Long oid = ctx.getParamAsLong(RequestContext.ORG_ID);
        Org org = OrgFactory.lookupById(oid);

        ActionForward retval =
            getStrutsDelegate().forwardParam(mapping.findForward("default"),
                "oid", oid.toString());

        if (isSubmitted(dynaForm)) {
            ActionErrors ae = updateSubscriptions(org, dynaForm, request);
            if (ae != null && ae.size() > 0) {
                getStrutsDelegate().saveMessages(request, ae);
                retval = getStrutsDelegate().forwardParam(mapping.findForward("error"),
                        "oid", oid.toString());
            }
            else {
                createSuccessMessage(request, "org.entitlements.syssoft.success", null);
                retval = getStrutsDelegate().forwardParam(mapping.findForward("success"),
                        "oid", oid.toString());
            }
        }
        setupFormValues(org, ctx, dynaForm, OrgManager.listEntitlementsFor(org));
        return retval;
    }

    private ActionErrors updateSubscriptions(Org org,
            DynaActionForm dynaForm, HttpServletRequest request) {

        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            return RhnValidationHelper.validatorErrorToActionErrors(
                    new ValidatorError("org.entitlements.system.defaultorg"));
        }

        ActionErrors ae = new ActionErrors();

        List <Entitlement> entitlements = new LinkedList<Entitlement>();
        entitlements.addAll(EntitlementManager.getBaseEntitlements());
        entitlements.addAll(EntitlementManager.getAddonEntitlements());

        for (Entitlement ent : entitlements) {
            String count = (String) dynaForm.get(ent.getLabel());
            Long newCount = null;
            try {
                newCount = Long.parseLong(count.trim());
            }
            catch (NumberFormatException ex) {
                ValidatorError error = new ValidatorError(
                        "orgsystemsubs.invalid", ent.getHumanReadableLabel());
                return (RhnValidationHelper.validatorErrorToActionErrors(error));
            }
            if (count != null && !StringUtils.isEmpty(count)) {
                UpdateOrgSystemEntitlementsCommand cmd =
                    new UpdateOrgSystemEntitlementsCommand(ent, org, newCount);
                ValidatorError ve = cmd.store();
                if (ve != null) {
                    return (RhnValidationHelper.validatorErrorToActionErrors(ve));
                }
            }
        }
        return ae;
    }

    private void setupFormValues(Org org, RequestContext ctx,
            DynaActionForm dynaForm, List <OrgEntitlementDto> dtos) {
        ctx.getRequest().setAttribute("org", org);
        for (OrgEntitlementDto dto : dtos) {
            ctx.getRequest().setAttribute(dto.getEntitlement().getLabel(), dto);
            dynaForm.set(dto.getEntitlement().getLabel(),
                        dto.getMaxEntitlements().toString());
        }
    }

}
