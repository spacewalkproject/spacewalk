/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerSnapshot;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

/**
 * SnapshotTagCreateAction
 * @version $Rev$
 */
public class SnapshotTagCreateAction extends RhnAction {

    protected Long getSnapshotID(RequestContext context) {
        return null;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm)formIn;
        RequestContext context = new RequestContext(request);
        Long sid = context.getRequiredParam("sid");
        Server server = context.lookupAndBindServer();
        Long snapshotID = getSnapshotID(context);

        Map params = makeParamMap(request);
        params.put("sid", sid);
        if (snapshotID != null) {
            params.put("ss_id", snapshotID);
            request.setAttribute("parentUrl", request.getRequestURI() +
                    "?sid=" + sid.toString() + "&ss_id=" + snapshotID.toString());
        }
        else {
            request.setAttribute("parentUrl", request.getRequestURI() +
                "?sid=" + sid.toString());
        }

        if (context.isSubmitted()) {
            String tagName = form.get("tagName").toString();
            ServerSnapshot snap = null;
            if (snapshotID != null) {
                snap = ServerFactory.lookupSnapshotById(snapshotID.intValue());
            }
            else {
                snap = ServerFactory.lookupLatestForServer(server);
            }
            if (!snap.addTag(tagName)) {
                createErrorMessage(request,
                        "system.history.snapshot.tagCreateFailure", null);
            }
            else {
                createSuccessMessage(request, "system.history.snapshot.tagCreateSuccess",
                        null);
                return getStrutsDelegate().forwardParams(
                        mapping.findForward(RhnHelper.CONFIRM_FORWARD), params);
            }
        }

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }
}
