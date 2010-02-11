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
package com.redhat.rhn.domain.action.test;

import com.redhat.rhn.common.util.test.TimeUtilsTest;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigDateDetails;
import com.redhat.rhn.domain.action.config.ConfigDateFileAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionActionResult;
import com.redhat.rhn.domain.action.config.ConfigUploadAction;
import com.redhat.rhn.domain.action.config.ConfigUploadMtimeAction;
import com.redhat.rhn.domain.action.config.DaemonConfigAction;
import com.redhat.rhn.domain.action.config.DaemonConfigDetails;
import com.redhat.rhn.domain.action.errata.ErrataAction;
import com.redhat.rhn.domain.action.kickstart.KickstartAction;
import com.redhat.rhn.domain.action.kickstart.KickstartActionDetails;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.rhnpackage.PackageActionDetails;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageEvr;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Hibernate;

import java.util.Date;
import java.util.Iterator;

/**
 * ActionFactoryTest
 * @version $Rev$
 */
public class ActionFactoryTest extends RhnBaseTestCase {

    /**
     * Test fetching an Action 
     * @throws Exception
     */
    public void testLookup() throws Exception {

        Action a = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_HARDWARE_REFRESH_LIST);
        assertTrue(a.getActionType().equals(ActionFactory.TYPE_HARDWARE_REFRESH_LIST));
        Long id = a.getId();
        Action a2 = ActionFactory.lookupById(id);
        assertNotNull(a2);
        assertTrue(a2.getName().startsWith("RHN-JAVA Test Action"));
    }

    /**
     * Test fetching an Action 
     * @throws Exception
     */
    public void testLookupLastCompletedAction() throws Exception {
        final User user = UserTestUtils.createUser("testUser", 
                                            UserTestUtils .createOrg("testOrg"));

        
        ConfigAction a = (ConfigAction)createAction(user,
                                            ActionFactory.TYPE_CONFIGFILES_DEPLOY);
        assertTrue(a.getActionType().equals(ActionFactory.TYPE_CONFIGFILES_DEPLOY));
        //complete it
        assertNotNull(a.getServerActions());
        for (Iterator itr = a.getServerActions().iterator(); itr.hasNext();) {
            ServerAction next = (ServerAction) itr.next();
            next.setCompletionTime(new Date());
            next.setStatus(ActionFactory.STATUS_COMPLETED);
        }
        ActionFactory.save(a);
        ConfigRevisionAction cra = (ConfigRevisionAction) a.
                                                        getConfigRevisionActions().
                                                            iterator().next();
        Server server = cra.getServer();

        Action action = ActionFactory.lookupLastCompletedAction(user,
                                            ActionFactory.TYPE_CONFIGFILES_DEPLOY,
                                                        server);       
        assertEquals(a, action);
    }    
    
    /**
     * Test fetching an Action with the logged in User
     * @throws Exception
     */
    public void testLookupWithLoggedInUser() throws Exception {

        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        Action a = createAction(user1, ActionFactory.TYPE_HARDWARE_REFRESH_LIST);
        Long id = a.getId();
        Action a2 = ActionFactory.lookupByUserAndId(user1, id);
        assertNotNull(a2);
        // Check to make sure it returns NULL
        // if we lookup with a User who isnt part of the
        // Org that owns that Action.  Ignore for 
        // Sat mode since there is only one Org.
    }
    
    /**
     * Test fetching a ScriptAction 
     * @throws Exception
     */
    public void testLookupScriptAction() throws Exception {
        Action newA = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_SCRIPT_RUN);
        Long id = newA.getId();
        Action a = ActionFactory.lookupById(id);

        assertNotNull(a);
        assertTrue(a instanceof ScriptRunAction);
        ScriptRunAction s = (ScriptRunAction) a;
        assertNotNull(s.getScriptActionDetails().getUsername());     
        assertNotNull(s.getEarliestAction());
    }


    /**
     * Test fetching a ScriptAction 
     * @throws Exception
     */
    public void testSchedulerUser() throws Exception {
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        Action newA = createAction(user1, ActionFactory.TYPE_REBOOT);
        newA.setSchedulerUser(user1);
        ActionFactory.save(newA);

        assertNotNull(newA.getSchedulerUser());
    }
    
    /**
     * Test fetching a ConfigRevisionAction 
     * @throws Exception
     */
    public void testLookupErrataAction() throws Exception {
        Action newA = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_ERRATA);
        assertNotNull(newA.getId());
        assertTrue(newA instanceof ErrataAction);
        ErrataAction ea = (ErrataAction) newA;
        assertNotNull(ea.getErrata());
        assertNotNull(((Errata) ea.getErrata().toArray()[0]).getId());
    }

    /**
     * Test fetching a DaemonConfigDetails
     * @throws Exception
     */
    public void testLookupDaemonConfig() throws Exception {
        Action newA = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_DAEMON_CONFIG);
        Long id = newA.getId();
        Action a = ActionFactory.lookupById(id);
        assertNotNull(a);
        assertTrue(a instanceof DaemonConfigAction);
        DaemonConfigAction dca = (DaemonConfigAction) a;
        assertNotNull(dca.getId());
        assertNotNull(dca.getDaemonConfigDetails());
        assertNotNull(dca.getDaemonConfigDetails().getActionId());
    }

    public void testAddServerToAction() throws Exception {
        User usr = UserTestUtils.createUser("testUser", 
                UserTestUtils.createOrg("testOrg"));
        Server s = ServerFactoryTest.createTestServer(usr);
        Action a = createAction(usr, ActionFactory.TYPE_ERRATA);
        ActionFactory.addServerToAction(s.getId(), a);
        
        assertNotNull(a.getServerActions());
        assertEquals(a.getServerActions().size(), 1);
        Object[] array = a.getServerActions().toArray();
        ServerAction sa = (ServerAction)array[0];
        assertTrue(TimeUtilsTest.timeEquals(sa.getCreated().getTime(),
                sa.getModified().getTime()));
        assertTrue(sa.getStatus().equals(ActionFactory.STATUS_QUEUED));
        
        assertTrue(sa.getServer().equals(s));
    }
    
    public void testLookupConfigRevisionAction() throws Exception {
        User usr = UserTestUtils.createUser("testUser", 
                            UserTestUtils.createOrg("testOrg"));
        
        Action newA = ActionFactory.createAction(ActionFactory.TYPE_CONFIGFILES_DIFF);
        newA.setOrg(usr.getOrg());

        ConfigTestUtils.giveOrgQuota(usr.getOrg());
        newA.setSchedulerUser(usr);

        Server newS = ServerFactoryTest.createTestServer(usr, true);
        ConfigRevisionAction crad = new ConfigRevisionAction();

        crad.setParentAction(newA);
        crad.setServer(newS);
        crad.setCreated(new Date());
        crad.setModified(new Date());

        // Create ConfigRevision
        ConfigTestUtils.giveOrgQuota(usr.getOrg());
        ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());
        crad.setConfigRevision(cr);
        ConfigAction ca = (ConfigAction) newA;
        ca.addConfigRevisionAction(crad);
        ca.addServerAction(createServerAction(newS, newA));
        ActionFactory.save(ca);
        Long id = crad.getId();
        ConfigRevisionAction result = ActionFactory.lookupConfigRevisionAction(id);
        assertEquals(crad.getId(), result.getId());
        assertEquals(crad.getServer(), result.getServer());
        assertEquals(crad.getCreated(), result.getCreated());
        
    }    
    
    public void testLookupConfigRevisionResult() throws Exception {
        User usr = UserTestUtils.createUser("testUser", 
                            UserTestUtils.createOrg("testOrg"));
        
        Action newA = ActionFactory.createAction(ActionFactory.TYPE_CONFIGFILES_DIFF);
        newA.setOrg(usr.getOrg());

        ConfigTestUtils.giveOrgQuota(usr.getOrg());
        newA.setSchedulerUser(usr);

        Server newS = ServerFactoryTest.createTestServer(usr, true);
        ConfigRevisionAction crad = new ConfigRevisionAction();

        crad.setParentAction(newA);
        crad.setServer(newS);
        crad.setCreated(new Date());
        crad.setModified(new Date());

        // Setup the CRAResult
        ConfigRevisionActionResult cresult = new ConfigRevisionActionResult();
        cresult.setCreated(new Date());
        cresult.setModified(new Date());
        byte [] text = "Differed In Foo ".getBytes("UTF-8");
        cresult.setResultBlob(Hibernate.createBlob(text));
        cresult.setConfigRevisionAction(crad);
        crad.setConfigRevisionActionResult(cresult);
        // Create ConfigRevision
        ConfigTestUtils.giveOrgQuota(usr.getOrg());
        ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());
        crad.setConfigRevision(cr);
        ConfigAction ca = (ConfigAction) newA;
        ca.addConfigRevisionAction(crad);
        ca.addServerAction(createServerAction(newS, newA));
        ActionFactory.save(ca);
        Long id = crad.getId();
        ConfigRevisionActionResult newResult = ActionFactory.
                                lookupConfigActionResult(id);
        
        assertEquals(cresult.getResultContents(), newResult.getResultContents());
        assertEquals(cresult.getActionConfigRevisionId(), 
                                newResult.getActionConfigRevisionId());

    }
    
    public void testRescheduleFailedServerActions() throws Exception {
        
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ServerAction sa = (ServerAction) a1.getServerActions().toArray()[0];
        
        sa.setStatus(ActionFactory.STATUS_FAILED);
        sa.setRemainingTries(new Long(0));
        ActionFactory.save(a1);
        
        ActionFactory.rescheduleFailedServerActions(a1, 5L);
        sa = (ServerAction) ActionFactory.reload(sa);
        
        assertTrue(sa.getStatus().equals(ActionFactory.STATUS_QUEUED));
        assertTrue(sa.getRemainingTries().longValue() > 0);
        
    }
    
    public void testRescheduleAllServerActions() throws Exception {
        
        User user1 = UserTestUtils.findNewUser("testUser", "testOrg");
        Action a1 = ActionFactoryTest.createAction(user1, ActionFactory.TYPE_REBOOT);
        ServerAction sa = (ServerAction) a1.getServerActions().toArray()[0];
        
        sa.setStatus(ActionFactory.STATUS_FAILED);
        sa.setRemainingTries(new Long(0));
        ActionFactory.save(a1);
        
        ActionFactory.rescheduleAllServerActions(a1, 5L);
        sa = (ServerAction) ActionFactory.reload(sa);
        
        assertTrue(sa.getStatus().equals(ActionFactory.STATUS_QUEUED));
        assertTrue(sa.getRemainingTries().longValue() > 0);
        
    }
    
    
    
    
    public void testCreateAction() throws Exception {
        Action a = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_HARDWARE_REFRESH_LIST);
        assertNotNull(a);
    }

    public void testCheckActionArchType() throws Exception {
        Action newA = createAction(UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")), ActionFactory.TYPE_PACKAGES_VERIFY);
        assertTrue(ActionFactory.checkActionArchType(newA, "verify"));
    }
    
    public static Action createAction(User usr, ActionType type) throws Exception {
        Action newA = ActionFactory.createAction(type);
        Long orgId = usr.getOrg().getId();
        newA.setSchedulerUser(usr);
        if (type.equals(ActionFactory.TYPE_ERRATA)) {
            Errata e1 = ErrataFactoryTest.createTestErrata(orgId);
            Errata e2 = ErrataFactoryTest.createTestErrata(orgId);
            // add the errata
            ((ErrataAction) newA).addErrata(e1);
            ((ErrataAction) newA).addErrata(e2);
        }
        else if (type.equals(ActionFactory.TYPE_CONFIGFILES_MTIME_UPLOAD)) {
            ConfigUploadMtimeAction cua = (ConfigUploadMtimeAction) newA;
            ConfigDateFileAction cfda = new ConfigDateFileAction();
            cfda.setFileName("/tmp/rhn-java-" + TestUtils.randomString());
            cfda.setFileType("W");
            cfda.setCreated(new Date());
            cfda.setModified(new Date());
            cua.addConfigDateFileAction(cfda);
            
            Server newS = ServerFactoryTest.createTestServer(usr);
            ConfigTestUtils.giveOrgQuota(usr.getOrg());
            ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());
            cua.addConfigChannelAndServer(cr.getConfigFile().getConfigChannel(), newS);
            // rhnActionConfigChannel requires a ServerAction to exist
            cua.addServerAction(ServerActionTest.createServerAction(newS, newA));
            ConfigDateDetails cdd = new ConfigDateDetails();
            cdd.setCreated(new Date());
            cdd.setModified(new Date());
            cdd.setStartDate(new Date());
            cdd.setImportContents("Y");
            cdd.setParentAction(cua);
            cua.setConfigDateDetails(cdd);
        }
        else if (type.equals(ActionFactory.TYPE_CONFIGFILES_UPLOAD)) {
            ConfigUploadAction cua = (ConfigUploadAction) newA;
            Server newS = ServerFactoryTest.createTestServer(usr);
            
            ConfigTestUtils.giveOrgQuota(usr.getOrg());
            ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());
            cua.addConfigChannelAndServer(cr.getConfigFile().getConfigChannel(), newS);
            cua.addServerAction(ServerActionTest.createServerAction(newS, newA));
            
            ConfigFileName name1 =
                ConfigurationFactory.lookupOrInsertConfigFileName("/etc/foo");
            ConfigFileName name2 =
                ConfigurationFactory.lookupOrInsertConfigFileName("/etc/bar");
            cua.addConfigFileName(name1, newS);
            cua.addConfigFileName(name2, newS);
        }
        else if (type.equals(ActionFactory.TYPE_CONFIGFILES_DEPLOY)) {
            Server newS = ServerFactoryTest.createTestServer(usr, true);
            ConfigRevisionAction crad = new ConfigRevisionAction();
            crad.setParentAction(newA);
            crad.setServer(newS);
            crad.setCreated(new Date());
            crad.setModified(new Date());

            // Setup the CRAResult
            ConfigRevisionActionResult cresult = new ConfigRevisionActionResult();
            cresult.setCreated(new Date());
            cresult.setModified(new Date());
            cresult.setConfigRevisionAction(crad);
            crad.setConfigRevisionActionResult(cresult);
            // Create ConfigRevision
            ConfigTestUtils.giveOrgQuota(usr.getOrg());
            ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());
            crad.setConfigRevision(cr);
            ConfigAction ca = (ConfigAction) newA;
            ca.addConfigRevisionAction(crad);
            ca.addServerAction(createServerAction(newS, newA));
        }
        else if (type.equals(ActionFactory.TYPE_SCRIPT_RUN)) {
            ScriptActionDetails sad = new ScriptActionDetails();
            sad.setUsername("AFTestTestUser");
            sad.setGroupname("AFTestTestGroup");
            String script = "#!/bin/csh\nls -al";
            sad.setScript(script.getBytes("UTF-8"));
            sad.setTimeout(new Long(9999));
            sad.setParentAction(newA);
            ((ScriptRunAction) newA).setScriptActionDetails(sad);
        }
        else if (type.equals(ActionFactory.TYPE_KICKSTART_INITIATE) ||
                type.equals(ActionFactory.TYPE_KICKSTART_SCHEDULE_SYNC)) {
            KickstartActionDetails ksad = new KickstartActionDetails();
            ksad.setStaticDevice("eth0");
            ksad.setParentAction(newA);
            ((KickstartAction) newA).setKickstartActionDetails(ksad);
        }
        else if (type.equals(ActionFactory.TYPE_PACKAGES_AUTOUPDATE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_DELTA) ||
                type.equals(ActionFactory.TYPE_PACKAGES_REFRESH_LIST) ||
                type.equals(ActionFactory.TYPE_PACKAGES_REMOVE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_RUNTRANSACTION) ||
                type.equals(ActionFactory.TYPE_PACKAGES_UPDATE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_VERIFY)) {

            PackageActionDetails d = new PackageActionDetails();
            String parameter = "upgrade";
            d.setParameter(parameter);
       
            //create packageArch
            Long testid = new Long(100);
            String query = "PackageArch.findById";
            PackageArch arch = (PackageArch) TestUtils.lookupFromCacheById(testid, query);
            d.setArch(arch);
  
            //create packageName
            String testname = "Test Name " + TestUtils.randomString();
            PackageName name = new PackageName();
            name.setName(testname);
            d.setPackageName(name);
       
            //create packageEvr
            PackageEvr evr = new PackageEvr();
            evr.setEpoch("" + System.currentTimeMillis());
            evr.setRelease("1.0");
            evr.setVersion("2.0");

            d.setEvr(evr);
            ((PackageAction) newA).addDetail(d);
        }
        // Here we specifically want to test the addition of the ServerAction details
        // objects.
        else if (type.equals(ActionFactory.TYPE_REBOOT)) {
            usr.addRole(RoleFactory.ORG_ADMIN);
            Server newS = ServerFactoryTest.createTestServer(usr, true);
            newA.addServerAction(ServerActionTest.createServerAction(newS, newA));
        } 
        else if (type.equals(ActionFactory.TYPE_DAEMON_CONFIG)) {
            DaemonConfigDetails dcd = new DaemonConfigDetails();
            dcd.setRestart("Y");
            dcd.setInterval(new Long(1440));
            dcd.setDaemonConfigCreated(new Date());
            dcd.setDaemonConfigModified(new Date());
            dcd.setParentAction(newA);
            ((DaemonConfigAction) newA).setDaemonConfigDetails(dcd);
        }

        newA.setName("RHN-JAVA Test Action");
        newA.setActionType(type);
        newA.setOrg(usr.getOrg());
        newA.setEarliestAction(new Date());
        newA.setVersion(new Long(0));
        newA.setArchived(new Long(0));
        newA.setCreated(new Date());
        newA.setModified(new Date());
        ActionFactory.save(newA);
        return newA;
    }

    /**
     * Create a new ServerAction
     * @param newS
     * @param newA
     * @return ServerAction created
     * @throws Exception
     */
    public static ServerAction createServerAction(Server newS, Action newA) 
        throws Exception {
        ServerAction sa = new ServerAction();
        sa.setStatus(ActionFactory.STATUS_QUEUED);
        sa.setRemainingTries(new Long(10));
        sa.setCreated(new Date());
        sa.setModified(new Date());
        sa.setServer(newS);
        sa.setParentAction(newA);
        return sa;
    }
}


