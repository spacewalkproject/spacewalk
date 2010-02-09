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
package com.redhat.rhn.frontend.action.configuration.files;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.commons.lang.StringEscapeUtils;
import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CompareDeployedSubmitAction
 * @version $Rev$
 */
public class CompareDeployedSubmitAction extends RhnSetAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User userIn, 
                                       ActionForm formIn, 
                                       HttpServletRequest requestIn) {
        Long cfnid = ConfigActionHelper.getFile(requestIn).getConfigFileName().getId();
        
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listSystemsForFileCompare(userIn, cfnid, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_SYSTEMS;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("comparedeployed.jsp.schedule", "schedule");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, 
                                   HttpServletRequest requestIn, 
                                   Map paramsIn) {
        ConfigActionHelper.processParamMap(requestIn, paramsIn);
    }
    
    /**
     * Schedule the config diff action using the set of systems in rhnSet.
     * @param mapping struts ActionMapping
     * @param formIn struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return the default ActionForward
     */
    public ActionForward schedule(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        updateSet(request);
        User user = requestContext.getLoggedInUser();
        
        //get the set from the database and then clear it.
        RhnSet set = RhnSetDecl.CONFIG_SYSTEMS.get(user);
        RhnSetDecl.CONFIG_SYSTEMS.clear(user);
        
        //We want a set of ids, but we have a set of RhnSetElements.  This
        //does the conversion.
        Set sids = new HashSet();
        Iterator i = set.getElements().iterator();
        while (i.hasNext()) {
            Long sid = ((RhnSetElement)i.next()).getElement();
            sids.add(sid);
        }
        
        //We need a set of ids to send to ActionManager.  We only have one id.
        ConfigRevision revision = 
            ConfigActionHelper.getRevision(request, ConfigActionHelper.getFile(request));
        Set crids = new HashSet();
        crids.add(revision.getId());
        
        //create the action and then create the message to send the user.
        Action action = ActionManager.createConfigDiffAction(user, crids, sids);
        makeMessage(action, request);
        
        //go to the next page.
        ActionForward base = mapping.findForward(RhnHelper.DEFAULT_FORWARD);
        Map params = new HashMap();
        processParamMap(formIn, request, params);
        return getStrutsDelegate().forwardParams(base, params);
    }
    
    private void makeMessage(Action action, HttpServletRequest request) {
        if (action != null) {
            //get how many servers this action was created for.
            int successes = action.getServerActions().size();
            String number = LocalizationService.getInstance()
                    .formatNumber(new Integer(successes));
            
            //build the url for the action we have created.
            String url = "/rhn/schedule/ActionDetails.do?aid=" + action.getId();
            
            //create the success message
            ActionMessages msg = new ActionMessages();
            String key;
            if (successes == 1) {
                key = "configdiff.schedule.success.singular";
            }
            else {
                key = "configdiff.schedule.success";
            }
            
            Object[] args = new Object[2];
            args[0] = StringEscapeUtils.escapeHtml(url);
            args[1] = StringEscapeUtils.escapeHtml(number);
            
            //add in the success message
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(key, args));
            getStrutsDelegate().saveMessages(request, msg);
        }
        else {
            //Something went wrong, tell user!
            ActionErrors errors = new ActionErrors();
            getStrutsDelegate().addError("configdiff.schedule.error", errors);
            getStrutsDelegate().saveMessages(request, errors);
        }
    }
    
}
