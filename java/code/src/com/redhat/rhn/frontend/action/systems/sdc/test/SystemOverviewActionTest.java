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
package com.redhat.rhn.frontend.action.systems.sdc.test;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;

/**
 * SystemOverviewActionTest
 * @version $Rev$
 */
public class SystemOverviewActionTest extends RhnMockStrutsTestCase {
    
    protected Server s;
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/details/Overview");

        s = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        request.addParameter("sid", s.getId().toString());
    }
    
    public void testSystemStatusNoErrata() throws Exception {
        actionPerform();
        assertEquals(Boolean.FALSE, request.getAttribute("hasUpdates"));
    }
    
    public void testSystemStatusWithErrata() throws Exception {
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        e.setAdvisoryType(ErrataFactory.ERRATA_TYPE_SECURITY);

        Org org = user.getOrg();
        Package p = PackageTest.createTestPackage(org);

        UserFactory.save(user);
        OrgFactory.save(org);
        
        int rows = ErrataCacheManager.insertNeededPackageCache(
                s.getId(), e.getId(), p.getId());
        assertEquals(1, rows);        
        
        actionPerform();
        assertEquals(Boolean.TRUE, request.getAttribute("hasUpdates"));
    }
    
    public void testSystemInactive() throws Exception {
        s.getServerInfo().setCheckin(new Date(1));
        TestUtils.saveAndFlush(s);
        actionPerform();
        assertEquals(request.getAttribute("systemInactive"), Boolean.TRUE);
    }
    
    public void testSystemActive() throws Exception {
        Calendar pcal = Calendar.getInstance();
        pcal.setTime(new Timestamp(System.currentTimeMillis()));
        pcal.roll(Calendar.MINUTE, -5);
        
        s.getServerInfo().setCheckin(pcal.getTime());
        TestUtils.saveAndFlush(s);
        actionPerform();
        assertEquals(request.getAttribute("systemInactive"), Boolean.FALSE);
    }
    
    public void testSystemUnentitled() throws Exception {
       SystemManager.removeAllServerEntitlements(s.getId());
       actionPerform();
       assertEquals(request.getAttribute("unentitled"), Boolean.TRUE);
    }
    
    public void testSystemEntitled() throws Exception {
        actionPerform();
        assertEquals(request.getAttribute("unentitled"), Boolean.FALSE);
    }
    
    public void testNoProbes() throws Exception {
        actionPerform();
        assertEquals(request.getAttribute("probeListEmpty"), Boolean.TRUE);
    }
    
    public void testLockSystem() throws Exception {
        request.addParameter("lock", "1");
        actionPerform();
        verifyActionMessage("sdc.details.overview.locked.alert");
        assertNotNull(s.getLock());
    }
    
    public void testUnlockSystem() throws Exception {
        SystemManager.lockServer(user, s, "test reason");
        request.addParameter("lock", "0");
        actionPerform();
        verifyActionMessage("sdc.details.overview.unlocked.alert");
        assertNull(s.getLock());
    }
    
    public void testActivateSatelliteApplet() throws Exception {
        
        request.addParameter("applet", "1");
        actionPerform();
        verifyActionMessage("sdc.details.overview.applet.scheduled");
    }
}
