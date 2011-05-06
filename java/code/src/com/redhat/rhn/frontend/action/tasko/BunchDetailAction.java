/**
 * Copyright (c) 2011 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.tasko;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.taskomatic.TaskomaticApi;
import com.redhat.rhn.taskomatic.TaskomaticApiException;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * BunchDetailAction
 * @version $Rev$
 */
public class BunchDetailAction extends RhnAction implements Listable {

    public static final String LIST_NAME = "runList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext ctx = new RequestContext(request);
        User loggedInUser = ctx.getLoggedInUser();
        String bunchLabel = request.getParameter("label");
        request.setAttribute("label", bunchLabel);
        request.setAttribute("bunchdescription", LocalizationService.getInstance().
                getMessage("bunch.jsp.description." + bunchLabel));

        if (ctx.isSubmitted()) {
            try {
                Date date = new TaskomaticApi().scheduleSingleSatBunch(loggedInUser,
                        bunchLabel);
                ActionMessages msgs = new ActionMessages();
                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                        new ActionMessage("message.bunch.singlescheduled", bunchLabel,
                        LocalizationService.getInstance().formatCustomDate(date)));
                saveMessages(request, msgs);
            }
            catch (TaskomaticApiException e) {
                createErrorMessage(request,
                        "repos.jsp.message.taskomaticdown", null);
            }
        }
        ListHelper helper = new ListHelper(this, request);
        helper.setListName(LIST_NAME);
        helper.setParentUrl(request.getRequestURI() + "?label=" + bunchLabel);
        helper.execute();
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext contextIn) {
        User user =  contextIn.getLoggedInUser();
        String bunchName = contextIn.getParam("label", true);
        try {
            List<Map> runs = new TaskomaticApi().findRunsByBunch(user, bunchName);
            return runs;
        }
        catch (TaskomaticApiException e) {
            createErrorMessage(contextIn.getRequest(),
                    "repos.jsp.message.taskomaticdown", null);
            return new ArrayList();
        }
    }
}
