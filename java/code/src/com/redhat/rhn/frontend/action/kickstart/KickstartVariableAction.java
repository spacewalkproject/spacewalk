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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;
import org.cobbler.CobblerObject;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartDetailsEdit extends RhnAction
 * @version $Rev: 1 $
 */
public abstract class KickstartVariableAction extends RhnAction {
    
    public static final String VARIABLES = "variables";

    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        
        
        checkPermissions(request);
        
       
        String cobblerId = getCobblerId(context);        
        
        if (isSubmitted((DynaActionForm) formIn)) {
            ValidatorError ve = processFormValues(request, (DynaActionForm) formIn, 
                    cobblerId);
            if (ve != null) {
                ValidatorError[] verr = {ve};
                getStrutsDelegate().saveMessages(request,
                        RhnValidationHelper.validatorErrorToActionErrors(verr));
            } 
            
        }
        
        setupFormValues(context, (DynaActionForm) formIn, cobblerId);
        request.setAttribute(getObjectString(), request.getParameter(getObjectString()));
        
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), 
                request.getParameterMap());
        
    }
    /**
     * Checks the permissions for the KS variable pages
     * @param request the http servlet request.
     */
    protected void checkPermissions(HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
                //Throw an exception with a nice error message so the user
                //knows what went wrong.
                LocalizationService ls = LocalizationService.getInstance();
                PermissionException pex =
                    new PermissionException(
                        "Only Org Admins or Configuration Admins can modify kickstarts");
                pex.setLocalizedTitle(ls.getMessage("permission.jsp.summary.acl.header"));
                pex.setLocalizedSummary(ls.getMessage(
                        "permission.jsp.summary.acl.reason5"));
                throw pex;
        }
    }
    /**
     * {@inheritDoc}
     */
    protected void setupFormValues(RequestContext ctx, 
            DynaActionForm form, String cId) {
        CobblerObject cobj = getCobblerObject(cId, ctx.getLoggedInUser());
        form.set(VARIABLES, StringUtil.convertMapToString(cobj.getKsMeta(), "\n"));
    }
        

    /**
     * {@inheritDoc}
     */
    protected ValidatorError processFormValues(HttpServletRequest request, 
            DynaActionForm form, 
            String cId) {
        
        ValidatorError error = null;
        RequestContext ctx = new RequestContext(request);
    
        try {
            
            CobblerObject cobj = getCobblerObject(cId, ctx.getLoggedInUser());
            cobj.setKsMeta(StringUtil.convertOptionsToMap((String)form.get(VARIABLES), 
                    "kickstart.jsp.error.invalidvariable", "\n"));
            cobj.save();
            
            return null;
        }
        catch (ValidatorException ve) {
            return ve.getResult().getErrors().get(0);
        }
    }

    protected String getSuccessKey() {
        return "kickstart.details.success";
    }


    /**
     * 
     * @param context
     * @return
     */
    protected abstract String getCobblerId(RequestContext context);
    
    protected abstract String getObjectString();
            
    
    /**
     * Get the CobblerObject that we'll use to set the ksmeta data
     * @param cobblerId the cobbler Id
     * @param user the user requesting
     * @return the CobblerObject (either a profile or distro)
     */
    protected abstract CobblerObject getCobblerObject(String cobblerId, User user);

    
}
