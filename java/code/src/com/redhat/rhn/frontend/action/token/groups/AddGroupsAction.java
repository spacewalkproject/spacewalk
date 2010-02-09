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

package com.redhat.rhn.frontend.action.token.groups;

import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.token.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.manager.system.ServerGroupManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * AddGroupsAction
 * @version $Rev$
 */
public class AddGroupsAction extends BaseListAction {
    private static final String ACCESS_MAP = "accessMap";

    /** {@inheritDoc} */
    public ActionForward handleDispatch(ListSessionSetHelper helper,
                                    ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        ActivationKey key = context.lookupAndBindActivationKey();
        User user = context.getLoggedInUser();
        ServerGroupManager sgm = ServerGroupManager.getInstance();
        for (String id : helper.getSet()) {
            Long sgid = Long.valueOf(id);
            key.addServerGroup(sgm.lookup(sgid, user));
        }
        getStrutsDelegate().saveMessage(
                    "activation-key.groups.jsp.added",
                        new String [] {String.valueOf(helper.getSet().size())}, request);
        
        Map params = new HashMap();
        params.put(RequestContext.TOKEN_ID, key.getToken().getId().toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams
                        (mapping.findForward("success"), params);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        ActivationKey key = context.lookupAndBindActivationKey();
        User user = context.getLoggedInUser();
        List <ServerGroup> mainList = ServerGroupFactory.listManagedGroups(user.getOrg());
        List <ServerGroup> groups = new LinkedList<ServerGroup>();
        for (ServerGroup sg : mainList) {
            if (!key.getServerGroups().contains(sg)) {
                groups.add(sg);
            }
        }
        setupAccessMap(context, groups);
        return groups;
    }
    
    /**
     * Setups the user permissions access map 
     * after checking if the user can access
     * the servergroup.
     * @param context the request context
     * @param groups list of server groups
     */
    static void setupAccessMap(RequestContext context, List <ServerGroup> groups) {
        ServerGroupManager sgm = ServerGroupManager.getInstance();
        Map<Long, Long> accessMap = new HashMap<Long, Long>();
        for (ServerGroup sg : groups) {
            if (sgm.canAccess(context.getLoggedInUser(), sg)) {
                accessMap.put(sg.getId(), sg.getId());    
            }
        }
        context.getRequest().setAttribute(ACCESS_MAP, accessMap);
    }
}
