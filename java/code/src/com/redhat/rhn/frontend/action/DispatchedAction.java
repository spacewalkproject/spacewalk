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
package com.redhat.rhn.frontend.action;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Abstract POST action class that provides for setup->confirm->commit
 * lifecycle.  This should probably be added as a <i>real</i> class and
 * promoted for general use as I suspect that many other pages using the rhn
 * list tag need to work the same way.
 * @version $Rev$
 */
public abstract class DispatchedAction extends RhnAction {

    /**
     * ${@inheritDoc}
     */
    public ActionForward execute(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        RequestContext context = new RequestContext(request);

        if (context.hasParam(RequestContext.DISPATCH)) {
            return commitAction(mapping, form, request, response);
        }

        if (context.hasParam(RequestContext.CONFIRM)) {
            return confirmAction(mapping, form, request, response);
        }

        return setupAction(mapping, form, request, response);
    }

    /**
     * Called to setup the page for display.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @return The action forward.
     * @throws Exception
     */
    protected abstract ActionForward setupAction(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception;

    /**
     * Called when a page form has been submitted and requires confirmation.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @return The action forward.
     * @throws Exception
     */
    protected ActionForward confirmAction(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        throw new Exception("confirmAction called but not overridden");
    }

    /**
     * Called when a page form has been submitted and confirmed.
     * Applies page submit to the system.
     * @param mapping An action mapping.
     * @param form The associated form.
     * @param request The requst.
     * @param response The respoinse.
     * @return The action forward.
     * @throws Exception
     */
    protected ActionForward commitAction(
            ActionMapping mapping,
            ActionForm form,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        throw new Exception("commitAction called but not overridden");
    }
}
