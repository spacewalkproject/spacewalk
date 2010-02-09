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
package com.redhat.rhn.frontend.action.rhnpackage.profile;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.channel.NoBaseChannelFoundException;
import com.redhat.rhn.domain.rhnpackage.profile.DuplicateProfileNameException;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.profile.ProfileManager;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionErrors;
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
 * CreateProfileAction
 * @version $Rev$
 */
public class CreateProfileAction extends RhnAction {
    
    private static Logger log = Logger.getLogger(CreateProfileAction.class);
    
    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        ActionForward forward = null;
        DynaActionForm f = (DynaActionForm)form;
        User user = requestContext.getLoggedInUser();
        
        Server server = requestContext.lookupAndBindServer();
        request.setAttribute("system", server);
        
        if (!isSubmitted(f)) {
            setup(request, f);
            forward =  strutsDelegate.forwardParams(mapping.findForward("default"),
                    request.getParameterMap());
        }
        else {
            
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, f);
            if (errors.isEmpty()) {
                ActionMessages msgs = processForm(request, user, server, f);
                if (!msgs.isEmpty()) {
                    strutsDelegate.saveMessages(request, msgs);
        
                    Map params = new HashMap();
                    params.put("sid", request.getParameter("sid"));
                    forward = strutsDelegate.forwardParams(mapping.findForward("created"),
                            params);
                    if (log.isDebugEnabled() && (forward != null)) {
                        log.debug("Where are we going [" + forward.toString() + "]");
                    }
                }
                else {
                    forward =  strutsDelegate.forwardParams(mapping.findForward("default"),
                            request.getParameterMap());
                }
            }
            else {
                strutsDelegate.saveMessages(request, errors);
                setup(request, f);
                forward = mapping.findForward("error");
            }
        }
        
        return forward;
    }
    
    private ActionMessages processForm(HttpServletRequest request, User user,
            Server server, DynaActionForm f) {
        
        if (log.isDebugEnabled()) {
            log.debug("Processing form.");
        }

        ActionMessages msgs = new ActionMessages();
        
        Boolean submitted = (Boolean) f.get("submitted");
        String name = (String) f.get("name");
        String description = (String) f.get("description");
        
        if (log.isDebugEnabled()) {
            log.debug("submitted [" + submitted + "]");
            log.debug("name [" + name + "]");
            log.debug("description [" + description + "]");
        }
        
        try {
            Profile p = ProfileManager.createProfile(user, server, name, description);
            ProfileManager.copyFrom(server, p);
            
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("create.jsp.successmessage",
                            name,
                            server.getName()));
        }
        catch (DuplicateProfileNameException dbe) {
            ActionMessages errors = new ActionMessages();
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("error.duplicateprofilename", dbe.getMessage()));
            addErrors(request, errors);
        }
        catch (NoBaseChannelFoundException nbcfe) {
            ActionMessages errors = new ActionMessages();
            errors.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("error.profileneedsbasechannel"));
            addErrors(request, errors);
        }
        
        return msgs;
    }
   
    private void setup(HttpServletRequest request, 
                            DynaActionForm form) {
        if (log.isDebugEnabled()) {
            log.debug("Setting up form with default values.");
        }
        
        Server server = (Server) request.getAttribute("system");
        if (form.get("name") == null) {
            form.set("name", getMessage("compare.jsp.profileof", 
                                                    server.getName()));            
        }
        if (form.get("description") == null) {
            form.set("description", getMessage("compare.jsp.profilemadefrom",
                    server.getName()));            
        }

    }
    
    private String getMessage(String key, String param) {
        return LocalizationService.getInstance().getMessage(key, param);
    }
}
