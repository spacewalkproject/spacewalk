/**
 * Copyright (c) 2013 Red Hat, Inc.
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
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * AdminListAction
 */
public class AdminListAction extends RhnAction implements Listable {


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        ManagedServerGroup serverGroup = requestContext.lookupAndBindServerGroup();
        User user = requestContext.getCurrentUser();

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                RhnSetDecl.setForSystemGroupAdmins(serverGroup));
        Set<Long> preselected = new HashSet<Long>();
        for (User item : (List<User>) ServerGroupFactory.listAdministrators(serverGroup)) {
                preselected.add(item.getId());
        }
        helper.preSelect(preselected);

        Map params = makeParamMap(request);
        params.put(RequestContext.SERVER_GROUP_ID, serverGroup.getId());

        if (requestContext.isSubmitted()) {
            // make sure the user has enough perms
            if (!UserManager.canAdministerSystemGroup(user, serverGroup)) {
                throw new PermissionCheckFailureException();
            }

            long updated = 0;
            // remove admins
            for (Iterator<Long> iter = helper.getRemovedKeys().iterator();
                    iter.hasNext();) {
                Long uid = iter.next();
                if (!UserManager.hasRole(uid, RoleFactory.ORG_ADMIN)) {
                    UserManager.revokeServerGroupPermission(uid, serverGroup.getId());
                }
                updated++;
            }

            // add group admins
            for (Iterator<Long> iter = helper.getAddedKeys().iterator(); iter.hasNext();) {
                Long uid = iter.next();
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
                    mapping.findForward("submitted"), params);
        }

        helper.execute();

        return StrutsDelegate.getInstance().forwardParams(
                mapping.findForward("default"), params);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        User currentUser = context.getCurrentUser();
        List<UserOverview> userList = UserManager.activeInOrg2(currentUser);
        for (UserOverview uo : userList) {
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
