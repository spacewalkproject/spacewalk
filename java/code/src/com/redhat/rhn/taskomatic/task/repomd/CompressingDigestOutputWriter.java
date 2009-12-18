/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.util.StringUtil;

import java.io.Closeable;
import java.io.Flushable;
import java.io.IOException;
import java.io.OutputStream;
import java.security.DigestOutputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.zip.GZIPOutputStream;

/**
 * 
 * @version $Rev $
 * 
 */
public class CompressingDigestOutputWriter extends OutputStream implements
        Closeable, Flushable {

    private DigestOutputStream uncompressedDigestStream;
    private DigestOutputStream compressedDigestStream;
    private OutputStream compressedStream;

    /**
     * 
     * @param stream The stream to compress
     * @param checksumAlgo checksum algorithm
     */
    public CompressingDigestOutputWriter(OutputStream stream, String checksumAlgo) {
        try {
            compressedDigestStream = new DigestOutputStream(stream,
                    MessageDigest.getInstance(checksumAlgo));
            compressedStream = new GZIPOutputStream(compressedDigestStream);
            uncompressedDigestStream = new DigestOutputStream(compressedStream,
                    MessageDigest.getInstance(checksumAlgo));
        }
        catch (NoSuchAlgorithmException nsae) {
            // XXX fatal runtime exception
        }
        catch (IOException ioe) {
            // XXX fatal runtime exception
        }
    }

    /**
     * write stream
     * @param arg0 int arg
     * @throws IOException ioexception
     */
    public void write(int arg0) throws IOException {
        uncompressedDigestStream.write(arg0);
    }

    /**
     * write stream with byte
     * @param b byte
     * @throws IOException ioexception
     */
    public void write(byte[] b) throws IOException {
        uncompressedDigestStream.write(b);
    }

    /**
     * flush stream
     * @throws IOException ioexception
     */
    public void flush() throws IOException {
        uncompressedDigestStream.flush();
    }

    /**
     * close stream
     * @throws IOException ioexception
     */
    public void close() throws IOException {
        uncompressedDigestStream.close();
    }

    /**
     * 
     * @return Returns the HexString of the Uncompressed digest stream
     */
    public String getUncompressedChecksum() {
        return StringUtil.getHexString(uncompressedDigestStream
                .getMessageDigest().digest());
    }

    /**
     * 
     * @return Returns the HexString of the compressed digest stream
     */
    public String getCompressedChecksum() {
        return StringUtil.getHexString(compressedDigestStream
                .getMessageDigest().digest());
    }

}
