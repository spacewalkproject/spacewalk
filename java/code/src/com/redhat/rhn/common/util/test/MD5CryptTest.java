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
package com.redhat.rhn.common.util.test;

import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.testing.RhnBaseTestCase;

/**
 * MD5CryptTest
 * @version $Rev$
 */
public class MD5CryptTest extends RhnBaseTestCase {
    
    /** Test the crypt function
     */
    public void testCrypt() {
        String key = "%43AazZ09!@#$%^&*()-+=/.~`?;:<>,";
        String salt = "testsalttest";
        
        /**
         * Ensure crypt(key) generates a random
         * 8 character salt.
         */
        String c1 = MD5Crypt.crypt(key);
        assertNotNull(c1);
        assertEquals(c1.charAt(11), '$');
        
        /**
         * Make sure the crypt(key, salt) works
         */
        String c2 = MD5Crypt.crypt(key, salt);
        String c3 = MD5Crypt.crypt(key, salt);
        assertEquals(c2, c3);
        //Make sure salt was truncated
        assertEquals(c2.charAt(11), '$');
        //Make sure our salt was used
        assertTrue(c2.startsWith("$1$testsalt"));
        c2 = c2.substring(12); //get encoded password
        assertNotNull(c2);
    }

    /** Test the crypt function
     */
    public void testMD5Hex() {
        String someString = "somestringtohex";
        String hexified = MD5Crypt.md5Hex(someString);
        assertNotNull(hexified);
        assertEquals("ff7191cd699b5e89db7ee6c7b3c79f62", hexified);
    }

}
