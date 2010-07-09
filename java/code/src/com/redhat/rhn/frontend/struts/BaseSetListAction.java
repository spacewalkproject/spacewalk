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
package com.redhat.rhn.frontend.struts;

import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import java.util.Collections;
import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * BaseSetListAction - extension of BaseListAction that includes necessary
 * logic to provide functionality for displaying an RhnSet.
 *
 * @version $Rev: 55183 $
 */
public abstract class BaseSetListAction extends BaseListAction {

    /**
     * The declaration of the set we are working with, must be one of the
     * constants from {@link RhnSetDecl}
     * @return the declaration of the set we are working with
     */
    public abstract RhnSetDecl getSetDecl();


    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx) {
        RhnSet set = getSetDecl().get(rctx.getCurrentUser());
        rctx.getRequest().setAttribute("set", set);
        rctx.getRequest().setAttribute("newset", trackSet(set, rctx.getRequest()));
        return;
    }
    /**
     * Helper method  to prePopulate a new set
     * This method is utiliy method NOT intended to be extended
     * It can be used when overriding the  'processRequestAttributes' method
     * A good use case for this method is when are preselecting a list of items
     * from the global list.
     *
     * @param rctx a request context object
     * @param identifiables A Iterator iterating over items of type
     *                              "com.redhat.rhn.domain.Identifiable"
     */
    protected final void populateNewSet(RequestContext rctx, Iterator identifiables) {
        RhnSet set = getSetDecl().get(rctx.getCurrentUser());
        set.clear();

        while (identifiables.hasNext()) {
            Identifiable tkn = (Identifiable) identifiables.next();
            set.addElement(tkn.getId());
        }
        RhnSetFactory.save(set);
        rctx.getRequest().setAttribute("set", set);
    }

    /**
     *
     * {@inheritDoc}
     */
    protected void processForm(RequestContext rctx, ActionForm form) {
        super.processForm(rctx, form);

        if (form instanceof DynaActionForm) {
            if (!isSubmitted((DynaActionForm) form)) {
                Iterator itr = getSelectedItemsIterator(rctx, form);
                if (itr != null && itr.hasNext()) {
                    populateNewSet(rctx, itr);
                }
            }
        }
    }

    /**
     * Extend this method to return an initial pre-selection list
     * So the items returned here will get automatically selected in
     * the rhn set. So when the table renders the items here will be
     * checked.
     * @return A Iterator iterating over items of type
     *                              "com.redhat.rhn.domain.Identifiable"
     *         EMPTY_LIST.iterator() is prefered by default
     *         but we should be handling null cases also where we use this.
     */
    protected Iterator getSelectedItemsIterator(RequestContext ctx,
                                                    ActionForm form) {
        return Collections.EMPTY_LIST.iterator();
    }

    /**
     * Should we clear the RhnSet for this action when beginning a new request? (i.e.
     * *NOT* a form submission)
     *
     * Default behavior is to clear the set to prevent stale selections from appearing.
     * Sub-classes can override this method if this is not desired.
     *
     * @return true to clear the RhnSet when starting a new pageflow, false otherwise.
     */
    protected boolean preClearSet() {
        return true;
    }

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping,
                                 ActionForm formIn,
                                 HttpServletRequest request,
                                 HttpServletResponse response) {

        RequestContext requestContext = new RequestContext(request);

        // Clear the set of systems if this is a new request, prevents stale
        // selections from hanging around if the user didn't complete their previous
        // attempt:
        if (!requestContext.isSubmitted() && preClearSet()) {
            RhnSet set = getSetDecl().get(requestContext.getCurrentUser());
            set.clear();
            RhnSetFactory.save(set);
        }

        return super.execute(mapping, formIn, request, response);
    }

}
