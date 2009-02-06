package com.redhat.rhn.taskomatic.task.repomd;

import java.io.Closeable;
import java.io.Flushable;
import java.io.IOException;
import java.io.OutputStream;
import java.security.DigestOutputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.zip.GZIPOutputStream;

import org.bouncycastle.crypto.digests.MD5Digest;

public class CompressingDigestOutputWriter extends OutputStream implements Closeable, Flushable {
	
	private DigestOutputStream uncompressedDigestStream;
	private DigestOutputStream compressedDigestStream;
	private OutputStream compressedStream;
	
	
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
	
	public String getUncompressedChecksum() {
		return HexStringUtils.getHexString(uncompressedDigestStream.getMessageDigest().digest());
	}

	public String getCompressedChecksum() {
		return HexStringUtils.getHexString(compressedDigestStream.getMessageDigest().digest());
	}

}
