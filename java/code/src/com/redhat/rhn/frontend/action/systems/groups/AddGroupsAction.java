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

package com.redhat.rhn.frontend.action.systems.groups;

import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.DispatchedAction;
import com.redhat.rhn.frontend.action.systems.sdc.SdcHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.collection.WebSessionSet;
import com.redhat.rhn.manager.system.ServerGroupManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * AddGroupsAction
 * @version $Rev$
 */
public class AddGroupsAction extends DispatchedAction {
    /** {@inheritDoc} */
    @Override
    protected ActionForward commitAction(ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        GroupSet groups = new GroupSet(request);
        User user = context.getLoggedInUser();
        Server server = context.lookupAndBindServer();
        ServerGroupManager manager = ServerGroupManager.getInstance();
        
        List <Server> servers = new LinkedList<Server>();
        servers.add(server);
        Set <String> set = SessionSetHelper.lookupAndBind(request, groups.getDecl());
        
        for (String id : set) {
            Long sgid = Long.valueOf(id);
            ServerGroup group = manager.lookup(sgid, user);
            manager.addServers(group, servers, user);
        }
        getStrutsDelegate().saveMessage(
                    "systems.groups.jsp.added",
                        new String [] {String.valueOf(set.size())}, request);
        
        Map params = new HashMap();
        params.put(RequestContext.SID, server.getId().toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams
                        (mapping.findForward("success"), params);
    }

    @Override
    protected ActionForward setupAction(ActionMapping mapping, ActionForm form,
            HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        RequestContext context = new RequestContext(request);
        Server server = context.lookupAndBindServer();
        User user = context.getLoggedInUser();
        new GroupSet(request);
        SdcHelper.ssmCheck(request, server.getId(), user);
        request.setAttribute(ListTagHelper.PARENT_URL, 
                                request.getRequestURI() + "?" + 
                                RequestContext.SID + "=" + server.getId()); 
        
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
    

    private static class GroupSet extends WebSessionSet {

        public GroupSet(HttpServletRequest request) {
            super(request);
        }
        
        /** {@inheritDoc} */
        @Override
        protected List getResult() {
            RequestContext context = getContext();
            User user = context.getLoggedInUser();
            Server server = context.lookupAndBindServer();
            ServerGroupManager manager = ServerGroupManager.getInstance();
            Set<ManagedServerGroup> groups = new HashSet<ManagedServerGroup>
                                                        (server.getManagedGroups());
            List<ManagedServerGroup> all = user.getOrg().getManagedServerGroups();
            List<ManagedServerGroup> ret = new LinkedList<ManagedServerGroup>();
            for (ManagedServerGroup group : all) {
                if (!groups.contains(group) && manager.canAccess(user, group)) {
                    ret.add(group);
                }
            }
            return ret;
        }

        /**
         * Returns the declaration 
         * @return the declaration
         */
        @Override
        protected String getDecl() {
            return getClass().getName() + 
                getContext().getRequiredParam(RequestContext.SID);
        }
        
        @Override
        protected String getDataSetName() {
            return "all";
        }
    }    
}
