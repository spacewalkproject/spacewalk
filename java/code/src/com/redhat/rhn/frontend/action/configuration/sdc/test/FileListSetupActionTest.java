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
package com.redhat.rhn.frontend.action.configuration.sdc.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;


public class FileListSetupActionTest extends RhnMockStrutsTestCase {
    
    private void doTheTest(String path, String feature) throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());
        SystemManagerTest.giveCapability(server.getId(), feature, 1L);
        //needed for config revisions
        ConfigTestUtils.giveOrgQuota(user.getOrg());
        
        //create a normal config revision
        ConfigRevision rev1 = ConfigTestUtils.createConfigRevision(user.getOrg());
        
        //create a config revision for a directory
        ConfigFile file2 = ConfigTestUtils
                .createConfigFile(rev1.getConfigFile().getConfigChannel());
        ConfigTestUtils.createConfigRevision(file2, ConfigFileType.dir());
        
        //create a config revision for a local channel
        ConfigChannel local = server.getLocalOverride();
        ConfigFile file3 = ConfigTestUtils.createConfigFile(local);
        ConfigTestUtils.createConfigRevision(file3);
        
        //we have to subscribe the server to the global channel.
        server.subscribe(file2.getConfigChannel());
        SystemManager.storeServer(server);
        
        //test the action
        performAction(path, server.getId(), 3);
    }
    
    private void performAction(String path, Long sid, int expectedSize) {
        setRequestPathInfo(path);
        addRequestParameter("sid", sid.toString());
        actionPerform();
        verifyPageList(ConfigFileNameDto.class);
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertEquals(expectedSize, dr.size());
    }
    
    public void testDeploy() throws Exception {
        doTheTest("/systems/details/configuration/DeployFile",
                            SystemManager.CAP_CONFIGFILES_DEPLOY);
    }
    
    public void testDiff() throws Exception {
        doTheTest("/systems/details/configuration/DiffFile", 
                                SystemManager.CAP_CONFIGFILES_DIFF);
    }
    
    public void testImport() throws Exception {
        doTheTest("/systems/details/configuration/addfiles/ImportFile",
                                    SystemManager.CAP_CONFIGFILES_UPLOAD);
    }

}
