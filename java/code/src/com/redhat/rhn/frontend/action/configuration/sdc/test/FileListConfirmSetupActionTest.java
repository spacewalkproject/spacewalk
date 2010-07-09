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
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.test.SystemManagerTest;
import com.redhat.rhn.testing.ConfigTestUtils;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;


/**
 * FileListConfirmSetupActionTest, diff and deploy in sdc config
 * @version $Rev$
 */
public class FileListConfirmSetupActionTest extends RhnMockStrutsTestCase {

    private void runTheTest(String path, RhnSet set, String feature) throws Exception {
        Server server = setupTest(set, feature);
        //test the action
        performAction(path, server.getId(), set.size());
        checkSelectAll(path, server.getId(), set.size(), set);
    }

    /**
     * @param set the set containing the file names
     * @return the server thats setup..
     * @throws Exception under exceptional circumstances
     */
    private Server setupTest(RhnSet set, String feature) throws Exception {
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
        ConfigRevision rev2 = ConfigTestUtils.createConfigRevision(file2,
                ConfigFileType.dir());

        //create a config revision for a local channel
        ConfigChannel local = server.getLocalOverride();
        ConfigFile file3 = ConfigTestUtils.createConfigFile(local);
        ConfigRevision rev3 = ConfigTestUtils.createConfigRevision(file3);

        //put the file names in the set so that they appear in the list.
        set.addElement(rev1.getConfigFile().getConfigFileName().getId());
        set.addElement(rev2.getConfigFile().getConfigFileName().getId());
        set.addElement(rev3.getConfigFile().getConfigFileName().getId());
        RhnSetManager.store(set);

        //we have to subscribe the server to the global channel.
        server.subscribe(file2.getConfigChannel());
        SystemManager.storeServer(server);
        return server;
    }

    private void performAction(String path, Long sid, int expectedSize) {
        setRequestPathInfo(path);
        addRequestParameter("sid", sid.toString());
        actionPerform();
        verifyPageList(ConfigFileNameDto.class);
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertEquals(expectedSize, dr.size());
    }

    private void checkSelectAll(String path, Long sid,
                                int expectedSize, RhnSet set) {
        set.clear();
        RhnSetManager.store(set);
        setRequestPathInfo(path);
        addRequestParameter("sid", sid.toString());
        addRequestParameter("selectall", Boolean.TRUE.toString());
        actionPerform();
        verifyPageList(ConfigFileNameDto.class);
        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertEquals(expectedSize, dr.size());
    }

    public void testDeploy() throws Exception {

        runTheTest("/systems/details/configuration/DeployFileConfirm",
                RhnSetDecl.CONFIG_FILE_NAMES.get(user),
                SystemManager.CAP_CONFIGFILES_DEPLOY);
    }

    public void testDiff() throws Exception {
        runTheTest("/systems/details/configuration/DiffFileConfirm",
                RhnSetDecl.CONFIG_FILE_NAMES.get(user),
                SystemManager.CAP_CONFIGFILES_DIFF);
    }

    public void testImport() throws Exception {
        runTheTest("/systems/details/configuration/addfiles/ImportFileConfirm",
                RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.get(user),
                SystemManager.CAP_CONFIGFILES_UPLOAD);
    }

    public void testImportWithNewPath() throws Exception {
        //create the server
        Server server = ServerFactoryTest.createTestServer(user, true,
                ServerConstants.getServerGroupTypeProvisioningEntitled());

        SystemManagerTest.giveCapability(server.getId(),
                            SystemManager.CAP_CONFIGFILES_UPLOAD, 1L);
        //create a new filename that this server isn't subscribed to
        ConfigFileName name = ConfigurationFactory
                .lookupOrInsertConfigFileName("/etc/foo" + TestUtils.randomString());

        //add the filename to the set
        RhnSet set = RhnSetDecl.CONFIG_IMPORT_FILE_NAMES.get(user);
        set.addElement(name.getId());
        RhnSetManager.store(set);

        //test that the filename appears.
        performAction("/systems/details/configuration/addfiles/ImportFileConfirm",
                server.getId(), 1);
    }
}
