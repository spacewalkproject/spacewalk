package com.redhat.rhn.frontend.action.rhnpackage;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.AlphaBarHelper;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.domain.rhnpackage.Package;

public class TargetSystemsListAction extends RhnAction {

    private final String LIST_NAME = "systemList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
            ActionForm formIn,
            HttpServletRequest request,
            HttpServletResponse response) {
        RequestContext requestContext = new RequestContext(request);
        User user = requestContext.getCurrentUser();
        long pid = requestContext.getRequiredParam("pid");
        Package pkg = PackageFactory.lookupByIdAndUser(pid, user);

        // show permission error if pid is invalid like we did before
        if (pkg == null) {
            throw new PermissionException("Invalid pid");
        }
        request.setAttribute("pid", pid);
        request.setAttribute("package_name", pkg.getFilename());
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI() + "?pid=" +
                pid);
        RhnListSetHelper helper = new RhnListSetHelper(request);

        RhnSet set = RhnSetDecl.TARGET_SYSTEMS.get(user);

        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }

        if (request.getParameter("dispatch") != null) {
            // if its one of the Dispatch actions handle it..
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("pid", pid);
                StrutsDelegate strutsDelegate = getStrutsDelegate();
                return strutsDelegate.forwardParams(mapping
                        .findForward(RhnHelper.CONFIRM_FORWARD), params);
            }
            RhnHelper.handleEmptySelection(request);
        }

        DataResult<SystemOverview> result = SystemManager.listPotentialSystemsForPackage(
                user, pid);
        result.setElaborationParams(new HashMap<String, Object>());

        request.getParameter(AlphaBarHelper.makeAlphaKey(TagHelper
                .generateUniqueName(LIST_NAME)));

        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, result);
        }

        if (!set.isEmpty()) {
            helper.syncSelections(set, result);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        ListTagHelper.bindSetDeclTo(LIST_NAME, RhnSetDecl.TARGET_SYSTEMS, request);
        TagHelper.bindElaboratorTo(LIST_NAME, result.getElaborator(), request);
        request.setAttribute(RequestContext.PAGE_LIST, result);

        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }
}
