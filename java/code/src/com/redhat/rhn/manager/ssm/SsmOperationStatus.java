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
package com.redhat.rhn.manager.ssm;

/**
 * @author Jason Dobies
 * @version $Revision$
 */
public enum SsmOperationStatus {

    /**
     * Represents an operation that has been started by the user but is still running.
     */
    IN_PROGRESS("In Progress"),

    /**
     * Represents an operation that has finished processing; this status does not indicate
     * any degree of success or failure of the operation.
     */
    COMPLETED("Completed");

    /**
     * Actual text stored in the database.
     */
    private String text;

    private SsmOperationStatus(String textIn) {
        this.text = textIn;
    }

    /**
     * Returns the textual representation of a particular enum instance.
     * 
     * @return will not be <code>null</code>
     */
    public String getText() {
        return this.text;
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        return text;
    }
}
