/**
 * Copyright (c) 2008 Red Hat, Inc.
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
import com.redhat.rhn.manager.ssm.SsmOperationManager;
import com.redhat.rhn.manager.ssm.SsmOperationStatus;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * @author Jason Dobies
 * @version $Revision$
 */
public class SsmOperationManagerTest extends RhnBaseTestCase {

    private User ssmUser;

    protected void setUp() throws Exception {
        ssmUser = UserTestUtils.findNewUser("ssmuser", "ssmorg");
    }

    public void testCreateAndAllOperations() {
        // Test
        SsmOperationManager.createOperation(ssmUser, "Test operation");

        DataResult result = SsmOperationManager.allOperations(ssmUser);

        // Verify
        assertNotNull(result);
        assertEquals(1, result.size());
    }

    public void testCreateCompleteAndInProgressOperations() {
        // Test
        SsmOperationManager.createOperation(ssmUser, "Test operation 1");
        SsmOperationManager.createOperation(ssmUser, "Test operation 2");

        DataResult result = SsmOperationManager.allOperations(ssmUser);
        assertNotNull(result);
        assertEquals(2, result.size());

        Map<String, Object> operationData = (Map<String, Object>) result.get(0);
        long operationId = (Long) operationData.get("id");

        SsmOperationManager.completeOperation(ssmUser, operationId);

        // Verify

        //   Verify counts for all and in progress operations
        DataResult all = SsmOperationManager.allOperations(ssmUser);
        DataResult inProgress = SsmOperationManager.inProgressOperations(ssmUser);

        assertEquals(2, all.size());
        assertEquals(1, inProgress.size());

        //   Verify the completed operation has its progress set to 100
        for (int ii = 0; ii < all.size(); ii++) {
            Map<String, Object> operation = (Map<String, Object>) all.get(ii);

            if (operation.get("status").equals(SsmOperationStatus.COMPLETED.getText())) {
                assertEquals(100L, operation.get("progress"));
            }
        }
    }

    public void testCreateAndFindOperation() {
        // Test
        SsmOperationManager.createOperation(ssmUser, "Test operation 1");
        
        DataResult result = SsmOperationManager.allOperations(ssmUser);
        assertNotNull(result);
        assertEquals(1, result.size());

        Map<String, Object> operationData = (Map<String, Object>) result.get(0);
        long operationId = (Long) operationData.get("id");
        
        DataResult operation = SsmOperationManager.findOperationById(ssmUser, operationId);
        
        // Verify
        assertNotNull(operation);
        assertEquals(1, operation.size());
        
        operationData = (Map<String, Object>) operation.get(0);
        
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
}
