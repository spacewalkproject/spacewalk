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
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.TrustedOrgDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.org.OrgManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * OrgDetailsAction extends RhnAction - Class representation of the table web_customer
 * @version $Rev: 1 $
 */
public class OrganizationTrustAction extends RhnAction {
    public static final String ORG_LIST = "orgList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                  ActionForm formIn,
                                  HttpServletRequest request,
                                  HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getLoggedInUser();
        String name = user.getOrg().getName();
        String orgid = user.getOrg().getId().toString();
        DataList<TrustedOrgDto> result = OrgManager.trustedOrgs(user);

        request.setAttribute("orgName", name);
        request.setAttribute("orgId", orgid);
        request.setAttribute(ListTagHelper.PAGE_LIST, result);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        return mapping.findForward("default");
    }

}
