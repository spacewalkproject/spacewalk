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

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.ServerGroupManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * ListRemoveGroupsAction
 * @version $Rev$
 */
public class ListRemoveGroupsAction extends BaseListAction implements Listable {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {
        setup(request);
        RequestContext context = new RequestContext(request);
        Map params = new HashMap();
                params.put(RequestContext.SID,
                        context.getRequiredParam(RequestContext.SID));
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request, params);
        helper.setDataSetName(getDataSetName());
        helper.setListName(getListName());
        helper.execute();
        if (helper.isDispatched()) {
            return handleDispatch(helper, mapping, formIn, request, response);
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public ActionForward handleDispatch(
            ListSessionSetHelper helper,
            ActionMapping mapping,
            ActionForm formIn, HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        User user = context.getLoggedInUser();
        Server server = context.lookupAndBindServer();
        ServerGroupManager manager = ServerGroupManager.getInstance();
        List <Server> servers = new LinkedList<Server>();
        servers.add(server);
        Set <String> set = helper.getSet();

        for (String id : set) {
            Long sgid = Long.valueOf(id);
            ServerGroup group = manager.lookup(sgid, user);
            manager.removeServers(group, servers, user);
        }
        helper.destroy();
        getStrutsDelegate().saveMessage(
                    "systems.groups.jsp.removed",
                        new String [] {String.valueOf(set.size())}, request);

        Map params = new HashMap();
        params.put(RequestContext.SID, server.getId().toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams
                        (mapping.findForward("success"), params);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        Server server = context.lookupAndBindServer();
        return server.getManagedGroups();
    }
}
