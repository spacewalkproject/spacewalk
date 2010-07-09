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
package com.redhat.rhn.frontend.action.monitoring;

import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.frontend.struts.RhnValidationHelper;
import com.redhat.rhn.frontend.struts.StrutsDelegate;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.struts.action.ActionErrors;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.DynaActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * ProbeSuiteEditAction - renders and saves a ProbeSuite
 * @version $Rev: 53528 $
 */
public abstract class BaseProbeSuiteEditAction extends RhnAction {

    /** {@inheritDoc} */
    public ActionForward execute(ActionMapping mapping, ActionForm formIn,
            HttpServletRequest req, HttpServletResponse resp) {
        DynaActionForm form = (DynaActionForm) formIn;
        RequestContext requestContext = new RequestContext(req);
        ProbeSuite suite = getProbeSuite(requestContext);

        StrutsDelegate strutsDelegate = getStrutsDelegate();

        String forwardName = "default";
        if (isSubmitted(form)) {
            ActionErrors errors = RhnValidationHelper.validateDynaActionForm(
                    this, form);
            if (!errors.isEmpty()) {
                strutsDelegate.saveMessages(req, errors);
            }
            else {
                suite.setDescription(form.getString("description"));
                suite.setSuiteName(form.getString("suite_name"));
                MonitoringManager.getInstance().
                    storeProbeSuite(suite, requestContext.getCurrentUser());
                createSuccessMessage(req, getSuccessKey(), suite.getSuiteName());
                forwardName = "saved";
            }
        }
        req.setAttribute("probeSuite", suite);
        form.set("description", suite.getDescription());
        form.set("suite_name", suite.getSuiteName());
        if (suite.getId() != null) {
            return strutsDelegate.forwardParam(mapping.findForward(forwardName),
                    RequestContext.SUITE_ID, suite.getId().toString());
        }
        else {
            return mapping.findForward(forwardName);
        }
    }

    /**
     * Key for the success message
     * @return String key
     */
    public abstract String getSuccessKey();

    /**
     * Get the ProbeSuite either new or existing
     * @param ctx RequestContext
     * @return ProbeSuite for the action.
     */
    public abstract ProbeSuite getProbeSuite(RequestContext ctx);
}
