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
package com.redhat.rhn.domain.action.config.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.config.ConfigChannelAssociation;
import com.redhat.rhn.domain.action.config.ConfigDateFileAction;
import com.redhat.rhn.domain.action.config.ConfigUploadMtimeAction;
import com.redhat.rhn.domain.action.server.test.ServerActionTest;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * ConfigUploadActionTest
 * @version $Rev$
 */
public class ConfigUploadMtimeActionTest extends RhnBaseTestCase {

    /**
     * Test fetching a ConfigUploadAction
     * @throws Exception
     */
    public void testLookupConfigUploadAction() throws Exception {
        Action newA = ActionFactoryTest.createAction(UserTestUtils.createUser("testUser",
                UserTestUtils.createOrg("testOrg")), ActionFactory
                .TYPE_CONFIGFILES_MTIME_UPLOAD);
        Long id = newA.getId();
        Action a = ActionFactory.lookupById(id);

        assertNotNull(a);
        assertTrue(a instanceof ConfigUploadMtimeAction);
        ConfigUploadMtimeAction cfa = (ConfigUploadMtimeAction) a;
        assertNotNull(cfa.getConfigDateFileActions());
        ConfigDateFileAction cfda = (ConfigDateFileAction)
            cfa.getConfigDateFileActions().toArray()[0];
        assertNotNull(cfda.getParentAction());
        // Check the ConfigChannel
        assertNotNull(cfa.getConfigChannels());
        ConfigChannel cc = cfa.getConfigChannels()[0];
        assertNotNull(cc.getId());
        // Check the Server
        assertNotNull(cfa.getServers());
        Server serv = cfa.getServers()[0];
        assertNotNull(serv.getId());
        assertNotNull(((ConfigChannelAssociation)
                cfa.getRhnActionConfigChannel().toArray()[0]).getParentAction().getId());
        assertNotNull(((ConfigChannelAssociation)
                cfa.getRhnActionConfigChannel().toArray()[0]).getServer().getId());
        assertNotNull(((ConfigChannelAssociation)
                cfa.getRhnActionConfigChannel().toArray()[0]).getConfigChannel().getId());
        // Check the ConfigDateDetails
        assertNotNull(cfa.getConfigDateDetails().getActionId());
    }

    public void testCreate() throws Exception {
        User usr = UserTestUtils.findNewUser("testUser", "testOrg");

        ConfigUploadMtimeAction testAction = (ConfigUploadMtimeAction)ActionFactoryTest
                .createAction(usr, ActionFactory.TYPE_CONFIGFILES_MTIME_UPLOAD);

        ConfigDateFileAction cfda = new ConfigDateFileAction();
        cfda.setFileName("/tmp/rhn-java-" + TestUtils.randomString());
        cfda.setFileType("W");
        testAction.addConfigDateFileAction(cfda);

        Server newS = ServerFactoryTest.createTestServer(usr);
        ConfigTestUtils.giveOrgQuota(usr.getOrg());
        ConfigRevision cr = ConfigTestUtils.createConfigRevision(usr.getOrg());

        testAction.addConfigChannelAndServer(cr.getConfigFile()
                .getConfigChannel(), newS);
        // rhnActionConfigChannel requires a ServerAction to exist
        testAction.addServerAction(ServerActionTest.createServerAction(newS, testAction));

        ActionFactory.save(testAction);
        flushAndEvict(testAction);
        /**
         * Get action back out of db and make sure it committed correctly
         */
        Action same = ActionFactory.lookupById(testAction.getId());

        assertTrue(same instanceof ConfigUploadMtimeAction);
        ConfigUploadMtimeAction sameAction = (ConfigUploadMtimeAction) same;

        assertNotNull(sameAction.getConfigDateFileActions());
        assertEquals(2, sameAction.getConfigDateFileActions().size());
        assertNotNull(sameAction.getConfigDateFileActions().toArray()[0]);
        assertNotNull(sameAction.getConfigDateFileActions().toArray()[1]);

        assertNotNull(sameAction.getRhnActionConfigChannel());
        assertEquals(2, sameAction.getRhnActionConfigChannel().size());
        assertNotNull(sameAction.getRhnActionConfigChannel().toArray()[0]);
        assertNotNull(sameAction.getRhnActionConfigChannel().toArray()[1]);

        assertNotNull(sameAction.getConfigDateDetails());
        assertEquals(sameAction.getName(), testAction.getName());
        assertEquals(sameAction.getId(), testAction.getId());
    }

}
