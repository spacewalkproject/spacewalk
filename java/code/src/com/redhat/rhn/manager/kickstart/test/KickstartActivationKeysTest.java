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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.frontend.dto.ActivationKeyDto;
import com.redhat.rhn.manager.kickstart.KickstartActivationKeysCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.testing.TestUtils;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * JUnit test case for the KickstartLister class.
 * @version $Rev$
 */

public class KickstartActivationKeysTest extends BaseKickstartCommandTestCase {

    public void testActivationKeysForKickstart() throws Exception {
        user.addRole(RoleFactory.ORG_ADMIN);

        String note = TestUtils.randomString() + 
            " -- Java unit test activation key.";
        
        ActivationKey key = ActivationKeyFactory.createNewKey(user, note);
        ActivationKeyFactory.save(key);
        key = (ActivationKey) reload(key);
        
        DataResult dr = KickstartLister.getInstance()
            .getActivationKeysInOrg(ksdata.getOrg(), null);
        assertTrue(dr.size() > 0);
        boolean found = false;
        Iterator i = dr.iterator();
        while (i.hasNext()) {
            ActivationKeyDto row = (ActivationKeyDto) i.next();
            assertNotNull(row.getId());
            assertNotNull(row.getNote());
            if (note.equals(row.getNote())) {
                found = true;
            }
        }
        assertTrue("Didnt find the updated note.", found);

        ActivationKey key2 = ActivationKeyFactory.lookupByKey(key.getKey());
        assertNotNull(key2.getId());
        assertNotNull(key2.getNote());
        assertEquals(note, key2.getNote());

    }

    public void testKickstartActivationKeysCommand() throws Exception {

        KickstartFactory.saveKickstartData(ksdata);

        Long ksid = ksdata.getId();

        user.addRole(RoleFactory.ORG_ADMIN);

        String note = TestUtils.randomString() + 
            " -- Java unit test activation key.";
        
        ActivationKey key1 = ActivationKeyFactory.createNewKey(user, "first " + note);
        ActivationKey key2 = ActivationKeyFactory.createNewKey(user, "second " + note);
        ActivationKey key3 = ActivationKeyFactory.createNewKey(user, "third " + note);
        ActivationKeyFactory.save(key1);
        ActivationKeyFactory.save(key2);
        ActivationKeyFactory.save(key3);

        ArrayList one = new ArrayList();
        one.add(key1.getId());
        ArrayList two = new ArrayList();
        two.add(key2.getId());
        ArrayList oneAndTwo = new ArrayList();
        oneAndTwo.add(key1.getId());
        oneAndTwo.add(key2.getId());
        ArrayList oneAndThree = new ArrayList();
        oneAndThree.add(key1.getId());
        oneAndThree.add(key3.getId());
        ArrayList all = new ArrayList();
        all.add(key1.getId());
        all.add(key2.getId());
        all.add(key3.getId());

        KickstartActivationKeysCommand command =
            new KickstartActivationKeysCommand(ksdata.getId(), user);

        // test adding
        checkTokens(command, one, null, 1);
        checkTokens(command, two, null, 2);
        checkTokens(command, one, null, 2);

        // test removing
        checkTokens(command, null, one, 1);
        checkTokens(command, null, two, 0);
        checkTokens(command, null, one, 0);

        // test multiples
        checkTokens(command, oneAndTwo, null, 2);
        checkTokens(command, all, null, 3);
        checkTokens(command, null, oneAndThree, 1);
        checkTokens(command, null, all, 0);

        // just for the heck of it, add and remove at the same time (add happens first...)
        checkTokens(command, all, one, 2);
        checkTokens(command, all, all, 0);
    }

    /**
     * Adds and removes tokens, then saves the kickstart profile,
     * loads it again, and compares what comes out with the 'expected'
     * value.
     *
     * @param command The KickstartActivationKeysCommand with the ksdata inside it.
     * @param tokensAdd The tokens to add to the kickstart profile. (can be null)
     * @param tokensRemove The tokens to remove from the kickstart profile. (can be null)
     * @param expectedCount The number of tokens we expect to have
     * after adding, then removing.
     */
    public void checkTokens(KickstartActivationKeysCommand command, ArrayList tokensAdd,
                             ArrayList tokensRemove, int expectedCount) {

        if (tokensAdd != null) {
            command.addTokensByIds(tokensAdd);
        }

        if (tokensRemove != null) {
            command.removeTokensByIds(tokensRemove);
        }

        command.store();

        KickstartData ks =
            KickstartFactory.lookupKickstartDataByIdAndOrg(user.getOrg(), 
                    command.getKickstartData().getId());

        assertEquals(expectedCount, ks.getDefaultRegTokens().size());
    }

}
