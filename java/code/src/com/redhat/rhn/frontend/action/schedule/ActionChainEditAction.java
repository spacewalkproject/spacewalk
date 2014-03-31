/**
 * Copyright (c) 2014 SUSE
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
package com.redhat.rhn.frontend.action.schedule;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.ActionChainEntryGroup;
import com.redhat.rhn.domain.action.ActionChainFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controller for the Action Chain list page.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainEditAction extends RhnAction {

    /** Query string parameter name. */
    public static final String ACTION_CHAIN_ID_PARAMETER = "id";

    /** Page attribute name. */
    public static final String DATE_ATTRIBUTE = "date";

    /** Page attribute name. */
    public static final String GROUPS_ATTRIBUTE = "groups";

    /** Page attribute name. */
    public static final String ACTION_CHAIN_ATTRIBUTE = "actionChain";

    /** Action forward after Action Chain deletion. */
    private static final String TO_LIST_FORWARD = "to_list";

    /** Logger instance */
    private static Logger log = Logger.getLogger(ActionChainEditAction.class);

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
        HttpServletRequest request, HttpServletResponse response) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext requestContext = new RequestContext(request);
        ActionChain actionChain = ActionChainFactory.getActionChain(Long
            .valueOf((String) request.getParameter(ACTION_CHAIN_ID_PARAMETER)));

        if (isSubmitted(form)) {
            if (requestContext.wasDispatched("actionchain.jsp.delete")) {
                return delete(mapping, request, actionChain);
            }
            if (requestContext.wasDispatched("actionchain.jsp.saveandschedule")) {
                return schedule(mapping, request, form, actionChain);
            }
        }
        setAttributes(request, form, actionChain);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * Schedules an Action Chain.
     * @param mapping current mapping object
     * @param request current request object
     * @param form current form object
     * @param actionChain current Action Chain
     * @return
     */
    private ActionForward schedule(ActionMapping mapping, HttpServletRequest request,
        DynaActionForm form, ActionChain actionChain) {
        Date date = getStrutsDelegate().readDatePicker(form, DATE_ATTRIBUTE,
            DatePicker.YEAR_RANGE_POSITIVE);
        ActionChainFactory.schedule(actionChain, date);
        ActionMessages messages = new ActionMessages();
        messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
            "actionchain.jsp.scheduled", actionChain.getLabel()));
        getStrutsDelegate().saveMessages(request, messages);
        return mapping.findForward(TO_LIST_FORWARD);
    }

    /**
     * Deletes an Action Chain.
     * @param mapping current mapping object
     * @param request current request object
     * @param actionChain current Action Chain
     * @return a forward
     */
    private ActionForward delete(ActionMapping mapping, HttpServletRequest request,
        ActionChain actionChain) {
        String label = actionChain.getLabel();
        ActionChainFactory.delete(actionChain);
        ActionMessages messages = new ActionMessages();
        messages.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
            "actionchain.jsp.deleted", label));
        getStrutsDelegate().saveMessages(request, messages);
        return mapping.findForward(TO_LIST_FORWARD);
    }

    /**
     * Sets page attributes.
     * @param request current request object
     * @param form current DynaActionForm
     * @param actionChain current Action Chain
     */
    private void setAttributes(HttpServletRequest request, DynaActionForm form,
        ActionChain actionChain) {
        List<ActionChainEntryGroup> groups = ActionChainFactory
            .getActionChainEntryGroups(actionChain);
        log.debug("Found " + groups.size() + " Action Chain Entry groups");
        request.setAttribute(ACTION_CHAIN_ATTRIBUTE, actionChain);
        request.setAttribute(GROUPS_ATTRIBUTE, groups);
        DatePicker datePicker = getStrutsDelegate().prepopulateDatePicker(request, form,
            DATE_ATTRIBUTE, DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute(DATE_ATTRIBUTE, datePicker);
    }
}
