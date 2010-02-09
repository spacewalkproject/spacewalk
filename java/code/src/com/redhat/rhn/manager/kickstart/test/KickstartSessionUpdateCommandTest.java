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
package com.redhat.rhn.manager.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.kickstart.test.KickstartSessionTest;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.manager.kickstart.KickstartSessionUpdateCommand;

/**
 * KickstartSessionUpdateCommand
 * @version $Rev$
 */
public class KickstartSessionUpdateCommandTest extends BaseKickstartCommandTestCase {

    public void testUpdateSession() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);
        KickstartSession session = 
            KickstartSessionTest.createKickstartSession(ksdata, user);
        KickstartFactory.saveKickstartSession(session);
        session = (KickstartSession) reload(session);
        KickstartSessionUpdateCommand cmd = 
            new KickstartSessionUpdateCommand(session.getId());
        cmd.setSessionState(KickstartFactory.SESSION_STATE_CONFIG_ACCESSED);
        cmd.store();
        assertEquals(session.getState(), KickstartFactory.SESSION_STATE_CONFIG_ACCESSED);
        
    }
    
}
