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
package com.redhat.rhn.frontend.action.systems.test;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.Iterator;

/**
 * ErrataSetupActionTest
 * @version $Rev$
 */
public class ErrataSetupActionTest extends RhnMockStrutsTestCase {
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/systems/details/ErrataList");

    }
    public void testInvalidParamCase() {
        addRequestParameter(RequestContext.SID, "-9999");
        actionPerform();
        assertPermissionException();

    }

    public void testNormalCase() throws Exception {
        Server server = ServerFactoryTest.createTestServer(user, true);
        addRequestParameter("sid", server.getId().toString());
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());

        for (Iterator itr = e.getPackages().iterator(); itr.hasNext();) {
            Package pkg = (Package) itr.next();
            ErrataCacheManager.insertNeededPackageCache(server.getId(),
                    e.getId(), pkg.getId());
        }

        actionPerform();
        assertNotNull(request.getAttribute("set"));
        assertNotNull(request.getAttribute("system"));

        //trying show bttn logic
        assertEquals(Boolean.TRUE.toString(),
                    request.getAttribute("showApplyErrata"));
        assertTrue(getActualForward().indexOf("errata.jsp") > -1);

        assertTrue(request.getAttribute("showApplyErrata").equals("true"));
        clearRequestParameters();
        addRequestParameter("sid", server.getId().toString());

        for (Iterator itr = e.getPackages().iterator(); itr.hasNext();) {
            Package pkg = (Package) itr.next();
            ErrataCacheManager.deleteNeededPackageCache(server.getId(),
                    e.getId(), pkg.getId());
        }
        actionPerform();
        assertEquals(Boolean.FALSE.toString(),
                request.getAttribute("showApplyErrata"));
    }

}
