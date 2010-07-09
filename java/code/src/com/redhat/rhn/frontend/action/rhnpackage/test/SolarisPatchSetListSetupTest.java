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
package com.redhat.rhn.frontend.action.rhnpackage.test;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.rhnpackage.SolarisPatchSetListSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

/**
 * SolarisPatchSetListSetupTest
 * @version $Rev$
 */
public class SolarisPatchSetListSetupTest extends RhnBaseTestCase {
    private Action action = null;

    public void setUp() {
        action = new SolarisPatchSetListSetupAction();
    }

    /**
     * TODO - populate the server with actual solaris patch clusters and
     * test the results.
     */
    public void testExecute() throws Exception {
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);
        sah.setupClampListBounds();

        User user = sah.getUser();
        user.addRole(RoleFactory.ORG_ADMIN);
        Server server = ServerFactoryTest.createTestServer(user, true);

        sah.getRequest().setupAddParameter("sid", server.getId().toString());
        sah.executeAction();

        RhnMockHttpServletRequest request = sah.getRequest();

        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() == 0);
    }
}
