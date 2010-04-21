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

package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;

/**
 * no such cobbler system record
 * <p>
 *
 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class NoSuchCobblerSystemRecordException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 4245255424549337483L;

    /**
     * Constructor
     */
    public NoSuchCobblerSystemRecordException() {
        this("No such cobbler system record");
    }

    /**
     * Constructor
     * @param cause the cause (which is saved for later retrieval by the
     * Throwable.getCause() method). (A null value is permitted, and indicates
     * that the cause is nonexistent or unknown.)
     */
    public NoSuchCobblerSystemRecordException(Throwable cause) {
        super(-214, "noSuchCobblerSystemRecord", "No such cobbler system record", cause);
    }

    /**
     * Constructor
     * @param message exception message
     */
    public NoSuchCobblerSystemRecordException(String message) {
        super(-214, "noSuchCobblerSystemRecord", message);
    }
}
