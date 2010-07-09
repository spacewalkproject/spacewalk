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
import com.redhat.rhn.frontend.action.errata.RemovePackagesSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.action.Action;

/**
 * AddPackagesConfirmSetupActionTest
 * @version $Rev$
 */
public class BaseErrataConfirmSetupActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        RemovePackagesSetupAction action2 = new RemovePackagesSetupAction();
        runTest(action2);
    }

    public void runTest(Action action) throws Exception {

        ActionHelper sah = new ActionHelper();

        sah.setUpAction(action);
        sah.setupClampListBounds();

        //Create a new errata
        Errata e = ErrataFactoryTest.createTestPublishedErrata(
                sah.getUser().getOrg().getId());
        sah.getRequest().setupAddParameter("eid", e.getId().toString());
        sah.getRequest().setupAddParameter("eid", e.getId().toString());

        sah.executeAction();
        assertNotNull(sah.getRequest().getAttribute("pageList"));
    }
}
