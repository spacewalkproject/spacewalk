/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.manager.ssm.test;

import java.util.Map;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.manager.ssm.SsmOperationManager;
import com.redhat.rhn.manager.ssm.SsmOperationStatus;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * @author Jason Dobies
 * @version $Revision$
 */
public class SsmOperationManagerTest extends RhnBaseTestCase {

    private User ssmUser;
    private String setLabel;

    protected void setUp() throws Exception {
        ssmUser = UserTestUtils.findNewUser("ssmuser", "ssmorg");
        setLabel = populateRhnSet();
    }

    public void testCreateAndAllOperations() throws Exception {
        // Test
        SsmOperationManager.createOperation(ssmUser, "Test operation", setLabel);

        DataResult result = SsmOperationManager.allOperations(ssmUser);

        // Verify
        assertNotNull(result);
        assertEquals(1, result.size());
    }

    public void testCreateCompleteAndInProgressOperations() throws Exception {
        // Test
        long completeMeId =
            SsmOperationManager.createOperation(ssmUser, "Test operation 1", setLabel);
        SsmOperationManager.createOperation(ssmUser, "Test operation 2", setLabel);

        SsmOperationManager.completeOperation(ssmUser, completeMeId);

        // Verify

        //   Verify counts for all and in progress operations
        DataResult all = SsmOperationManager.allOperations(ssmUser);
        DataResult inProgress = SsmOperationManager.inProgressOperations(ssmUser);

        assertEquals(2, all.size());
        assertEquals(1, inProgress.size());

        //   Verify the completed operation has its progress set to 100
        for (int ii = 0; ii < all.size(); ii++) {
            Map<String, Object> operation = (Map<String, Object>) all.get(ii);

            if (operation.get("id").equals(completeMeId)) {
                assertEquals(SsmOperationStatus.COMPLETED.getText(),
                    operation.get("status"));
                assertEquals(100L, operation.get("progress"));
            }
        }
    }

    public void testCreateAndFindOperation() throws Exception {
        // Test
        long operationId =
            SsmOperationManager.createOperation(ssmUser, "Test operation 1", setLabel);
        
        DataResult operation = SsmOperationManager.findOperationById(ssmUser, operationId);
        
        // Verify
        assertNotNull(operation);
        assertEquals(1, operation.size());
        
        Map<String, Object> operationData = (Map<String, Object>) operation.get(0);
        
        assertEquals("Test operation 1", operationData.get("description"));
        assertEquals(0L, operationData.get("progress"));
        assertEquals(SsmOperationStatus.IN_PROGRESS.getText(), operationData.get("status"));
        assertNotNull(operationData.get("started"));
        assertNotNull(operationData.get("modified"));
    }

    public void testFindNonExistentOperation() {
        // Test
        DataResult result = SsmOperationManager.findOperationById(ssmUser, 100000L);

        // Verify
        assertNotNull(result);
        assertEquals(0, result.size());
    }

    public void testFindServerDataForOperation() throws Exception {
        // Setup
        long operationId =
            SsmOperationManager.createOperation(ssmUser, "Test operation", setLabel);
        
        // Test
        DataResult result = SsmOperationManager.findServerDataForOperation(operationId);

        // Verify
        assertNotNull(result);
        assertEquals(2, result.size());
        
        Map serverData = (Map) result.get(0);
        assertNotNull(serverData.get("id"));
        assertNotNull(serverData.get("name"));
    }
    
    /**
     * Populates an RhnSet with server IDs.
     * 
     * @return label referencing the set that was populated
     * @throws Exception if there is an error creating a server
     */
    private String populateRhnSet() throws Exception {
        RhnSetDecl setDecl =
            RhnSetDecl.findOrCreate("SsmOperationManagerTestSet", SetCleanup.NOOP);
        RhnSet set = setDecl.create(ssmUser);
        
        for (int ii = 0; ii < 2; ii++) {
            Server testServer = ServerFactoryTest.createTestServer(ssmUser, true);
            set.addElement(testServer.getId());
        }

        RhnSetManager.store(set);
        
        return set.getLabel();
    }
}
