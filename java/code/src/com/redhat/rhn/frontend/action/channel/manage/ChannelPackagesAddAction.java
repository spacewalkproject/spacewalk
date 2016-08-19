/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.SelectableChannel;
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
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class ChannelPackagesAddAction extends ChannelPackagesBaseAction {

    private final String SELECTED_CHANNEL = "selected_channel";
    private final String ALL_PACKAGES = "all_managed_packages";
    private final String ALL_PACKAGES_SELECTED = "all_selected";
    private final String ORPHAN_PACKAGES = "orphan_packages";
    private final String ORPHAN_PACKAGES_SELECTED = "orphan_selected";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getCurrentUser();

        long cid = requestContext.getRequiredParam("cid");
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);

        if (!UserManager.verifyChannelAdmin(user, chan)) {
              throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }
        if (chan.getOrg() == null) {
            throw new PermissionCheckFailureException();
        }


        request.setAttribute("cid", chan.getId());


        RhnSet set =  RhnSetDecl.PACKAGES_TO_ADD.get(user);

        //Since if we are going to the confirm screen, we don't need to
        //actually do anything else, so lets go ahead and forward and save some time
        String button = LocalizationService.getInstance().getMessage(
        "channel.jsp.package.addbutton");
        if (button.equals(request.getParameter(RhnHelper.CONFIRM_FORWARD)) &&
            set.size() > 0) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("cid", cid);
            return getStrutsDelegate().forwardParams(
                                mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
        }




        String selectedChan = request.getParameter(SELECTED_CHANNEL);
        DataResult result = null;


        //selected channel id
        long scid = 0;


        //go ahead and set these to false.  We'll change them down a bit  if we need to
        request.setAttribute(ALL_PACKAGES_SELECTED, false);
        request.setAttribute(ORPHAN_PACKAGES_SELECTED, false);

        //If a channel isn't selected, select one smartly
        if (selectedChan == null) {
            if (chan.isCloned()) {
                selectedChan = chan.getOriginal().getId().toString();
            }
            else {
                selectedChan = ORPHAN_PACKAGES;
            }
        }


        if (ALL_PACKAGES.equals(selectedChan)) {
            result = PackageManager.lookupCustomPackagesForChannel(cid,
                    user.getOrg().getId());
            request.setAttribute(ALL_PACKAGES_SELECTED, true);
        }
        else if (ORPHAN_PACKAGES.equals(selectedChan)) {
            result = PackageManager.listOrphanPackages(user.getOrg().getId(), false);
            request.setAttribute(ORPHAN_PACKAGES_SELECTED, true);
        }
        else {
            scid = Long.parseLong(selectedChan);
            result = PackageManager.lookupPackageForChannelFromChannel(scid, cid);
        }


        //Add Red Hat Base Channels, and custom base channels to the list, and if one
        //      is selected, select it
        List<SelectableChannel> chanList = findChannels(user, scid);
        chanList.remove(chan);

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

        ListTagHelper.bindSetDeclTo(listName,  RhnSetDecl.PACKAGES_TO_ADD, request);
        TagHelper.bindElaboratorTo(listName, result.getElaborator(), request);



        request.setAttribute("channel_list", chanList);


        request.setAttribute("channel_name", chan.getName());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(RequestContext.PAGE_LIST, result);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);

    }
}
