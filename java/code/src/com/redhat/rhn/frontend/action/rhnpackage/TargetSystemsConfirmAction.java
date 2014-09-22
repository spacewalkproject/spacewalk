package com.redhat.rhn.frontend.action.rhnpackage;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionMessage;
import org.apache.struts.action.ActionMessages;
import org.apache.struts.action.DynaActionForm;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.ActionChain;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.ActionChainHelper;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.action.ActionChainManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.domain.rhnpackage.Package;

public class TargetSystemsConfirmAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        if (request.getParameter("dispatch") != null) {
            if (requestContext.wasDispatched("installconfirm.jsp.confirm")) {
                return executePackageAction(mapping, formIn, request, response);
            }
        }

        User user = requestContext.getCurrentUser();
        long pid = requestContext.getRequiredParam("pid");
        Package pkg = PackageFactory.lookupByIdAndUser(pid, user);

        // show permission error if pid is invalid like we did before
        if (pkg == null) {
            throw new PermissionException("Invalid pid");
        }
        request.setAttribute("pid", pid);
        request.setAttribute("package_name", pkg.getFilename());

        List<SystemOverview> items = getDataResult(request);

        DynaActionForm dynaForm = (DynaActionForm) formIn;
        DatePicker picker = getStrutsDelegate().prepopulateDatePicker(request, dynaForm,
                "date", DatePicker.YEAR_RANGE_POSITIVE);
        request.setAttribute("date", picker);

        ActionChainHelper.prepopulateActionChains(request);

        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() + "?pid=" +
                pid);
        request.setAttribute(RequestContext.PAGE_LIST, items);

        return getStrutsDelegate().forwardParams(
                mapping.findForward(RhnHelper.DEFAULT_FORWARD), request.getParameterMap());

    }

    private List<SystemOverview> getDataResult(HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();
        return SystemManager.inSet(user, RhnSetDecl.TARGET_SYSTEMS.getLabel());
    }

    /**
     * Executes the appropriate PackageAction
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request ServletRequest
     * @param response ServletResponse
     * @return The ActionForward to go to next.
     */
    public ActionForward executePackageAction(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest request, HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        Long pid = requestContext.getRequiredParam("pid");
        User user = requestContext.getCurrentUser();
        Package pkg = PackageFactory.lookupByIdAndUser(pid, user);

        // show permission error if pid is invalid like we did before
        if (pkg == null) {
            throw new PermissionException("Invalid pid");
        }

        List<Map<String, Long>> pkgMapList = new ArrayList<Map<String, Long>>();
        Map<String, Long> pkgMap = new HashMap<String, Long>();
        pkgMap.put("name_id", pkg.getPackageName().getId());
        pkgMap.put("evr_id", pkg.getPackageEvr().getId());
        pkgMap.put("arch_id", pkg.getPackageArch().getId());
        pkgMapList.add(pkgMap);

        List<SystemOverview> data = getDataResult(request);
        Set<Long> serverIds = new HashSet<Long>();
        for (SystemOverview system : data) {
            serverIds.add(system.getId());
        }
        int numSystems = data.size();

        //The earliest time to perform the action.
        DynaActionForm dynaActionForm = (DynaActionForm) formIn;
        Date earliest = getStrutsDelegate().readDatePicker(dynaActionForm, "date",
                DatePicker.YEAR_RANGE_POSITIVE);

        //The action chain to append this action to, if any
        ActionChain actionChain = ActionChainHelper.readActionChain(dynaActionForm, user);

        ActionChainManager.schedulePackageInstalls(user, serverIds, pkgMapList, earliest,
                actionChain);

        ActionMessages msgs = new ActionMessages();

        if (actionChain == null) {
            msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "message.systeminstalls", LocalizationService.getInstance()
                            .formatNumber(numSystems)));
        }
        else {
            msgs.add(ActionMessages.GLOBAL_MESSAGE, new ActionMessage(
                    "message.addedtoactionchain", actionChain.getId(), StringUtil
                            .htmlifyText(actionChain.getLabel())));
        }

        strutsDelegate.saveMessages(request, msgs);
        Map<String, Object> params = new HashMap<String, Object>();
        processParamMap(formIn, request, params);
        return strutsDelegate.forwardParams(mapping.findForward(RhnHelper.CONFIRM_FORWARD),
                params);
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn, HttpServletRequest request,
            Map<String, Object> params) {
        RequestContext requestContext = new RequestContext(request);
        Long pid = requestContext.getRequiredParam("pid");
        params.put("pid", pid);
        getStrutsDelegate().rememberDatePicker(params, (DynaActionForm) formIn, "date",
                DatePicker.YEAR_RANGE_POSITIVE);
    }
}
