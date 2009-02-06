package com.redhat.rhn.taskomatic.task.repomd;

import java.util.Date;

public class RepomdIndexData {
	private String checksum;
	private String openChecksum;
	private Date timestamp;
	
	public RepomdIndexData(String checksum, String openChecksum, Date timestamp) {
		this.checksum = checksum;
		this.openChecksum = openChecksum;
		this.timestamp = timestamp;
	}
	
	public String getChecksum() {
		return checksum;
	}
	public void setChecksum(String checksum) {
		this.checksum = checksum;
	}
	public String getOpenChecksum() {
		return openChecksum;
	}
	public void setOpenChecksum(String openChecksum) {
		this.openChecksum = openChecksum;
	}
	public Date getTimestamp() {
		return timestamp;
	}
	public void setTimestamp(Date timestamp) {
		this.timestamp = timestamp;
	}
}
