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

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.MultiOrgSystemEntitlementsDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.manager.org.OrgManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * SystemEntitlementsAction
 * @version $Rev$
 */
public class SystemEntitlementsAction extends RhnAction {

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response) throws Exception {

        RequestContext requestContext = new RequestContext(request);
        User u = requestContext.getLoggedInUser();

        List<MultiOrgSystemEntitlementsDto>result = OrgManager.allOrgsEntitlements();

        Long orgCount = OrgManager.getTotalOrgCount(u);

        request.setAttribute("orgCount", orgCount);
        request.setAttribute("pageList", result);
        request.setAttribute("parentUrl", request.getRequestURI());

        return mapping.findForward("default");
    }

}
