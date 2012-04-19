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
package com.redhat.rhn.frontend.action.audit.ssm;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.scap.ScapAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.audit.ScapManager;

/**
 * SSM OpenSCAP XCCDF scanning.
 * This action dispatches the second submit and commits the action.
 * @version $Rev$
 */
public class SsmScheduleXccdfConfirmAction extends RhnAction {

    private static final String PATH = "path";
    private static final String PARAMS = "params";
    private static final String DATE = "date";
    private static final String ERROR = "error";

    /**
     * {@inheritDoc}
     */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        DynaActionForm form = (DynaActionForm) formIn;

        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(this, form);
            if (errors.isEmpty()) {
                return processForm(mapping, request, form);
            }
        }

        return strutsDelegate.forwardParams(
                mapping.findForward(ERROR),
                request.getParameterMap());
    }

    private ActionForward processForm(ActionMapping mapping,
            HttpServletRequest request, DynaActionForm form) {
        RequestContext context = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        ScapAction scapAction = ScapManager.scheduleXccdfEvalInSsm(
                context.getLoggedInUser(),
                (String) form.get(PATH),
                (String) form.get(PARAMS),
                getStrutsDelegate().readDatePicker(form, DATE,
                        DatePicker.YEAR_RANGE_POSITIVE));

        ActionMessages msgs = new ActionMessages();
        msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage("message.xccdfeval.ssm"));
        strutsDelegate.saveMessages(request, msgs);

        Map paramMap = makeParamMap(request);
        paramMap.put("aid", scapAction.getId());
        return strutsDelegate.forwardParams(mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                paramMap);
    }
}
