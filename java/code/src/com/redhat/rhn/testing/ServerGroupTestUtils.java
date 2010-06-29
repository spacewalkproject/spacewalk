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
package com.redhat.rhn.testing;

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.server.test.ServerGroupTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.system.ServerGroupManager;


/**
 * ServerGroupTestUtils
 * @version $Rev$
 */
public class ServerGroupTestUtils {
    
    private ServerGroupTestUtils() {
    }
    
    
    public static final String NAME = "ManagedGroup";
    public static final String DESCRIPTION = "User Managed Group ";


    /**
     * Create Entitled Server group (Update, Management, Provis, etc..)
     * @param org bar
     * @return baz
     * @throws Exception if error
     */
    public static EntitlementServerGroup createEntitled(Org org) throws Exception {
        return ServerGroupTestUtils.createEntitled(org, 
                             ServerConstants.getServerGroupTypeUpdateEntitled());
    }

    /**
     * Create Entitled Server group (Update, Management, Provis, etc..)
     * @param org to own
     * @param typeIn you want
     * @return EntitlementServerGroup created
     * @throws Exception foob
     */
    public static EntitlementServerGroup createEntitled(Org org,
                                                ServerGroupType typeIn)
                                            throws Exception {
        return (EntitlementServerGroup) ServerGroupTest.createTestServerGroup(org, typeIn);
    }

    /**
     * Create a ManagedServerGroup ( a group of servers )
     * @param user to own
     * @return ManagedServerGroup created 
     * @throws Exception if failure
     */
    public static ManagedServerGroup createManaged(User user) throws Exception {
        ServerGroupTest.checkSysGroupAdminRole(user);
        return (ManagedServerGroup) ServerGroupManager.getInstance().
                                        create(user, NAME + TestUtils.randomString(), 
                                                    DESCRIPTION);
    }
}
