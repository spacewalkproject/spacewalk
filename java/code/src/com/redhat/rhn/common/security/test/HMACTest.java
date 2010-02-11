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

import com.redhat.rhn.common.security.HMAC;
import com.redhat.rhn.testing.RhnBaseTestCase;

/*
 * Test for HMAC
 *
 * @version $Rev$
 */
public class HMACTest extends RhnBaseTestCase {

    public void doTestSHA1(String data, String key, String expect)
        throws Exception {
       
        String value = HMAC.sha1(data, key);
        assertEquals(expect, value);
    }

    public void doTestMD5(String data, String key, String expect)
        throws Exception {
       
        String value = HMAC.md5(data, key);
        assertEquals(expect, value);
    }

    public void testDataKeySHA1() throws Exception {
        doTestSHA1("data", "key", "104152c5bfdca07bc633eebd46199f0255c9f49d");
    }

    public void testDataKeyMD5() throws Exception {
        doTestMD5("data", "key", "9d5c73ef85594d34ec4438b7c97e51d8");
    }

    public void testLongKeySHA1() throws Exception {
        doTestSHA1("data", 
      "this is a very long key to see if that breaks the implementation, xxxx", 
                   "fba60ff23634892fa139a3a24de8514562fc9c8c");
    }

    public void testlongkeymd5() throws Exception {
        doTestMD5("data", 
      "this is a very long key to see if that breaks the implementation, xxxx", 
                  "582c5a52823a09b071b2577eb9ccad28");
    }
}
