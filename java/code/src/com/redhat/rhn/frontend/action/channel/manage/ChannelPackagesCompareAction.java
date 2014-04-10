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
import com.redhat.rhn.domain.channel.SelectableChannel;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 */
public class ChannelPackagesCompareAction extends ChannelPackagesBaseAction {

    protected final String CHANNEL_LIST = "channel_list";
    protected final String CHANNEL_NAME = "channel_name";
    protected final String NO_PACKAGES = "no_packages";
    protected final String OTHER_CHANNEL = "other_channel";
    protected final String OTHER_ID = "other_id";
    protected final String SELECTED_CHANNEL = "selected_channel";
    protected final String SYNC_TYPE = "sync_type";

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getCurrentUser();


        long cid = requestContext.getRequiredParam(RequestContext.CID);
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);
        String syncType = request.getParameter(SYNC_TYPE);

        if (!UserManager.verifyChannelAdmin(user, chan)) {
              throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }
        if (chan.getOrg() == null) {
            throw new PermissionCheckFailureException();
        }


        String selectedChan = request.getParameter(SELECTED_CHANNEL);
        request.setAttribute(RequestContext.CID , chan.getId());
        request.setAttribute(CHANNEL_NAME , chan.getName());

        if (requestContext.wasDispatched("channel.jsp.package.mergebutton")) {
            Map params = new HashMap();
            params.put(RequestContext.CID, cid);
            params.put(OTHER_ID, selectedChan);
            params.put(SYNC_TYPE, syncType);
            return getStrutsDelegate().forwardParams(
                                mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
        }

        //selected channel id
        long scid = 0;
        String sname = "";

        //If a channel isn't selected, select one smartly
        if (selectedChan == null) {
            if (chan.isCloned()) {
                scid = chan.getOriginal().getId();
            }
        }
        else if (!NO_PACKAGES.equals(selectedChan)) {
            scid = Long.parseLong(selectedChan);
        }

        //Add Red Hat Base Channels, and custom base channels to the list, and if one
        //      is selected, select it
        List<SelectableChannel> chanList = findChannels(user, scid);
        DataResult result = null;


        if (scid != 0) {
            sname = ChannelFactory.lookupByIdAndUser(scid, user).getName();

            result = PackageManager.comparePackagesBetweenChannels(cid, scid);

            TagHelper.bindElaboratorTo(listName, result.getElaborator(), request);
        }

        request.setAttribute(CHANNEL_LIST, chanList);
        request.setAttribute(OTHER_CHANNEL, sname);
        request.setAttribute(SYNC_TYPE, syncType);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(RequestContext.PAGE_LIST, result);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);

    }
}
