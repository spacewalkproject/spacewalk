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
package com.redhat.rhn.domain.solaris.test;

import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.solaris.PatchType;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.hibernate.Session;

/**
 * PatchTypeTest
 * @version $Rev$
 */
public class PatchTypeTest extends RhnBaseTestCase {

    /**
     * Simple test to make sure we can lookup PatchTypes from
     * the db. Turn on hibernate.show_sql to make sure hibernate
     * is only going to the db once.
     * @throws Exception HibernateException
     */
    public void testPatchType() throws Exception {


        PatchType p1 = lookupByLabel("temporary");
        PatchType p2 = lookupByLabel("temporary");

        assertNotNull(p1.getName());
        assertEquals(p1.getName(), p2.getName());
    }

    public static PatchType lookupByLabel(String label) throws Exception {
       Session session = null;

       session = HibernateFactory.getSession();

       return (PatchType) session.getNamedQuery("PatchType.findByLabel")
                                           .setString("label", label)
                                           //Retrieve from cache if there
                                           .setCacheable(true)
                                           .uniqueResult();
    }

}
