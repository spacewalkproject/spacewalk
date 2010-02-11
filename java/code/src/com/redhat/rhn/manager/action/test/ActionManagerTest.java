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

package com.redhat.rhn.manager.action.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.kickstart.KickstartAction;
import com.redhat.rhn.domain.action.kickstart.KickstartActionDetails;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestAction;
import com.redhat.rhn.domain.action.kickstart.KickstartGuestActionDetails;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.KickstartSessionHistory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.test.PackageTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.ActionedSystem;
import com.redhat.rhn.frontend.dto.PackageListItem;
import com.redhat.rhn.frontend.dto.PackageMetadata;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.action.ActionIsChildException;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.kickstart.ProvisionVirtualInstanceCommand;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.profile.test.ProfileManagerTest;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.apache.log4j.Logger;
import org.hibernate.Query;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/** JUnit test case for the User
 *  class.
 */
public class ActionManagerTest extends RhnBaseTestCase {
    private static Logger log = Logger.getLogger(ActionManagerTest.class);
    
    public void testGetSystemGroups() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        
        
        user1.addRole(RoleFactory.ORG_ADMIN);
        // Here we have to commit the User because we added a Server
        // and need to update their rhnUserServerPerms table.  This should be
        // mapped to hibernate so we don't have to do these two manual commits!
        UserFactory.save(user1);
    
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setFilterColumn("earliest");
        pc.setStart(1);
        DataResult dr = ActionManager.pendingActions(user1, pc);
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
    }
    
    public void testLookupAction() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        user1.addRole(RoleFactory.ORG_ADMIN);
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        Long actionId = a1.getId();
        
        //Users must have access to a server for the action to lookup the action
        Server s = ServerFactoryTest.createTestServer(user1, true);
        a1.addServerAction(ServerActionTest.createServerAction(s, a1));
        ActionManager.storeAction(a1);
        
        Action a2 = ActionManager.lookupAction(user1, actionId);
        assertNotNull(a2);
    }
    
    public void testFailedActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction child = ServerActionTest.createServerAction(ServerFactoryTest
                .createTestServer(user), parent);
        
        child.setStatus(ActionFactory.STATUS_FAILED);
        
        parent.addServerAction(child);
        ActionFactory.save(parent);
        UserFactory.save(user);
        
        DataResult dr = ActionManager.failedActions(user, null);
        assertNotEmpty(dr);
    }
    
    public void testPendingActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction child = ServerActionTest.createServerAction(ServerFactoryTest
                .createTestServer(user), parent);
        
        child.setStatus(ActionFactory.STATUS_QUEUED);
        
        parent.addServerAction(child);
        ActionFactory.save(parent);
        UserFactory.save(user);
        
        DataResult dr = ActionManager.pendingActions(user, null);
        
        Long actionid = new Long(parent.getId().longValue()); 
        TestUtils.arraySearch(dr.toArray(), "getId", actionid);
        assertNotEmpty(dr);
    }
    
    private Action createActionWithServerActions(User user, int numServerActions) 
        throws Exception {
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        Channel baseChannel = ChannelFactoryTest.createTestChannel(user);
        baseChannel.setParentChannel(null);
        for (int i = 0; i < numServerActions; i++) {
            Server server = ServerFactoryTest.createTestServer(user, true);
            server.addChannel(baseChannel);
            TestUtils.saveAndFlush(server);
            
            ServerAction child = ServerActionTest.createServerAction(server, parent);
            child.setStatus(ActionFactory.STATUS_QUEUED);
            TestUtils.saveAndFlush(child);
            
            parent.addServerAction(child);
        }
        ActionFactory.save(parent);
        return parent;
    }
    
    private List createActionList(User user, Action [] actions) {
        List returnList = new LinkedList();
        
        for (int i = 0; i < actions.length; i++) {
            returnList.add(actions[i]);
        }
        
        return returnList;
    }
    
    public void assertServerActionCount(Action parentAction, int expected) {
        Session session = HibernateFactory.getSession();
        Query query = session.createQuery("from ServerAction sa where " + 
            "sa.parentAction = :parent_action");
        query.setEntity("parent_action", parentAction);
        List results = query.list();
        int initialSize = results.size();
        assertEquals(expected, initialSize);
    }
    
    public void assertServerActionCount(User user, int expected) {
        Session session = HibernateFactory.getSession();
        Query query = session.createQuery("from ServerAction sa where " + 
            "sa.parentAction.schedulerUser = :user");
        query.setEntity("user", user);
        List results = query.list();
        int initialSize = results.size();
        assertEquals(expected, initialSize);
    }
    
    public void assertActionsForUser(User user, int expected) throws Exception {
        Session session = HibernateFactory.getSession();
        Query query = session.createQuery("from Action a where a.schedulerUser = :user");
        query.setEntity("user", user);
        List results = query.list();
        int initialSize = results.size();
        assertEquals(expected, initialSize);
    }
    
    public void testSimpleCancelActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);

        Action parent = createActionWithServerActions(user, 1);
        List actionList = createActionList(user, new Action [] {parent});
        
        assertServerActionCount(parent, 1);
        assertActionsForUser(user, 1);
        ActionManager.cancelActions(user, actionList);
        assertServerActionCount(parent, 0);
        assertActionsForUser(user, 1); // shouldn't have been deleted
    }
    
    public void testCancelActionWithChildren() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Action parent = createActionWithServerActions(user, 1);
        Action child = createActionWithServerActions(user, 1);
        child.setPrerequisite(parent);
        List actionList = createActionList(user, new Action [] {parent});
        
        assertServerActionCount(parent, 1);
        assertActionsForUser(user, 2);
        ActionManager.cancelActions(user, actionList);
        assertServerActionCount(parent, 0);
        assertActionsForUser(user, 2); // shouldn't have been deleted
    }
    
    public void testCancelActionWithMultipleServerActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);

        Action parent = createActionWithServerActions(user, 2);
        List actionList = createActionList(user, new Action [] {parent});
        
        assertServerActionCount(parent, 2);
        assertActionsForUser(user, 1);
        ActionManager.cancelActions(user, actionList);
        assertServerActionCount(parent, 0);
        assertActionsForUser(user, 1); // shouldn't have been deleted
    }
    
    public void testCancelActionWithParentFails() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Action parent = createActionWithServerActions(user, 1);
        Action child = createActionWithServerActions(user, 1);
        child.setPrerequisite(parent);
        List actionList = createActionList(user, new Action [] {child});
        
        try {
            ActionManager.cancelActions(user, actionList);
            fail("Exception not thrown when deleting action with a prerequisite.");
        }
        catch (ActionIsChildException e) {
            // expected
        }
    }
    
    public void testComplexHierarchy() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Action parent1 = createActionWithServerActions(user, 3);
        for (int i = 0; i < 9; i++) {
            Action child = createActionWithServerActions(user, 2);
            child.setPrerequisite(parent1);
        }
        Action parent2 = createActionWithServerActions(user, 3);
        for (int i = 0; i < 9; i++) {
            Action child = createActionWithServerActions(user, 2);
            child.setPrerequisite(parent2);
        }
        assertServerActionCount(user, 42);
        
        List actionList = createActionList(user, new Action [] {parent1, parent2});
        
        assertServerActionCount(parent1, 3);
        assertActionsForUser(user, 20);
        
        ActionManager.cancelActions(user, actionList);
        assertServerActionCount(parent1, 0);
        assertActionsForUser(user, 20); // shouldn't have been deleted
        assertServerActionCount(user, 0);
        
    }

    public void testCancelKickstartAction() throws Exception {
        Session session = HibernateFactory.getSession();
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        UserFactory.save(user);
        
        Action parentAction = createActionWithServerActions(user, 1);
        Server server = ((ServerAction)parentAction.getServerActions().iterator().next())
            .getServer();
        ActionFactory.save(parentAction);
        
        KickstartData ksData = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        KickstartSession ksSession = KickstartSessionTest.createKickstartSession(server, 
                ksData, user, parentAction);
        TestUtils.saveAndFlush(ksSession);
        ksSession = (KickstartSession)reload(ksSession);
        
        List actionList = createActionList(user, new Action [] {parentAction});
        
        Query kickstartSessions = session.createQuery(
                "from KickstartSession ks where ks.action = :action");
        kickstartSessions.setEntity("action", parentAction);
        List results = kickstartSessions.list();
        assertEquals(1, results.size());
        
        assertEquals(1, ksSession.getHistory().size());
        KickstartSessionHistory history = 
            (KickstartSessionHistory)ksSession.getHistory().iterator().next();
        assertEquals("created", history.getState().getLabel());

        ActionManager.cancelActions(user, actionList);
        
        // New history entry should have been created:
        assertEquals(2, ksSession.getHistory().size());
        
        // Test that the kickstart wasn't deleted but rather marked as failed:
        assertEquals("failed", ksSession.getState().getLabel());
    }
    
    public void testCompletedActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction child = ServerActionTest.createServerAction(ServerFactoryTest
                .createTestServer(user), parent);
        
        child.setStatus(ActionFactory.STATUS_COMPLETED);
        
        parent.addServerAction(child);
        ActionFactory.save(parent);
        UserFactory.save(user);
        
        DataResult dr = ActionManager.completedActions(user, null);
        assertNotEmpty(dr);
    }
    
    public void testRecentlyScheduledActions() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        Action parent = ActionFactoryTest.createAction(user, ActionFactory.TYPE_ERRATA);
        ServerAction child = ServerActionTest.createServerAction(ServerFactoryTest
                .createTestServer(user), parent);
        
        child.setStatus(ActionFactory.STATUS_COMPLETED);
        child.setCreated(new Date(System.currentTimeMillis()));
        
        parent.addServerAction(child);
        ActionFactory.save(parent);
        UserFactory.save(user);
        
        DataResult dr = ActionManager.recentlyScheduledActions(user, null, 30);
        assertNotEmpty(dr);
    }

    public void testLookupFailLoookupAction() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        try {
            ActionManager.lookupAction(user1, new Long(-1));
            fail("Expected to fail");
        } 
        catch (LookupException le) {
            assertTrue(true);
        }
    }

    public void testRescheduleAction() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ServerAction sa = (ServerAction) a1.getServerActions().toArray()[0];
        
        sa.setStatus(ActionFactory.STATUS_FAILED);
        sa.setRemainingTries(new Long(0));
        ActionFactory.save(a1);
        
        ActionManager.rescheduleAction(a1);
        sa = (ServerAction) ActionFactory.reload(sa);
        assertTrue(sa.getStatus().equals(ActionFactory.STATUS_QUEUED));
        assertTrue(sa.getRemainingTries().longValue() > 0);
    }
    
    public void testInProgressSystems() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        
        
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ServerAction sa = (ServerAction) a1.getServerActions().toArray()[0];
        
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        ActionFactory.save(a1);
        // Gotta be ORG_ADMIN to view failed systems 
        user1.addRole(RoleFactory.ORG_ADMIN);
        // Here we have to commit the User because we added a Server
        // and need to update their rhnUserServerPerms table.  This should be
        // mapped to hibernate so we don't have to do these two manual commits!
        UserFactory.save(user1);
        DataResult dr = ActionManager.inProgressSystems(user1, a1, null);
        assertTrue(dr.size() > 0);
        assertTrue(dr.get(0) instanceof ActionedSystem);
        ActionedSystem as = (ActionedSystem) dr.get(0);
        as.setSecurityErrata(new Long(1));
        assertNotNull(as.getSecurityErrata());
    }
    
    public void testFailedSystems() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        
        
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ServerAction sa = (ServerAction) a1.getServerActions().toArray()[0];
        
        sa.setStatus(ActionFactory.STATUS_FAILED);
        ActionFactory.save(a1);
        // Gotta be ORG_ADMIN to view failed systems 
        user1.addRole(RoleFactory.ORG_ADMIN);
        // Here we have to commit the User because we added a Server
        // and need to update their rhnUserServerPerms table.  This should be
        // mapped to hibernate so we don't have to do these two manual commits!
        UserFactory.save(user1);
        
        assertTrue(ActionManager.failedSystems(user1, a1, null).size() > 0);
    }
    
    public void testCreateErrataAction() throws Exception {
        User user = UserTestUtils.createUser("testUser", 
                UserTestUtils.createOrg("testOrg"));
        Errata errata = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        Action a = ActionManager.createErrataAction(user.getOrg(), errata);
        assertNotNull(a);
        assertNotNull(a.getOrg());
        a = ActionManager.createErrataAction(user, errata);
        assertNotNull(a);
        assertNotNull(a.getOrg());
        assertTrue(a.getActionType().equals(ActionFactory.TYPE_ERRATA));
    }
    
    public void testAddServerToAction() throws Exception {
        User usr = UserTestUtils.createUser("testUser", 
                UserTestUtils.createOrg("testOrg"));
        Server s = ServerFactoryTest.createTestServer(usr);
        Action a = ActionFactoryTest.createAction(usr, ActionFactory.TYPE_ERRATA);
        ActionManager.addServerToAction(s.getId(), a);
        
        assertNotNull(a.getServerActions());
        assertEquals(a.getServerActions().size(), 1);
        Object[] array = a.getServerActions().toArray();
        ServerAction sa = (ServerAction)array[0];
        assertTrue(sa.getStatus().equals(ActionFactory.STATUS_QUEUED));
        assertTrue(sa.getServer().equals(s));
    }
    
    public void testSchedulePackageRemoval() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        assertNotNull(user);

        Server srvr = ServerFactoryTest.createTestServer(user, true);
        RhnSet set = RhnSetManager.createSet(user.getId(), "removable_package_list", 
                SetCleanup.NOOP);
        assertNotNull(srvr);
        assertNotNull(set);

        Package pkg = PackageTest.createTestPackage(user.getOrg());

        set.addElement(pkg.getPackageName().getId(), pkg.getPackageEvr().getId(),
                pkg.getPackageArch().getId());
        RhnSetManager.store(set);

        PackageAction pa = ActionManager.schedulePackageRemoval(user, srvr, 
            set, new Date());
        assertNotNull(pa);
        assertNotNull(pa.getId());
        PackageAction pa1 = (PackageAction) ActionManager.lookupAction(user, pa.getId());
        assertNotNull(pa1);
        assertEquals(pa, pa1);
    }
    
    public void testSchedulePackageVerify() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        assertNotNull(user);

        Server srvr = ServerFactoryTest.createTestServer(user, true);
        RhnSet set = RhnSetManager.createSet(user.getId(), "verify_package_list", 
                SetCleanup.NOOP);
        assertNotNull(srvr);
        assertNotNull(set);
        
        Package pkg = PackageTest.createTestPackage(user.getOrg());

        set.addElement(pkg.getPackageName().getId(), pkg.getPackageEvr().getId(),
                pkg.getPackageArch().getId());
        RhnSetManager.store(set);
        
        PackageAction pa = ActionManager.schedulePackageVerify(user, srvr, set, new Date());
        assertNotNull(pa);
        assertNotNull(pa.getId());
        PackageAction pa1 = (PackageAction) ActionManager.lookupAction(user, pa.getId());
        assertNotNull(pa1);
        assertEquals(pa, pa1);
    }
    
    public void testScheduleSriptRun() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        assertNotNull(user);

        Server srvr = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        SystemManagerTest.giveCapability(srvr.getId(), "script.run", new Long(1));
        assertNotNull(srvr);

        ScriptActionDetails sad = ActionFactory.createScriptActionDetails(
                "root", "root", new Long(10), "#!/bin/csh\necho hello");
        assertNotNull(sad);
        ScriptRunAction sra = ActionManager.scheduleScriptRun(
                user, srvr, "Run script test", sad, new Date());
        assertNotNull(sra);
        assertNotNull(sra.getId());
        ScriptRunAction pa1 = (ScriptRunAction)
                ActionManager.lookupAction(user, sra.getId());
        assertNotNull(pa1);
        assertEquals(sra, pa1);
        ScriptActionDetails sad1 = pa1.getScriptActionDetails();
        assertNotNull(sad1);
        assertEquals(sad, sad1);
    }

    public void testScheduleKickstart() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        assertNotNull(user);
 
        Server srvr = ServerFactoryTest.createTestServer(user, true);
        assertNotNull(srvr);
        KickstartData testKickstartData
            = KickstartDataTest.createKickstartWithChannel(user.getOrg());
                                                        
        KickstartAction ka
            = ActionManager.scheduleKickstartAction(testKickstartData,
                                                    user,
                                                    srvr,
                                                    new Date(System.currentTimeMillis()),
                                                    "",
                                                    "localhost");
        assertNotNull(ka);
        TestUtils.saveAndFlush(ka);
        assertNotNull(ka.getId());
        KickstartActionDetails kad = ka.getKickstartActionDetails();
        KickstartAction ka2 = (KickstartAction)
            ActionManager.lookupAction(user, ka.getId());
        assertNotNull(ka2);
        assertEquals(ka, ka2);
        KickstartActionDetails kad2 = ka2.getKickstartActionDetails();
        assertNotNull(kad);
        assertEquals(kad, kad2);
    }

    public void testScheduleGuestKickstart() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);
        assertNotNull(user);
 
        Server srvr = ServerFactoryTest.createTestServer(user, true);
        assertNotNull(srvr);
        KickstartData testKickstartData
            = KickstartDataTest.createKickstartWithChannel(user.getOrg());

        KickstartSession ksSession = 
            KickstartSessionTest.createKickstartSession(srvr, 
                                                        testKickstartData, 
                                                        user);
        TestUtils.saveAndFlush(ksSession);
        
        String kickstartHost = "localhost.localdomain";
        ProvisionVirtualInstanceCommand command = 
            new ProvisionVirtualInstanceCommand(srvr.getId(),
                                                testKickstartData.getId(),
                                                user,
                                                new Date(System.currentTimeMillis()),
                                                kickstartHost);
        
        command.setGuestName("testGuest1");
        command.setMemoryAllocation(256L);
        command.setLocalStorageSize(2L);
        command.setVirtualCpus(2L);
        command.setKickstartSession(ksSession);
        KickstartGuestAction ka =
            ActionManager.scheduleKickstartGuestAction(command, ksSession.getId());
        assertEquals(kickstartHost, 
                ka.getKickstartGuestActionDetails().getKickstartHost());
        
        assertNotNull(ka);
        TestUtils.saveAndFlush(ka);
        assertNotNull(ka.getId());
        KickstartGuestActionDetails kad =
            (KickstartGuestActionDetails) ka.getKickstartGuestActionDetails();
        KickstartGuestAction ka2 = (KickstartGuestAction)
            ActionManager.lookupAction(user, ka.getId());
        assertNotNull(ka2);
        assertNotNull(kad.getCobblerSystemName());
        assertEquals(ka, ka2);
        KickstartGuestActionDetails kad2 =
            (KickstartGuestActionDetails) ka2.getKickstartGuestActionDetails();
        assertNotNull(kad);
        assertEquals(kad, kad2);

        assertEquals("256", kad.getMemMb().toString());
        assertEquals("2", kad.getVcpus().toString());
        assertEquals("testGuest1", kad.getGuestName());
        assertEquals("2", kad.getDiskGb().toString());
    }
                                                                   
    public void testSchedulePackageDelta() throws Exception {
        User user = UserTestUtils.findNewUser("testUser", "testOrg");
        user.addRole(RoleFactory.ORG_ADMIN);

        Server srvr = ServerFactoryTest.createTestServer(user, true);
        
        List profileList = new ArrayList();
        profileList.add(ProfileManagerTest.
                createPackageListItem("kernel-2.4.23-EL-mmccune", 500341));
        profileList.add(ProfileManagerTest.
                createPackageListItem("kernel-2.4.24-EL-mmccune", 500341));
        profileList.add(ProfileManagerTest.
                createPackageListItem("kernel-2.4.25-EL-mmccune", 500341));
        //profileList.add(ProfileManagerTest.
        //        createPackageListItem("other-2.1.0-EL-mmccune", 500400));
        
        List systemList = new ArrayList();
        systemList.add(ProfileManagerTest.
                createPackageListItem("kernel-2.4.23-EL-mmccune", 500341));
        
        
        RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.get(user);
        
       
        List pkgs = ProfileManager.comparePackageLists(new DataResult(profileList),
                new DataResult(systemList), "foo");
        
        Action action = ActionManager.schedulePackageRunTransaction(user, srvr, pkgs,
                new Date());
        assertTrue(action instanceof PackageAction);
        PackageAction pa = (PackageAction) action;
        
        Map params = new HashMap();
        params.put("action_id", pa.getId());
        DataResult dr = TestUtils.runTestQuery("package_install_list", params);
        assertEquals(2, dr.size());
    }   
    
    
    public void aTestSchedulePackageDelta() throws Exception {
        User user = UserFactory.lookupById(new Long(3567268));
        Server srvr = ServerFactory.lookupById(new Long(1005385254));
        RhnSetDecl.PACKAGES_FOR_SYSTEM_SYNC.get(user);
        
        List a = new ArrayList();
        PackageListItem pli = new PackageListItem();
        pli.setIdCombo("3427|195967");
        pli.setEvrId(new Long(195967));
        pli.setName("apr");
        pli.setRelease("0.4");
        pli.setNameId(new Long(3427));
        pli.setEvr("0.9.5-0.4");
        pli.setVersion("0.9.5");
        pli.setEpoch(null);
        a.add(pli);
        
        pli = new PackageListItem();
        pli.setIdCombo("23223|196372");
        pli.setEvrId(new Long(196372));
        pli.setName("bcel");
        pli.setRelease("1jpp_2rh");
        pli.setNameId(new Long(23223));
        pli.setEvr("5.1-1jpp_2rh:0");
        pli.setVersion("5.1");
        pli.setEpoch("0");
        a.add(pli);

        pli = new PackageListItem();
        pli.setIdCombo("500000103|250840");
        pli.setEvrId(new Long(250840));
        pli.setName("aspell");
        pli.setRelease("25.1");
        pli.setNameId(new Long(500000103));
        pli.setEvr("0.33.7.1-25.1:2");
        pli.setVersion("0.33.7.1");
        pli.setEpoch("2");
        a.add(pli);
        
        List b = new ArrayList();
        pli = new PackageListItem();
        pli.setIdCombo("26980|182097");
        pli.setEvrId(new Long(182097));
        pli.setName("asm");
        pli.setRelease("2jpp");
        pli.setNameId(new Long(26980));
        pli.setEvr("1.4.1-2jpp:0");
        pli.setVersion("1.4.1");
        pli.setEpoch("0");
        b.add(pli);
        
        pli = new PackageListItem();
        pli.setIdCombo("500000103|271970");
        pli.setEvrId(new Long(271970));
        pli.setName("aspell");
        pli.setRelease("25.3");
        pli.setNameId(new Long(500000103));
        pli.setEvr("0.33.7.1-25.3:2");
        pli.setVersion("0.33.7.1");
        pli.setEpoch("2");
        b.add(pli);
        
        pli = new PackageListItem();
        pli.setIdCombo("23223|700004953");
        pli.setEvrId(new Long(700004953));
        pli.setName("bcel");
        pli.setRelease("10");
        pli.setNameId(new Long(23223));
        pli.setEvr("5.0-10");
        pli.setVersion("5.0");
        pli.setEpoch(null);
        b.add(pli);
        
        List pkgs = ProfileManager.comparePackageLists(new DataResult(a),
                new DataResult(b), "foo");
        
        for (Iterator itr = pkgs.iterator(); itr.hasNext();) {
            PackageMetadata pm = (PackageMetadata) itr.next();
            log.warn("pm [" + pm.toString() + "] compare [" +
                    pm.getComparison() + "] release [" +
                    (pm.getSystem() != null ? pm.getSystem().getRelease() :
                        pm.getOther().getRelease()) + "]");
        }
//        assertEquals(1, diff.size());
//        PackageMetadata pm = (PackageMetadata) diff.get(0);
//        assertNotNull(pm);
//        assertEquals(PackageMetadata.KEY_OTHER_NEWER, pm.getComparisonAsInt());
//        assertEquals("kernel-2.4.22-27.EL-bretm", pm.getProfileEvr());
//        assertEquals("kernel-2.4.21-27.EL", pm.getSystemEvr());
        
        Action action = ActionManager.schedulePackageRunTransaction(user, srvr, pkgs,
                new Date());
        System.out.println("Action is an [" + action.getClass().getName() + "]");
        //1005385254&set_label=packages_for_system_sync&prid=6110jjj
        /*
         * INSERT INTO rhnPackageDeltaElement
  (package_delta_id, transaction_package_id)
VALUES
  (:delta_id,
   lookup_transaction_package(:operation, :n, :e, :v, :r, :a))

         */
    }
    
    //schedulePackageDelta
}
