/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.dto.OrgDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.acl.AclManager;
import com.redhat.rhn.manager.org.OrgManager;


/**
 * OrgDetailsAction extends RhnAction - Class representation of the table web_customer
 * @version $Rev: 1 $
 */
public class OrgDetailsAction extends RhnAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Only satellite admin's can modify org names");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orgdetail"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }

        ActionForward retval = mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        DynaActionForm dynaForm = (DynaActionForm) formIn;

        // Let's try to limit the number of times we hydrate Org from the DB, shall we?
        RequestContext ctxt = new RequestContext(request);
        Long oid = ctxt.getRequiredParam(RequestContext.ORG_ID);
        Org theOrg = getOrgFor(oid);

        // Bolt if someone handed us a garbage OID
        if (theOrg == null) {
            getStrutsDelegate().saveMessage("api.org.nosuchorg",
                            new String[] {oid.toString()}, request);
            return mapping.findForward("nosuchorg");
        }

        if (isSubmitted(dynaForm)) {
            updateOrgDetails(mapping, dynaForm, request, response, oid, theOrg);
            retval = mapping.findForward("success");
            retval = getStrutsDelegate().forwardParam(retval, "oid", oid.toString());
        }
        else {
            setupFormValues(request, dynaForm, oid, theOrg);
        }
        return retval;
    }

    private Org getOrgFor(Long oid) {
        Org org = OrgFactory.lookupById(oid);
        return org;
    }
    private void setupFormValues(HttpServletRequest request,
            DynaActionForm daForm,
            Long oid,
            Org org) {

        OrgDto dto = OrgManager.toDetailsDto(org);
        daForm.set("submitted", Boolean.TRUE);
        daForm.set("orgName", dto.getName());
        daForm.set("id", dto.getId().toString());
        daForm.set("users", dto.getUsers().toString());
        daForm.set("systems", dto.getSystems().toString());
        daForm.set("actkeys", dto.getActivationKeys().toString());
        daForm.set("ksprofiles", dto.getKickstartProfiles().toString());
        daForm.set("groups", dto.getServerGroups().toString());
        daForm.set("cfgchannels", dto.getConfigChannels().toString());

        request.setAttribute("org", org);
        request.setAttribute(RequestContext.ORG_ID, oid);
    }

    /**
     *
     * @param mapping action mapping
     * @param dynaForm form for org details
     * @param request coming in
     * @param response going out
     * @param oid ID of Org we're operating on
     * @param org Org object for oid
     * @throws Exception to parent
     */
    private void updateOrgDetails(ActionMapping mapping,
            DynaActionForm dynaForm,
            HttpServletRequest request,
            HttpServletResponse response,
            Long oid,
            Org org) throws Exception {

        RequestContext requestContext = new RequestContext(request);
        if (validateForm(request, dynaForm, oid, org)) {
            String name = dynaForm.getString("orgName");
            org.setName(name);
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("message.org_name_updated", name));
            getStrutsDelegate().saveMessages(request, msg);
        }
    }

    /**
     *
     * @param request coming in
     * @param form to validate against
     * @param oid ID of Org we're operating on
     * @param currOrg Org object for oid
     * @return if it passed
     */
    private boolean validateForm(HttpServletRequest request, DynaActionForm form,
                    Long oid, Org currOrg) {
        boolean retval = true;

        String orgName = form.getString("orgName");
        RequestContext requestContext = new RequestContext(request);

        if (currOrg.getName().equals(orgName)) {
            getStrutsDelegate().saveMessage("message.org_name_not_updated",
                    new String[] {"orgName"}, request);
            retval = false;
        }
        else {
            try {
                OrgManager.checkOrgName(orgName);
            }
            catch (ValidatorException ve) {
                getStrutsDelegate().saveMessages(request, ve.getResult());
                retval = false;
            }
        }
        return retval;
    }
}
