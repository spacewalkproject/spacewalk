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
package com.redhat.rhn.testing;

import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;

/**
 * BaseDeleteActionTest
 * @version $Rev$
 */
public abstract class BaseDeleteErrataActionTest extends RhnMockStrutsTestCase {
    
    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo(getRequestPath());
        user.getOrg().getEntitlements().add(OrgFactory.getEntitlementEnterprise());
        user.getOrg().addRole(RoleFactory.CHANNEL_ADMIN);
    }

    /**
     * {@inheritDoc}
     */
    public void testExecuteSatellite() throws Exception {
        /* This test never finishes correctly on hosted
         * due to the errata deletion stored procedure
         * being painfully slow on hosted. Therefore
         * we will not run the test there.
         */
        return;
        
//        if (!Config.get().isSatellite()) {
//            return;
//        }
        
//     RhnSet errataToDelete = RhnSetFactory.createRhnSet(user.getId(), 
//                             "errata_to_delete", 
//                             SetCleanup.NOOP);
//     
//     List list = new ArrayList();
//     
//     for (int j = 0; j < 5; ++j) {
//         Errata e = createAnErrata(user);
//         list.add(e);
//         errataToDelete.addElement(e.getId());
//     }
//     
//     RhnSetManager.store(errataToDelete);
//     
//     RhnSet set = RhnSetDecl.ERRATA_TO_DELETE.get(user);
//     assertEquals(5, set.size());
//     
//     actionPerform();
//     verifyForward("default");
//     
//     set = RhnSetDecl.ERRATA_TO_DELETE.get(user);
//    
//     assertEquals(0, set.size());
//     
//     Iterator i = list.iterator();
//     
//     /* verify that the errata have indeed been deleted */
//     while (i.hasNext()) {
//         Errata e = (Errata) i.next();
//         TestUtils.flushAndEvict(e);
//         e = ErrataFactory.lookupById(e.getId());
//         assertNull(e);
//     }
    }
    
    /**
     * Creates a published or unpublished errata depending on which
     * type is being tested
     * @param user user who is creating the errata
     * @return the errata
     * @throws Exception if error
     * 
     */
    public abstract Errata createAnErrata(User user) throws Exception;
    
    /**
     * @return the request path
     */
    public abstract String getRequestPath();
}
