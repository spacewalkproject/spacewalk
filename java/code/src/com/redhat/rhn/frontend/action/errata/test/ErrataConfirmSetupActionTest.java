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
package com.redhat.rhn.frontend.action.errata.test;

import com.redhat.rhn.common.util.DatePicker;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * ErrataConfirmSetupActionTest - test ErrataConfirmSetupAction setting
 * up the information in the request for the pageview
 * @version $Rev$
 */
public class ErrataConfirmSetupActionTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {

        // Create Errata
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        request.addParameter("eid", e.getId().toString());
        request.addParameter(DatePicker.USE_DATE, "true");

        //Create a System
        Server server = ServerFactoryTest.createTestServer(user, true);

        //Associate the system and the errata
        UserFactory.save(user);
        OrgFactory.save(user.getOrg());
        Package p = (Package) e.getPackages().iterator().next();
        int rows = ErrataCacheManager.insertNeededErrataCache(
                server.getId(), e.getId(), p.getId());
        assertEquals(1, rows);

        //Add the system to the set
        RhnSet set = RhnSetDecl.SYSTEMS_AFFECTED.get(user);
        set.addElement(server.getId());
        RhnSetFactory.save(set);

        // Execute the Action
        setRequestPathInfo("/errata/details/ErrataConfirm");
        actionPerform();

        //Test the expected results.
        verifyPageList(SystemOverview.class);
        assertNotNull(request.getAttribute("errata"));
        Errata e2 = (Errata) request.getAttribute("errata");
        assertEquals(e, e2);
        assertNotNull(request.getAttribute("date"));
    }
}
