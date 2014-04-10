/**
 * Copyright (c) 2014 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.AlphaBarHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 */
public class ChannelPackagesCompareMergeAction extends ChannelPackagesCompareAction {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getCurrentUser();

        long cid = requestContext.getRequiredParam(RequestContext.CID);
        long scid = requestContext.getRequiredParam(OTHER_ID);
        String syncType = request.getParameter(SYNC_TYPE);
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
        Channel schan = ChannelFactory.lookupByIdAndUser(scid, user);

        if (!UserManager.verifyChannelAdmin(user, chan)) {
              throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }
        if (!canAccessChannel(user, schan)) {
            throw new PermissionCheckFailureException();
        }
        if (chan.getOrg() == null) {
            throw new PermissionCheckFailureException();
        }

        request.setAttribute(RequestContext.CID, chan.getId());
        request.setAttribute(CHANNEL_NAME, chan.getName());
        request.setAttribute(OTHER_ID, scid);
        request.setAttribute(SYNC_TYPE, syncType);

        RhnSet set =  RhnSetDecl.PACKAGES_TO_SYNC_CHANNEL.get(user);

        //Since if we are going to the confirm screen, we don't need to
        //actually do anything else, so lets go ahead and forward and save some time
        if (requestContext.wasDispatched("channel.jsp.package.mergebutton") &&
            set.size() > 0) {
            Map params = new HashMap();
            params.put(RequestContext.CID, cid);
            return getStrutsDelegate().forwardParams(
                                 mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
        }

        DataResult result = PackageManager.comparePackagesBetweenChannelsPreview(
                                            cid, scid, syncType);


        RhnListSetHelper helper = new RhnListSetHelper(request);

        String alphaBarPressed = request.getParameter(
                AlphaBarHelper.makeAlphaKey(TagHelper.generateUniqueName(listName)));
        if (!requestContext.isSubmitted() && alphaBarPressed == null) {
            set.clear();
            RhnSetManager.store(set);
        }
        else if (ListTagHelper.getListAction(listName, request) != null) {
            helper.execute(set, listName, result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount(listName, set.size(), request);
        }

        ListTagHelper.bindSetDeclTo(listName, RhnSetDecl.PACKAGES_TO_SYNC_CHANNEL, request);
        TagHelper.bindElaboratorTo(listName, result.getElaborator(), request);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(RequestContext.PAGE_LIST, result);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
