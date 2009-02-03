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
package com.redhat.rhn.manager.ssm;

import java.util.HashMap;
import java.util.Map;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BaseManager;

/**
 * Handles the tracking of SSM asynchronous operations, providing functionality for
 * the creation, update, and retrieval of the data.
 *
 * @author Jason Dobies
 * @version $Revision$
 */
public class SsmOperationManager extends BaseManager {

    private final Log log = LogFactory.getLog(this.getClass());

    /**
     * Private constructor to enforce static nature of the class.
     */
    private SsmOperationManager() {
    }

    /**
     * Returns a list of all operations for the given user, regardless of their status.
     *
     * @param user operations returned only for this user; cannot be <code>null</code>
     * @return list of maps containing the data describing each operation
     */
    public static DataResult allOperations(User user) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        SelectMode m = ModeFactory.getMode("ssm_queries", "find_all_operations");

        Map<String, Object> params = new HashMap<String, Object>(1);
        params.put("user_id", user.getId());

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Returns a list of all operations for the given user that are currently executing.
     *
     * @param user operations returned only for this user; cannot be <code>null</code>
     * @return list of maps containing the data describing each matching operation
     */
    public static DataResult inProgressOperations(User user) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        SelectMode m = ModeFactory.getMode("ssm_queries", "find_operations_with_status");

        Map<String, Object> params = new HashMap<String, Object>(2);
        params.put("user_id", user.getId());
        params.put("status", SsmOperationStatus.IN_PROGRESS.getText());

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Returns the details of the given operation.
     *
     * @param user        verifies that the user isn't trying to load someone else's
     *                    operation; cannot be <code>null</code>
     * @param operationId database ID of the operation to load
     * @return list of size 1 if the operation was found, containing a map of database
     *         column to value for the given operation; list of size 0 if no matches
     *         were found in the database
     */
    public static DataResult findOperationById(User user, long operationId) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }
        
        SelectMode m = ModeFactory.getMode("ssm_queries", "find_operation_by_id");

        Map<String, Object> params = new HashMap<String, Object>(2);
        params.put("user_id", user.getId());
        params.put("op_id", operationId);

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Creates a new operation, defaulting the status to "in progress" and the progress
     * of the operation to 0.
     *
     * @param user        user under which to associate the operation; cannot be
     *                    <code>null</code>
     * @param description high level description of what the operation is doing;
     *                    cannot be <code>null</code>
     */
    public static void createOperation(User user, String description) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        if (description == null) {
            throw new IllegalArgumentException("description cannot be null");
        }
        
        WriteMode m = ModeFactory.getWriteMode("ssm_queries", "create_operation");

        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("user_id", user.getId());
        params.put("description", description);
        params.put("status", SsmOperationStatus.IN_PROGRESS.getText());

        m.executeUpdate(params);
    }

    /**
     * Indicates the operation has completed, updating its status and progress completed
     * values to indicate this.
     * 
     * @param user        verifies that the user isn't trying to load someone else's
     *                    operation; cannot be <code>null</code>
     * @param operationId database ID of the operation to update
     */
    public static void completeOperation(User user, long operationId) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }
        
        WriteMode m = ModeFactory.getWriteMode("ssm_queries", "update_status_and_progress");

        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("user_id", user.getId());
        params.put("op_id", operationId);
        params.put("status", SsmOperationStatus.COMPLETED.getText());
        params.put("progress", 100);

        m.executeUpdate(params);
    }
}

