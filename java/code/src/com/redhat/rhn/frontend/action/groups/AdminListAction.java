/**
 * Copyright (c) 2013--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.groups;

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.UserOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * AdminListAction
 */
public class AdminListAction extends BaseListAction {

    private ManagedServerGroup serverGroup;
    private User user;

    protected void setup(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        serverGroup = requestContext.lookupAndBindServerGroup();
        user = requestContext.getCurrentUser();
    }

    protected void processHelper(ListSessionSetHelper helper) {
        helper.ignoreEmptySelection();

        Set<String> preselected = new HashSet<String>();
        for (User item : (List<User>) ServerGroupFactory.listAdministrators(serverGroup)) {
                preselected.add(item.getId().toString());
        }
        helper.preSelect(preselected);
    }

    /** {@inheritDoc} */
    protected ActionForward handleDispatch(
            ListSessionSetHelper helper,
            ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {

        // make sure the user has enough perms
        if (!UserManager.canAdministerSystemGroup(user, serverGroup)) {
            throw new PermissionCheckFailureException();
        }

        long updated = 0;
        // remove admins
        for (Iterator<String> iter = helper.getRemovedKeys().iterator();
                iter.hasNext();) {
            Long uid = Long.valueOf(iter.next());
            if (!UserManager.hasRole(uid, RoleFactory.ORG_ADMIN)) {
                UserManager.revokeServerGroupPermission(uid, serverGroup.getId());
            }
            updated++;
        }

        // add group admins
        for (Iterator<String> iter = helper.getAddedKeys().iterator();
                iter.hasNext();) {
            Long uid = Long.valueOf(iter.next());
            if (!UserManager.hasRole(uid, RoleFactory.ORG_ADMIN)) {
                UserManager.revokeServerGroupPermission(uid, serverGroup.getId());
                UserManager.grantServerGroupPermission(uid, serverGroup.getId());
            }
            updated++;
        }
        if (updated > 0) {
            createSuccessMessage(request, "systemgroup.admins.updated",
                    serverGroup.getName());
        }
        return StrutsDelegate.getInstance().forwardParams(
                mapping.findForward("submitted"), getParamsMap(request));
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        List<UserOverview> userList = UserManager.activeInOrg2(user);
        for (UserOverview uo : userList) {
            uo.setSelectable(true);
            if (UserManager.hasRole(uo.getId(), RoleFactory.ORG_ADMIN)) {
                uo.setDisabled(true);
            }
            else if (UserManager.hasRole(uo.getId(), RoleFactory.SYSTEM_GROUP_ADMIN)) {
                uo.setLogin(uo.getLogin() + "*");
            }
        }
        return userList;
    }
}
