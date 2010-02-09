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
import com.redhat.rhn.domain.action.config.ConfigAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionAction;
import com.redhat.rhn.domain.action.config.ConfigRevisionActionResult;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * ConfigRevisionActionTest
 * @version $Rev$
 */
public class ConfigRevisionActionTest extends RhnBaseTestCase {
    
    public void testBeanMethods() {
        ConfigRevisionAction cra = new ConfigRevisionAction();
        Date now = new Date();
        Long three = new Long(3);
        ConfigAction parent = new ConfigAction();
        Server server = ServerFactory.createServer();
        ConfigRevision revision = ConfigurationFactory.newConfigRevision();
        ConfigRevisionActionResult result = new ConfigRevisionActionResult();
        
        cra.setCreated(now);
        assertTrue(now.equals(cra.getCreated()));
        
        cra.setModified(now);
        assertTrue(now.equals(cra.getModified()));
        
        cra.setFailureId(three);
        assertEquals(three, cra.getFailureId());
        
        cra.setId(three);
        assertEquals(three, cra.getId());
        
        cra.setParentAction(parent);
        assertTrue(parent.equals(cra.getParentAction()));
        
        cra.setServer(server);
        assertTrue(server.equals(cra.getServer()));
        
        cra.setConfigRevision(revision);
        assertTrue(revision.equals(cra.getConfigRevision()));
        
        cra.setConfigRevisionActionResult(result);
        assertTrue(result.equals(cra.getConfigRevisionActionResult()));
    }
    
    /**
     * Test fetching a ConfigRevisionAction 
     * @throws Exception
     */
    public void testLookupConfigRevision() throws Exception {
        User user = UserTestUtils.createUser("testUser", UserTestUtils
                .createOrg("testOrg")); 
        Action a = ActionFactoryTest.createAction(user, 
                   ActionFactory.TYPE_CONFIGFILES_DEPLOY);

        assertNotNull(a);
        assertTrue(a instanceof ConfigAction);
        assertNotNull(a.getActionType());

        ConfigAction a2 = (ConfigAction) ActionFactoryTest.createAction(user,
                          ActionFactory.TYPE_CONFIGFILES_DEPLOY);
        ActionFactory.save(a2);
        ConfigRevisionAction cra = (ConfigRevisionAction)
            a2.getConfigRevisionActions().toArray()[0];
        assertNotNull(cra.getId());
    }
    
    public static ConfigRevisionAction createTestRevision(User user, Action parent) 
                                                                     throws Exception {
        ConfigRevisionAction cra = new ConfigRevisionAction();
        cra.setServer(ServerFactoryTest.createTestServer(user));
        
        ConfigTestUtils.giveOrgQuota(user.getOrg());
        cra.setConfigRevision(ConfigTestUtils.createConfigRevision(user.getOrg()));
        cra.setCreated(new Date());
        cra.setModified(new Date());
        ((ConfigAction) parent).addConfigRevisionAction(cra);
        return cra;
    }

}
