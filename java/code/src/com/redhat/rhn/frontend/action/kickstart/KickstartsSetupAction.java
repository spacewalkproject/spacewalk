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
package com.redhat.rhn.frontend.action.kickstart;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.kickstart.CobblerProfileDto;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * KickstartsSetupAction.
 * @version $Rev: 1 $
 */
public class KickstartsSetupAction  extends RhnAction {
    
    /**
     * 
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user =  requestContext.getLoggedInUser();
        DataResult <KickstartDto>result = KickstartLister.getInstance().
                            kickstartsInOrg(user.getOrg(), null);
        for (KickstartDto dto : result) {
            if (dto.isOrgDefault()) {
                request.setAttribute("orgDefaultExists", Boolean.TRUE);
                break;
            }
        }
        
        List<CobblerProfileDto> dtos = KickstartLister.getInstance().
                                                listCobblerProfiles(user);  
        result.addAll(dtos);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute("pageList", result);
        TagHelper.bindElaboratorTo("ksList", result.getElaborator(), request);
        return mapping.findForward("default");
    }
}
