/**
 * Copyright (c) 2015--2018 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.groups;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemGroupOverview;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SSMGroupManageAction
 * @version $Rev$
 */
public class SSMGroupConfirmAction extends RhnAction
    implements Listable<SystemGroupOverview> {

    // must match rl:list dataset and name tags!!
    private String ADD_DATA = "addSet";
    private String ADD_LIST = "addList";
    private String RMV_DATA = "removeSet";
    private String RMV_LIST = "removeList";

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        RequestContext rctx = new RequestContext(request);
        User user = rctx.getCurrentUser();
        DynaActionForm daForm = (DynaActionForm)form;

        RhnSet groupSet = RhnSetDecl.SSM_GROUP_LIST.lookup(user);
        if (groupSet == null) {
            return mapping.findForward("success");
        }

        ListSessionSetHelper addedHelper = new ListSessionSetHelper(this, request);
        addedHelper.setDataSetName(ADD_DATA);
        addedHelper.setListName(ADD_LIST);
        addedHelper.ignoreEmptySelection();
        addedHelper.execute();

        ListSessionSetHelper removedHelper = new ListSessionSetHelper(this, request);
        removedHelper.setDataSetName(RMV_DATA);
        removedHelper.setListName(RMV_LIST);
        removedHelper.ignoreEmptySelection();
        removedHelper.execute();

        List<SystemGroupOverview> addList = new ArrayList<SystemGroupOverview>();
        List<SystemGroupOverview> removeList = new ArrayList<SystemGroupOverview>();

        List<SystemGroupOverview> groups = SystemManager.groupList(user, null);
        Map<Long, SystemGroupOverview> groupMap = new HashMap<Long, SystemGroupOverview>();
        for (SystemGroupOverview group : groups) {
            groupMap.put(group.getId(), group);
        }

        for (RhnSetElement element : groupSet.getElements()) {
            Long gid = element.getElement();
            if (groupMap.containsKey(gid)) {
                if (element.getElementTwo() == SSMGroupManageAction.ADD) {
                    addList.add(groupMap.get(gid));
                }
                else if (element.getElementTwo() == SSMGroupManageAction.REMOVE) {
                    removeList.add(groupMap.get(gid));
                }
            }
        }

        List<SystemOverview> systems = SystemManager.inSet(user, RhnSetDecl.SYSTEMS
                .getLabel());

        // If submitted, actually do the add / remove
        if (addedHelper.isDispatched()) {
            Set<Server> servers = new HashSet<Server>();
            for (SystemOverview system : systems) {
                servers.add(ServerFactory.lookupById(system.getId()));
            }
            ServerGroupManager manager = ServerGroupManager.getInstance();
            for (SystemGroupOverview group : addList) {
                ManagedServerGroup msg = manager.lookup(group.getId(), user);
                Set<Server> difference = new HashSet<Server>(servers);
                difference.removeAll(msg.getServers());
                manager.addServers(msg, difference, user);
            }
            for (SystemGroupOverview group : removeList) {
                ManagedServerGroup msg = manager.lookup(group.getId(), user);
                Set<Server> intersection = new HashSet<Server>(msg.getServers());
                intersection.retainAll(servers);
                manager.removeServers(msg, intersection, user);
            }
            createSuccessMessage(request, "ssm.groups.changed", null);
            groupSet.clear();
            RhnSetManager.store(groupSet);

            return mapping.findForward("success");
        }

        request.setAttribute(ADD_DATA, addList);
        request.setAttribute(RMV_DATA, removeList);
        request.setAttribute("numServers", systems.size());
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    @Override
    public List getResult(RequestContext context) {
        // TODO Auto-generated method stub
        return null;
    }
}

