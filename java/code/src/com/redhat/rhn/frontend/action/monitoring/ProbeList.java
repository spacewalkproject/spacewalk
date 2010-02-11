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
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.frontend.struts.BaseListAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.monitoring.MonitoringManager;

import org.apache.commons.lang.StringUtils;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ProbeList - Base class for rendering the list of Probes in an Org.
 * @version $Rev: 1 $
 */
public class ProbeList extends BaseListAction {
    
    public static final String PROBE_STATE = "state";
    
    public static final String PROBE_COUNT_CRITICAL = "criticalCount";
    public static final String PROBE_COUNT_WARNING = "warningCount";
    public static final String PROBE_COUNT_PENDING = "pendingCount";
    public static final String PROBE_COUNT_UNKNOWN = "unknownCount";
    public static final String PROBE_COUNT_OK = "okCount";
    public static final String PROBE_COUNT_ALL = "allCount";
    
    /**
     * {@inheritDoc}
     */
    protected void processRequestAttributes(RequestContext rctx) {
        super.processRequestAttributes(rctx);
        String stateparam = rctx.getParam(PROBE_STATE, false);
        if (StringUtils.isEmpty(stateparam)) {
            stateparam = "all";
        }
        stateparam = stateparam.toLowerCase();
        // Add all/warning/ok/Class css classname 
        rctx.getRequest().setAttribute(stateparam + "Class", "content-nav-selected");
        rctx.getRequest().setAttribute(stateparam + "Link", "content-nav-selected-link");
        
        // Setup the probe state summary
        Map counts = new HashMap();
        counts.put(PROBE_COUNT_CRITICAL, "0");
        counts.put(PROBE_COUNT_WARNING, "0");
        counts.put(PROBE_COUNT_PENDING, "0");
        counts.put(PROBE_COUNT_UNKNOWN, "0");
        counts.put(PROBE_COUNT_OK, "0");
        counts.put(PROBE_COUNT_ALL, "0");
        
        List stateCount = MonitoringManager.getInstance().
            listProbeStateSummary(rctx.getCurrentUser());
        Iterator i = stateCount.iterator();
        long stateSum = 0;
        while (i.hasNext()) {
            Map row = (Map) i.next();
            Long cnt = (Long) row.get("state_count");
            stateSum = stateSum + cnt.longValue();
            String state = ((String) row.get("state")).toLowerCase();
            counts.put(state + "Count", cnt.toString());
        }
        counts.put(PROBE_COUNT_ALL, Long.toString(stateSum));
        
        i = counts.keySet().iterator();
        while (i.hasNext()) {
            String key = (String) i.next();
            rctx.getRequest().setAttribute(key, counts.get(key));
        }
    }

    protected DataResult getDataResult(RequestContext rctx, PageControl pc) {
        String state = rctx.getParam(PROBE_STATE, false);
        return MonitoringManager.getInstance().
            listProbesByState(rctx.getCurrentUser(), state, pc);
    }



}
