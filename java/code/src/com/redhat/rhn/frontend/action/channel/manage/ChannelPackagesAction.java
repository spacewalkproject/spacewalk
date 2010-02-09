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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
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
 * @version $Rev$
 */
public class ChannelPackagesAction extends RhnAction {

    private final String LIST_NAME = "packageList";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();

        long cid = requestContext.getRequiredParam("cid");
        Channel chan = ChannelFactory.lookupByIdAndUser(cid, user);

        if (!UserManager.verifyChannelAdmin(user, chan)) {
              throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }
        if (chan.getOrg() == null) {
            throw new PermissionCheckFailureException();
        }



        DataResult result = PackageManager.listPackagesInChannelForList(cid);
        RhnListSetHelper helper = new RhnListSetHelper(request);

        RhnSet set =  RhnSetDecl.PACKAGES_TO_REMOVE.get(user);
        String alphaBarPressed = request.getParameter(
                AlphaBarHelper.makeAlphaKey(TagHelper.generateUniqueName(LIST_NAME)));
        if (!requestContext.isSubmitted() && alphaBarPressed == null) {
            set.clear();
            RhnSetManager.store(set);
        }
        else if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        ListTagHelper.bindSetDeclTo(LIST_NAME,  RhnSetDecl.PACKAGES_TO_REMOVE, request);
        TagHelper.bindElaboratorTo(LIST_NAME, result.getElaborator(), request);

        request.setAttribute("cid", chan.getId());
        request.setAttribute("channel_name", chan.getName());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("pageList", result);

        String button = LocalizationService.getInstance().getMessage(
                "channel.jsp.package.removebutton");


        if (button.equals(request.getParameter("confirm")) && set.size() > 0) {
            Map params = new HashMap();
            params.put("cid", cid);
            return getStrutsDelegate().forwardParams(mapping.findForward("confirm"),
                    params);
        }

        return mapping.findForward("default");

    }





}
