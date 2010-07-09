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
package com.redhat.rhn.frontend.xmlrpc.api.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.frontend.xmlrpc.api.ApiHandler;
import com.redhat.rhn.testing.RhnBaseTestCase;

public class ApiHandlerTest extends RhnBaseTestCase {

    public void testSystemVersion() {
        ApiHandler handler = new ApiHandler();
        /*
         * No way to tell if we get the correct version or not, so just make sure we
         * get *something*.
         */

        String version = Config.get().getString("web.version");
        assertEquals(version, handler.systemVersion());
    }

    public void testGetVersion() {
        ApiHandler handler = new ApiHandler();
        String version = Config.get().getString("web.apiversion");
        assertEquals(version, handler.getVersion());
    }
}
