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
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.test.KickstartDataTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * KickstartsSetupActionTest
 * @version $Rev: 1 $
 */
public class ScriptSetupActionTest extends RhnMockStrutsTestCase {

    public void testKickstartList() throws Exception {
        // Create a kickstart and the defaults so the list
        // will return something.
        UserTestUtils.addProvisioning(user.getOrg());
        KickstartData k = KickstartDataTest.createTestKickstartData(user.getOrg());
        setRequestPathInfo("/kickstart/Scripts");
        addRequestParameter(RequestContext.KICKSTART_ID, k.getId().toString());
        actionPerform();
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);

    }

}

