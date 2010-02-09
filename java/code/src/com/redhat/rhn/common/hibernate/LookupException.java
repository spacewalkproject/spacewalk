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

/*
 * AUTOMATICALLY GENERATED FILE, DO NOT EDIT.
 */
package com.redhat.rhn.common.hibernate;

import com.redhat.rhn.common.db.DatabaseException;

/**
 * Thrown if the the object couldn't be found, or it multiple objects were found
 * <p>

 *
 * @version definition($Rev: 76724 $)/template($Rev: 67725 $)
 */
public class LookupException extends DatabaseException  {

    private String localizedTitle;
    private String localizedReason1;
    private String localizedReason2;

    /////////////////////////
    // Constructors
    /////////////////////////
    /**
     * Constructor
     * @param message exception message
     */
    public LookupException(String message) {
        super(message);
        setDefaults();
    }

    /**
     * Constructor
     * @param message exception message
     * @param cause the cause (which is saved for later retrieval
     * by the Throwable.getCause() method). (A null value is 
     * permitted, and indicates that the cause is nonexistent or 
     * unknown.)
     */
    public LookupException(String message, Throwable cause) {
        super(message, cause);
        setDefaults();
    }
    
    private void setDefaults() {
        localizedTitle = "lookup.default.title";
        localizedReason1 = "lookup.default.reason1";
        localizedReason2 = "lookup.default.reason2";
    }
    
    
    /**
     * @return Returns the localizedReason1.
     */
    public String getLocalizedReason1() {
        return localizedReason1;
    }
    
    
    /**
     * @param reason1KeyIn The localizedReason1 to set.
     */
    public void setLocalizedReason1(String reason1KeyIn) {
        localizedReason1 = reason1KeyIn;
    }
    
    
    /**
     * @return Returns the localizedReason2.
     */
    public String getLocalizedReason2() {
        return localizedReason2;
    }
    
    
    /**
     * @param reason2KeyIn The localizedReason2 to set.
     */
    public void setLocalizedReason2(String reason2KeyIn) {
        localizedReason2 = reason2KeyIn;
    }
    
    
    /**
     * @return Returns the localizedTitle.
     */
    public String getLocalizedTitle() {
        return localizedTitle;
    }
    
    
    /**
     * @param titleKeyIn The localizedTitle to set.
     */
    public void setLocalizedTitle(String titleKeyIn) {
        localizedTitle = titleKeyIn;
    }

}
