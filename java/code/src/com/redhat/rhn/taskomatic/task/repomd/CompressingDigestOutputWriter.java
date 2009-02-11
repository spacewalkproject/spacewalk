package com.redhat.rhn.taskomatic.task.repomd;

import java.io.Closeable;
import java.io.Flushable;
import java.io.IOException;
import java.io.OutputStream;
import java.security.DigestOutputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.zip.GZIPOutputStream;

import com.redhat.rhn.common.util.StringUtil;


public class CompressingDigestOutputWriter extends OutputStream implements Closeable, Flushable {
	
	private DigestOutputStream uncompressedDigestStream;
	private DigestOutputStream compressedDigestStream;
	private OutputStream compressedStream;
	
	/**
	 * 
	 * @param stream The stream to compress
	 */
	public CompressingDigestOutputWriter(OutputStream stream) {
		try {
			compressedDigestStream = new DigestOutputStream(stream, MessageDigest.getInstance("SHA1"));
			compressedStream = new GZIPOutputStream(compressedDigestStream);
			uncompressedDigestStream = new DigestOutputStream(compressedStream, MessageDigest.getInstance("SHA1"));
		} 
		catch (NoSuchAlgorithmException nsae) {
			// XXX fatal runtime exception
		} 
		catch (IOException ioe) {
			// XXX fatal runtime exception
		}
	}

	public void write(int arg0) throws IOException {
		uncompressedDigestStream.write(arg0);
	}
	
	public void write (byte[] b) throws IOException {
		uncompressedDigestStream.write(b);
	}
	
	public void flush() throws IOException {
		uncompressedDigestStream.flush();
	}
	
	public void close() throws IOException {
		uncompressedDigestStream.close();
	}
	/**
	 * 
	 * @return Returns the HexString of the Uncompressed digest stream
	 */
	public String getUncompressedChecksum() {
		return StringUtil.getHexString(uncompressedDigestStream.getMessageDigest().digest());
	}
    /**
     * 
     * @return Returns the HexString of the compressed digest stream
     */
	public String getCompressedChecksum() {
		return StringUtil.getHexString(compressedDigestStream.getMessageDigest().digest());
	}

}
