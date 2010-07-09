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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.test.ErrataFactoryTest;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.frontend.dto.OwnedErrata;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.Iterator;

/**
 * DeleteConfirmSetupActionTest
 * @version $Rev$
 */
public class UnpublishedDeleteConfirmSetupActionTest extends RhnMockStrutsTestCase {

    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/errata/manage/UnpublishedDeleteConfirm");
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
    }

    public void testExecute() throws Exception {

        RhnSet errataToDelete = RhnSetFactory.createRhnSet(user.getId(),
                "errata_to_delete",
                SetCleanup.NOOP);

        /* Here we add both published and unpublished errata to the set
         * so that when we get the result back, we verify that we are only
         * unpublished errata are appearing in the set. We add two
         * published for every unpublished so that we will not have an
         * equal number in the set
         */
        for (int j = 0; j < 5; ++j) {
            Errata e = ErrataFactoryTest
                       .createTestUnpublishedErrata(user.getOrg().getId());
            errataToDelete.addElement(e.getId());
            e = ErrataFactoryTest
                .createTestPublishedErrata(user.getOrg().getId());
            errataToDelete.addElement(e.getId());
            e = ErrataFactoryTest
            .createTestPublishedErrata(user.getOrg().getId());
            errataToDelete.addElement(e.getId());
        }

        RhnSetManager.store(errataToDelete);

        RhnSet set = RhnSetDecl.ERRATA_TO_DELETE.get(user);
        assertEquals(15, set.size());

        actionPerform();

        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertEquals(5, dr.size());

        Iterator i = dr.iterator();

        /* Verify that we only got unpublished results back */
        while (i.hasNext()) {
            OwnedErrata e = (OwnedErrata) i.next();
            assertTrue(e.getPublished().equals(new Integer(0)));
        }
    }
}
