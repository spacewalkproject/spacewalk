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
package com.redhat.rhn.manager.solarispatchset.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.solarispatchset.SolarisPatchSetManager;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * SolarisManagerTest
 * @version $Rev$
 */
public class SolarisPatchSetManagerTest extends RhnBaseTestCase {

    //initial tests for Solaris feature.

    public void testSystemAvailablePatchSetList() throws Exception {
        PageControl pc = new PageControl();
        pc.setIndexData(false);
        pc.setStart(1);
        
        // comment this out for now until we can write better tests
        //User u = UserTestUtils.findNewUser("testUser", "testOrg");
        //Server server = ServerFactoryTest.createTestServer(u);
        //assertNotNull(server);
        //assertNotNull(server.getId());

        DataResult dr = SolarisPatchSetManager.systemAvailablePatchSetList(
                                                   new Long(1000010004), pc);
        assertNotNull(dr);
    }
}
