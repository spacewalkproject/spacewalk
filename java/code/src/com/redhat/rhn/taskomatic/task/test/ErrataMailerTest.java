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

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.taskomatic.task.ErrataMailer;
import com.redhat.rhn.testing.BaseTestCaseWithUser;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class ErrataMailerTest extends BaseTestCaseWithUser {
    
    public void testErrataMailer() throws Exception {
        final Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
        final Channel c = ChannelFactoryTest.createBaseChannel(user);
        // Override the methods that make the size of the task grow really huge
        // We still test the majority of the stuff in ErrataMailer(), just not
        // the queries that get all the users and errata.
        ErrataMailer em = new ErrataMailer() {
            protected List findTargetUsers() throws Exception {
                List retval = new LinkedList();
                Map row = new HashMap();
                row.put("id", user.getId());
                row.put("email", user.getEmail());
                row.put("login", user.getLogin());
                retval.add(row);
                return retval;
            }

            protected List getErrataToProcess() {
                List retval = new LinkedList();
                Map row = new HashMap();
                row.put("channel_id", c.getId());
                row.put("errata_id", e.getId());
                row.put("org_id", user.getOrg().getId());
                retval.add(row);
                return retval;
            }
        };
        em.execute(null, true);
    }
    
    public void testErrataQueries() throws Exception {
        
        TestErrataMailer em = new TestErrataMailer();
        assertNotNull(em.testFindUsers());
    }
    
    public class TestErrataMailer extends ErrataMailer {

        public List testFindUsers() throws Exception {
            return findTargetUsers();
        }
    }
}
