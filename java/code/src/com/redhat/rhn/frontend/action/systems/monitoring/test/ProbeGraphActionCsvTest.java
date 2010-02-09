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
package com.redhat.rhn.frontend.action.systems.monitoring.test;

import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnJmockBaseTestCase;

import java.sql.Timestamp;

/**
 * ProbeGraphActionCsvTest - specific test to test output of CSV for a probe graph
 * 
 * @version $Rev$
 */
public class ProbeGraphActionCsvTest extends RhnJmockBaseTestCase {
    
    private User user;
    private Probe probe;
    private Timestamp testTime; 
    

    public void testExecuteCSV() throws Exception {
        //TODO Fix broken test. The fix is coming with some changes in 415.
        
        /*if (!Config.get().isSatellite()) {
            return;
        }
        ProbeGraphAction action = new ProbeGraphAction();
        Mock mreq = JMockTestUtils.createRequestWithSessionAndUser();
        Mock mresp = mock(HttpServletResponse.class);
        HttpServletRequest request = (HttpServletRequest) mreq.proxy();
        HttpServletResponse response = (HttpServletResponse) mresp.proxy();
        RhnMockServletOutputStream out = new RhnMockServletOutputStream();
        
        user = UserTestUtils.findNewUser("testUser", "testOrg");
        
        Mock mockPxtSession = mock(WebSession.class);
        mockPxtSession.stubs().method("getUser").will(returnValue(user));
        
        Mock mockPxtDelegate = mock(PxtSessionDelegate.class);
        mockPxtDelegate.stubs().method("getUser").with(isA(HttpServletRequest.class)).will(
                returnValue(user));
        
        PxtSessionDelegateFactory.setTestPxtSessionDelegate(
                (PxtSessionDelegate)mockPxtDelegate.proxy());
        
        // server = ServerFactoryTest.createTestServer(user, false);
        probe = MonitoringFactoryTest.createTestProbe(user);

        testTime = MonitoringManagerTest.addTimeSeriesDataToProbe(user, probe, 20, 
                MonitoringManagerTest.TEST_METRIC);
        testTime = MonitoringManagerTest.addTimeSeriesDataToProbe(user, probe, 20, 
                MonitoringManagerTest.TEST_METRIC2);

        String[] metrics = new String[2];
        metrics[0] = MonitoringManagerTest.TEST_METRIC;
        metrics[1] = MonitoringManagerTest.TEST_METRIC2;

        addRequestParam(mreq, ProbeGraphAction.STARTTS, 
                new Long(testTime.getTime() - 60000000).toString());
        addRequestParam(mreq, ProbeGraphAction.ENDTS, 
                new Long(testTime.getTime()).toString());
        
        addRequestParam(mreq, RequestContext.PROBEID, probe.getId().toString());
        mreq.expects(atLeastOnce()).method("getParameterValues").
            with(eq("metrics")).will(returnValue(metrics));
        addRequestParam(mreq, RequestContext.LIST_DISPLAY_EXPORT, "1");
        
        JMockTestUtils.setupExportParameters(mresp, out);
        action.execute(null, null, request, response);
        assertTrue(out.getContents().startsWith("Id,Data,Time,Metric"));
        assertTrue(out.getContents().endsWith("0,pctfree\n"));*/
    }

}
