/**
 * Copyright (c) 2015 Red Hat, Inc.
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
package com.redhat.rhn.common.db.test;

import com.redhat.rhn.common.db.ResetPasswordFactory;
import com.redhat.rhn.domain.common.ResetPassword;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

public class ResetPasswordFactoryTest extends BaseTestCaseWithUser {

    public void testToken() throws Exception {
        String tok = ResetPasswordFactory.generatePasswordToken(user);
        assertNotNull(tok);
        assertEquals(40, tok.length());
    }

    public void testDirectCreate() {
        ResetPassword rp = new ResetPassword(user.getId(),
                        ResetPasswordFactory.generatePasswordToken(user));
        assertNotNull(rp);
        assertEquals(rp.getUserId(), user.getId());
        assertNotNull(rp.getToken());
        assertTrue(rp.isValid());
    }

    public void testFactoryCreate() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        assertNotNull(rp);
        assertNotNull(rp);
        assertEquals(rp.getUserId(), user.getId());
        assertNotNull(rp.getToken());
        assertTrue(rp.isValid());
    }

    public void testNoToken() {
        ResetPassword rp = ResetPasswordFactory.lookupByToken("Thistokencannotexist");
        assertNull(rp);
    }

    public void testRecoverAndDelete() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        ResetPassword found = ResetPasswordFactory.lookupByToken(rp.getToken());
        assertEquals(found.getUserId(), user.getId());
        assertNotNull(found.getToken());
        assertTrue(found.isValid());
        assertEquals(rp.getToken(), found.getToken());
        int rmv = ResetPasswordFactory.deleteUserTokens(user.getId());
        assertEquals(1, rmv);
    }

    public void testInvalidate() {
        ResetPassword rp = ResetPasswordFactory.createNewEntryFor(user);
        assertNotNull(rp);
        int rmvd = ResetPasswordFactory.deleteUserTokens(user.getId());
        assertEquals(1, rmvd);
        ResetPassword rp1 = ResetPasswordFactory.createNewEntryFor(user);
        ResetPassword rp2 = ResetPasswordFactory.createNewEntryFor(user);
        ResetPassword rp3 = ResetPasswordFactory.createNewEntryFor(user);
        assertNotSame(rp1, rp2);
        assertNotSame(rp1, rp3);
        assertNotSame(rp2, rp3);

        ResetPassword found = ResetPasswordFactory.lookupByToken(rp1.getToken());
        assertNotNull(found);
        assertTrue(!found.isValid());

        found = ResetPasswordFactory.lookupByToken(rp2.getToken());
        assertNotNull(found);
        assertTrue(!found.isValid());

        found = ResetPasswordFactory.lookupByToken(rp3.getToken());
        assertNotNull(found);
        assertTrue(found.isValid());

        int inv = ResetPasswordFactory.invalidateUserTokens(user.getId());
        assertEquals(1, inv);

        rmvd = ResetPasswordFactory.deleteUserTokens(user.getId());
        assertEquals(3, rmvd);
    }

}
