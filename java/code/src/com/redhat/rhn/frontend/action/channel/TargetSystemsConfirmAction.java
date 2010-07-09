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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * TargetSystemsConfirmAction
 * @version $Rev$
 */
public class TargetSystemsConfirmAction extends RhnAction implements Listable {

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
        request.setAttribute("channel_name", chan.getName());
        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                TargetSystemsAction.getSetDecl(chan));
        helper.setWillClearSet(false);
        helper.execute();

        request.setAttribute("channel_name", chan.getName());
        request.setAttribute("cid", chan.getId());
        if (helper.isDispatched()) {
            RhnSet set = TargetSystemsAction.getSetDecl(chan).get(user);
            for (Long id : set.getElementValues()) {
                Server s  = SystemManager.lookupByIdAndUser(id, user);
                SystemManager.subscribeServerToChannel(user, s, chan);
            }
            Map params = new HashMap();
            params.put(RequestContext.CID, cid);
            ActionMessages msgs = new ActionMessages();
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("channeltarget.success", set.size(), chan.getName()));
            getStrutsDelegate().saveMessages(request, msgs);


            return getStrutsDelegate().forwardParams(mapping.findForward("success"),
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
        return SystemManager.inSet(user, TargetSystemsAction.getSetDecl(chan).getLabel());
    }



}
