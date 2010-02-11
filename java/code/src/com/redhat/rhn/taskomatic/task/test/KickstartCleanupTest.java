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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionState;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartableTreeTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.taskomatic.task.KickstartCleanup;
import com.redhat.rhn.taskomatic.task.TaskConstants;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.sql.Connection;
import java.sql.Statement;
import java.util.Date;

public class KickstartCleanupTest extends RhnBaseTestCase {
    
   protected void setUp() throws Exception {
        verifyDatasourceConfig();
    }
    
    public void testHungKickstart() throws Exception {
        
        Session session = HibernateFactory.getSession();
        KickstartSessionState failedState = lookupByLabel("failed");
        KickstartSessionState inProgressState = lookupByLabel("in_progress");
        KickstartSession ksession = createSession();
        ksession.setState(inProgressState);
        TestUtils.saveAndFlush(ksession);
        backdateKickstartSession(session, ksession, 2);
        session.clear();
        ksession = (KickstartSession) 
            session.load(KickstartSession.class, ksession.getId());
        KickstartCleanup j = new KickstartCleanup();
        j.execute(null, true);
        session.clear();
        ksession = (KickstartSession) 
            session.load(KickstartSession.class, ksession.getId());
        assertTrue(ksession.getState().getId().equals(failedState.getId()));
    }
    
    public void testAbandonedKickstart() throws Exception {
        Session session = HibernateFactory.getSession();
        KickstartSessionState failedState = lookupByLabel("failed");
        KickstartSessionState createdState = lookupByLabel("created");
        KickstartSession ksession = createSession();
        ksession.setState(createdState);
        TestUtils.saveAndFlush(ksession);
        backdateKickstartSession(session, ksession, 7);
        session.clear();
        ksession = (KickstartSession) 
            session.load(KickstartSession.class, ksession.getId());
        KickstartCleanup j = new KickstartCleanup();
        j.execute(null, true);
        session.clear();
        ksession = (KickstartSession) 
            session.load(KickstartSession.class, ksession.getId());
        assertTrue(ksession.getState().getId().equals(failedState.getId()));        
    }
    
    private static void backdateKickstartSession(Session session, 
            KickstartSession ksession, int days) throws Exception {
        Connection cn = session.connection();
        StringBuffer sql = new StringBuffer();
        sql.append("update rhnkickstartsession set last_action = sysdate - ");
        sql.append(String.valueOf(days));
        sql.append(" where id = ").append(ksession.getId());
        Statement stmt = null;
        try {
            stmt = cn.createStatement();
            stmt.execute(sql.toString());
        }
        finally {
            if (stmt != null) {
                stmt.close();
            }
        }
    }
    
    private static KickstartSession createSession() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        Server s = ServerFactoryTest.createTestServer(user);
        KickstartSessionState state = lookupByLabel("injected");
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
        KickstartVirtualizationType type = KickstartFactory.
         lookupKickstartVirtualizationTypeByLabel(KickstartVirtualizationType.XEN_PARAVIRT);
        ksession.setVirtualizationType(type);
        TestUtils.saveAndFlush(ksession);
        return ksession;
    }
    
    private void verifyDatasourceConfig() throws Exception {
        SelectMode select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_FIND_CANDIDATES);
        assertNotNull(select);
        
        select = ModeFactory.getMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_FIND_PREREQ_ACTION);
        assertNotNull(select);
        
        select = ModeFactory.getMode(TaskConstants.MODE_NAME, 
                TaskConstants.TASK_QUERY_KSCLEANUP_FIND_FAILED_STATE_ID);
        assertNotNull(select);
        
        WriteMode update = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                TaskConstants.TASK_QUERY_KSCLEANUP_MARK_SESSION_FAILED);
        assertNotNull(update);
        
        CallableMode proc = ModeFactory.getCallableMode(TaskConstants.MODE_NAME, 
                TaskConstants.TASK_QUERY_KSCLEANUP_REMOVE_ACTION); 
        assertNotNull(proc);        
    }
    
    /**
     * Helper method to lookup KickstartSessionState by label
     * @param label Label to lookup
     * @return Returns the KickstartSessionState
     * @throws Exception
     */
    private static KickstartSessionState lookupByLabel(String label) throws Exception {
        Session session = HibernateFactory.getSession();
        return (KickstartSessionState) session
                          .getNamedQuery("KickstartSessionState.findByLabel")
                          .setString("label", label)
                          .uniqueResult();
    }    
    
    public static void main(String[] argv) throws Exception {
        KickstartCleanupTest kct = new KickstartCleanupTest();
        kct.setUp();
        kct.testHungKickstart();
    }
}
