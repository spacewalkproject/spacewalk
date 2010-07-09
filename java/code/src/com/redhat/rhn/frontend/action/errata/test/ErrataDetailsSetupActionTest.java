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
import com.redhat.rhn.frontend.action.errata.ErrataDetailsSetupAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * ErrataDetailsSetupActionTest
 * @version $Rev$
 */
public class ErrataDetailsSetupActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {
        ErrataDetailsSetupAction action = new ErrataDetailsSetupAction();
        ActionHelper sah = new ActionHelper();
        sah.setUpAction(action);

        Errata e = ErrataFactoryTest.createTestErrata(
                sah.getUser().getOrg().getId());
        e.addKeyword("test");

        sah.getRequest().setupAddParameter("eid", e.getId().toString());

        sah.executeAction();

        assertNotNull(sah.getRequest().getAttribute("errata"));
        assertNotNull(sah.getRequest().getAttribute("issued"));
        assertNotNull(sah.getRequest().getAttribute("updated"));
        assertNotNull(sah.getRequest().getAttribute("topic"));
        assertNotNull(sah.getRequest().getAttribute("description"));
        assertNotNull(sah.getRequest().getAttribute("solution"));
        assertNotNull(sah.getRequest().getAttribute("notes"));
        assertNotNull(sah.getRequest().getAttribute("references"));
        assertNotNull(sah.getRequest().getAttribute("channels"));
        assertNotNull(sah.getRequest().getAttribute("fixed"));
        assertNotNull(sah.getRequest().getAttribute("cve"));
        assertNotNull(sah.getRequest().getAttribute("keywords"));
    }
}
