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
package com.redhat.rhn.frontend.action.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelOverview;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
import com.redhat.rhn.frontend.listview.ListControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ChannelFamilyTreeAction
 * @version $Rev$
 */
public class ChannelFamilyTreeAction extends BaseChannelTreeAction {
    
  
    

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        
        RequestContext requestContext = new RequestContext(request);
        
        Long cfid = requestContext.getRequiredParam("cfid");
        
        User user = requestContext.getLoggedInUser();
        ChannelOverview co = ChannelManager.getEntitlement(user.getOrg().getId(), cfid);
        
        DataResult<ChannelTreeNode> dr = getDataResult(requestContext, null);
        Collections.sort(dr);
        dr = handleOrphans(dr);
        dr.setFilter(false);
        request.setAttribute("pageList", dr);
        request.setAttribute("cfid", cfid);
        request.setAttribute("familyName", co.getName());

        return mapping.findForward("default");
    }

    @Override
    protected DataResult getDataResult(RequestContext requestContext, ListControl lc) {
        User user = requestContext.getCurrentUser();
        Long cfid = requestContext.getRequiredParam("cfid");
        return ChannelManager.channelFamilyTree(user, cfid, lc);
    }

    

    
    

}
