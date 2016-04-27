/**
 * Copyright (c) 2016 Red Hat, Inc.
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

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListRhnSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * ListPackagesAction
 */
public class ListPackagesAction extends RhnAction implements Listable {

    public static final String LIST_NAME = "packageList";
    public static final String DATASET_NAME = "packages";
    public static final String EID_PARAM = "eid";

    /**
     * {@inheritDoc}
     */
    @Override
    public ActionForward execute(ActionMapping mapping, ActionForm form,
                    HttpServletRequest request, HttpServletResponse response) {
        RequestContext ctxt = new RequestContext(request);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
       //put advisory in request for the toolbar
        request.setAttribute("advisory", ctxt.lookupErratum().getAdvisory());

        ListRhnSetHelper helper = new ListRhnSetHelper(this, request,
                                                       RhnSetDecl.PACKAGES_TO_REMOVE);
        helper.setListName(LIST_NAME);
        helper.setDataSetName(DATASET_NAME);
        helper.execute();

        if (helper.isDispatched()) {
            StrutsDelegate delegate = getStrutsDelegate();
            Long eid = ctxt.getRequiredParam(EID_PARAM);
            ActionForward af = mapping.findForward(RhnHelper.CONFIRM_FORWARD);
            return delegate.forwardParam(af, EID_PARAM, eid.toString());
        }
        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List getResult(RequestContext context) {
        //Get the errata from the eid in the request
        Errata errata = context.lookupErratum();
        return PackageManager.packagesInErrata(errata, null);
    }

}
