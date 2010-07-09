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
package com.redhat.rhn.frontend.action.multiorg;

import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.org.OrgManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * UserListSetupAction
 * @version $Rev: 101893 $
 */
public class UserListSetupAction extends RhnAction {

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext requestContext = new RequestContext(request);

        User user = requestContext.getLoggedInUser();

        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);
        Org org = OrgFactory.lookupById(oid);
        String name = org.getName();

        Long canModify =  (user.getOrg().getId().longValue() ==
                           oid.longValue()) &&
                          (user.hasRole(RoleFactory.ORG_ADMIN)) ?
                                  new Long(1) : new Long(0);
        DataList result = OrgManager.activeUsers(oid);

        request.setAttribute("canModify", canModify);
        request.setAttribute("orgName", name);
        request.setAttribute("pageList", result);
        request.setAttribute("parentUrl", request.getRequestURI() + "?oid=" + oid);
        return mapping.findForward("default");
    }
}
