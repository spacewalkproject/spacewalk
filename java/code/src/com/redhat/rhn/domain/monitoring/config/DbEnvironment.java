/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.domain.monitoring.config;



/**
 * DbEnvironment - Class representation of the table rhn_db_environment.
 * @version $Rev: 1 $
 */
public class DbEnvironment {

    private String dbName;
    private String environment;
    /** 
     * Getter for dbName 
     * @return String to get
    */
    public String getDbName() {
        return this.dbName;
    }

    /** 
     * Setter for dbName 
     * @param dbNameIn to set
    */
    public void setDbName(String dbNameIn) {
        this.dbName = dbNameIn;
    }

    /** 
     * Getter for environment 
     * @return String to get
    */
    public String getEnvironment() {
        return this.environment;
    }

    /** 
     * Setter for environment 
     * @param environmentIn to set
    */
    public void setEnvironment(String environmentIn) {
        this.environment = environmentIn;
    }

}
