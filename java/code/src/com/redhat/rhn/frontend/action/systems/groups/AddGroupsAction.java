/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * AddGroupsAction
 * @version $Rev$
 */
public class AddGroupsAction extends RhnAction implements Listable {

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext context = new RequestContext(request);
        User user = context.getCurrentUser();
        Server server = context.lookupAndBindServer();
        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.execute();

        if (helper.isDispatched()) {
            ServerGroupManager manager = ServerGroupManager.getInstance();
            List <Server> servers = new LinkedList<Server>();
            servers.add(server);

            for (String id : helper.getSet()) {
                ServerGroup group = manager.lookup(Long.valueOf(id), user);
                manager.addServers(group, servers, user);
            }
            helper.destroy();
            getStrutsDelegate().saveMessage(
                    "systems.groups.jsp.added",
                        new String [] {String.valueOf(helper.getSet().size())}, request);

        Map<String, Object> params = new HashMap<String, Object>();
        params.put(RequestContext.SID, server.getId().toString());
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        return strutsDelegate.forwardParams
                        (mapping.findForward("success"), params);

        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

        /** {@inheritDoc} */
    public DataResult<ManagedServerGroup> getResult(RequestContext context) {

        Server server = context.lookupAndBindServer();
        ServerGroupManager manager = ServerGroupManager.getInstance();
        List<ManagedServerGroup> serverGroups = server.getManagedGroups();
        List<ManagedServerGroup> all = context.getCurrentUser().getOrg().
            getManagedServerGroups();
        List<ManagedServerGroup> ret = new LinkedList<ManagedServerGroup>();
        for (ManagedServerGroup group : all) {
            if (!serverGroups.contains(group) && manager.canAccess(
                        context.getCurrentUser(), group)) {
                ret.add(group);
            }
        }
        return new DataResult<ManagedServerGroup>(ret);
    }
}
