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
package com.redhat.rhn.domain.kickstart.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionState;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.test.ProfileTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

/**
 * KickstartSessionTest
 * @version $Rev$
 */
public class KickstartSessionTest extends BaseTestCaseWithUser {
    private KickstartData k;
    private KickstartSession ksession;
    private Server s;
    
    public void setUp() throws Exception {
        super.setUp();
        user.addRole(RoleFactory.ORG_ADMIN);
        k = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        assertNotNull(k);
        Profile p  = ProfileTest.createTestProfile(user, 
                k.getKickstartDefaults().getKstree().getChannel());
        ksession = createKickstartSession(k, user);
        s = ksession.getOldServer();
        ksession.setServerProfile(p);
        TestUtils.saveAndFlush(ksession);
    }

    public void testIdsForSS() throws Exception {
        assertNotNull(KickstartFactory.SESSION_STATE_CREATED.getId());
        assertNotNull(KickstartFactory.SESSION_STATE_COMPLETE.getId());
        assertNotNull(KickstartFactory.SESSION_STATE_FAILED.getId());
        assertNotNull(KickstartFactory.SESSION_STATE_STARTED.getId());
    }
    
    
    public void testKickstartDataTest() throws Exception {

        KickstartSession ks2 = KickstartFactory.
            lookupKickstartSessionById(ksession.getId());
        assertEquals(ksession.getId(), ks2.getId());
        assertEquals(ksession.getKsdata(), k);
        assertNotNull(ks2.getServerProfile());
    }
    
    public void testLookupByServer() throws Exception {

        KickstartSession lookedUp = KickstartFactory.
            lookupKickstartSessionByServer(s.getId());
        assertEquals(lookedUp.getId(), ksession.getId());
    }
    
    
    public void testLookupAllForServerAndFail() throws Exception {

        KickstartSession session2 = createKickstartSession(s, k, user);
        KickstartFactory.saveKickstartSession(session2);
        assertEquals(2, KickstartFactory.
                lookupAllKickstartSessionsByServer(s.getId()).size());
        
        session2.setState(KickstartFactory.SESSION_STATE_CREATED);
        session2.markFailed("some failed message");
        KickstartFactory.saveKickstartSession(session2);
        session2 = (KickstartSession) reload(session2);
        assertEquals("Got wrong status: " + session2.getState().getLabel(),
                KickstartFactory.SESSION_STATE_FAILED, session2.getState());
    }
    
    
    public void testHistory() throws Exception {
        ksession = addHistory(ksession);
        Thread.sleep(2000);
        KickstartFactory.saveKickstartSession(ksession);
        ksession = (KickstartSession) reload(ksession);
        assertNotNull(ksession.getHistory());
        assertEquals(2, ksession.getHistory().size());
        
        ksession.addHistory(KickstartFactory.SESSION_STATE_FAILED, "FAILED");
        
        KickstartFactory.saveKickstartSession(ksession);
        ksession = (KickstartSession) reload(ksession);
        assertTrue(ksession.getMostRecentHistory().startsWith("FAILED"));
    }
    
    public void testGetUrl() {
        String url = ksession.getUrl("xmlrpc.rhn.webdev.redhat.com", new Date());
        assertNotNull(url);
        // http://xmlrpc.rhn.webdev.redhat.com/ty/gtIKQrRN
        assertTrue(url.startsWith("http"));
        assertTrue(url.indexOf("http://xmlrpc.rhn.webdev.redhat.com/ty/") == 0);

    }
    
    public static KickstartSession addHistory(KickstartSession session) 
        throws Exception {
        session.addHistory(KickstartFactory.SESSION_STATE_STARTED, 
                "some hist" + TestUtils.randomString());
        return session;
    }
    
    public static KickstartSession createKickstartSession(Server s, KickstartData k,
            User userIn) throws Exception {
        return createKickstartSession(s, k, userIn, null);
        
    }
    public static KickstartSession createKickstartSession(Server s, KickstartData k,
            User userIn, Action actionIn) throws Exception {
        
        KickstartSessionState state = KickstartFactory.SESSION_STATE_CREATED;
        KickstartSession ksession = new KickstartSession();
        ksession.setKsdata(k);
        ksession.setKickstartMode("label");
        ksession.setKstree(KickstartableTreeTest.createTestKickstartableTree());
        ksession.setOrg(k.getOrg());
        ksession.setState(state);
        ksession.setCreated(new Date());
        ksession.setModified(new Date());
        ksession.setPackageFetchCount(new Long(0));
        ksession.setDeployConfigs(Boolean.FALSE);
        ksession.setOldServer(s);
        ksession.setNewServer(s);
        ksession.setVirtualizationType(KickstartFactory.
                lookupKickstartVirtualizationTypeByLabel(
                    KickstartVirtualizationType.XEN_PARAVIRT));
        
        if (actionIn != null) {
            ksession.setAction(actionIn);
        }
        
        return ksession;
        
    }
    
    public static KickstartSession createKickstartSession(KickstartData k,
            User userIn) throws Exception {
        Server s = ServerFactoryTest.createTestServer(userIn, true);
        Channel baseChannel = ChannelFactoryTest.createTestChannel(userIn);
        baseChannel.setParentChannel(null);
        s.addChannel(baseChannel);
        TestUtils.saveAndFlush(s);
        return createKickstartSession(s, k, userIn);
    }

}
