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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
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
 * Overview Action for the Configuration top level.
 * @version $Rev$
 */
public class OrgTrustDetailsAction extends RhnAction {
    
    /**
     * {@inheritDoc}
     */
    public final ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);        
        User user = requestContext.getLoggedInUser();
        Org org = user.getOrg();
        
        Long oid = requestContext.getParamAsLong(RequestContext.ORG_ID);        
        Org trustOrg = OrgFactory.lookupById(oid);
                
        String created = LocalizationService.getInstance()
        .formatDate(trustOrg.getCreated());
        
        String since = OrgManager.getTrustedSince(user, org, trustOrg);
                
        request.setAttribute("orgtrust", trustOrg.getName());
        request.setAttribute("created", created);
        request.setAttribute("since", since);
        request.setAttribute("migrationsfrom", 
                OrgManager.getMigratedSystems(user, trustOrg, org));
        request.setAttribute("migrationsto", 
                OrgManager.getMigratedSystems(user, org, trustOrg));
        request.setAttribute("channelsfrom",
                OrgManager.getSharedChannels(user, trustOrg, org));
        request.setAttribute("channelsto",
                OrgManager.getSharedChannels(user, org, trustOrg));
        request.setAttribute("sysleech",
                OrgManager.getSharedSubscribedSys(user, trustOrg, org));
        request.setAttribute("sysseed",
                OrgManager.getSharedSubscribedSys(user, org, trustOrg));

        return getStrutsDelegate().forwardParams(mapping.findForward("default"),
                      request.getParameterMap());
    }

}
