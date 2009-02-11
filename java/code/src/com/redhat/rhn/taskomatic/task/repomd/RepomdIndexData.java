package com.redhat.rhn.taskomatic.task.repomd;

import java.util.Date;

public class RepomdIndexData {
	private String checksum;
	private String openChecksum;
	private Date timestamp;
	
	/**
	 * 
	 * @param checksum checksum info
	 * @param openChecksum open checksum info
	 * @param timestamp
	 */
	public RepomdIndexData(String checksum, String openChecksum, Date timestamp) {
		this.checksum = checksum;
		this.openChecksum = openChecksum;
		this.timestamp = timestamp;
	}
	/**
	 * 
	 * @return checksum info
	 */
	public String getChecksum() {
		return checksum;
	}
	/**
	 * 
	 * @param checksum The checksum to set.
	 */
	public void setChecksum(String checksum) {
		this.checksum = checksum;
	}
	/**
	 * 
	 * @return The open checksum
	 */
	public String getOpenChecksum() {
		return openChecksum;
	}
	/**
	 * 
	 * @param openChecksum The open checksum to set.
	 */
	public void setOpenChecksum(String openChecksum) {
		this.openChecksum = openChecksum;
	}
	/**
	 * 
	 * @return Returns timestamp
	 */
	public Date getTimestamp() {
		return timestamp;
	}
	/**
	 * 
	 * @param timestamp The timestamp to set.
	 */
	public void setTimestamp(Date timestamp) {
		this.timestamp = timestamp;
	}
}
