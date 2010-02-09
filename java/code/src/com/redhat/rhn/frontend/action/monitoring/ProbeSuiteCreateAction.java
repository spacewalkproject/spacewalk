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
import com.redhat.rhn.manager.monitoring.MonitoringManager;

/**
 * ProbeSuiteCreateAction - creates a ProbeSuite and saves it to the DB.
 * @version $Rev: 53528 $
 */
public class ProbeSuiteCreateAction extends BaseProbeSuiteEditAction {

    /**
     * {@inheritDoc}
     */
    public String getSuccessKey() {
        return "probeSuiteCreate.success";
    }

    /**
     * {@inheritDoc}
     */
    public ProbeSuite getProbeSuite(RequestContext ctx) {
        ProbeSuite retval;
        if (ctx.getRequest().getAttribute("probeSuite") != null) {
            retval = (ProbeSuite) ctx.getRequest().getAttribute("probeSuite");
        } 
        else {
            retval = MonitoringManager.
                getInstance().createProbeSuite(ctx.getCurrentUser());
        }
        return retval;
    }

}
