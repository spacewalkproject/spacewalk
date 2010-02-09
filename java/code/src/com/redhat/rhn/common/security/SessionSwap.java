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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;

/**
 * SessionSwap, a class to handle secure data manipulations in a way
 * consistent with SessionSwap from the perl codebase.  Effectively a
 * wrapper to make it a bit easier to exchange data with different
 * parts of our codebase that speak different languages.  A session
 * swap token is basically a tuple of a certain form that contains N
 * pieces of hex data and a signature that is based on a shared
 * secret.  Someday this should become a true HMAC, but for now, it is
 * an older algorithm.
 * 
 * @version $Rev$
 */

public class SessionSwap {
    
    private static Logger log = Logger.getLogger(SessionSwap.class);

    public static final char[] HEX_CHARS = {'0', '1', '2', '3',
                                             '4', '5', '6', '7',
                                             '8', '9', 'a', 'b',
                                             'c', 'd', 'e', 'f' };

    /** utility class, no public constructor  */
    private SessionSwap() {
    }

    /** given an array of strings, compute the hex session swap, which
     * contains both the original data and the 'signature'.  so the
     * resulting string is encapsulated and can be passed around as
     * 'signed' data.
     * 
     * @param in an array of strings, all of which must be valud hex
     * @return String of the signature, in the form "D1:D2:D3xHEX"
     *         where D1... are the input data and HEX is the hex signature.
     */
    public static String encodeData(String[] in) {
        for (int i = 0; i < in.length; i++) {
            if (!StringUtils.containsOnly(in[i], HEX_CHARS)) {
                throw new IllegalArgumentException("encodeData input must be " +
                                                   "lowercase hex, but wasn't: " + in[i]);
            }
        }

        String joined = StringUtils.join(in, ':');

        String[] components = new String[] { joined, generateSwapKey(joined) };

        return StringUtils.join(components, "x");
    }

    /** 
     * simple wrapper around encodeData(String[]) for easier consumption 
     * @see SessionSwap#encodeData(String[]) encodeData
     * @param in The data to encode
     * @return The reulting session swap string.
     */
    public static String encodeData(String in) {
        return encodeData(new String[] { in });
    }

    /** given a session swap string, this will crack it open and
     * return the data.  
     * @param in The session swap to inspect.
     * @return The data extracted from the session swap
     * @throws SessionSwapTamperException if the data was
     *         tampered with, making it easy to use and trust 
     */
    public static String[] extractData(String in) {
        String[] splitResults = StringUtils.split(in, 'x');
        String[] data = StringUtils.split(splitResults[0], ':');

        String recomputedDigest = encodeData(data);

        if (recomputedDigest.equals(in)) {
            return data;
        }
        throw new SessionSwapTamperException(in);
    }
    /**
     * compute the md5sum of
     * key1:key2:(data):key3:key4.  
     * @param data to compute
     * @return computed data
     */
    public static String generateSwapKey(String data) {
        Config c = Config.get();
        StringBuffer swapKey = new StringBuffer(20);
        
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_1));
        swapKey.append(":");
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_2));
        swapKey.append(":");
        swapKey.append(data);
        swapKey.append(":");
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_3));
        swapKey.append(":");
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_4));
        return computeMD5Hash(swapKey.toString());
    }
    
    /**
     * compute md5sum for any arbitrary text
     * 
     * @param text text to hash
     * @return md5 computed hash value
     */
    public static String computeMD5Hash(String text) {
        // TODO This should be merged with the md5 method(s)
        // in HMAC
        MessageDigest digest = null;
        try {
            digest = MessageDigest.getInstance("MD5");
        }
        catch (NoSuchAlgorithmException e) {
            // this really shouldn't happen.  really.            
            throw new IllegalArgumentException("Unable to instantiate MD5 " + 
                    "MessageDigest algorithm");
        }
        digest.update(text.getBytes());
        return HMAC.byteArrayToHex(digest.digest());
    }
    
    /**
     * Takes an array of strings and SHA1 hashes the 'joined' results.
     * 
     * This is a port of the RHN::SessionSwap:rhn_hmac_data method.
     * 
     * @param text array to SHA1 hash
     * @return String of hex chars
     */
    public static String rhnHmacData(List<String> text) {
        
        Config c = Config.get();
        StringBuffer swapKey = new StringBuffer(20);
        if (log.isDebugEnabled()) {
            for (String tmp : text) {
                log.debug("val : " + tmp);
            }
        }
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_4));
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_3));
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_2));
        swapKey.append(c.getString(ConfigDefaults.WEB_SESSION_SWAP_SECRET_1));
        
        String joinedText = StringUtils.join(text.iterator(), "\0");
        
        
        if (log.isDebugEnabled()) {
            log.debug("Data     : [" + joinedText + "]");
            log.debug("Key      : [" + swapKey + "]");
        }
        String retval = HMAC.sha1(joinedText, swapKey.toString());
        if (log.isDebugEnabled()) {
            log.debug("retval: " + retval);
        }
        return retval;
    }

}
