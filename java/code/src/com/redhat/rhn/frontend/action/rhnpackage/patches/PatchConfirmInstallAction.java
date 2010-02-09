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
package com.redhat.rhn.frontend.action.rhnpackage.patches;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.actions.LookupDispatchAction;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataConfirmAction
 * @version $Rev: 53116 $
 */
public class PatchConfirmInstallAction extends LookupDispatchAction {
    
    private StrutsDelegate getStrutsDelegate() {
        return StrutsDelegate.getInstance();
    }

    /**
     * Action to execute if confirm button is clicked
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward confirmPatch(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        
        User user = requestContext.getLoggedInUser();
        Long sid = requestContext.getRequiredParam("sid");
        Server server = SystemManager.lookupByIdAndUser(sid, user);
        RhnSet set = RhnSetDecl.PATCH_INSTALL.get(user);
        
        int numPatches = set.size();
                       
        if (set != null) {             
             Action install = ActionManager.createPatchInstallAction(user, server, set);
             
             ActionManager.storeAction(install); //commit action
             RhnSetDecl.PATCH_INSTALL.clear(user);
             
             ActionMessages msgs = new ActionMessages();

             /**
              * If there was only one action archived, display the "action" archived
              * message, else display the "actions" archived message.
              */
             if (numPatches == 1) {
                 msgs.add(ActionMessages.GLOBAL_MESSAGE,
                          new ActionMessage("message.patchinstall",
                                  LocalizationService.getInstance()
                                      .formatNumber(new Integer(numPatches)),
                                  install.getId().toString(),
                                  sid.toString(),
                                  server.getName()));
             }
             else {
                 msgs.add(ActionMessages.GLOBAL_MESSAGE,
                          new ActionMessage("message.patchinstalls", 
                                  LocalizationService.getInstance()
                                  .formatNumber(new Integer(numPatches)),
                              install.getId().toString(),
                              sid.toString(),
                              server.getName()));
             }
             
             strutsDelegate.saveMessages(request, msgs);
                                                   
             Map params = makeParamMap(request);
             return strutsDelegate.forwardParams(mapping.findForward("installed"), params);
        }
        /*
         * Everything is not ok.                 
         * TODO: error msg
         */
        Map params = makeParamMap(request);
        return strutsDelegate.forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Default action to execute if dispatch parameter is missing
     * or isn't in map
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward unspecified(ActionMapping mapping,
                                     ActionForm formIn,
                                     HttpServletRequest request,
                                     HttpServletResponse response) {
        Map params = makeParamMap(request);
        return getStrutsDelegate().forwardParams(mapping.findForward("default"), params);
    }
    
    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    
    protected Map makeParamMap(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        Map params = requestContext.makeParamMapWithPagination();
        Long sid = requestContext.getParamAsLong("sid");
        
        if (sid != null) {
            params.put("sid", sid);
        }
        
        return params;
    }
    
    /**
     * {@inheritDoc}
     */
    protected Map getKeyMethodMap() {
        Map map = new HashMap();
        map.put("packagelist.jsp.confirmpatchinstall", "confirmPatch");
        return map;
    }    
    
}
