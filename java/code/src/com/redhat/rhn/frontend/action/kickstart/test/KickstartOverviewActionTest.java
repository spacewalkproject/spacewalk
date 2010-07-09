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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.frontend.action.kickstart.KickstartOverviewAction;

public class KickstartOverviewActionTest extends BaseKickstartEditTestCase {

    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartOverview");
        actionPerform();

        DataResult ksdr = (DataResult) request.getAttribute(
                                            KickstartOverviewAction.KICKSTART_SUMMARY);
        assertNotNull(ksdr);
        assertTrue(ksdr.size() > 0);
        assertNotNull(request.getAttribute(
                                KickstartOverviewAction.SYSTEMS_CURRENTLY_KICKSTARTING));
        assertNotNull(request.getAttribute(
                                KickstartOverviewAction.SYSTEMS_TO_BE_KICKSTARTED));
    }
}
