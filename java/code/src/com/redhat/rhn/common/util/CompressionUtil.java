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

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

/**
 * 
 * CompressionUtil
 * @version $Rev$
 */
public class CompressionUtil {

    private CompressionUtil() {
    }
    
    /**
     * Gzip compress a string
     * @param string the string to compress
     * @return the compressed data
     */
    public static byte[] gzipCompress(String string) {
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        try {
            GZIPOutputStream gz = new GZIPOutputStream(stream);
            BufferedOutputStream bufos = new BufferedOutputStream(gz);
            bufos.write(string.getBytes());
            bufos.flush();
            bufos.close();
            return stream.toByteArray();
            
        }
        catch (IOException e) {
            return null;
        }
    }
    
    /**
     * unzip some gzip compressed data
     * @param bytes the data to uncompress
     * @return the uncompressed data
     */
    public static String gzipDecompress(byte[] bytes) {
        ByteArrayInputStream stream = new ByteArrayInputStream(bytes);
        String toRet = "";
        try {
            GZIPInputStream gs = new GZIPInputStream(stream);
            BufferedInputStream bufis = new BufferedInputStream(gs);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            byte[] buf = new byte[1024];
            int len;
            while ((len = bufis.read(buf)) > 0) {
              bos.write(buf, 0, len);
            }
            return bos.toString();
        }
        catch (IOException e) {
            return null;
        }
    }
    
    
}
