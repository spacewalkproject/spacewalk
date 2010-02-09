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
package com.redhat.rhn.domain.monitoring.command.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeParameterValue;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.command.Command;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.command.CommandParameter;
import com.redhat.rhn.domain.monitoring.command.Metric;
import com.redhat.rhn.domain.monitoring.command.ThresholdParameter;
import com.redhat.rhn.domain.monitoring.command.ThresholdType;
import com.redhat.rhn.domain.monitoring.test.MonitoringFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.commons.collections.Transformer;
import org.hibernate.HibernateException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * CommandTest
 * @version $Rev: 52080 $
 */
public class CommandTest extends RhnBaseTestCase {

    public void testCommand() throws Exception {
        Command c = MonitoringConstants.getCommandCheckTCP();
        assertNotNull(c);
        assertNotNull(c.getCommandClass());
        assertNotNull(c.getCommandClass().getMetrics());
        assertNotNull(c.getCommandParameters());
        assertTrue(c.getCommandParameters().size() > 0);
        for (Iterator i = c.getCommandParameters().iterator(); i.hasNext();) {
            CommandParameter cp = (CommandParameter) i.next();
            assertNotNull(cp.getFieldWidgetName());
            if ("critical".equals(cp.getParamName()) ||
                "warning".equals(cp.getParamName())) {
                assertEquals(ThresholdParameter.class, cp.getClass());
                assertNotNull(((ThresholdParameter) cp).getMetric());
            }
        }
        
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Probe probe = MonitoringFactoryTest.createTestProbe(user);
        
        assertNotNull(probe.getCommand().getMetrics());
        Iterator i = probe.getCommand().getMetrics().iterator();
        assertTrue(i.hasNext());
        Metric m = (Metric) i.next();
        assertNotNull(m);
    }

    public void testCommandGroup() {
        Command c = MonitoringConstants.getCommandCheckTCP();
        CommandGroup g = c.getCommandGroup();
        assertNotNull(c.getCommandGroup());
        assertContains(g.getCommands(), c);
    }
    
    public void testThresholdParametersByMetric() {
        List l = MonitoringFactory.loadAllCommands();
        for (Iterator i = l.iterator(); i.hasNext();) {
            Command c = (Command) i.next();
            for (Iterator j = c.getMetrics().iterator(); j.hasNext();) {
                Metric m = (Metric) j.next();
                List tpl = c.listThresholds(m);
                assertNotNull(tpl);
                int sortKey = -10;
                for (Iterator k = tpl.iterator(); k.hasNext();) {
                    ThresholdParameter tp = (ThresholdParameter) k.next();
                    assertEquals(m, tp.getMetric());
                    assertTrue(sortKey < tp.getThresholdType().getSortKey());
                    sortKey = tp.getThresholdType().getSortKey();
                }
            }
        }
    }
    
    public void testCheckAscending() {
        Command c = MonitoringConstants.getCommandCheckTCP();
        Metric latency = null;
        for (Iterator i = c.getMetrics().iterator(); i.hasNext();) {
            Metric m = (Metric) i.next();
            if ("latency".equals(m.getMetricId())) {
                latency = m;
            }
        }
        assertNotNull(latency);
        MapTransformer toValue = new MapTransformer();
        toValue.map.put(ThresholdType.WARN_MAX, "2");
        toValue.map.put(ThresholdType.CRIT_MAX, "3");
        assertEquals(0, c.checkAscendingValues(latency, toValue).size());
        
        toValue.map.put(ThresholdType.WARN_MAX, null);
        toValue.map.put(ThresholdType.CRIT_MAX, "3");
        assertEquals(0, c.checkAscendingValues(latency, toValue).size());

        toValue.map.put(ThresholdType.WARN_MAX, "2");
        toValue.map.put(ThresholdType.CRIT_MAX, null);
        assertEquals(0, c.checkAscendingValues(latency, toValue).size());
        
        toValue.map.put(ThresholdType.WARN_MAX, "");
        toValue.map.put(ThresholdType.CRIT_MAX, "");
        assertEquals(0, c.checkAscendingValues(latency, toValue).size());
        
        toValue.map.put(ThresholdType.WARN_MAX, "3");
        toValue.map.put(ThresholdType.CRIT_MAX, "3");
        assertEquals(4, c.checkAscendingValues(latency, toValue).size());

        toValue.map.put(ThresholdType.WARN_MAX, "3");
        toValue.map.put(ThresholdType.CRIT_MAX, "2");
        assertEquals(4, c.checkAscendingValues(latency, toValue).size());
    }
    
    private static class MapTransformer implements Transformer {
        private HashMap map = new HashMap();

        public Object transform(Object input) {
            return map.get(((ThresholdParameter) input).getThresholdType());
        }
    }
    
    public void testCommandParameters() throws HibernateException {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        Probe probe = MonitoringFactoryTest.createTestProbe(user);
        assertNotNull(probe.getCommand().getCommandParameters());
        assertTrue(probe.getCommand().getCommandParameters().size() > 0);
        
        // Add some param values to the ServerProbe
        Iterator i = probe.getCommand().getCommandParameters().iterator();
        while (i.hasNext()) {
            CommandParameter cp = (CommandParameter) i.next();
            if (cp.getDefaultValue() != null) {
                probe.addProbeParameterValue(cp.getDefaultValue(), cp, user);
            }
        }

        Object[] params = probe.getCommand().getCommandParameters().toArray();
        CommandParameter cp = (CommandParameter) params[0];
        ProbeParameterValue ppv = probe.getProbeParameterValue(cp);
        
        //  Now check that we can set a value
        assertNotNull(ppv);
        // Check for this down below
        probe.setParameterValue(ppv, ppv.getValue() + "_changed");
        
        // Now check that they store correctly
        Long probeId = probe.getId();
        Org org = user.getOrg();
        MonitoringFactory.save(probe, user);
        
        probe = (ServerProbe) reload(probe);
        // Test ProbeCommandParameters
        probe = MonitoringFactory.lookupProbeByIdAndOrg(probeId, org);
        assertNotNull(probe.getProbeParameterValues());
        assertTrue(probe.getProbeParameterValues().size() > 0);
        ProbeParameterValue pv = (ProbeParameterValue) 
            probe.getProbeParameterValues().toArray()[0];
        assertNotNull(pv.getLastUpdateDate());
        
        /*Iterator j = probe.getProbeParameterValues().iterator();
        boolean changedValue = false;
        while (j.hasNext()) {
            ProbeParameterValue ppvChanged = (ProbeParameterValue) j.next();
            if (ppvChanged.getValue().endsWith("_changed")) {
                changedValue = true;
            }
        }
        assertTrue(changedValue);*/
        
        
    }
}

