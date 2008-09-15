/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * DeleteProfileAction
 * @version $Rev$
 */
public class DeleteProfileAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(DeleteProfileAction.class);
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm)form;
        Long prid = requestContext.getRequiredParam("prid");
        User user = requestContext.getLoggedInUser();
        Profile profile = ProfileManager.lookupByIdAndOrg(prid, user.getOrg());
        request.setAttribute("profile", profile);
        
        if (!isSubmitted(f)) {
            setup(request, f);
            forward =  strutsDelegate.forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
        else {
            ActionMessages msgs = processForm(profile, f);
            strutsDelegate.saveMessages(request, msgs);
    
            Map params = new HashMap();
            params.put("sid", request.getParameter("sid"));
            forward = strutsDelegate.forwardParams(mapping.findForward("deleted"),
                    params);
            if (log.isDebugEnabled() && (forward != null)) {
                log.debug("Where are we going [" + forward.toString() + "]");
            }
        }
        
        return forward;
    }
    
    private ActionMessages processForm(Profile profile, DynaActionForm f) {
        
        if (log.isDebugEnabled()) {
            log.debug("Processing form.");
        }

        ActionMessages msgs = new ActionMessages();
        
        int numDeleted = ProfileManager.deleteProfile(profile);
        if (numDeleted > 0) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("deleteconfirm.jsp.profiledeleted",
                            profile.getName()));
        }
        
        return msgs;
    }
   
    private void setup(HttpServletRequest request, DynaActionForm form) {
        RequestContext requestContext = new RequestContext(request);
        
        form.set("prid", requestContext.getRequiredParam("prid"));
        form.set("sid", requestContext.getRequiredParam("sid"));
    }
}
