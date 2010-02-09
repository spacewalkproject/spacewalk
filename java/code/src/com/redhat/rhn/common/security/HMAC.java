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
package com.redhat.rhn.common.security;

import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/**
 * A class to generate Hashed Message Authentication Codes.
 *
 * @version $Rev$
 */
public class HMAC {

    private HMAC() {
    }

    private static final String HEXCHARS = "0123456789abcdef";

    /**
     * Convert a byte array to a hex string of the format
     * "1f 30 b7".  package protected so that SessionSwap can use it.
     * @param a The byte array to convert
     * @return the resulting hex string
     */
    public static String byteArrayToHex(byte[] a) {
        int hn, ln, cx;
        StringBuffer buf = new StringBuffer(a.length * 2);
        for (cx = 0; cx < a.length; cx++) {
            hn = ((a[cx]) & 0x00ff) / 16;
            ln = (a[cx]) & 0x000f;
            buf.append(HEXCHARS.charAt(hn));
            buf.append(HEXCHARS.charAt(ln));
        }
        return buf.toString();
    }

    /** 
     * Generate an HMAC hash for the given text and key using SHA1 as the 
     * hash function.
     * @param text The text to hash
     * @param key The key to use when generating the hash.
     * @return The resulting hash string
     */
    public static String sha1(String text, String key) {
        try {
            SecretKey skey = new SecretKeySpec(key.getBytes(), "HMACSHA1");
            Mac mac = Mac.getInstance(skey.getAlgorithm());
            mac.init(skey);
            mac.update(text.getBytes());
            return byteArrayToHex(mac.doFinal());
        }
        catch (NoSuchAlgorithmException e) {
            throw new IllegalArgumentException("No such alg: " + e);
        }
        catch (InvalidKeyException e) {
            throw new IllegalArgumentException("Invalid key: " + e);
        }
    }

    /** 
     * Generate an HMAC hash for the given text and key using MD5 as the 
     * hash function.
     * @param text The text to hash
     * @param key The key to use when generating the hash.
     * @return The resulting hash string
     * TODO: Make this use the JDK MD5 algorithm as above vs
     * the custom one below.
     */
    public static String md5(String text, String key) {
        return generate(text, key, "MD5");
    }
    
    private static String generate(String text, String key, String algorithm) {
        MessageDigest msgDigest = null;
        try {
            msgDigest = MessageDigest.getInstance(algorithm);
        }
        catch (NoSuchAlgorithmException e) {
            throw new IllegalArgumentException("Algorithm " + algorithm + 
                                               " not found");
        }

        byte[] keyBytes;
        /* if key is longer than 64 bytes reset it to key=MD5(key) */
        if (key.length() > 64) {
            msgDigest.update(key.getBytes());
            keyBytes = msgDigest.digest();
            msgDigest.reset();
        }
        else {
            keyBytes = key.getBytes();
        }
        byte[] temp = new byte[64];
        for (int i = 0; i < 64; i++) {
            if (i < keyBytes.length) {
                temp[i] = keyBytes[i];
            }
            else {
                temp[i] = 0;
            }
        }
        keyBytes = temp;
        
        /*
         * the HMAC_MD5 transform looks like:
         *
         * MD5(K XOR opad, MD5(K XOR ipad, text))
         *
         * where K is an n byte key
         * ipad is the byte 0x36 repeated 64 times
         * opad is the byte 0x5c repeated 64 times
         * and text is the data being protected
         */

        /* start out by storing key in pads */
        byte[] iPad = new byte[64];
        byte[] oPad = new byte[64];

        /* XOR key with ipad and opad values */
        for (int i = 0; i < 64; i++) {
            iPad[i] = (byte)(keyBytes[i] ^ 0x36);
            oPad[i] = (byte)(keyBytes[i] ^ 0x5c);
        }
        
        msgDigest.update(iPad);
        msgDigest.update(text.getBytes());
        byte[] digest = msgDigest.digest();
        msgDigest.reset();

        msgDigest.update(oPad);
        msgDigest.update(digest);
        byte[] res = msgDigest.digest();
        return byteArrayToHex(res);
    }
}
