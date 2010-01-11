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
package com.redhat.rhn.frontend.action.channel.manage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class ChannelPackagesRemoveAction extends RhnAction {

    private final String LIST_ACTION = "packageList";


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

        RhnSet set =  RhnSetDecl.PACKAGES_TO_REMOVE.get(user);
        DataResult result = PackageManager.packageIdsInSet(user, set.getLabel(), null);

        
        TagHelper.bindElaboratorTo(LIST_ACTION, result.getElaborator(), request);
        request.setAttribute("cid", chan.getId());
        request.setAttribute("channel_name", chan.getName());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("pageList", result);

        String button = LocalizationService.getInstance().getMessage(
        "channel.jsp.package.confirmbutton");

        if (button.equals(request.getParameter("confirm")) && set.size() > 0) {
            removePackages(user, chan, set);
            ActionMessages msg = new ActionMessages();
            String[] actionParams = {set.size() + "", chan.getName()};
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("channel.jsp.package.removesuccess",
                            actionParams));

            getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);

            Map params = new HashMap();
            params.put("cid", cid);
            return getStrutsDelegate().forwardParams(mapping.findForward("complete"),
                    params);

        }
        return mapping.findForward("default");

    }


    private void removePackages(User user, Channel chan, RhnSet set) {
        List<Long> ids = new ArrayList<Long>();
        ids.addAll(set.getElementValues());
        ChannelManager.removePackages(chan, ids, user);
        ErrataCacheManager.deleteCacheEntriesForChannelPackages(chan.getId(), ids);
        ChannelManager.refreshWithNewestPackages(chan, "web.channel_package_remove");
    }

}
