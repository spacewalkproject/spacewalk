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
package com.redhat.rhn.frontend.action.configuration.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.BaseSetOperateOnSelectedItemsAction;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * For ssm config channel subscriptions.
 * @version $Rev$
 */
public class SubscribeSubmit extends BaseSetOperateOnSelectedItemsAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user, ActionForm form,
            HttpServletRequest request) {
        return ConfigurationManager.getInstance().ssmChannelListForSubscribe(user, null);
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.CONFIG_CHANNELS_RANKING;
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("ssm.config.subscribe.jsp.continue", "proceed");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm form,
            HttpServletRequest request, Map params) {
        //no-op
    }
    
    /**
     * Continue to the confirm page.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward proceed(ActionMapping mapping,
                                    ActionForm formIn,
                                    HttpServletRequest request,
                                    HttpServletResponse response) {
        //if they chose no probe suites, return to the same page with a message
        RhnSet set = updateSet(request);
        
        RequestContext context = new RequestContext(request);
        if (!context.isJavaScriptEnabled()) {
            return handleNoScript(mapping, formIn, request, response);
        }
        
        if (set.isEmpty()) {
            return handleEmptySelection(mapping, formIn, request);
        }
        
        /* BZ 221637 - Any channels that is already subscribed to by all servers will be
           omitted from the user selectable list. This RhnSet is used in the ranking
           process on the next page, so need to add in those omitted channels explicitly
           so they take place in the ranking.        
         */
        User user = context.getLoggedInUser();
        ConfigurationManager manager = ConfigurationManager.getInstance();
        DataResult channels = manager.ssmChannelListForSubscribeAlreadySubbed(user);

        for (Iterator it = channels.iterator(); it.hasNext();) {
            ConfigChannelDto channel = (ConfigChannelDto) it.next();
            set.addElement(channel.getId());
        }

        RhnSetManager.store(set);
        
        return mapping.findForward("confirm");
    }
    

    /**
     * 
     * {@inheritDoc}
     */
    protected ActionMessage getNoScriptMessage() {
       return new ActionMessage(
               "common.config.subscription.jsp.error.nojavascript"); 
    }    
}
