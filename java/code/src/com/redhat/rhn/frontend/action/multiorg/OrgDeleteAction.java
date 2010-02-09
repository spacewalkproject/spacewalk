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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.acl.AclManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgDetailsAction extends RhnAction - Class representation of the table web_customer
 * @version $Rev: 1 $
 */
public class OrgDeleteAction extends RhnAction {    

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);        

        ActionForward retval = mapping.findForward("default");
        DynaActionForm dynaForm = (DynaActionForm) formIn;
        
        if (!AclManager.hasAcl("user_role(satellite_admin)", request, null)) {
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex =
                new PermissionException("Only satellite admin's can delete organizations");
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.orgdetail"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.general"));
            throw pex;
        }                        
        
        if (isSubmitted(dynaForm)) {
            Org bOrg = OrgFactory.getSatelliteOrg();
            if (oid.longValue() == bOrg.getId().longValue()) {
                createErrorMessage(request, "org.base.delete.error", bOrg.getName());
                retval = mapping.findForward("error");                
            } 
            else {
                deleteOrg(oid, request);                 
                retval = mapping.findForward("success");                
            }
            retval = getStrutsDelegate().forwardParam(retval, "oid", oid.toString());
        }
        else {
            setupFormValues(request, dynaForm);            
        }
        return retval;
    }
                                 
    /**
     * 
     * @param request Request coming in
     * @param daForm to populate 
     */
    private void setupFormValues(HttpServletRequest request, 
                                     DynaActionForm daForm) {
        daForm.set("submitted", Boolean.TRUE);
       
        RequestContext requestContext = new RequestContext(request);         
        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);        
        Org org = OrgFactory.lookupById(oid);
        
        request.setAttribute("orgName", org.getName());
        request.setAttribute("users", OrgFactory.getActiveUsers(org));
        request.setAttribute("systems", OrgFactory.getActiveSystems(org));
        request.setAttribute("actkeys", OrgFactory.getActivationKeys(org));
        request.setAttribute("ksprofiles", OrgFactory.getKickstarts(org));
        request.setAttribute("groups", OrgFactory.getServerGroups(org));
        request.setAttribute("cfgchannels", OrgFactory.getConfigChannels(org));   
        request.setAttribute(RequestContext.ORG_ID, oid);
    }
 
    /**
     * 
     * @param oidIn Organization Id to delete
     * @return Success or Failure in form of Boolean
     */
    private void deleteOrg(Long oidIn, HttpServletRequest request) {
        Org org = OrgFactory.lookupById(oidIn);
        String name = org.getName();
     
        OrgFactory.deleteOrg(oidIn);
        ActionMessages msg = new ActionMessages();        
        msg.add(ActionMessages.GLOBAL_MESSAGE, 
                new ActionMessage("message.org_deleted", name));
        getStrutsDelegate().saveMessages(request, msg);            
    }

}
