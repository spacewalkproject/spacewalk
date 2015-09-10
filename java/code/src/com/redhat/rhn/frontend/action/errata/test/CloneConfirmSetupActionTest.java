/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.test.ChannelFactoryTest;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * CloneConfirmSetupActionTest
 */
public class CloneConfirmSetupActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/errata/manage/CloneConfirm");
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
    }

    public void testExecute() throws Exception {

        RhnSet errataToClone = RhnSetFactory.createRhnSet(user.getId(),
                                                          "clone_errata_list",
                                                          SetCleanup.NOOP);

        Channel original = ChannelFactoryTest.createTestChannel(user);

        for (int j = 0; j < 5; ++j) {
            Errata e = ErrataFactoryTest.createTestPublishedErrata(user.getOrg().getId());
            original.addErrata(e);
            errataToClone.addElement(e.getId());
        }

        RhnSetManager.store(errataToClone);

        RhnSet set = RhnSetDecl.ERRATA_CLONE.get(user);
        assertEquals(5, set.size());

        actionPerform();

        DataResult dr = (DataResult) request.getAttribute(RequestContext.PAGE_LIST);
        assertNotNull(dr);
        assertTrue(dr.size() == 5);
    }
}
