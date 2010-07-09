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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Iterator;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * PackagePushSetupAction
 */
public class PackagePushSetupAction extends RhnListAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getLoggedInUser();

        PageControl pc = new PageControl();
        pc.setFilterColumn("earliest");

        Long eid = rctx.getRequiredParam("eid");
        Errata e = ErrataManager.lookupErrata(eid, user);

        /* If the errata is unpublished, we
         * don't need to do a package push
         */
        if (!e.isPublished()) {
            request.setAttribute("eid", eid);
            return mapping.findForward("finished");
        }

        clampListBounds(pc, request, user);

        RhnSet targetChannels = RhnSetDecl.CHANNELS_FOR_ERRATA.get(user);

        Set set = targetChannels.getElements();

        Iterator i = set.iterator();

        RhnSet packageSet = RhnSetDecl.PACKAGES_TO_PUSH.get(user);

        if (!rctx.isSubmitted()) {
            packageSet.clear();
            RhnSetManager.store(packageSet);
        }

        /* Here we loop through the set of channels the user just selected
         * and prompt them if they would like to push the packages in
         * the errata that are newer than the version of the channel into
         * the channel */
        while (i.hasNext()) {

            if (set.isEmpty()) {
                mapping.findForward("finished");
            }

            RhnSetElement element = (RhnSetElement) i.next();
            Long cid = element.getElement();
            DataResult dr = PackageManager.
                            possiblePackagesForPushingIntoChannel(cid, eid, pc);

            i.remove();

            Channel c = ChannelManager.lookupByIdAndUser(cid, user);
            if (!dr.isEmpty()) {
                request.setAttribute("pageList", dr);
                request.setAttribute("cid", cid);
                request.setAttribute("set", packageSet);
                request.setAttribute("advisory", e.getAdvisory());
                request.setAttribute("channel_name", c.getName());
                return mapping.findForward("default");
            }
        }

        request.setAttribute("eid", eid);
        return mapping.findForward("finished");
    }

}
