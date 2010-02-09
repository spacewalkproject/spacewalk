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

package com.redhat.rhn.frontend.action.renderers;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.monitoring.ProbeCategoryDto;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.taglibs.list.ListTagHelper;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import java.util.Iterator;

import javax.servlet.http.HttpServletRequest;

/**
 * Renders YourRhn fragment for warning probes
 * 
 * @version $Rev$
 */
public class WarningProbesRenderer extends  BaseFragmentRenderer {

    private static final String MONITORING_WARNING_EMPTY = "monitoringWarningEmpty";
    private static final String MONITORING_WARNING_LIST = "monitoringWarningList";
    private static final String WARNING_REFLINK_KEY_ARG0 = "warningReflinkkeyarg0";

    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        String warningProbesCSSTable = null;
        DataResult mwdr = MonitoringManager.getInstance()
                .listProbeCountsByState(user,
                        MonitoringConstants.PROBE_STATE_WARN, pc);
        long warningCount = 0;
        for (Iterator i = mwdr.iterator(); i.hasNext();) {
            ProbeCategoryDto probeCategory = (ProbeCategoryDto) i.next();
            warningCount += probeCategory.getServerCount().longValue();
        }

        if (mwdr.isEmpty()) {
            warningProbesCSSTable = RendererHelper.makeEmptyTable(true, 
                    "yourrhn.jsp.warningprobes",
                    "yourrhn.jsp.nowarningprobes");
        }

        request.setAttribute(MONITORING_WARNING_EMPTY, warningProbesCSSTable);
        request.setAttribute(WARNING_REFLINK_KEY_ARG0, new Long(
                warningCount));
        request.setAttribute(MONITORING_WARNING_LIST, mwdr);
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());
    }

    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/monitoringWarning.jsp";
    }

}
