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
package com.redhat.rhn.domain.server.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import org.hibernate.Session;

import java.util.Date;

/**
 * NoteTest
 * @version $Rev$
 */
public class NoteTest extends RhnBaseTestCase {

    /**
     * Test Note creation and equals method
     * @throws Exception
     */
    public void testEquals() throws Exception {
        Note note1 = createTestNote();
        Note note2 = new Note();

        assertFalse(note1.equals(note2));
        assertFalse(note1.equals(new Date()));

        Session session = HibernateFactory.getSession();
        note2 = (Note) session.getNamedQuery("Note.findById")
                                  .setLong("id", note1.getId().longValue())
                                  .uniqueResult();
        assertEquals(note1, note2);

        TestUtils.removeObject(note1);
    }

    /**
     * Helper method to create a test Note
     * @return A new Note.
     * @throws Exception
     */
    public static Note createTestNote() throws Exception {
        Note note = new Note();

        User user = UserTestUtils.createUser("testuser",
                                    UserTestUtils.createOrg("testorg"));
        note.setCreator(user);
        note.setServer(ServerFactoryTest.createTestServer(user));
        note.setSubject("RHN-JAVA Unit tests are good");
        note.setNote("I will write them always.");

        assertNull(note.getId());
        TestUtils.saveAndFlush(note);
        assertNotNull(note.getId());

        return note;
    }
}
