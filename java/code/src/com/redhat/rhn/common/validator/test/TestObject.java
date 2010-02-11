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

package com.redhat.rhn.common.validator.test;

import java.util.Date;

/**
 * TODO: Implement subobject checking
 * 
 * $Rev$
 */
public class TestObject {
    
    private String stringField;
    private Long longField;
    private Date dateField;
    private String compoundField;
    private String secondStringField;
    private Long secondLongField;
    private String numberString;
    private String asciiString;
    private String usernameString;
    private String posixString;
    private String twoCharField;

    
    /**
     * @return the twoCharField
     */
    public String getTwoCharField() {
        return twoCharField;
    }

    
    /**
     * @param twoCharFieldIn the twoCharField to set
     */
    public void setTwoCharField(String twoCharFieldIn) {
        this.twoCharField = twoCharFieldIn;
    }

    public String getSecondStringField() {
        return secondStringField;
    }

    public void setSecondStringField(String secondStringFieldIn) {
        this.secondStringField = secondStringFieldIn;
    }
    
    public void setStringField(String sin) {
        stringField = sin;
    }

    public String getStringField() {
        return stringField;
    }

    public void setLongField(Long lin) {
        longField = lin;
    }

    public Long getLongField() {
        return longField;
    }
    

    public void setDateField(Date din) {
        dateField = din;
    }

    public Date getDateField() {
        return dateField;
    }

    public void setCompoundField(String compoundIn) {
        compoundField = compoundIn;
    }
    
    public String getCompoundField() {
        return compoundField;
    }

    
    /**
     * @return Returns the secondLongField.
     */
    public Long getSecondLongField() {
        return secondLongField;
    }

    
    /**
     * @param secondLongFieldIn The secondLongField to set.
     */
    public void setSecondLongField(Long secondLongFieldIn) {
        this.secondLongField = secondLongFieldIn;
    }

    
    /**
     * @return Returns the numberString.
     */
    public String getNumberString() {
        return numberString;
    }

    
    /**
     * @param numberStringIn The numberString to set.
     */
    public void setNumberString(String numberStringIn) {
        this.numberString = numberStringIn;
    }
    
    /**
     * 
     * @param asciiIn The ascii string to set
     */
    public void setAsciiString(String asciiIn) {
        this.asciiString = asciiIn;  
    }
    
    public String getAsciiString() {
        return asciiString;
    }

    /**
     *
     * @param usernameIn The username string to set
     */
    public void setUsernameString(String usernameIn) {
        this.usernameString = usernameIn;  
    }
    
    /**
     * @return Returns the usernameString.
     */
    public String getUsernameString() {
        return usernameString;
    }

    /**
     * returns the posixString
     * @return
     */
    public String getPosixString() {
        return posixString;
    }

    /**
     * The posixString to set
     * @param posixString
     */
    public void setPosixString(String posixIn) {
        posixString = posixIn;
    }
}
