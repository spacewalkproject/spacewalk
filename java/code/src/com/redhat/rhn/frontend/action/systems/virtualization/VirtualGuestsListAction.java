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
package com.redhat.rhn.frontend.action.systems.virtualization;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.common.validator.ValidatorWarning;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemListAction;
import com.redhat.rhn.frontend.dto.VirtualSystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * VirtualGuestsListAction
 * @version $Rev$
 */
public class VirtualGuestsListAction extends BaseSystemListAction {

    private static final Map GUEST_ACTIONS = new HashMap();
    private static final Map GUEST_SETTING_ACTIONS = new HashMap();
    static {
        LocalizationService localization = LocalizationService.getInstance();
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.startsystem"), "start");
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.suspendsystem"), "suspend");
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.resumesystem"), "resume");
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.restartsystem"), "restart");
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.shutdownsystem"), 
                "shutdown");
        GUEST_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.deletesystem"), "delete");
        
        GUEST_SETTING_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.setguestvcpus"), "setVcpu");
        GUEST_SETTING_ACTIONS.put(
                localization.getMessage("virtualguestslist.jsp.setguestmemory"), 
                "setMemory");
    }

    /**
     * Called when the Apply Action button is pressed, determines the path
     * of execution based on the action options dropdown.
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward applyAction(ActionMapping mapping,
                                         ActionForm formIn,
                                         HttpServletRequest request,
                                         HttpServletResponse response) {
        String guestAction = request.getParameter("guestAction"); 
        String actionToTake = (String)GUEST_ACTIONS.get(guestAction); 
        return virtualAction(mapping, formIn, request, response, actionToTake);
    }
    
    /**
     * Apply requested settings change to the selected guests.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward applySettings(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {
        String guestSettingToModify = request.getParameter("guestSettingToModify");
        String actionToTake = (String)GUEST_SETTING_ACTIONS.get(guestSettingToModify); 
        
        return virtualAction(mapping, formIn, request, response, actionToTake);
    }
    
    /**
     * Performs the virtual action
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @param dispatchAction The name of the action we are performing
     * @return The ActionForward to go to next.
     */
    public ActionForward virtualAction(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response,
                                       String dispatchAction) {
        Map params = new HashMap();
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        params = makeParamMap(formIn, request);
        ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, 
                (DynaActionForm)formIn);
        if (!errors.isEmpty()) {
            strutsDelegate.saveMessages(request, errors);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        
        RhnSet set = updateSet(request);
        //if they chose no systems, return to the same page with a message
        if (set.isEmpty()) {
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, 
                    new ActionMessage("virtualsystems.none"));
            
            strutsDelegate.saveMessages(request, msg);
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }

        //on to the confirmation page, with the action 'type'
        params.put("actionName", dispatchAction);

        // Add a guestSettingValue parameter if we have one in our request:
        String guestSettingValue = request.getParameter("guestSettingValue");
        if (guestSettingValue != null) {
            params.put("guestSettingValue", guestSettingValue);
        }
        
        List<ValidatorError> validationErrors = new LinkedList<ValidatorError>();
        List<ValidatorWarning> validationWarnings = new LinkedList<ValidatorWarning>();
        if (dispatchAction.equals("setVcpu")) {
            Iterator it = set.getElements().iterator();
            while (it.hasNext()) {
                RhnSetElement element = (RhnSetElement)it.next();
                ValidatorResult result = SystemManager.validateVcpuSetting(
                        element.getElement(), Integer.parseInt(guestSettingValue));
                validationErrors.addAll(result.getErrors());
                validationWarnings.addAll(result.getWarnings());
            }
        }
        else if (dispatchAction.equals("setMemory")) {
            Iterator it = set.getElements().iterator();
            List virtInstanceIds = new LinkedList();
            while (it.hasNext()) {
                RhnSetElement element = (RhnSetElement)it.next();
                virtInstanceIds.add(element.getElement());
                
            }
            
            ValidatorResult result = SystemManager.validateGuestMemorySetting(
                    virtInstanceIds, Integer.parseInt(guestSettingValue));
            validationErrors.addAll(result.getErrors());
            validationWarnings.addAll(result.getWarnings());
        }
        strutsDelegate.saveMessages(request,
                        validationErrors, validationWarnings);

        // Redirect back to the screen with error messages if any problems were found with
        // the proposed guest setting changes:
        if (validationErrors.size() > 0) {
            return strutsDelegate.forwardParams(mapping.findForward("default"), params);
        }
        return strutsDelegate.forwardParams(mapping.findForward("confirm"), params);
    }

    protected DataResult getDataResult(User user, ActionForm form, 
            HttpServletRequest request) {
        RequestContext ctx = new RequestContext(request);
        Long sid = ctx.getRequiredParam(RequestContext.SID);
        DataResult dr = SystemManager.virtualGuestsForHostList(user, sid, null);

        for (int i = 0; i < dr.size(); i++) {
            VirtualSystemOverview current = (VirtualSystemOverview) dr.get(i);
            current.setSystemId(current.getVirtualSystemId());
        }

        return dr;
    }
    
    protected void processMethodKeys(Map map) {
        map.put("virtualguestslist.jsp.applyaction", "applyAction");
        map.put("virtualguestslist.jsp.applychanges", "applySettings");
    }
    
    protected void processParamMap(ActionForm formIn, 
            HttpServletRequest request, Map params) {
        RequestContext ctx = new RequestContext(request);
        Long sid = ctx.getRequiredParam(RequestContext.SID);

        if (sid != null) {
            params.put("sid", sid);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.VIRTUAL_SYSTEMS;
    }
}
