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
package com.redhat.rhn.domain.monitoring.test;

import com.redhat.rhn.domain.monitoring.MonitoringConstants;
import com.redhat.rhn.domain.monitoring.MonitoringFactory;
import com.redhat.rhn.domain.monitoring.Probe;
import com.redhat.rhn.domain.monitoring.ProbeState;
import com.redhat.rhn.domain.monitoring.ProbeType;
import com.redhat.rhn.domain.monitoring.ServerProbe;
import com.redhat.rhn.domain.monitoring.TemplateProbe;
import com.redhat.rhn.domain.monitoring.command.CommandGroup;
import com.redhat.rhn.domain.monitoring.satcluster.SatCluster;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.monitoring.ModifyProbeCommand;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.HibernateException;

import java.util.Calendar;
import java.util.List;

/**
 * MonitoringFactoryTest
 * @version $Rev: 52080 $
 */
public class MonitoringFactoryTest extends RhnBaseTestCase {

    private User user;
    private Probe probe;

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        user = UserTestUtils.findNewUser("testUser", "testOrg");
        probe = createTestProbe(user, MonitoringConstants.getProbeTypeCheck());
    }

    /**
     * Test fetching a ServerProbe 
     * @throws Exception in case of error
     */
    public void testLookup() throws Exception {
        Long id = probe.getId();
        flushAndEvict(probe);
        Probe lookedUp = MonitoringFactory.lookupProbeByIdAndOrg(id, 
                user.getOrg()); 
        assertNotNull(lookedUp);
        assertNotNull(lookedUp.getLastUpdateDate());
        assertNotNull(lookedUp.getLastUpdateUser());
        assertNotNull(((ServerProbe) lookedUp).getSatCluster());
        assertNotNull(((ServerProbe)probe).getSatCluster());
    }
    
    public void testProbeState() throws HibernateException {

        ProbeState ps = new ProbeState((SatCluster)
                user.getOrg().getMonitoringScouts().iterator().next());
        ps.setState(MonitoringConstants.PROBE_STATE_OK);
        ps.setOutput("Test State from Unit Tests");
        ps.setProbe(probe);
        probe.setState(ps);
        MonitoringFactory.save(probe, user);
        Long probeId = probe.getId();
        flushAndEvict(probe);
        probe = MonitoringFactory.lookupProbeByIdAndOrg(probeId, user.getOrg());
        assertNotNull(probe.getState());
        assertNotNull(probe.getState().getProbe());
        assertFalse(probe.getNotifyCritical().booleanValue());
    }
    
    public void testProbeLastUpdate() throws Exception {
        // Set its lastupdatedate to 
        // something way in the past.
        Calendar cal = Calendar.getInstance();
        cal.roll(Calendar.YEAR, -10);
        probe.setLastUpdateDate(cal.getTime());
        probe.setLastUpdateUser("somethingnotvalid");
        MonitoringFactory.save(probe, user);
        assertTrue(probe.getLastUpdateDate().after(cal.getTime()));
        assertTrue(probe.getLastUpdateUser().equals(
                user.getLogin()));
    }
    
    
    public void testDeleteProbe() throws HibernateException {
        Long id = probe.getId();
        MonitoringFactory.deleteProbe(probe);
        flushAndEvict(probe);
        assertNull(MonitoringFactory.
                lookupProbeByIdAndOrg(id, user.getOrg()));
    }
    
    public void testGetCommandGroups() {
        List l = MonitoringFactory.loadAllCommandGroups();
        assertNotNull(l);
        assertTrue(l.size() > 0);
        assertEquals(CommandGroup.class, l.get(0).getClass());
    }
    
    public static Probe createTestProbe(User userIn) {
        return createTestProbe(userIn, MonitoringConstants.getProbeTypeCheck());
    }
    
    public static Probe createTestProbe(User u, ProbeType typeIn) {
        ModifyProbeCommand cmd = new CreateTestProbeCommand(u, typeIn);
        assertNotNull(cmd.getProbe().getId());
        assertEquals(typeIn, cmd.getProbe().getType());
        return cmd.getProbe();
    }

    private static final class CreateTestProbeCommand extends ModifyProbeCommand {
        
        public CreateTestProbeCommand(User u, ProbeType pt) {
            super(u, MonitoringConstants.getCommandCheckTCP(), createProbe(pt, u));
            setDescription("rhnUnitTest" + TestUtils.randomString());
            setNotificationIntervalMinutes(new Long(100));
            setCheckIntervalMinutes(new Long(100));
            setNotification(Boolean.FALSE);
            storeProbe();
        }

        private static Probe createProbe(ProbeType pt, User u) {
            u.addRole(RoleFactory.ORG_ADMIN);
            UserFactory.save(u);
            if (MonitoringConstants.getProbeTypeCheck().equals(pt)) {
                ServerProbe retval = ServerProbe.newInstance();
                Server s = null;
                try {
                    s = ServerFactoryTest.createTestServer(u, true);
                }
                catch (Exception e) {
                    e.printStackTrace();
                    throw new RuntimeException(e);
                }
                retval.setServer(s);
                retval.setSatCluster((SatCluster) 
                        u.getOrg().getMonitoringScouts().iterator().next());
                return retval;
            } 
            else if (MonitoringConstants.getProbeTypeSuite().equals(pt)) {
                return TemplateProbe.newInstance();
            } 
            else {
                fail("Illegal probe type " + pt);
                return null; // Make the compiler happy
            }
        }
    }
}

