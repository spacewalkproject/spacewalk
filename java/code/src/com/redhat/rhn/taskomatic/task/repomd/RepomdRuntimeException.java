package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.RhnRuntimeException;

public class RepomdRuntimeException extends RhnRuntimeException {
	
	public RepomdRuntimeException() {
		super();
	}
	
	public RepomdRuntimeException(String msg) {
		super(msg);
	}
	
	public RepomdRuntimeException(Throwable cause) {
	    super(cause);
	}

	private static final long serialVersionUID = 59953070843471704L;

}
