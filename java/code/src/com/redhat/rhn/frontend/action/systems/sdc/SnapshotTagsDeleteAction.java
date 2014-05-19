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
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SnapshotTagDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;

/**
 * SystemPendingEventsCancelAction
 * @version $Rev$
 */
public class SnapshotTagsDeleteAction extends RhnAction {

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        Long sid = context.getRequiredParam("sid");
        User user =  context.getCurrentUser();
        Server server = context.lookupAndBindServer();

        RhnSet set = RhnSetDecl.SNAPSHOT_TAGS_TO_DELETE.get(user);
        DataResult<SnapshotTagDto> result = SystemManager
                .snapshotTagsInSet(context.getCurrentUser(), null,
                RhnSetDecl.SNAPSHOT_TAGS_TO_DELETE.getLabel(), sid);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
        request.setAttribute(RequestContext.PAGE_LIST, result);

        if (context.wasDispatched("confirm.jsp.confirm")) {
            for (SnapshotTagDto sTag : result) {
                ServerFactory.removeTagFromSnapshot(sid,
                        ServerFactory.lookupSnapshotTagbyName(sTag.getName()));
            }
            createSuccessMessage(request, "system.history.snapshot.tagDeleteSuccess",
                    new Integer(set.size()).toString());
            set.clear();
            RhnSetManager.store(set);
            Map params = makeParamMap(request);
            params.put("sid", server.getId());
            return getStrutsDelegate().forwardParams(
                    mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

}
