package com.redhat.rhn.taskomatic.task.repomd;

import com.redhat.rhn.common.RhnRuntimeException;

public class RepomdRuntimeException extends RhnRuntimeException {
    /**
     * Default constructor
     */
	public RepomdRuntimeException() {
		super();
	}
	/**
	 * Constructor takes in a msg
	 * @param msg
	 */
	public RepomdRuntimeException(String msg) {
		super(msg);
	}
	/**
	 * Constructor takes in a cause
	 * @param cause
	 */
	public RepomdRuntimeException(Throwable cause) {
	    super(cause);
	}

	private static final long serialVersionUID = 59953070843471704L;

}
