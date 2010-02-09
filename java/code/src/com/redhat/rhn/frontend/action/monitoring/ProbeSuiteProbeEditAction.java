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
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.frontend.action.systems.monitoring.BaseProbeEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;

import java.util.HashMap;

/**
 * Edit a probe that is part of a probe suite
 * @version $Rev$
 */
public class ProbeSuiteProbeEditAction extends BaseProbeEditAction {

    /**
     * {@inheritDoc}
     */
    protected void addAttributes(RequestContext rctx) {
        ProbeSuite suite = rctx.lookupProbeSuite();
        rctx.getRequest().setAttribute("probeSuite", suite);
    }

    protected void addSuccessParams(RequestContext rctx, HashMap params, Probe probe) {
        params.put(RequestContext.SUITE_ID, rctx.lookupProbeSuite().getId());
    }

}
