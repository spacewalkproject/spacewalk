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
package com.redhat.rhn.frontend.action.systems.audit;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.audit.scap.XccdfDiffSubmitAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.audit.ScapManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

/**
 * ListScapAction
 * @version $Rev$
 */

public class ListScapAction extends ScapSetupAction {
    private static final String LIST_NAME = "xccdfScans";
    private static final String DELET_BUT = "system.audit.listscap.jsp.removebut";
    private static final String DIFF_BUT = "system.audit.listscap.jsp.diffbut";

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
        setupScapEnablementInfo(context);

        DataResult result = ScapManager.allScans(server);
        RhnListSetHelper helper = new RhnListSetHelper(request);

        RhnSet set = getSetDecl(sid).get(user);
        if (!context.isSubmitted()) {
            RhnSetManager.store(set);
        }
        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        ListTagHelper.bindSetDeclTo(LIST_NAME, getSetDecl(sid), request);
        TagHelper.bindElaboratorTo(LIST_NAME, result.getElaborator(), request);

        request.setAttribute("sid", sid);
        request.setAttribute(ListTagHelper.PARENT_URL,
            request.getRequestURI() + "?sid=" + sid);
        request.setAttribute(RequestContext.PAGE_LIST, result);

        int selectionSize = set.size();
        if (context.wasDispatched(DELET_BUT) && selectionSize > 0) {
            Map<String, Long> params = new HashMap<String, Long>();
            params.put("sid", sid);
            return getStrutsDelegate().forwardParams(mapping.findForward("submitDelete"),
                    params);
        }
        else if (context.wasDispatched(DIFF_BUT)) {
            if (selectionSize == 2) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put(XccdfDiffSubmitAction.VIEW, XccdfDiffSubmitAction.CHANGED);
                Set<Long> scanIds = set.getElementValues();
                Iterator<Long> it = scanIds.iterator();
                if (it.hasNext()) {
                    params.put(XccdfDiffSubmitAction.FIRST, it.next());
                }
                if (it.hasNext()) {
                    params.put(XccdfDiffSubmitAction.SECOND, it.next());
                }
                return getStrutsDelegate().forwardParams(mapping.findForward("submitDiff"),
                        params);
            }
            ActionMessages msg = new ActionMessages();
            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "system.audit.listscap.jsp.diffmessage"));
            getStrutsDelegate().saveMessages(request, msg);
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    protected RhnSetDecl getSetDecl(Long sid) {
        return RhnSetDecl.XCCDF_TESTRESULTS.createCustom(sid);
    }
}
