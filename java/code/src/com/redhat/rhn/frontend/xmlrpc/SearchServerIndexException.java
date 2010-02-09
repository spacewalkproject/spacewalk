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
 * SearchServerIndexException is used to note inconsistencies between search server indexes
 * and database values
 * @version $Rev$
 */
public class SearchServerIndexException extends FaultException {

    /**
     *
     */
    private static final long serialVersionUID = 1L;

    /**
     * Constructor
     *
     */
    public SearchServerIndexException() {
        super(2903, "errorWithSearchIndex",
                "Search server index out of sync with database.");
    }

    /**
     * Constructor
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is
     * permitted, and indicates that the cause is nonexistent or
     * unknown.)
     */
    public SearchServerIndexException(Throwable cause) {
        super(2903 , "errorWithSearchIndex" ,
                "Search server index out of sync with database." , cause);
    }

    /**
     * Constructor with message.
     * @param message exception message.
     */
    public SearchServerIndexException(String message) {
        super(2903 , "errorWithSearchIndex", message);
    }


}
