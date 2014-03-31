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

package com.redhat.rhn.frontend.action.rhnpackage;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.SessionSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


/**
 * @author paji
 * BaseSystemPackagesAction
 * @version $Rev$
 */
public abstract class BaseSystemPackagesConfirmAction extends RhnAction {
    private static final String DATA_SET = RequestContext.PAGE_LIST;
    private static final String WIDGET_SUMMARY = "widgetSummary";
    private static final String HEADER_KEY = "header";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        if (request.getParameter("dispatch") != null) {
            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {
                return executePackageAction(mapping, formIn, request, response);
            }
        }

        List<PackageListItem> items = getDataResult(request);

        Server server = requestContext.lookupAndBindServer();

        /*
         * If we are removing a package that is not in a channel the server is
         *  subscribed to, then the rollback will not work, lets give the user
         *  a message telling them that.
         */
        if (this instanceof RemoveConfirmSetupAction &&
            server.hasEntitlement(EntitlementManager.PROVISIONING)) {
            for (PackageListItem item : items) {
                Map<String, Long> map = item.getKeyMap();
                if (!SystemManager.hasPackageAvailable(server, map.get("name_id"),
                                            map.get("arch_id"), map.get("evr_id"))) {
                    ActionMessages msgs = new ActionMessages();
                    msgs.add(ActionMessages.GLOBAL_MESSAGE,
                          new ActionMessage("package.remove.cant.rollback"));
                     getStrutsDelegate().saveMessages(request, msgs);
                     break;
                }
            }
        }

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", picker);

        ActionChainHelper.prepopulateActionChains(request);

        request.setAttribute("system", server);
        requestContext.copyParamToAttributes(RequestContext.SID);
        request.setAttribute(ListTagHelper.PARENT_URL,
                request.getRequestURI() + "?sid=" + server.getId());
        request.setAttribute(WIDGET_SUMMARY, getWidgetSummary());
        request.setAttribute(HEADER_KEY, getHeaderKey());
        request.setAttribute(DATA_SET, items);

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD),
                request.getParameterMap());


    }


    private List<PackageListItem> getDataResult(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);

        Long sid = requestContext.getRequiredParam("sid");

        Set <String> data = SessionSetHelper.lookupAndBind(request, getDecl(sid));
        List<PackageListItem> items = new LinkedList<PackageListItem>();
        for (String key : data) {
            items.add(PackageListItem.parse(key));
        }
        return items;
    }

    /**
     * Executes the appropriate PackageAction
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward executePackageAction(ActionMapping mapping,
                                       ActionForm formIn,
                                       HttpServletRequest request,
                                       HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        Long sid = requestContext.getRequiredParam("sid");
        User user = requestContext.getCurrentUser();
        //updateList(newactions, user.getId());

        List<Map<String, Long>> data = PackageListItem.toKeyMaps(getDataResult(request));
        int numPackages = data.size();

        //Archive the actions
        Server server = SystemManager.lookupByIdAndUser(sid, user);

        //The earliest time to perform the action.
        DynaActionForm dynaActionForm = (DynaActionForm)formIn;
        Date earliest = getStrutsDelegate().readDatePicker(dynaActionForm, "date",
            DatePicker.YEAR_RANGE_POSITIVE);

        //The action chain to append this action to, if any
        ActionChain actionChain = ActionChainHelper.readActionChain(dynaActionForm, user);

        PackageAction pa = schedulePackageAction(formIn, requestContext, data, earliest,
            actionChain);

        //Remove the actions from the users set
        SessionSetHelper.obliterate(request, getDecl(sid));

        ActionMessages msgs = new ActionMessages();

        if (actionChain == null) {
            /**
             * If there was only one action archived, display the "action" archived
             * message, else display the "actions" archived message.
             */
            if (numPackages == 1) {
                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                         new ActionMessage(getMessageKeyForOne(),
                                 LocalizationService.getInstance()
                                     .formatNumber(numPackages),
                                 pa.getId().toString(),
                                 sid.toString(),
                                 StringUtil.htmlifyText(server.getName())));
            }
            else {
                msgs.add(ActionMessages.GLOBAL_MESSAGE,
                         new ActionMessage(getMessageKeyForMany(),
                                 LocalizationService.getInstance()
                                 .formatNumber(numPackages),
                             pa.getId().toString(),
                             sid.toString(),
                             StringUtil.htmlifyText(server.getName())));
            }
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE,
                new ActionMessage("message.addedtoactionchain", actionChain.getId(),
                    StringUtil.htmlifyText(actionChain.getLabel())));
        }

        strutsDelegate.saveMessages(request, msgs);
        Map params = new HashMap();
        processParamMap(formIn, request, params);
        return strutsDelegate.forwardParams(mapping.findForward("confirm"), params);
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        RequestContext requestContext = new RequestContext(request);
        Long sid = requestContext.getRequiredParam("sid");
        params.put("sid", sid);
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm)formIn,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
    }

    /**
     * the Session set declaration..
     * @param sid the sid of the system
     * @return the Session Set label.
     */
    protected abstract String getDecl(Long sid);

    /**
     * hook point to return the notification message key for single package updates
     * @return the message key
     */
    protected abstract String getMessageKeyForOne();

    /**
     * hook point to return the notification message key for multiple package updates
     * @return the message key
     */
    protected abstract String getMessageKeyForMany();

    /**
     * hook point to return the widget summary key
     * @return the widget summary key
     */
    protected abstract String getWidgetSummary();

    /**
     * hook point to return the widget summary key
     * @return the widget summary key
     */
    protected abstract String getHeaderKey();
    /**
     * hook point to return action key.
     * @return the action key
     */
    protected String getActionKey() {
        return "installconfirm.jsp.confirm";
    }
    /**
     * Hook point for subclasses to
     * schedule the package action and return the scheduled
     * action for storing
     * @param formIn the action form
     * @param context the request context
     * @param pkgs the list of packages
     * @param earliest the earliest date to perform the action
     * @param actionChain the action chain to add the action to or null
     * @return the schedule package action
     */
    protected abstract PackageAction schedulePackageAction(ActionForm formIn,
        RequestContext context, List<Map<String, Long>> pkgs, Date earliest,
        ActionChain actionChain);

}
