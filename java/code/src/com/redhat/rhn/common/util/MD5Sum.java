/**
 * Copyright (c) 2009--2016 Red Hat, Inc.
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
import java.io.FileInputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Copied from: http://www.koders.com/java/fidEC98D99B347D738A2B560EA856B93ADEABCF6B4E.aspx
 * @version $Rev$
 */
public class MD5Sum {

    // limit for byte array in memory - 2,147,483,647 bytes OR 2.1GB
    public static final int SCOUR_MD5_BYTE_LIMIT = Integer.MAX_VALUE;

    // buffer size to read file by chunks - 4 MB
    public static final int MD5_BUFFER_SIZE = 1024 * 1024 * 4;

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

            StringBuilder hexString = new StringBuilder();

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
        StringBuilder sb = new StringBuilder();
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
     * Method: getFileMD5Sum Purpose: get the MD5 sum of a file.
     * @param f the file to read
     * @return the MD5 sum string
     * @throws IOException on IO error
     * @throws MD5CryptException on getting MD5 MessageDigest instance
     */
    public static String getFileMD5Sum(File f) throws IOException, MD5CryptException {
        try {
            if (md == null) {
                md = MessageDigest.getInstance("MD5");
            }
        }
        catch (NoSuchAlgorithmException e) {
            throw new MD5CryptException(
                    "Problem getting MD5 message digest " + "(NoSuchAlgorithm Exception).");
        }

        md.reset();
        FileInputStream fis = new FileInputStream(f);

        byte[] dataBuffer = new byte[MD5_BUFFER_SIZE];

        int nread = 0;

        while ((nread = fis.read(dataBuffer)) != -1) {
            md.update(dataBuffer, 0, nread);
        }

        fis.close();

        byte[] digest = md.digest();

        StringBuilder hexString = new StringBuilder();

        for (int i = 0; i < digest.length; i++) {
            hexString.append(hexDigit(digest[i]));
        }

        return hexString.toString();

    }

}
