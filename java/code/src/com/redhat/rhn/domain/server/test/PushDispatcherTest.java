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

import com.redhat.rhn.domain.server.PushDispatcher;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;

import java.util.Date;

public class PushDispatcherTest extends RhnBaseTestCase {

    private static final String JABBER_ID = "Test Jabber ID";
    private static final String JABBER_ID_NEW = "Another Test Jabber ID";
    private static final Date LAST_CHECKIN = new Date();
    private static final String HOSTNAME = "test.hostname.com";
    private static final Integer PORT = new Integer(1290);

    private PushDispatcher original;

    public void setUp() throws Exception {
        super.setUp();

        original = createPushDispatcher();
    }

    public void testCreatePushDispatcher() throws Exception {
        PushDispatcher lookupDispatcher = (PushDispatcher) TestUtils
                .lookupTestObject("from PushDispatcher where id = " +
                        original.getId().toString());

        assertEquals(JABBER_ID, lookupDispatcher.getJabberId());
        assertEquals(LAST_CHECKIN, lookupDispatcher.getLastCheckin());
        assertEquals(HOSTNAME, lookupDispatcher.getHostname());
        assertEquals(PORT, lookupDispatcher.getPort());
    }

    public void testUpdatePushDispatcher() throws Exception {
        PushDispatcher lookupDispatcher = (PushDispatcher) TestUtils
                .lookupTestObject("from PushDispatcher where id = " +
                        original.getId().toString());
        lookupDispatcher.setJabberId(JABBER_ID_NEW);
        TestUtils.saveAndFlush(original);

        lookupDispatcher = (PushDispatcher) TestUtils
                .lookupTestObject("from PushDispatcher where id = " +
                        original.getId().toString());
        assertEquals(JABBER_ID_NEW, lookupDispatcher.getJabberId());
    }

    public void testDeletePushDispatcher() throws Exception {
        TestUtils.removeObject(original);
        assertNull(TestUtils.lookupTestObject("from PushDispatcher where id = " +
                original.getId().toString()));
    }

    private PushDispatcher createPushDispatcher() {
        PushDispatcher dispatcher = new PushDispatcher();
        dispatcher.setJabberId(JABBER_ID);
        dispatcher.setLastCheckin(LAST_CHECKIN);
        dispatcher.setHostname(HOSTNAME);
        dispatcher.setPort(PORT);

        TestUtils.saveAndFlush(dispatcher);
        return dispatcher;

    }
}
