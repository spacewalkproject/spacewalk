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
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.action.rhnpackage.PackageIndexAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.HashMap;
import java.util.Map;

/**
 * PackageIndexActionTest
 * @version $Rev$
 */
public class PackageIndexActionTest extends RhnBaseTestCase {

    public void testUpdate() throws Exception {
        PackageIndexAction pia = new PackageIndexAction();
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(pia);
        ah.getUser().addRole(RoleFactory.ORG_ADMIN);

        Server svr = ServerFactoryTest.createTestServer(ah.getUser(), true);
        ah.getRequest().setupAddParameter("sid", svr.getId().toString());
        ah.executeAction("update");

        SelectMode m = ModeFactory.getMode("test_queries", "scheduled_actions");
        Map params = new HashMap();
        params.put("user_id", ah.getUser().getId());
        DataResult dr = m.execute(params);
        assertEquals(1, dr.size());
        assertEquals(ah.getRequest().getAttribute("system"), svr);
    }

}
