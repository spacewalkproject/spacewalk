/**
 * Copyright (c) 2011 Red Hat, Inc.
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
 * InvalidChecksumLabelException
 * @version $Rev$
 */
public class InvalidChecksumLabelException extends FaultException {

    /**
     * Constructor
     */
    public InvalidChecksumLabelException() {
        super(1210, "invalidChecksumLabelLabel", "Invalid checksum label");
    }

    /**
     * Constructor
     * @param label the profile label
     */
    public InvalidChecksumLabelException(String label) {
        super(1210, "invalidChecksumLabelLabel", "Invalid checksum label: " + label);
    }
}
