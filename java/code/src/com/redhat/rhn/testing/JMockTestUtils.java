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

import org.jmock.cglib.MockObjectTestCase;

import javax.servlet.ServletOutputStream;

/**
 * JMockTestUtils - simple util class for helping with utilization of jmock's API
 * @version $Rev$
 */
public class JMockTestUtils extends MockObjectTestCase {

    /**
     * Add the proper params to the mock request to work with unit tests that
     * excercise CSV export functionality
     * @param mresp mock response
     * @param out ServletOutputStream to write output to
     */
    public void addExportParameters(org.jmock.Mock mresp, ServletOutputStream out) {
        mresp.expects(atLeastOnce()).method("getCharacterEncoding")
                .withNoArguments().will(returnValue("UTF-8"));
        mresp.expects(atLeastOnce()).method("setContentType").with(
                eq("text/csv;charset=UTF-8"));
        mresp.expects(atLeastOnce()).method("setHeader").with(
                eq("Content-Disposition"),
                eq("attachment; filename=download.csv"));
        mresp.expects(atLeastOnce()).method("getOutputStream")
                .withNoArguments().will(returnValue(out));
    }

    /**
     * Add the proper params to the mock request to work with unit tests that
     * excercise CSV export functionality
     * @param mresp mock response
     * @param out ServletOutputStream to write output to
     */
    public static void setupExportParameters(org.jmock.Mock mresp,
            ServletOutputStream out) {
        new JMockTestUtils().addExportParameters(mresp, out);
    }

}
