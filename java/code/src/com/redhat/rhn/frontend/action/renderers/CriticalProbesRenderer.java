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
 * Renders YourRhn fragment for critical probes
 * 
 * @version $Rev$
 */
public class CriticalProbesRenderer extends BaseFragmentRenderer {

    private static final String CRITICAL_REFLINK_KEY_ARG0 = "criticalReflinkkeyarg0";
    private static final String MONITORING_CRITICAL_EMPTY = "monitoringCriticalEmpty";
    private static final String MONITORING_CRITICAL_LIST = "monitoringCriticalList";
    private static final String MONITORING_CRITICAL_CLASS = "monitoringCriticalClass";
    
    /**
     * {@inheritDoc}
     */
    protected void render(User user, PageControl pc, HttpServletRequest request) {
        String criticalProbesCSSTable = null;
        DataResult mcdr = MonitoringManager.getInstance()
                .listProbeCountsByState(user,
                        MonitoringConstants.PROBE_STATE_CRITICAL, pc);

        long criticalCount = 0;
        for (Iterator i = mcdr.iterator(); i.hasNext();) {
            ProbeCategoryDto probeCategory = (ProbeCategoryDto) i.next();
            criticalCount += probeCategory.getServerCount().longValue();
        }
        
        if (mcdr.isEmpty()) {
            criticalProbesCSSTable = RendererHelper.makeEmptyTable(true, 
                    "yourrhn.jsp.criticalprobes",
                    "yourrhn.jsp.nocriticalprobes");
        }

        request.setAttribute(MONITORING_CRITICAL_EMPTY, criticalProbesCSSTable);
        request.setAttribute(MONITORING_CRITICAL_LIST, mcdr);
        request.setAttribute(CRITICAL_REFLINK_KEY_ARG0, new Long(
                criticalCount));
        request.setAttribute(ListTagHelper.PARENT_URL, request.getRequestURI());

        RendererHelper.setTableStyle(request, MONITORING_CRITICAL_CLASS);
    }
    
    /**
     * {@inheritDoc}
     */
    protected String getPageUrl() {
        return "/WEB-INF/pages/common/fragments/yourrhn/monitoringCritical.jsp";        
    }
}
