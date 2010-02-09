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
package com.redhat.rhn.manager.ssm;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.BaseManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * Handles the tracking of SSM asynchronous operations, providing functionality for
 * the creation, update, and retrieval of the data.
 *
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

        SelectMode m = ModeFactory.getMode("ssm_operation_queries", "find_all_operations");

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

        SelectMode m =
            ModeFactory.getMode("ssm_operation_queries", "find_operations_with_status");

        Map<String, Object> params = new HashMap<String, Object>(2);
        params.put("user_id", user.getId());
        params.put("status", SsmOperationStatus.IN_PROGRESS.getText());

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Returns a list of all operations for the given user that have completed.
     *
     * @param user operations returned only for this user; cannot be <code>null</code>
     * @return list of maps containing the data describing each matching operation
     */
    public static DataResult completedOperations(User user) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        SelectMode m =
            ModeFactory.getMode("ssm_operation_queries", "find_operations_with_status");

        Map<String, Object> params = new HashMap<String, Object>(2);
        params.put("user_id", user.getId());
        params.put("status", SsmOperationStatus.COMPLETED.getText());

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

        SelectMode m = ModeFactory.getMode("ssm_operation_queries", "find_operation_by_id");

        Map<String, Object> params = new HashMap<String, Object>(2);
        params.put("user_id", user.getId());
        params.put("op_id", operationId);

        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Creates a new operation, defaulting the status to "in progress".
     * <p/>
     * For efficiency, this call assumes the following:
     * <ul>
     * <li>The set of servers that are taking place in the operation are already in the
     * database as an RhnSet (the name of set is passed into this call).</li>
     * <li>The server ID is stored in the first element (i.e. "element" in the set table).
     * </ul>
     * <p/>
     * This should be a safe assumption since, at very least, if all servers are taking
     * place in the operation they are already in the SSM RhnSet. If only a subset
     * is needed, a nested select can be used to drop them into a new set, preventing
     * the need to have another insert per server for this call.
     *
     * @param user        user under which to associate the operation; cannot be
     *                    <code>null</code>
     * @param description high level description of what the operation is doing;
     *                    cannot be <code>null</code>
     * @param rhnSetLabel references a RhnSet with the server IDs to associate with the
     *                    new operation; if this is <code>null</code> no mappings will
     *                    be created at this time
     * @return the id of the created operation
     */
    public static long createOperation(User user, String description,
                                       String rhnSetLabel) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        if (description == null) {
            throw new IllegalArgumentException("description cannot be null");
        }

        SelectMode selectMode;
        WriteMode writeMode;
        Map<String, Object> params = new HashMap<String, Object>();

        // Select the operation ID manually from the sequence so we can add the mappings
        // from the operation to the servers
        selectMode = ModeFactory.getMode("ssm_operation_queries", "get_seq_nextval");
        DataResult nextValResult = selectMode.execute(params);
        Map<String, Object> nextValMap = (Map<String, Object>) nextValResult.get(0);
        long operationId = (Long) nextValMap.get("nextval");

        // Add the operation data
        writeMode = ModeFactory.getWriteMode("ssm_operation_queries", "create_operation");

        params.clear();
        params.put("op_id", operationId);
        params.put("user_id", user.getId());
        params.put("description", description);
        params.put("status", SsmOperationStatus.IN_PROGRESS.getText());

        writeMode.executeUpdate(params);

        // Add the server/operation mappings
        if (rhnSetLabel != null) {
            associateServersWithOperation(operationId, user.getId(), rhnSetLabel);
        }

        return operationId;
    }

    /**
     * Indicates the operation has completed, updating its status to indicate this.
     *
     * @param user        verifies that the user isn't trying to load someone else's
     *                    operation; cannot be <code>null</code>
     * @param operationId database ID of the operation to update
     */
    public static void completeOperation(User user, long operationId) {
        if (user == null) {
            throw new IllegalArgumentException("user cannot be null");
        }

        WriteMode m =
            ModeFactory.getWriteMode("ssm_operation_queries", "update_status");

        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("user_id", user.getId());
        params.put("op_id", operationId);
        params.put("status", SsmOperationStatus.COMPLETED.getText());

        m.executeUpdate(params);
    }

    /**
     * Returns a list of servers that took part in the given SSM operation.
     *
     * @param operationId operation for which to return the server IDs
     * @return list of maps, one per server ID, where each map contains a single
     *         entry (key: server_id) containing the server ID
     */
    public static DataResult findServerDataForOperation(long operationId) {
        SelectMode m = ModeFactory.getMode("ssm_operation_queries",
            "find_server_data_for_operation_id");

        Map<String, Object> params = new HashMap<String, Object>(1);
        params.put("op_id", operationId);

        // list of maps of server_id -> <id>
        DataResult result = m.execute(params);
        return result;
    }

    /**
     * Associates an operation with a group of servers against which it was run, where
     * the servers are found in an RhnSet. The IDs for these servers must be stored in
     * the "element" field of the RhnSet.
     *
     * @param operationId identifies an existing operation to associate with servers
     * @param userId      identifies the user performing the operation
     * @param setLabel    identifies the set in which to find server IDs
     */
    public static void associateServersWithOperation(long operationId, long userId,
                                                     String setLabel) {
        WriteMode writeMode =
            ModeFactory.getWriteMode("ssm_operation_queries", "map_servers_to_operation");

        Map<String, Object> params = new HashMap<String, Object>(3);
        params.put("op_id", operationId);
        params.put("user_id", userId);
        params.put("set_label", setLabel);

        writeMode.executeUpdate(params);
    }
}

