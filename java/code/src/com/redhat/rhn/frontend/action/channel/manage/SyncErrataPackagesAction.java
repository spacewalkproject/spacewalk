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
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.channel.ChannelEditor;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SyncErrataAction
 * @version $Rev$
 */
public class SyncErrataPackagesAction extends RhnAction implements Listable  {


    private Logger log = Logger.getLogger(SyncErrataPackagesAction.class);

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

        RhnSetDecl pkgDecl = RhnSetDecl.ERRATA_PACKAGES_TO_SYNC.createCustom(chan.getId());

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                pkgDecl);

        helper.setPreSelectAll(true);
        helper.execute();

        if (helper.isDispatched()) {

            Set eSet = RhnSetDecl.ERRATA_TO_SYNC.createCustom(
                    chan.getId()).get(user).getElementValues();
            Set pSet = pkgDecl.get(user).getElementValues();
            syncErrata(eSet, pSet, chan, user);


            ActionMessages msg = new ActionMessages();
            String[] msgParams = {eSet.size() + "", pSet.size() + "", chan.getName()};
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("channel.jsp.errata.sync.complete",
                            msgParams));
            getStrutsDelegate().saveMessages(rc.getRequest(), msg);


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
        String label = RhnSetDecl.ERRATA_TO_SYNC.createCustom(
                    chan.getId()).getLabel();

        return ChannelManager.listErrataPackagesForResync(chan, user, label);
    }


    private void syncErrata(Collection<Long> eids, Collection<Long> pids,
                                                      Channel chan, User user) {

        ChannelEditor.getInstance().addPackages(user, chan, pids);
        for (Long eid : eids) {
            Errata e = ErrataManager.lookupErrata(eid, user);
            if (e.isPublished() && e.isCloned()) {
                ErrataFactory.syncErrataDetails((PublishedClonedErrata) e);
            }
            else {
                log.fatal("Tried to sync errata with id " + eid +
                        " But it was not published or was not cloned");
            }
        }

    }

}
