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

package com.redhat.rhn.common.security.test;

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.common.security.SessionSwapTamperException;
import com.redhat.rhn.testing.RhnBaseTestCase;

import java.util.ArrayList;
import java.util.List;

/**
 * SessionSwapTest, which does what the name suggests
 * @version $Rev$
 */

public class SessionSwapTest extends RhnBaseTestCase {
    private static String singleInput = "deadbeef";
    private static String singleResult = "deadbeefxd91f5c42e0bf4f077d5e019f27835206";

    private static String[] multiInputs = { "acedeed987", "badbeef123" };
    private static String multiResult =
        "acedeed987:badbeef123xed3ddd1d609ec8bb59c5167b6904aec0";

    // DONT CHECK THIS IN EVER!!!
    public void testSessionSwapEncode() throws Exception {
        // ensure results match precomputed values from perl code
        assertEquals(singleResult, SessionSwap.encodeData(singleInput));
        assertEquals(multiResult, SessionSwap.encodeData(multiInputs));

        try {
            SessionSwap.encodeData("this string contains non-hex");
            fail();
        }
        catch (IllegalArgumentException iae) {
            // pass
        }
    }

    public void testSessionSwapExtract() throws Exception {
        String swapToken = SessionSwap.encodeData(singleInput);
        String[] result = SessionSwap.extractData(swapToken);

        assertEquals(1, result.length);
        assertEquals(singleInput, result[0]);

        try {
            result = SessionSwap.extractData("badbadbad" + swapToken);
            fail();
        }
        catch (SessionSwapTamperException sste) {
            // pass
        }
    }

    public void testRhnHmacData() throws Exception {
        List<String> testvalues = new ArrayList<String>();
        testvalues.add("");
        testvalues.add("1");
        testvalues.add("1");
        testvalues.add("/test/path");
        String value = SessionSwap.rhnHmacData(testvalues);
        assertEquals("Check the WEB_SESSION_SWAP_SECRET_* " +
                "variables to make sure they didnt change",
                "a6352e4a91bfb0d480988ed3813e0e77c94ecda8", value);
               //a6352e4a91bfb0d480988ed3813e0e77c94ecda8
    }
}
