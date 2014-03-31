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
package com.redhat.rhn.frontend.action.systems;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ErrataConfirmSetupAction
 * @version $Rev$
 */
public class ErrataConfirmSetupAction extends RhnAction implements Listable {


    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();


        Long sid = requestContext.getRequiredParam("sid");
        RhnSet set = ErrataSetupAction.getSetDecl(sid).get(user);
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                ErrataSetupAction.getSetDecl(sid));
        helper.setWillClearSet(false);
        helper.execute();

        if (helper.isDispatched()) {
            if (!set.isEmpty()) {
                return confirmErrata(mapping, formIn, request, response);
            }
            RhnHelper.handleEmptySelection(request);
        }
        //Setup the datepicker widget
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request,
                (DynaActionForm)formIn, "date", DatePicker.YEAR_RANGE_POSITIVE);

        //Setup the Action Chain widget
        ActionChainHelper.prepopulateActionChains(request);

        request.setAttribute("date", picker);
        request.setAttribute("system", server);

        return getStrutsDelegate().forwardParams(mapping.findForward(
                RhnHelper.DEFAULT_FORWARD), request.getParameterMap());
    }


    /**
     * Action to execute if confirm button is clicked
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward confirmErrata(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();
        DynaActionForm form = (DynaActionForm) formIn;

        User user = requestContext.getCurrentUser();
        Long sid = requestContext.getRequiredParam("sid");

        Map hparams = new HashMap();

        Server server = SystemManager.lookupByIdAndUser(sid, user);
        RhnSet set = ErrataSetupAction.getSetDecl(sid).get(user);

        // Get the errata IDs
        Set<Long> errataList = set.getElementValues();
        if (server != null && !errataList.isEmpty()) {
            Date earliest = getStrutsDelegate().readDatePicker(form, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
            ActionChain actionChain = ActionChainHelper.readActionChain(form, user);
            List<Long> serverIds = Arrays.asList(server.getId());
            List<Long> errataIds = new ArrayList<Long>(errataList);
            ErrataManager.applyErrata(user, errataIds, earliest, actionChain, serverIds);

            ActionMessages msg = new ActionMessages();
            Object[] args = null;
            String messageKey = null;

            if (actionChain == null) {
                messageKey = "errata.schedule";
                if (errataList.size() != 1) {
                    messageKey += ".plural";
                }
                args = new Object[3];
                args[0] = new Long(errataList.size());
                args[1] = server.getName();
                args[2] = server.getId().toString();
            }
            else {
                messageKey = "message.addedtoactionchain";
                args = new Object[2];
                args[0] = actionChain.getId();
                args[1] = actionChain.getLabel();
            }

            msg.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(messageKey, args));
            strutsDelegate.saveMessages(request, msg);
            hparams.put("sid", sid);

            ErrataSetupAction.getSetDecl(sid).clear(user);
            return strutsDelegate.forwardParams(mapping.findForward("confirmed"), hparams);
        }
        /*
         * Everything is not ok.
         * TODO: Error page or some other shout-to-user-venue
         * What happens if a few ServerActions fail to be scheduled?
         */
        Map params = makeParamMap(request);
        return strutsDelegate.forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), params);
    }

    /**
     * Makes a parameter map containing request params that need to
     * be forwarded on to the success mapping.
     * @param request HttpServletRequest containing request vars
     * @return Returns Map of parameters
     */
    protected Map makeParamMap(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);

        Map params = requestContext.makeParamMapWithPagination();
        Long sid = requestContext.getRequiredParam("sid");
        if (sid != null) {
            params.put("sid", sid);
        }
        return params;
    }


    /**
     *
     * {@inheritDoc}
     */
    public List getResult(RequestContext context) {
        Long sid = context.getParamAsLong("sid");
        return SystemManager.errataInSet(context.getCurrentUser(),
                    ErrataSetupAction.getSetDecl(sid).getLabel(), null);
    }

}
