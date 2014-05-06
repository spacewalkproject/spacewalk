/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemPendingEventsAction
 * @version $Rev$
 */
public class SystemPendingEventsAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        Long sid = context.getRequiredParam("sid");
        Server server = context.lookupAndBindServer();
        User user = context.getCurrentUser();

        Map params = makeParamMap(request);
        params.put("sid", server.getId());

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() +
                "?sid=" + server.getId());
        request.setAttribute("sid", sid);

        RhnSet set =  RhnSetDecl.PENDING_ACTIONS_TO_DELETE.get(user);

        RhnListSetHelper helper = new RhnListSetHelper(request);

        if (context.wasDispatched("system.event.pending.cancel")) {
            helper.updateSet(set, RhnSetDecl.PENDING_ACTIONS_TO_DELETE.getLabel());
            if (!set.isEmpty()) {
                return getStrutsDelegate().forwardParams(
                        mapping.findForward("continue"), params);
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }

        set.clear();
        RhnSetManager.store(set);

        DataResult result = SystemManager.systemPendingEvents(sid, null);

        if (ListTagHelper.getListAction(RequestContext.PAGE_LIST, request) != null) {
            helper.execute(set, RequestContext.PAGE_LIST, result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount(RequestContext.PAGE_LIST,
                    set.size(), request);
        }

        ListTagHelper.bindSetDeclTo(RequestContext.PAGE_LIST,
                RhnSetDecl.PENDING_ACTIONS_TO_DELETE, request);
        TagHelper.bindElaboratorTo(RequestContext.PAGE_LIST,
                result.getElaborator(), request);

        params.put("isLocked", server.getLock() == null ? false : true);
        request.setAttribute(RequestContext.PAGE_LIST, result);

        return StrutsDelegate.getInstance().forwardParams(
                mapping.findForward("default"), params);
    }
}
