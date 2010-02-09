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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SyncErrataAction
 * @version $Rev$
 */
public class SyncErrataAction extends RhnAction implements Listable  {

    /**
     *
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rc = new RequestContext(request);
        User user = rc.getLoggedInUser();

        Channel chan = ChannelManager.lookupByIdAndUser(
                rc.getRequiredParam(RequestContext.CID), user);

        try {
            ChannelManager.verifyChannelAdmin(user, chan.getId());
        }
        catch (InvalidChannelRoleException e) {
            addMessage(request, e.getMessage());
            return mapping.findForward("default");
        }

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                RhnSetDecl.ERRATA_TO_SYNC.createCustom(chan.getId()));

        helper.execute();
        if (helper.isDispatched()) {
            Map params = new HashMap();
            params.put(RequestContext.CID, chan.getId());
            return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                    params);
        }

        request.setAttribute("channel_name", chan.getName());
        request.setAttribute(RequestContext.CID, chan.getId());
        return mapping.findForward("default");
    }


    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        User user = context.getLoggedInUser();
        Channel chan = ChannelManager.lookupByIdAndUser(
                context.getRequiredParam(RequestContext.CID), user);

        return ChannelManager.listErrataNeedingResync(chan, user);
    }


}
