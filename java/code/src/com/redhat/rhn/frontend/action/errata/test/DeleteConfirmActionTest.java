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
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetFactory;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.errata.UnpublishedDeleteConfirmAction;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * DeleteConfirmActionTest
 * @version $Rev$
 */
public class DeleteConfirmActionTest extends RhnBaseTestCase {

    public void testExecute() throws Exception {

        UnpublishedDeleteConfirmAction action = new UnpublishedDeleteConfirmAction();
        ActionHelper sah = new ActionHelper();

        sah.setUpAction(action);
        User usr = sah.getUser();

        RhnSet deleteme = RhnSetFactory.createRhnSet(usr.getId(), "errata_to_delete",
                SetCleanup.NOOP);

        //Create a set of Errata id's
        for (int i = 0; i < 5; i++) {
            Errata e = ErrataFactoryTest.createTestErrata(usr.getOrg().getId());
            deleteme.addElement(e.getId());
        }
        RhnSetManager.store(deleteme); //save the set

        RhnSet set = RhnSetDecl.ERRATA_TO_DELETE.get(usr);
        assertEquals(5, set.size());
        sah.executeAction();
        /*
         * TODO:
         * Currently, the delete procedure takes around 5 min. to run. This is
         * unacceptable. We will eventually, need to put a timer in here to wait
         * a second or two before making sure that the set was deleted, but until
         * we can delete erratas in an acceptable time frame to have integrated
         * into our unit tests, I'm going to comment this line out.
         *
        assertTrue(UserManager.getSet(usr, "errata_to_delete").size() == 0);
         */
    }
}
