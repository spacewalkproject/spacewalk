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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class ChannelDetailsAction extends RhnAction {
   

    
    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        
        
        long cid = requestContext.getRequiredParam("cid");
        
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
        ChannelFactory.lookupByLabelAndUser(chan.getLabel(), user);
        
        if (requestContext.isSubmitted()) {
            UserManager.verifyChannelAdmin(user, chan);
            String global = request.getParameter("global");
            chan.setGloballySubscribable(global != null, user.getOrg());
            chan = (Channel) ChannelFactory.reload(chan);
        }
        
        request.setAttribute("systems_subscribed",  
                SystemManager.subscribedToChannelSize(user, cid));
        request.setAttribute("channel_name", chan.getName());
        request.setAttribute("pack_size", ChannelFactory.getPackageCount(chan));
        request.setAttribute("globally", chan.isGloballySubscribable(user.getOrg()));
        request.setAttribute("channel", chan);
        
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            request.setAttribute("checkbox_disabled", true);
        }
        
        
        
        return mapping.findForward("default");

    }
    
    

    
    
}
