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
package com.redhat.rhn.common;


/**
 * A generic unchecked exception that may be used to wrap checked exceptions we cannot
 * handle or do not expect. SQLException is a good example of a checked exception that
 * we may want to wrap in an unchecked exception because we typically cannot do much of
 * anything with it.
 *
 * <br/><br/>
 *
 * Custom, unchecked exceptions should extend RhnRuntimeException so that we can provide
 * generic error handling, reporting, logging, etc.
 *
 * @version $Rev$
 */
public class RhnRuntimeException extends RuntimeException {

    /**
     *
     */
    public RhnRuntimeException() {
    }

    /**
     * @param msg An error message
     */
    public RhnRuntimeException(String msg) {
        super(msg);
    }

    /**
     * @param t The Throwable to wrap
     */
    public RhnRuntimeException(Throwable t) {
        super(t);
    }

    /**
     * @param msg An error message
     * @param t The Throwable to wrap
     */
    public RhnRuntimeException(String msg, Throwable t) {
        super(msg, t);
    }

}
