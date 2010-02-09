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
 * InvalidTimeZoneException thrown when an invalid timezone is passed in as
 * an argument.  TimeZone's are invalid if it does not exist in the
 * <code>rhn_timezone</code> table.
 * @version $Rev$
 */
public class InvalidTimeZoneException extends FaultException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 6530929336847535373L;

    /**
     * constructor
     * @param tzid invalid timezone id
     */
    public InvalidTimeZoneException(int tzid) {
        super(2500, "invalidTimeZoneId", tzid + " is an invalid timezone id");
    }

    /**
     * constructor
     * @param tzid invalid timezone id
     * @param cause exception being wrapped
     */
    public InvalidTimeZoneException(int tzid, Throwable cause) {
        super(2500, "invalidTimeZoneId", tzid +
                " is an invalid timezone id", cause);
    }
}
