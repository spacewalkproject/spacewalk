/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.action.test;

import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * SearchActionTest
 */
public class SearchActionTest extends RhnMockStrutsTestCase {


    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/Search");
    }

    public void testSystemRedirect() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter("search_string", "test search");
        addRequestParameter("search_type", "systems");
        actionPerform();
        assertTrue(getActualForward().startsWith("/systems/Search.do"));
    }

    public void testErrataRedirect() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter("search_string", "test search");
        addRequestParameter("search_type", "errata");
        actionPerform();
        assertTrue(getActualForward().startsWith("/errata/Search.do"));
    }

    public void testPackageRedirect() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter("search_string", "test search");
        addRequestParameter("search_type", "packages");
        actionPerform();
        assertTrue(getActualForward().startsWith("/channels/software/Search.do"));
    }

    public void testDocRedirect() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter("search_string", "test search");
        addRequestParameter("search_type", "docs");
        actionPerform();
        assertTrue(getActualForward().startsWith("/help/Search.do"));
    }

    public void testFaultySubmit() throws Exception {
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter("search_string", "test search");
        addRequestParameter("search_type", "l337_hax0r");
        actionPerform();
        verifyForward("error");
    }

}
