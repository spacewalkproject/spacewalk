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
package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelPackagesAction
 * @version $Rev$
 */
public class CustomPackagesDeleteConfirmAction extends RhnAction {

    private final String LIST_NAME = "packageList";


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();


        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionException(RoleFactory.CHANNEL_ADMIN);
        }

        RhnSet set =  RhnSetDecl.DELETABLE_PACKAGE_LIST.get(user);
        DataResult result = PackageManager.packageIdsInSet(user, set.getLabel(), null);


        TagHelper.bindElaboratorTo(LIST_NAME, result.getElaborator(), request);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("pageList", result);

        String button = LocalizationService.getInstance().getMessage(
        "channel.jsp.manage.package.delete");


        if (button.equals(request.getParameter("confirm")) && set.size() > 0) {
            int setSize = set.size();

            deletePackages(user, set);


            ActionMessages msg = new ActionMessages();
            String[] actionParams = {setSize + ""};
            msg.add(ActionMessages.GLOBAL_MESSAGE,
                    new ActionMessage("channel.java.package.deletesuccess",
                            actionParams));

            getStrutsDelegate().saveMessages(requestContext.getRequest(), msg);


            Map params = new HashMap();
            return getStrutsDelegate().forwardParams(mapping.findForward("deleted"),
                    params);

        }
        return mapping.findForward("default");

    }


    private void deletePackages(User user, RhnSet set) {
        PackageManager.deletePackages(set.getElementValues(), user);
    }

}
