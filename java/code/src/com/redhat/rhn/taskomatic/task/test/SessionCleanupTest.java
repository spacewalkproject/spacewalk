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
package com.redhat.rhn.taskomatic.task.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.domain.session.WebSessionFactory;
import com.redhat.rhn.taskomatic.task.SessionCleanup;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

/**
 * SessionCleanupTest
 * JUnit test for SessionCleanup
 * @version $Rev$
 */
public class SessionCleanupTest extends RhnBaseTestCase {

/**
 * @throws Exception
 */
    public void testExecute() throws Exception {

        WebSession s = WebSessionFactory.createSession();

        /* we set the expire time of our test websession to an insanely large negative
        number this ensures that we do not accidentally delete real entries in the
        database */
        s.setExpires((System.currentTimeMillis() / 1000) * -2);
        WebSessionFactory.save(s);
        assertNotNull(s.getId());
        Config c = Config.get();
        TestUtils.saveAndFlush(s);

        /* commit it to the database in order for the py/sql calls to work correctly
        due to py/sql and Hibernate's JUnit test behavior not playing well together */
        commitAndCloseSession();

        /*set the delete batch size to 1 to make sure only one entry is deleted.
        We set session_database_lifetime to the current time such that when
        the deletion boundary is calculated by SessionCleanup, the result will be
        a negative value, but one that ensures our test websession is selected
        and deleted. */

        c.setString("session_database_lifetime",
                     new Long(System.currentTimeMillis() / 1000).toString());

        c.setString("session_delete_batch_size", "1");
        c.setString("session_delete_commit_interval", "1");
        SessionCleanup sc = new SessionCleanup();
        sc.execute(null);

       // assertNull(WebSessionFactory.lookupById(sessionId));
    }
}
