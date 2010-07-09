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
package com.redhat.rhn.domain.action.script.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptResult;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * ScriptActionTest
 * Test suite for ScriptAction and ScriptResult
 * @version $Rev$
 */
public class ScriptRunActionTest extends RhnBaseTestCase {

    public void testScriptAction() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Action newA = ActionFactoryTest.createAction(usr,
                                                     ActionFactory.TYPE_SCRIPT_RUN);
        Long id = newA.getId();
        assertTrue(newA instanceof ScriptRunAction);
        ScriptRunAction action = (ScriptRunAction) newA;

        ScriptResult result1 = new ScriptResult();
        Server s1 = ServerFactoryTest.createTestServer(usr);
        result1.setServerId(s1.getId());
        result1.setReturnCode(new Long(1));
        result1.setStartDate(new Date());
        Calendar futureCal = GregorianCalendar.getInstance();
        futureCal.set(2050, 12, 14);
        result1.setStopDate(futureCal.getTime());

        Server s2 = ServerFactoryTest.createTestServer(usr);
        ScriptResult result2 = new ScriptResult();
        result2.setServerId(s2.getId());
        result2.setReturnCode(new Long(1));
        result2.setStartDate(new Date());
        result2.setStopDate(futureCal.getTime());

        ScriptActionDetails sad = action.getScriptActionDetails();
        result1.setActionScriptId(sad.getId());
        result2.setActionScriptId(sad.getId());
        sad.setParentAction(action);
        sad.setUsername("SRTestUser");
        sad.setGroupname("SRTestGroup");
        sad.setTimeout(new Long(9999));
        result1.setParentScriptActionDetails(sad);
        result2.setParentScriptActionDetails(sad);
        sad.addResult(result1);
        sad.addResult(result2);
        String expectedScript = "#!/bin/csh";
        //sad.setScript(expectedScript.getBytes("UTF-8"));
        sad.setScript(expectedScript.getBytes("UTF-8"));
        action.setScriptActionDetails(sad);

        ActionFactory.save(action);
        flushAndEvict(action);
        /**
         * Get action back out of db and make sure
         * getResults().size() is 2
         */
        Action a = ActionFactory.lookupById(id);
        assertTrue(a instanceof ScriptRunAction);
        ScriptRunAction scriptaction = (ScriptRunAction) a;
        assertNotNull(scriptaction.getScriptActionDetails().getId());
        assertNotNull(scriptaction.getScriptActionDetails().getParentAction().getId());
        assertNotNull(scriptaction.getScriptActionDetails().getScript());
        assertNotNull(scriptaction.getScriptActionDetails().getResults());
        assertEquals(2, scriptaction.getScriptActionDetails().getResults().size());

        assertEquals(expectedScript,
                     scriptaction.getScriptActionDetails().getScriptContents());
        assertTrue(scriptaction.getScriptActionDetails().getParentAction()
                .equals(scriptaction));

    }

    public void testScriptActionDetails() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");
        Action newA = ActionFactoryTest.createAction(usr,
                                                     ActionFactory.TYPE_SCRIPT_RUN);
        Long id = newA.getId();
        assertTrue(newA instanceof ScriptRunAction);
        ScriptRunAction action = (ScriptRunAction) newA;

        Date startDate = new Date();
        Calendar futureCal = GregorianCalendar.getInstance();
        futureCal.set(2050, 12, 14);
        Date stopDate = futureCal.getTime();

        ScriptResult result1 = new ScriptResult();
        Server s1 = ServerFactoryTest.createTestServer(usr);
        result1.setServerId(s1.getId());
        result1.setReturnCode(new Long(1));
        result1.setStartDate(startDate);
        result1.setStopDate(stopDate);

        ScriptActionDetails sad = action.getScriptActionDetails();
        result1.setActionScriptId(sad.getId());
        sad.setParentAction(action);
        sad.setUsername("SRTestUser");
        sad.setGroupname("SRTestGroup");
        sad.setTimeout(new Long(9999));
        result1.setParentScriptActionDetails(sad);
        sad.addResult(result1);
        action.setScriptActionDetails(sad);

        ActionFactory.save(action);
        flushAndEvict(action);

        Action a = ActionFactory.lookupById(id);
        ScriptRunAction scriptaction = (ScriptRunAction) a;
        assertEquals(1, scriptaction.getScriptActionDetails().getResults().size());

        ScriptResult lookupResult = (ScriptResult)scriptaction.getScriptActionDetails().
            getResults().iterator().next();
        assertEquals(startDate.getTime() / 1000,
                lookupResult.getStartDate().getTime() / 1000);
        assertEquals(stopDate.getTime() / 1000,
                lookupResult.getStopDate().getTime() / 1000);
    }

}
