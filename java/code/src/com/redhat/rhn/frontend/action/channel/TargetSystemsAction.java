/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 
 * TargetSystemsAction
 * @version $Rev$
 */
public class TargetSystemsAction extends RhnAction implements Listable {

    /**
     * 
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        
        Long cid = requestContext.getRequiredParam(RequestContext.CID);
        Channel chan = ChannelManager.lookupByIdAndUser(cid, user);
        
        ListRhnSetHelper helper = new ListRhnSetHelper(this, request, getSetDecl(chan));
        helper.execute();
        request.setAttribute("channel_name", chan.getName());
        request.setAttribute("cid", chan.getId());
        
        
        if (helper.isDispatched()) {
            Map params = new HashMap();
            params.put(RequestContext.CID, cid);
            return getStrutsDelegate().forwardParams(mapping.findForward("confirm"),
                    params);
        } 
        
        return mapping.findForward("default");
    }
    
    
    /**
     *     
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        User user =  context.getLoggedInUser();
        Long cid = (Long) context.getRequiredParam(RequestContext.CID);
        Channel chan = ChannelManager.lookupByIdAndUser(cid, user);
        return SystemManager.listTargetSystemForChannel(user, chan);
    }
    
    /**
     * get the set decl
     * @param c the channel
     * @return the set decl
     */
    public static RhnSetDecl getSetDecl(Channel c) {
        return RhnSetDecl.TARGET_SYSTEMS_FOR_CHANNEL.createCustom(c.getId());
    }

}
