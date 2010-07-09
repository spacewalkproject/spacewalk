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
package com.redhat.rhn.manager.system.test;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.manager.system.CancelKickstartSessionOperation;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

/**
 * CancelKickstartSessionOperationTest
 * @version $Rev$
 */
public class CancelKickstartSessionOperationTest extends BaseTestCaseWithUser {

    public void testOperation() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        KickstartData k = KickstartDataTest.createKickstartWithOptions(user.getOrg());
        KickstartSession ksession = KickstartSessionTest.createKickstartSession(k, user);
        Server s = ksession.getOldServer();
        Action a = ActionFactoryTest.createAction(user,
                ActionFactory.TYPE_KICKSTART_INITIATE);
        ksession.setAction(a);
        ActionFactory.save(a);
        KickstartFactory.saveKickstartData(k);
        flushAndEvict(k);
        TestUtils.saveAndFlush(ksession);
        flushAndEvict(ksession);

        CancelKickstartSessionOperation dso =
            new CancelKickstartSessionOperation(user, s.getId());
        dso.store();

        KickstartSession lookedUp = KickstartFactory.
            lookupKickstartSessionByServer(s.getId());
        assertNull(lookedUp.getAction());

    }
}
