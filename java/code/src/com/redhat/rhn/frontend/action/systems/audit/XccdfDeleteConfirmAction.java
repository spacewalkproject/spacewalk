/**
 * Copyright (c) 2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.systems.audit;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.XccdfTestResultDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.audit.ScapManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * XccdfDeleteConfirmAction
 */
public class XccdfDeleteConfirmAction extends RhnAction {
    private static final String CONFIRM_BUT = "confirm.jsp.confirm";
    private static final String LIST_NAME = "xccdfScans";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext context = new RequestContext(request);
        Long sid = context.getRequiredParam(RequestContext.SID);
        Server server = context.lookupAndBindServer();
        User user = context.getCurrentUser();

        RhnSet set = getSetDecl(sid).get(user);
        if (request.getParameter("xid") != null) {
            Long xid = Long.parseLong(request.getParameter("xid"));
            if (xid != null && xid > 0) {
                // Being redirected from XccdfDetails.do, asked to delete a single scan
                set.clear();
                set.addElement(xid);
                RhnSetFactory.save(set);
            }
        }

        DataResult<XccdfTestResultDto> result = ScapManager.scansInSet(user,
                set.getLabel());

        TagHelper.bindElaboratorTo(LIST_NAME, result.getElaborator(), request);

        request.setAttribute(RequestContext.SID, sid);
        request.setAttribute(ListTagHelper.PARENT_URL,
            request.getRequestURI() + "?" + RequestContext.SID + "=" + sid);
        request.setAttribute(RequestContext.PAGE_LIST, result);

        if (context.wasDispatched(CONFIRM_BUT)) {
           Long removedCount = null;
           try {
               removedCount = ScapManager.deleteScansInSet(result);
           }
           finally {
               RhnSetFactory.cleanup(set);
           }
           Long retainedCount = result.size() - removedCount;
           ActionMessages msg = (removedCount == 0) ?
               new ActionErrors() : new ActionMessages();
           String[] messageParams = {removedCount.toString(), retainedCount.toString()};
           msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
               "system.audit.xccdfdeleteconfirm.jsp.message", messageParams));
           getStrutsDelegate().saveMessages(request, msg);
           Map<String, Long> params = new HashMap<String, Long>();
           params.put(RequestContext.SID, sid);
           return getStrutsDelegate().forwardParams(mapping.findForward("submit"),
                   params);
        }

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected RhnSetDecl getSetDecl(Long sid) {
        return RhnSetDecl.XCCDF_TESTRESULTS.createCustom(sid);
    }
}
