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

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeCreateAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.CreateTemplateProbeCommand;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;

import org.apache.struts.action.DynaActionForm;

import java.util.Map;

/**
 * ProbeSuiteProbeCreateAction
 * @version $Rev$
 */
public class ProbeSuiteProbeCreateAction extends BaseProbeCreateAction {

    /**
     * {@inheritDoc}
     */
    protected void addAttributes(RequestContext ctx) {
        ProbeSuite suite = ctx.lookupProbeSuite();
        ctx.getRequest().setAttribute("probeSuite", suite);
    }

    /**
     * {@inheritDoc}
     */
    protected void addSuccessParams(RequestContext ctx, Map params, Probe probe) {
        params.put(RequestContext.SUITE_ID, ctx.lookupProbeSuite().getId());
    }

    /**
     * {@inheritDoc}
     */
    protected ModifyProbeCommand makeModifyProbeCommand(RequestContext ctx,
            DynaActionForm form, Command command) {
        ProbeSuite suite = ctx.lookupProbeSuite();
        return new CreateTemplateProbeCommand(ctx.getCurrentUser(), command, suite);
    }

}
