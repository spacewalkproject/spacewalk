/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.DispatchedAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.collection.WebSessionSet;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.org.OrgManager;

/**
 * OrgChannelListAction
 * @version $Rev$
 */
public class OrgChannelListAction extends DispatchedAction {
    
    @Override
    protected ActionForward setupAction(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        
        RequestContext ctx = new RequestContext(request);
        new OrgSet(request);
        Long cid = ctx.getParamAsLong("cid");
        Channel c = ChannelManager.lookupByIdAndUser(cid,
             ctx.getLoggedInUser());
        
        request.setAttribute("channel_name", c.getName());                
        request.setAttribute(ListTagHelper.PARENT_URL, 
                request.getRequestURI() + "?" + 
                RequestContext.CID + "=" + c.getId()); 

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    
    private static class OrgSet extends WebSessionSet {

        public OrgSet(HttpServletRequest request) {
            super(request);
        }

        @Override
        protected List getResult() {
            RequestContext context = getContext();
            User user = context.getLoggedInUser();
            Org org = user.getOrg();
            Long cid = context.getParamAsLong(RequestContext.CID);         
            return OrgManager.orgChannelTrusts(cid, org);                        
        }
        
        @Override
        protected String getDecl() {
            return super.getDecl() + 
                    getContext().getLoggedInUser().getOrg().getId();
        }
        
    }

}
