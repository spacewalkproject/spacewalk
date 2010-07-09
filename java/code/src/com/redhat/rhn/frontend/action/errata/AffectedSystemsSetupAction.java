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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.struts.RhnListAction;
import com.redhat.rhn.frontend.struts.RhnListSetHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.frontend.taglibs.list.TagHelper;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * AffectedSystemsSetupAction
 * @version $Rev$
 */
public class AffectedSystemsSetupAction extends RhnListAction {
    public static final String DISPATCH = "dispatch";
    public static final String LIST_NAME = "systemAffectedList";

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);
        StrutsDelegate strutsDelegate = getStrutsDelegate();

        User user = requestContext.getLoggedInUser();


        Errata errata = requestContext.lookupErratum();
        DataResult dr = ErrataManager.systemsAffected(user, errata.getId(), null);

        RhnSet set = RhnSetDecl.SYSTEMS_AFFECTED.get(user);
        RhnListSetHelper helper = new RhnListSetHelper(request);

        //if its not submitted
        // ==> this is the first visit to this page
        // clear the 'dirty set'
        if (!requestContext.isSubmitted()) {
            set.clear();
            RhnSetManager.store(set);
        }

        if (request.getParameter(DISPATCH) != null) {
            helper.updateSet(set, LIST_NAME);
            if (!set.isEmpty()) {
                // Send to AffectedSystemsAction to handle submit
                return strutsDelegate.forwardParams(mapping.findForward("confirm"),
                        request.getParameterMap());
            }
            else {
                RhnHelper.handleEmptySelection(request);
            }
        }

        if (ListTagHelper.getListAction(LIST_NAME, request) != null) {
            helper.execute(set, LIST_NAME, dr);
        }

        // if I have a previous set selections populate data using it
        if (!set.isEmpty()) {
            helper.syncSelections(set, dr);
            ListTagHelper.setSelectedAmount(LIST_NAME, set.size(), request);
        }

        TagHelper.bindElaboratorTo("systemAffectedList", dr.getElaborator(), request);

        request.setAttribute("pageList", dr);
        request.setAttribute("set", set);
        request.setAttribute("errata", errata);
        request.setAttribute("parentUrl", request.getRequestURI() + "?" +
                RequestContext.ERRATA_ID + "=" + errata.getId());

        return strutsDelegate.forwardParams(mapping.findForward("default"),
                                       request.getParameterMap());
    }
}
