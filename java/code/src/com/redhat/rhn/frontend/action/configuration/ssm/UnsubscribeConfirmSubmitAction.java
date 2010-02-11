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
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.configuration.ConfigActionHelper;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListDispatchAction;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Iterator;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UnsubscribeConfirmSubmitAction
 * @version $Rev$
 */
public class UnsubscribeConfirmSubmitAction extends RhnListDispatchAction {

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map mapIn) {
        mapIn.put("unsubscribeconfirm.jsp.confirm", "confirm");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
            HttpServletRequest requestIn, Map paramsIn) {
        //no-op
    }
    
    /**
     * Unsubscribes selected systems from selected config channels.
     * @param mapping struts ActionMapping
     * @param form struts ActionForm
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @return forward to the starting Diff page.
     */
    public ActionForward confirm(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) {
        User user = new RequestContext(request).getLoggedInUser();
        RhnSet channelSet = RhnSetDecl.CONFIG_CHANNELS.get(user);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        DataResult systemSet = cm.ssmSystemListForChannels(user, null);
        
        int successes = 0;
        Iterator systems = systemSet.iterator();
        //go through each system in the set
        while (systems.hasNext()) {
            Long sid = ((ConfigSystemDto)systems.next()).getId();
            Server server;
            boolean hit = false;
            try {
                server = SystemManager.lookupByIdAndUser(sid, user);
            }
            catch (LookupException e) {
                continue; //skip this element
            }
            
            Iterator channels = channelSet.getElements().iterator();
            //go through each channel and unsubscribe the current system
            while (channels.hasNext()) {
                Long ccid = ((RhnSetElement)channels.next()).getElement();
                ConfigChannel channel;
                try {
                    channel = cm.lookupConfigChannel(user, ccid);
                }
                catch (LookupException e) {
                    continue; //skip this element
                }
                
                //unsubscribe the channel
                if (server.unsubscribe(channel)) {
                    hit = true;
                }
            }
            
            //update the number of successes if we have done something to this server
            if (hit) {
                successes++;
            }
        }
        
        RhnSetManager.remove(channelSet); //clear the set
        //now that we have unsubscribed from channels, these other sets may
        //no longer be valid, so delete them too.
        ConfigActionHelper.clearRhnSets(user);
        
        createMessage(request, successes);
        return mapping.findForward("success");
    }
    
    private void createMessage(HttpServletRequest request, int successes) {
        ActionMessages msg = new ActionMessages();
        if (successes == 1) {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("unsubscribe.ssm.success"));
        }
        else {
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("unsubscribe.ssm.successes", new Integer(successes)));
        }
        getStrutsDelegate().saveMessages(request, msg);
    }
    
}
