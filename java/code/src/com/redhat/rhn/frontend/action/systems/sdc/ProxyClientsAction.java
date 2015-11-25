/**
 * Copyright (c) 2014--2015 Red Hat, Inc.
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

import java.util.List;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemHardwareAction handles the interaction of the ChannelDetails page.
 * @version $Rev$
 */
public class ProxyClientsAction extends RhnAction implements Listable<SystemOverview> {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext ctx = new RequestContext(request);
        User user =  ctx.getCurrentUser();
        Server server = ctx.lookupAndBindServer();
        Long sid = server.getId();

        SystemManager.ensureAvailableToUser(user, sid);

        if (server.isProxy()) {
            request.setAttribute("version",
                    server.getProxyInfo().getVersion().getVersion());
        }

        ListHelper helper = new ListHelper(this, request);
        helper.setListName("systemList");
        helper.setDataSetName(RequestContext.PAGE_LIST);
        helper.execute();

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Get the list of client systems
     * @param context the request context
     * @return the list of client systems
     */
    public List<SystemOverview> getResult(RequestContext context) {
        Long sid = context.getRequiredParam(RequestContext.SID);
        DataResult<SystemOverview> clients = SystemManager.listClientsThroughProxy(sid);
        clients.elaborate();
        return clients;
    }

}
