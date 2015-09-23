/**
 * Copyright (c) 2015 SUSE LLC
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

import com.redhat.rhn.domain.common.LoggingFactory;

import org.jmock.cglib.MockObjectTestCase;

/**
 * RhnJmockBaseTestCase - This is the same thing as {@link RhnBaseTestCase}
 * but it extends from {@link MockObjectTestCase}.
 */
public abstract class RhnJmockBaseTestCase extends MockObjectTestCase {

    /**
     * Called once per test method.
     *
     * @throws Exception if an error occurs during test setup
     */
    protected void setUp() throws Exception {
        super.setUp();
        try {
            LoggingFactory.clearLogId();
        }
        catch (Exception se) {
            TestCaseHelper.tearDownHelper();
            LoggingFactory.clearLogId();
        }
    }

    /**
     * Called once per test method to clean up.
     *
     * @throws Exception if an error occurs during tear down
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        TestCaseHelper.tearDownHelper();
    }
}
