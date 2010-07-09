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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.domain.action.Action;

import java.util.Date;

/**
 * ConfigDateFileAction - Class representation of the table rhnActionConfigDateFile.
 *
 * @version $Rev$
 */
public class ConfigDateAction extends Action {

    private Long actionId;
    private Date startDate;
    private Date endDate;
    private String importContents;
    private Date configDateCreated;
    private Date configDateModified;

    /**
     * Getter for actionId
     * @return Long to get
    */
    public Long getActionId() {
        return this.actionId;
    }

    /**
     * Setter for actionId
     * @param actionIdIn to set
    */
    public void setActionId(Long actionIdIn) {
        this.actionId = actionIdIn;
    }

    /**
     * Getter for startDate
     * @return Date to get
    */
    public Date getStartDate() {
        return this.startDate;
    }

    /**
     * Setter for startDate
     * @param startDateIn to set
    */
    public void setStartDate(Date startDateIn) {
        this.startDate = startDateIn;
    }

    /**
     * Getter for endDate
     * @return Date to get
    */
    public Date getEndDate() {
        return this.endDate;
    }

    /**
     * Setter for endDate
     * @param endDateIn to set
    */
    public void setEndDate(Date endDateIn) {
        this.endDate = endDateIn;
    }

    /**
     * Getter for importContents
     * @return String to get
    */
    public String getImportContents() {
        return this.importContents;
    }

    /**
     * Setter for importContents
     * @param importContentsIn to set
    */
    public void setImportContents(String importContentsIn) {
        this.importContents = importContentsIn;
    }

    /**
     * @return Returns the configDateCreated.
     */
    public Date getConfigDateCreated() {
        return configDateCreated;
    }

    /**
     * @param configDateCreatedIn The configDateCreated to set.
     */
    public void setConfigDateCreated(Date configDateCreatedIn) {
        this.configDateCreated = configDateCreatedIn;
    }
    /**
     * @return Returns the configDateModified.
     */
    public Date getConfigDateModified() {
        return configDateModified;
    }
    /**
     * @param configDateModifiedIn The configDateModified to set.
     */
    public void setConfigDateModified(Date configDateModifiedIn) {
        this.configDateModified = configDateModifiedIn;
    }
 }
