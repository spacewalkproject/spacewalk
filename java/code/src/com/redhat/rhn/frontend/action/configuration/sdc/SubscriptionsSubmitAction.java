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
package com.redhat.rhn.frontend.action.configuration.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SubscriptionsSubmitAction
 * @version $Rev$
 */
public class SubscriptionsSubmitAction extends BaseSetOperateOnSelectedItemsAction {
    
    public static final String CONTINUE_ACTION = 
                                        "sdc.config.subscriptions.jsp.continue";
    public static final String WIZARD_MODE = "wizard_mode";
    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS_RANKING;
    }

        /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm formIn,
            HttpServletRequest request) {
        RequestContext context = new RequestContext(request);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        Server server = context.lookupAndBindServer();
        return cm.listGlobalChannelsForSystemSubscriptions(server, user, null);        
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put(CONTINUE_ACTION, "moveToRankChannel");
    }

    /**
     * 
     * {@inheritDoc}
     */
    protected ActionMessage getNoScriptMessage() {
       return new ActionMessage(
               "common.config.subscription.jsp.error.nojavascript"); 
    }
    
    /**
     * 
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward moveToRankChannel(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RhnSet set = updateSet(request);
        //if they chose no systems, return to the same page with a message
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }
        RequestContext context = new RequestContext(request);
       // if you are not Java script enabled we are not
       // letting you get to the ranking page.
       if (!context.isJavaScriptEnabled()) {
           return handleNoScript(mapping, formIn, request, response);
       }
       
       Server server = context.lookupAndBindServer();       
        //Map params = makeParamMap(formIn, request);
        Map params2 = new HashMap();
        params2.put(RequestContext.SID, server.getId().toString());
        params2.put(WIZARD_MODE, Boolean.TRUE.toString());
        return getStrutsDelegate().forwardParams(mapping.findForward("rank"),
                                                                        params2);
    }

    protected void processParamMap(ActionForm form, 
                                    HttpServletRequest request, Map params) {
        RequestContext  context = new RequestContext(request);
        params.put(RequestContext.SID, 
                        context.lookupAndBindServer().getId().toString());
    }    
}
