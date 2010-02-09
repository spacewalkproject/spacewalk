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
package com.redhat.rhn.manager.ssm.test;

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.manager.ssm.SsmOperationManager;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.ArrayList;
import java.util.List;

/**
 * Populates the database with sample SSM operation log entries, used primarily for
 * development and debugging of the UI pages for this feature.
 * <p/>
 * The populate methods in this class should be disabled (i.e. prefix with __) at all
 * times when committing this file.
 *
 * @author Jason Dobies
 * @version $Revision$
 */
public class SsmOperationDataPopulatorTest extends RhnBaseTestCase {

    protected void tearDown() throws Exception {
        // Override so the base class' tearDown doesn't rollback the transaction;
        // for this class we want the data to be persisted and remain there
    }

    public void testDummy() {
        // Stub to have at least one test when all of the actual populate ones are
        // disabled so JUnit doesn't complain
    }

    public void aTestPopulateDataSet1() throws Exception {
        // The following control the data that are created in this call
        String userLoginName = "admin";
        int numInProgressOperations = 3;
        int numCompletedOperations = 8;

        // Add servers under a specific user
        User user = UserFactory.lookupByLogin(userLoginName);
        List<Server> servers = createServersForUser(user, 5);

        // Add servers to a RhnSet for use in the create operation
        RhnSet serverSet = createSetOfServers("SsmOperationPopulatorSet", user, servers);

        // Create some sample in progress operations

        for (int ii = 0; ii < numInProgressOperations; ii++) {
            SsmOperationManager.createOperation(user, "Sample In Progress Operation " + ii,
                serverSet.getLabel());
        }

        // Create some sample completed operations
        for (int ii = 0; ii < numCompletedOperations; ii++) {
            long opId = SsmOperationManager.createOperation(user,
                "Sample Completed Operation " + ii, serverSet.getLabel());
            SsmOperationManager.completeOperation(user, opId);
        }

        // Cleanup; after the creates the RhnSet is no longer needed
        RhnSetManager.remove(serverSet);

        super.commitAndCloseSession();
    }

    private List<Server> createServersForUser(User user, int count) throws Exception {
        List<Server> servers = new ArrayList<Server>(count);

        for (int ii = 0; ii < count; ii++) {
            Server server = ServerFactoryTest.createTestServer(user, true);
            servers.add(server);
        }

        return servers;
    }

    private RhnSet createSetOfServers(String setName, User user, List<Server> servers) {
        RhnSetDecl setDecl =
            RhnSetDecl.findOrCreate(setName, SetCleanup.NOOP);
        RhnSet rhnSet = setDecl.create(user);

        for (Server server : servers) {
            rhnSet.addElement(server.getId());
        }

        RhnSetManager.store(rhnSet);
        return rhnSet;
    }

}
