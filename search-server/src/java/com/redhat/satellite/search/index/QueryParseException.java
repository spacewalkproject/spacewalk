/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.index;


/**
 * QueryParseException thrown if there is a problem parsing the query input.
 * @version $Rev$
 */
public class QueryParseException extends Exception {
    /**
     * Simple no-arg constructor
     */
    public QueryParseException() {
        super();
    }

    /**
     * Constructor
     * @param message error message
     * @param cause root cause
     */
    public QueryParseException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Constructor
     * @param message error message
     */
    public QueryParseException(String message) {
        super(message);
    }

    /**
     * Constructor
     * @param cause root cause
     */
    public QueryParseException(Throwable cause) {
        super(cause);
    }
}
