/**
 * Copyright (c) 2014--2017 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.sdc;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.BaseSystemsAction;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.HashSet;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProxyClientsAction
 * @version $Rev$
 */
public class ProxyClientsAction extends BaseSystemsAction {

    private Server server;

    /** {@inheritDoc} */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();
        server = requestContext.lookupAndBindServer();

        if (server.isProxy()) {
            request.setAttribute("version",
                    server.getProxyInfo().getVersion().getVersion());
            DataResult<SystemOverview> result = getDataResult(user, null, formIn);
            if (result.isEmpty()) {
                request.setAttribute(SHOW_NO_SYSTEMS, Boolean.TRUE);
            }
            RhnSet set = getSetDecl().get(user);

            RhnListSetHelper helper = new RhnListSetHelper(request);
            if (ListTagHelper.getListAction("systemList", request) != null) {
                helper.execute(set, "systemList", result);
            }
            if (!set.isEmpty()) {
                helper.syncSelections(set, result);
                ListTagHelper.setSelectedAmount("systemList", set.size(), request);
            }
            ListTagHelper.bindSetDeclTo("systemList", getSetDecl(), request);
            request.setAttribute(RequestContext.PAGE_LIST, result);
            request.setAttribute(ListTagHelper.PARENT_URL,
                    request.getRequestURI() + "?sid=" + server.getId());
            TagHelper.bindElaboratorTo("systemList", result.getElaborator(), request);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected DataResult<SystemOverview> getDataResult(User user, PageControl pc,
            ActionForm formIn) {
        DataResult<SystemOverview> clients = SystemManager.listClientsThroughProxy(
                server.getId());
        if (clients != null && !clients.isEmpty()) {
            HashSet<Long> clientIdSet = new HashSet<>();
            for (SystemOverview client: clients) {
                clientIdSet.add(client.getId());
            }
            clients.clear();
            for (SystemOverview client: SystemManager.systemList(user, pc)) {
                if (clientIdSet.contains(client.getId())) {
                    clients.add(client);
                }
            }
        }
        return clients;
    }
}
