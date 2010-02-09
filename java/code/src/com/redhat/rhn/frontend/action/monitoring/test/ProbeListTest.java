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
package com.redhat.rhn.frontend.action.monitoring.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.frontend.action.monitoring.ProbeList;
import com.redhat.rhn.frontend.dto.monitoring.ServerProbeDto;
import com.redhat.rhn.manager.monitoring.test.MonitoringManagerTest;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ProbeListTest
 * @version $Rev: 1 $
 */
public class ProbeListTest extends RhnMockStrutsTestCase {
    
    public void testExecute() throws Exception {
        UserTestUtils.addMonitoring(user.getOrg());
        for (int i = 0; i < 5; i++) {
            MonitoringManagerTest.createProbeWithState(user, 
                    MonitoringConstants.PROBE_STATE_CRITICAL);
            MonitoringManagerTest.createProbeWithState(user, 
                    MonitoringConstants.PROBE_STATE_OK);
            MonitoringManagerTest.createProbeWithState(user, 
                    MonitoringConstants.PROBE_STATE_PENDING);
            MonitoringManagerTest.createProbeWithState(user, 
                    MonitoringConstants.PROBE_STATE_UNKNOWN);
            MonitoringManagerTest.createProbeWithState(user, 
                    MonitoringConstants.PROBE_STATE_WARN);
            
        }
        setRequestPathInfo("/monitoring/ProbeList");
        actionPerform();
        verifyPageList(ServerProbeDto.class);
        assertEquals("content-nav-selected", request.getAttribute("allClass"));
        assertEquals("content-nav-selected-link", request.getAttribute("allLink"));
        
        checkCount(ProbeList.PROBE_COUNT_ALL);
        checkCount(ProbeList.PROBE_COUNT_CRITICAL);
        checkCount(ProbeList.PROBE_COUNT_OK);
        checkCount(ProbeList.PROBE_COUNT_PENDING);
        checkCount(ProbeList.PROBE_COUNT_UNKNOWN);
        checkCount(ProbeList.PROBE_COUNT_WARNING);
        
        addRequestParameter(ProbeList.PROBE_STATE, 
                MonitoringConstants.PROBE_STATE_CRITICAL);
        actionPerform();
        assertEquals("content-nav-selected", request.getAttribute("criticalClass"));
        assertEquals("content-nav-selected-link", request.getAttribute("criticalLink"));
    }
    
    private void checkCount(String name) {
        String cnt = (String) request.getAttribute(name);
        assertTrue(new Long(cnt).longValue() > 0);
        
    }
}

