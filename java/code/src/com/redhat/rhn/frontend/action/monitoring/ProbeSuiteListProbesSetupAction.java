/**
 * Copyright (c) 2009 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseSetListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;

/**
 * List the probes in a suite
 *
 * @version $Rev$
 */
public class ProbeSuiteListProbesSetupAction extends BaseSetListAction {

    /**
     * {@inheritDoc}
     */
    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        Long id = rctx.getRequiredParam(RequestContext.SUITE_ID);
        User user = rctx.getCurrentUser();
        return MonitoringManager.getInstance().listProbesInSuite(id, user, pc);
    }

    protected void processRequestAttributes(RequestContext rctx) {
        super.processRequestAttributes(rctx);
        ProbeSuite suite = rctx.lookupProbeSuite();
        rctx.getRequest().setAttribute("probeSuite", suite);
    }

    /**
     * {@inheritDoc}
     */
    public RhnSetDecl getSetDecl() {
        return RhnSetDecl.SUITE_PROBES_TO_DELETE;
    }

}
