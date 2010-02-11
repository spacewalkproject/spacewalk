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

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.test.ServerFactoryTest;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * ErrataConfirmActionTest - test that ErrataConfirmAction correctly 
 * schedules the Actions associated with the Errata
 * @version $Rev$
 */
public class ErrataConfirmActionTest extends RhnMockStrutsTestCase {

    public void testExecute() throws Exception {
        setRequestPathInfo("/errata/details/ErrataConfirmSubmit");
        addDispatchCall("confirm.jsp.confirm");
        RhnSet updateMe = RhnSetDecl.SYSTEMS_AFFECTED.create(user);
        // Create Errata
        Errata e = ErrataFactoryTest.createTestErrata(user.getOrg().getId());
        // Create package
        // Create a set of System IDs
        for (int i = 0; i < 5; i++) {
            Server s = ServerFactoryTest.createTestServer(user, true);
            updateMe.addElement(s.getId());
            ErrataFactoryTest.updateNeedsErrataCache(
                    ((Package)e.getPackages().iterator().next()).getId(), 
                    s.getId(), e.getId());
            UserFactory.save(user);
        }
        RhnSetManager.store(updateMe); //save the set
                
        addRequestParameter("eid", e.getId().toString());
        // Execute the Action
        actionPerform();
        verifyForward("confirmed");
    }
    
}
