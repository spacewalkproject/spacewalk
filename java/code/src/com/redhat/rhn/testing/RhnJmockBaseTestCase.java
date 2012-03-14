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

import org.jmock.Mock;
import org.jmock.cglib.MockObjectTestCase;

import javax.servlet.http.HttpServletRequest;

/**
 *
 * RhnJmockBaseTestCase - Add a bit of cleanup logic to the MockObjectTestCase
 * @version $Rev$
 */
public abstract class RhnJmockBaseTestCase extends MockObjectTestCase {

    /**
     * {@inheritDoc}
     */
    protected void tearDown() throws Exception {
        // TODO Auto-generated method stub
        super.tearDown();
        TestCaseHelper.tearDownHelper();
    }

    /**
     * Add a variable to the Mocked request object
     * @param mreq Mock of the HttpServletRequest object
     * @param name of the parameter
     * @param value value of the param
     */
    public void addRequestParam(Mock mreq, String name, String value) {
        if (!(mreq.proxy() instanceof HttpServletRequest)) {
            throw new IllegalArgumentException(
                    "mreq must be a proxy/mock of a HttpServletRequest");
        }
        mreq.expects(atLeastOnce()).method("getParameter").
            with(eq(name)).will(returnValue(value));
    }
    /**
     * Util for turning of the spew from the l10n service for
     * test cases that make calls with dummy string IDs.
     */
    public static void disableLocalizationServiceLogging() {
        RhnBaseTestCase.disableLocalizationServiceLogging();
    }

    /**
     * Util for turning on the spew from the l10n service for
     * test cases that make calls with dummy string IDs.
     */
    public static void enableLocalizationServiceLogging() {
        RhnBaseTestCase.enableLocalizationServiceLogging();
    }

}
