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
package com.redhat.rhn.common.util;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Copied from: http://www.koders.com/java/fidEC98D99B347D738A2B560EA856B93ADEABCF6B4E.aspx
 * @version $Rev$
 */
public class MD5Sum {
    
    // 2,147,483,647 bytes OR 2.1GB
    public static final int SCOUR_MD5_BYTE_LIMIT = Integer.MAX_VALUE;
    private static MessageDigest md = null;

    private MD5Sum() {
    }

    /**
     * Method: md5Sum Purpose: calculate the MD5 in a way compatible with how
     * the scour.net protocol encodes its passwords (incidentally, it also
     * outputs a string identical to the md5sum unix command).
     * @param str the String from which to calculate the sum
     * @return the MD5 checksum
     */
    public static String md5Sum(String str) {
        try {
            return md5Sum(str.getBytes("UTF-8"));
        }
        catch (UnsupportedEncodingException e) {
            throw new IllegalStateException(e.getMessage());
        }
    }

    /**
     * MD5Sum the byte array
     * 
     * @param input to sum
     * @return String md5sum
     */
    public static String md5Sum(byte[] input) {
        return md5Sum(input, -1);
    }

    /**
     * mdsum the byte array with a limit
     * @param input to sum
     * @param limit to stop at
     * @return String md5sum 
     */
    public static String md5Sum(byte[] input, int limit) {
        try {
            if (md == null) {
                md = MessageDigest.getInstance("MD5");
            }

            md.reset();
            byte[] digest;

            if (limit == -1) {
                digest = md.digest(input);
            }
            else {
                md.update(input, 0, limit > input.length ? input.length : limit);
                digest = md.digest();
            }

            StringBuffer hexString = new StringBuffer();

            for (int i = 0; i < digest.length; i++) {
                hexString.append(hexDigit(digest[i]));
            }

            return hexString.toString();
        }
        catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e.getMessage());
        }
    }

    /**
     * Method: hexDigit Purpose: convert a hex digit to a String, used by
     * md5Sum.
     * @param x the digit to translate
     * @return the hex code for the digit
     */
    private static String hexDigit(byte x) {
        StringBuffer sb = new StringBuffer();
        char c;

        // First nibble
        c = (char) ((x >> 4) & 0xf);
        if (c > 9) {
            c = (char) ((c - 10) + 'a');
        }
        else {
            c = (char) (c + '0');
        }

        sb.append(c);

        // Second nibble
        c = (char) (x & 0xf);
        if (c > 9) {
            c = (char) ((c - 10) + 'a');
        }
        else {
            c = (char) (c + '0');
        }

        sb.append(c);
        return sb.toString();
    }

    /**
     * Method: getFileMD5Sum Purpose: get the MD5 sum of a file. Scour exchange
     * only counts the first SCOUR_MD5_BYTE_LIMIT bytes of a file for
     * caclulating checksums (probably for efficiency or better comaprison
     * counts against unfinished downloads).
     * @param f the file to read
     * @return the MD5 sum string
     * @throws IOException on IO error
     */
    public static String getFileMD5Sum(File f) throws IOException {
        String sum = null;

        byte[] barray = FileUtils.readByteArrayFromFile(f, 0, f.length());
        sum = md5Sum(barray, SCOUR_MD5_BYTE_LIMIT);

        return sum;
    }

}
