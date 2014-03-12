/**
 * Copyright (c) 2014 Red Hat, Inc.
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

package com.redhat.rhn.common.util;

import java.util.Random;

/**
 * CryptHelper - utility class for crypto routines
 */
public class CryptHelper {
    private static String b64t = // a string containing acceptable salt chars
        "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    /**
     * CryptHelper
     */
    private CryptHelper() {
    }

    /**
     * getSalt - Cleans salt parameter
     * @param salt - string in question
     * @return Returns the salt portion of passed-in salt
     */
    static String getSalt(String salt, String prefix, Integer saltLength) {
        // If salt starts with prefix ($1$, $5$) then discard that portion of it
        if (salt.startsWith(prefix)) {
            salt = salt.substring(prefix.length());
        }

        // If we recieve a string such as $1$salt$something else, we only want
        // to keep the salt portion of it
        int end = salt.indexOf('$');
        if (end != -1) {
            salt = salt.substring(0, end);
        }

        // Ensure salt length is <= saltLength
        if (salt.length() > saltLength) {
            salt = salt.substring(0, saltLength);
        }

        return salt;
    }

    /**
     * to64 - Utility function for generateEncodedKey
     * @param value value
     * @param length length
     * @return String
     */
    static String to64(int value, int length) {
        StringBuffer out = new StringBuffer();

        while (length > 0) {
            out.append(b64t.substring((value & 0x3f), (value & 0x3f) + 1));
            --length;
            value >>= 6;
        }
        return out.toString();
    }

    /**
     * generateRandomSalt - function to generate random salt string
     * @param saltLength - length of the salt string to generate
     * @return String
     */
    static String generateRandomSalt(Integer saltLength) {
        StringBuffer salt = new StringBuffer();
        Random r = new Random();

        for (int i = 0; i < saltLength; i++) {
            int rand = r.nextInt(b64t.length());
            salt.append(b64t.charAt(rand));
        }

        return salt.toString();
    }
}
