/**
 * Copyright (c) 2009--2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.errata;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.common.RhnSetAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ListPackagesAction
 * @version $Rev$
 */
public class ListPackagesAction extends RhnSetAction {

    /**
     * confirm handles updating the set and forwarding the user to the confirmation
     * screen.
     * @param mapping ActionMapping
     * @param formIn ActionForm
     * @param request Request
     * @param response Response
     * @return Returns the action forward for the confirm mapping.
     */
    public ActionForward confirm(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        //update the set
        updateSet(request);

        //forward to the confirm mapping
        Long eid = requestContext.getRequiredParam("eid");
        return strutsDelegate.forwardParam(mapping.findForward("confirm"),
                                      "eid", eid.toString());
    }

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(User user,
                                       ActionForm formIn,
                                       HttpServletRequest request) {
        RequestContext requestContext = new RequestContext(request);

        //Get the errata from the eid in the request
        Errata errata = requestContext.lookupErratum();
        return PackageManager.packagesInErrata(errata, null);
    }

    /**
     * {@inheritDoc}
     */
    protected void processMethodKeys(Map map) {
        map.put("errata.edit.packages.list.removepackages", "confirm");
    }

    /**
     * {@inheritDoc}
     */
    protected void processParamMap(ActionForm formIn,
                                   HttpServletRequest request,
                                   Map params) {
        params.put("eid", request.getParameter("eid"));
    }

    /**
     * {@inheritDoc}
     */
    protected RhnSetDecl getSetDecl() {
        return RhnSetDecl.PACKAGES_TO_REMOVE;
    }

}
