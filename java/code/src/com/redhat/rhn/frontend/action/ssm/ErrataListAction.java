/**
 * Copyright (c) 2013 SUSE
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

package com.redhat.rhn.frontend.action.ssm;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.ListSessionSetHelper;
import com.redhat.rhn.frontend.taglibs.list.helper.Listable;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 *
 * @author bo
 */
public class ErrataListAction extends RhnAction implements Listable {
    public static final String LIST_NAME = "errataList";

    /**
     * Entry-point caller.
     * <p/>
     * @param mapping    The ActionMapping used to select this instance.
     * @param actionForm The optional ActionForm bean for this request.
     * @param request    The HTTP Request we are processing.
     * @param response   The HTTP Response we are processing.
     * <p/>
     * @return ActionForward returns an action forward
     * @throws java.lang.Exception General exception.
     */
    @Override
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm actionForm,
                                 HttpServletRequest request,
                                 HttpServletResponse response)
            throws Exception {
        RequestContext requestContext = new RequestContext(request);

        ListSessionSetHelper helper = new ListSessionSetHelper(this, request);
        helper.setListName(LIST_NAME);
        helper.execute();

        if (helper.isDispatched() && requestContext.wasDispatched("errata.jsp.apply")) {
            return handleConfirm(mapping, requestContext, helper);
        }


        return mapping.findForward(RhnHelper.DEFAULT_FORWARD);
    }

    private ActionForward handleConfirm(ActionMapping mapping,
            RequestContext context,
            ListSessionSetHelper helper) {
        RhnSet set = getSetDecl().get(context.getCurrentUser());
        set.clear();
        for (String item : helper.getSet()) {
            set.addElement(item);
        }
        RhnSetManager.store(set);
        return mapping.findForward("confirm");
    }

    /**
     * @return Returns RhnSetDecl.ERRATA
     */
    private static RhnSetDecl getSetDecl() {
        return RhnSetDecl.ERRATA;
    }

    /** {@inheritDoc} */
    public List getResult(RequestContext context) {
        return ErrataManager.relevantErrataToSystemSet(context.getLoggedInUser());
    }
}
