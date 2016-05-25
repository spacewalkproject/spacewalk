/**
 * Copyright (c) 2016 SUSE LLC
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

package com.redhat.rhn.frontend.taglibs.test;

import com.redhat.rhn.testing.RhnMockServletOutputStream;
import org.jmock.Expectations;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;

/**
 * Helper class for testing CSV export.
 */
public class CSVMockTestHelper {

    /**
     * Returns the expectations of {@link HttpServletResponse} when CSV Export is performed.
     * @param response the response
     * @param out - the output stream
     * @return the expectations
     * @throws IOException if something goes wrong
     */
    public static Expectations getCsvExportParameterExpectations(
            HttpServletResponse response,
            RhnMockServletOutputStream out) throws IOException {
        return new Expectations() { {
            atLeast(1).of(response).getCharacterEncoding();
            will(returnValue("UTF-8"));
            atLeast(1).of(response).setContentType("text/csv;charset=UTF-8");
            atLeast(1).of(response).setHeader("Content-Disposition",
                    "attachment; filename=download.csv");
            atLeast(1).of(response).getOutputStream();
            will(returnValue(out));
        } };
    }
}
