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

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.hibernate.TransactionException;

/**
 * TestCaseHelper - helper class to contain some common logic
 * between a few of our base unit test classes.
 *
 * @version $Rev$
 */
public class TestCaseHelper {

    private TestCaseHelper() {
    }

    /**
     * shared logic for tearing down resources used in our unit tests
     */
    public static void tearDownHelper() {
        TransactionException rollbackException = null;
        if (HibernateFactory.inTransaction()) {
            try {
                HibernateFactory.rollbackTransaction();
                //HibernateFactory.commitTransaction();
            }
            catch (TransactionException e) {
                rollbackException = e;
            }
        }
        HibernateFactory.closeSession();
        if (rollbackException != null) {
            throw rollbackException;
        }
        // In case someone disabled it and forgot to
        // renable it.
        RhnBaseTestCase.enableLocalizationServiceLogging();

    }

}
