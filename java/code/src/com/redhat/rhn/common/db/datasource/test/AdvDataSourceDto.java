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
package com.redhat.rhn.common.db.datasource.test;



/**
 * AdvDataSourceDto
 * @version $Rev$
 */
public class AdvDataSourceDto {
    private Long id;
    private Long pin;
    private String testColumn;
    private String foobar;
    
    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param idIn the id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * @return the pin
     */
    public Long getPin() {
        return pin;
    }
    
    /**
     * @param pinIn the pin to set
     */
    public void setPin(Long pinIn) {
        this.pin = pinIn;
    }
    
    /**
     * @return the testColumn
     */
    public String getTestColumn() {
        return testColumn;
    }
    
    /**
     * @param testColumnIn the testColumn to set
     */
    public void setTestColumn(String testColumnIn) {
        this.testColumn = testColumnIn;
    }
    
    /**
     * @return the foobar
     */
    public String getFoobar() {
        return foobar;
    }
    
    /**
     * @param foobarIn the foobar to set
     */
    public void setFoobar(String foobarIn) {
        this.foobar = foobarIn;
    }
    
}
