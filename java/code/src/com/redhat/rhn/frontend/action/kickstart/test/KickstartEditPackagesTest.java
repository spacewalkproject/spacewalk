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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

public class KickstartEditPackagesTest extends RhnMockStrutsTestCase {

    public void testDisplay() throws Exception {
        KickstartData k = KickstartTestHelper.createTestKickStart(user);
        setupForDisplay(k);
        actionPerform();
    }

    public void testEditWithAdd() throws Exception {
        KickstartData k = KickstartTestHelper.createTestKickStart(user);
        setupForEdit(k);
        addRequestParameter("packageList", "@ Base\ntomcat-testing\n");
        actionPerform();
    }

    public void testEditWithDelete() throws Exception {
        KickstartData k = KickstartTestHelper.createTestKickStart(user);
        setupForEdit(k);
        addRequestParameter("packageList", "");
        actionPerform();
    }

    private void setupForDisplay(KickstartData k) throws Exception {
        clearRequestParameters();
        setRequestPathInfo("/kickstart/KickstartPackagesEdit");
        addRequestParameter("ksid", k.getId().toString());
    }

    private void setupForEdit(KickstartData k) throws Exception {
        setupForDisplay(k);
        addRequestParameter("submitted", "true");
    }


}
