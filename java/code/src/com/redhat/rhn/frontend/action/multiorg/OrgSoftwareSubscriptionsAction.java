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
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.UpdateOrgSoftwareEntitlementsCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Iterator;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgSoftwareSubscriptionsAction - updates the Channel subs for a single org
 * @version $Rev: 1 $
 */
public class OrgSoftwareSubscriptionsAction extends RhnAction {

    private static Logger log = Logger.getLogger(OrgSoftwareSubscriptionsAction.class);
    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
    
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        RequestContext ctx = new RequestContext(request);
        Long oid = ctx.getParamAsLong(RequestContext.ORG_ID);
        Org org = OrgFactory.lookupById(oid);
        request.setAttribute("org", org);
        request.setAttribute("parentUrl", request.getRequestURI());
        
        ActionForward retval = 
            getStrutsDelegate().forwardParam(mapping.findForward("default"), 
                "oid", oid.toString());
        
        // Used to tell if we're submitting the form for pagination or an actual 
        // form submit.
        String updateOrgs = request.getParameter("updateOrganizations");
        boolean update = (updateOrgs != null) && (!updateOrgs.equals("0"));
        if (isSubmitted(dynaForm) && update) {
            
            ActionErrors ae =  updateSubscriptions(org, request);
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
        setupFormValues(org, request);
        
        return retval;
    }

    void setupFormValues(Org org, HttpServletRequest request) {
        request.setAttribute("pageList", ChannelManager.
                listChannelFamilySubscriptionsFor(org));
    }

    private ActionErrors updateSubscriptions(Org org, HttpServletRequest request) {        

        List entitlements = ChannelManager.entitlements(
                OrgFactory.getSatelliteOrg().getId(), null);
        
        if (org.getId().equals(OrgFactory.getSatelliteOrg().getId())) {
            return RhnValidationHelper.validatorErrorToActionErrors(
                    new ValidatorError("org.entitlements.system.defaultorg"));
        }

        ActionErrors errors = new ActionErrors();
        Iterator i = entitlements.iterator();
        while (i.hasNext()) {
            ChannelOverview co = (ChannelOverview) i.next();
            ChannelFamily cfm = ChannelFamilyFactory.lookupById(co.getId().longValue());
            String count = (String) request.getParameter(co.getId().toString());
            
            // check for bad numbers
            if (count != null) {
                // check for invalid number format                
                try {
                    Long.parseLong(count.trim());
                }
                catch (NumberFormatException ex) {
                    ValidatorError error = new ValidatorError(
                    "orgsoftwaresubs.invalid", cfm.getName());
                    return (RhnValidationHelper.validatorErrorToActionErrors(error));
                }                            
            }
            
            if (count != null && !StringUtils.isEmpty(count)) {
                //Test id is a number
                if (!StringUtils.isNumeric(count)) {                    
                    errors.add(ActionMessages.GLOBAL_MESSAGE,
                            new ActionMessage("orgsoftwaresubs.edit.ent", cfm.getName()));
                    continue;
                }
                UpdateOrgSoftwareEntitlementsCommand cmd = 
                    new UpdateOrgSoftwareEntitlementsCommand(cfm.getLabel(), org, 
                            new Long(count));
                ValidatorError ve = cmd.store();
                if (ve != null) {
                    errors.add(RhnValidationHelper.validatorErrorToActionErrors(ve));
                }
            }
        }        
        return errors;
    }
}
