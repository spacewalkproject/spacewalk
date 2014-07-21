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

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * SHA256Crypt
 * Utility class to create/check SHA256 passwords
 * Passwords are in the format of $1$salt$encodedpassword.
 */
public class SHA256Crypt {

    private static Integer saltLength = 16; // SHA-256 encoded password salt length

    /**
     * SHA256Crypt
     */
    private SHA256Crypt() {
    }

    /**
     * getSHA256MD - get SHA256 MessageDigest object instance
     * @return MessageDigest object instance
     */
    private static MessageDigest getSHA256MD() {
        MessageDigest md;

        try {
            md = MessageDigest.getInstance("SHA-256");
        }
        catch (NoSuchAlgorithmException e) {
            throw new SHA256CryptException("Problem getting SHA-256 message digest");
        }

        return md;
    }

    /**
     * generateEncodedKey - Handles generating the encoded key from the final digest
     * @param digest - Digest to use for encoding
     * @param salt - salt to prepend to output
     * @return Returns encoded string $1$salt$encodedkey
     */
    private static String generateEncodedKey(byte[] digest, String salt) {
        StringBuilder out = new StringBuilder(CryptHelper.getSHA256Prefix());
        out.append(salt);
        out.append("$");

        int val = ((digest[ 0] << 16) & 0x00ffffff) |
                  ((digest[10] <<  8) &   0x00ffff) |
                   (digest[20]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[21] << 16) & 0x00ffffff) |
              ((digest[ 1] <<  8) &   0x00ffff) |
               (digest[11]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[12] << 16) & 0x00ffffff) |
              ((digest[22] <<  8) &   0x00ffff) |
               (digest[ 2]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[ 3] << 16) & 0x00ffffff) |
              ((digest[13] <<  8) &   0x00ffff) |
               (digest[23]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[24] << 16) & 0x00ffffff) |
              ((digest[ 4] <<  8) &   0x00ffff) |
               (digest[14]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[15] << 16) & 0x00ffffff) |
              ((digest[25] <<  8) &   0x00ffff) |
               (digest[ 5]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[ 6] << 16) & 0x00ffffff) |
              ((digest[16] <<  8) &   0x00ffff) |
               (digest[26]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[27] << 16) & 0x00ffffff) |
              ((digest[ 7] <<  8) &   0x00ffff) |
               (digest[17]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[18] << 16) & 0x00ffffff) |
              ((digest[28] <<  8) &   0x00ffff) |
               (digest[ 8]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((digest[ 9] << 16) & 0x00ffffff) |
              ((digest[19] <<  8) &   0x00ffff) |
               (digest[29]        &       0xff);
        out.append(CryptHelper.to64(val, 4));

        val = ((((byte) 0)    << 16) & 0x00ffffff) |
              ((digest[31] <<  8) &      0x00ffff) |
               (digest[30]        &          0xff);
        out.append(CryptHelper.to64(val, 3));

        return out.toString();
    }

    /**
     * crypt - method to help in setting passwords.
     * @param key - The key to encode
     * @return Returns a string in the form of "$1$RandomSalt$encodedkey"
     */
    public static String crypt(String key) {
        return crypt(key, CryptHelper.generateRandomSalt(saltLength));
    }

    /**
     * crypt
     * Encodes a key using a salt (s) in the same manner as the perl crypt() function
     * @param key - The key to encode
     * @param s - The salt
     * @return Returns a string in the form of "$1$salt$encodedkey"
     * @throws SHA256CryptException
     */
    public static String crypt(String key, String s) {
        final byte[] keyBytes = key.getBytes();
        final int keyLen = keyBytes.length;

        String salt = CryptHelper.getSalt(s, CryptHelper.getSHA256Prefix(), saltLength);
        final byte[] saltBytes = salt.getBytes();
        final int saltLen = saltBytes.length;

        final int blocksize = 32;

        MessageDigest ctx = getSHA256MD();
        ctx.update(keyBytes);  // add the key/salt to the first digest
        ctx.update(saltBytes);

        MessageDigest altCtx = getSHA256MD();
        altCtx.update(keyBytes);  // add the key/salt/key to the second digest
        altCtx.update(saltBytes);
        altCtx.update(keyBytes);

        byte[] altResult = altCtx.digest();

        int cnt = keyBytes.length;
        while (cnt > blocksize) {
            ctx.update(altResult, 0, blocksize);
            cnt -= blocksize;
        }

        ctx.update(altResult, 0, cnt);

        cnt = keyBytes.length;
        while (cnt > 0) {
            if ((cnt & 1) != 0) {
                ctx.update(altResult, 0, blocksize);
            }
            else {
                ctx.update(keyBytes);
            }
            cnt >>= 1;
        }

        altResult = ctx.digest();

        altCtx = getSHA256MD();

        for (int i = 1; i <= keyLen; i++) {
            altCtx.update(keyBytes);
        }

        byte[] tempResult = altCtx.digest();

        final byte[] pBytes = new byte[keyLen];
        int cp = 0;
        while (cp < keyLen - blocksize) {
            System.arraycopy(tempResult, 0, pBytes, cp, blocksize);
            cp += blocksize;
        }
        System.arraycopy(tempResult, 0, pBytes, cp, keyLen - cp);

        altCtx = getSHA256MD();

        for (int i = 1; i <= 16 + (altResult[0] & 0xff); i++) {
            altCtx.update(saltBytes);
        }

        tempResult = altCtx.digest();

        final byte[] sBytes = new byte[saltLen];
        cp = 0;
        while (cp < saltLen - blocksize) {
            System.arraycopy(tempResult, 0, sBytes, cp, blocksize);
            cp += blocksize;
        }
        System.arraycopy(tempResult, 0, sBytes, cp, saltLen - cp);

        for (int i = 0; i <= 5000 - 1; i++) {
            ctx = getSHA256MD();
            if ((i & 1) != 0) {
                ctx.update(pBytes, 0, keyLen);
            }
            else {
                ctx.update(altResult, 0, blocksize);
            }

            if (i % 3 != 0) {
                ctx.update(sBytes, 0, saltLen);
            }

            if (i % 7 != 0) {
                ctx.update(pBytes, 0, keyLen);
            }

            if ((i & 1) != 0) {
                ctx.update(altResult, 0, blocksize);
            }
            else {
                ctx.update(pBytes, 0, keyLen);
            }

            altResult = ctx.digest();
        }

        return generateEncodedKey(altResult, salt);
    }
}
