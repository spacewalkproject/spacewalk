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
package com.redhat.rhn.frontend.action.channel.test;

import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

public class PackageSearchActionTest extends RhnMockStrutsTestCase {

    public void testFilter() throws Exception {
        setRequestPathInfo("/channels/software/Search");
        addRequestParameter(RequestContext.FILTER_STRING, "zzzzz");
        addRequestParameter("search_string", "somesearch");
//        actionPerform();
//        assertTrue(getActualForward().indexOf("zzzzz") > 0);
//        assertTrue(getActualForward().indexOf("somesearch") > 0);
        assertTrue(true);
        // need to fix this test, action requires a fake Xmlrpcserver
        // to responde to the search request. It can be overridden with
        // a config at the beginning of the test.
        System.out.println("FIXME");
    }

}
