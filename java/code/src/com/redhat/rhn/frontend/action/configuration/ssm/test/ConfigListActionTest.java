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
package com.redhat.rhn.frontend.action.configuration.ssm.test;

import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * DiffActionTest
 * @version $Rev$
 */
public class ConfigListActionTest extends RhnMockStrutsTestCase {
    
    private void doTheTest(String path) throws Exception {
        //give the user org_admin role.
        UserTestUtils.addUserRole(user, RoleFactory.CONFIG_ADMIN);
        UserTestUtils.addProvisioning(user.getOrg());
        
        //create the revision, file, and channel.
        ConfigRevision revision = ConfigTestUtils.createConfigRevision(user.getOrg());
        revision.getConfigFile().setLatestConfigRevision(revision);
        ConfigurationFactory.commit(revision);
        
        //create a server and add it to the two required server groups
        //provisioning for config management and enterprise for server grouping
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeEnterpriseEntitled());
        ServerGroup group = ServerGroupTest.createTestServerGroup(user.getOrg(),
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        ServerFactory.addServerToGroup(server, group);
        server.subscribe(revision.getConfigFile().getConfigChannel());
        ServerFactory.save(server);
        
        //add the server to the system list and save.
        RhnSet set = RhnSetDecl.SYSTEMS.get(user);
        set.addElement(server.getId());
        RhnSetFactory.save(set);
        
        //perform the action we are testing.
        setRequestPathInfo(path);
        actionPerform();
        verifyPageList(ConfigFileNameDto.class);
    }
    
    public void testExecute() throws Exception {
        doTheTest("/systems/ssm/config/Diff");
        doTheTest("/systems/ssm/config/Deploy");
    }
}

