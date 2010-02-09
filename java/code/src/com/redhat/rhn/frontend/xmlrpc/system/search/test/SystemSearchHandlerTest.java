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
package com.redhat.rhn.frontend.xmlrpc.system.search.test;

import com.redhat.rhn.frontend.xmlrpc.test.BaseHandlerTestCase;

/**
 * No unit-tests exist for SystemSearchHandler, reason being that to add usable test
 * data is more work than can be expanded for now.  The problem is that adding test
 * data to the DB is only one part, we also need this data to be indexed by the
 * search-server, indexing is a delayed event which happens every 5 minutes.
 *
 */
public class SystemSearchHandlerTest extends BaseHandlerTestCase {

    /**
     * empty test to act as a place holder
     * @throws Exception
     */
    public void testDummy() throws Exception {
        assertTrue(true);
    }
}
