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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.suite.ProbeSuite;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * Helper class to hold util methods until we can refactor
 * some of our list handling code.
 * @version $Rev: 51639 $
 */
public class ProbeSuiteHelper {

    public static final String DELETE_SUITES_LIST_NAME = "probe_suite_delete_list";
    public static final String DELETE_PROBES_LIST_NAME = "probe_suite_probes_list";

    private ProbeSuiteHelper() {
    }

    /**
     * Get the servers that are not in the suite indicated by the current request
     * @param rctx the context of the current request
     * @param pc the page control we are using
     * @return DataResult of SystemOverview DTOs
     */
    public static DataResult getServersNotInSuite(RequestContext rctx, PageControl pc) {
        ProbeSuite suite = rctx.lookupProbeSuite();
        rctx.getRequest().setAttribute("probeSuite", suite);
        User u = rctx.getCurrentUser();
        return MonitoringManager.getInstance().systemsNotInSuite(u, suite, pc);
    }

    /**
     * Get the Servers in the Suite.
     * @param request from struts
     * @param pc pageControl for pagination
     * @return DataResult of MonitoredServers
     */
    public static DataResult getServersInSuite(HttpServletRequest request, PageControl pc) {
        RequestContext rctx = new RequestContext(request);
        ProbeSuite probeSuite = rctx.lookupProbeSuite();
        rctx.getRequest().setAttribute("probeSuite", probeSuite);
        return MonitoringManager.getInstance().
            systemsInSuite(rctx.getCurrentUser(), probeSuite, pc);
    }

    /**
     * Add the id of the current probe suite into <code>params</code>
     * @param request the current request
     * @param params the map to which to add the probe suite ID
     */
    public static void processParamMap(HttpServletRequest request, Map params) {
        RequestContext rctx = new RequestContext(request);
        ProbeSuite probeSuite = rctx.lookupProbeSuite();
        params.put(RequestContext.SUITE_ID, probeSuite.getId());
    }
}
