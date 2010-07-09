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
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.kickstart.crypto.test.CryptoTest;
import com.redhat.rhn.manager.kickstart.KickstartCryptoKeyCommand;

import java.util.LinkedList;
import java.util.List;

/**
 * KickstartCryptoCommandTest
 * @version $Rev$
 */
public class KickstartCryptoCommandTest extends BaseKickstartCommandTestCase {

    public void testCommand() {
        KickstartCryptoKeyCommand cmd =
            new KickstartCryptoKeyCommand(ksdata.getId(), user);

        CryptoKey key = CryptoTest.createTestKey(user.getOrg());
        KickstartFactory.saveCryptoKey(key);
        key = (CryptoKey) reload(key);
        List ids = new LinkedList();
        ids.add(key.getId());
        cmd.addKeysByIds(ids);
        cmd.store();
        flushAndEvict(cmd.getKickstartData());
        assertTrue(cmd.getKickstartData().getCryptoKeys().size() == 1);
        cmd.removeKeysById(ids);
        cmd.store();
        flushAndEvict(cmd.getKickstartData());
        assertTrue(cmd.getKickstartData().getCryptoKeys().size() == 0);
    }
}
