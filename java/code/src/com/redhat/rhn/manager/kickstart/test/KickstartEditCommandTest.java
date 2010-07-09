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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;

/**
 * KickstartEditCommandTest - test for KickstartDetailsCommand
 * @version $Rev$
 */
public class KickstartEditCommandTest extends BaseKickstartCommandTestCase {

    public void testKickstartEditCommand() throws Exception {

        KickstartEditCommand command = new KickstartEditCommand(ksdata.getId(), user);
        command.setComments("My Comment");
        command.setActive(Boolean.TRUE);
        command.setLabel("scoobykickstart");
        command.store();

        KickstartData k2 = command.getKickstartData();
        assertNotNull(k2.getComments());
        assertNotNull(k2.getLabel());

        assertEquals(Boolean.TRUE, k2.isActive());
        assertEquals(command.getComments(), k2.getComments());
        assertEquals(command.getLabel(), k2.getLabel());
    }

    public void testKickstartLabel() throws Exception {
        KickstartEditCommand command = new KickstartEditCommand(ksdata.getId(), user);
        command.setLabel("shaggy-ks-rhel4");
        command.store();
        assertEquals(ksdata.getLabel(), command.getLabel());
    }

    public void testOrgDefault() throws Exception {
        assertFalse(ksdata.isOrgDefault().booleanValue());
        KickstartData k1 = KickstartDataTest.createKickstartWithChannel(user.getOrg());
        Long oldDefaultId = k1.getId();
        k1.setOrgDefault(Boolean.TRUE);
        assertTrue(k1.isOrgDefault().booleanValue());
        KickstartFactory.saveKickstartData(k1);
        flushAndEvict(k1);

        KickstartEditCommand command = new KickstartEditCommand(ksdata.getId(), user);
        command.setIsOrgDefault(Boolean.TRUE);
        assertTrue(ksdata.isOrgDefault().booleanValue());
        k1 = KickstartFactory.lookupKickstartDataByIdAndOrg(user.getOrg(), oldDefaultId);
        assertFalse(k1.isOrgDefault().booleanValue());
    }

}
