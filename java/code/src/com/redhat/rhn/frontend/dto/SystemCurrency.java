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
package com.redhat.rhn.frontend.dto;

import java.io.Serializable;
import java.util.Date;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev: 1743 $
 */
public class SystemCurrency extends BaseDto implements Serializable  {

    private String statusDisplay;
    private Long id;
    private Long critical;
    private Long important;
    private Long moderate;
    private Long low;
    private Long bug;
    private Long enhancement;
    private String name;
    private Date created;
    private Date modified;

    /**
     * @return Returns the statusDisplay.
     */
    public String getStatusDisplay() {
        return statusDisplay;
    }
    /**
     * @param statusDisplayIn The statusDisplay to set.
     */
    public void setStatusDisplay(String statusDisplayIn) {
        this.statusDisplay = statusDisplayIn;
    }

    /**
     * @return Returns the system id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    /**
     * @return Returns the critical count.
     */
    public Long getCritical() {
        return critical;
    }
    /**
     * @param criticalIn The critical to set.
     */
    public void setCritical(Long criticalIn) {
        this.critical = criticalIn;
    }
    /**
     * @return Returns the important count.
     */
    public Long getImportant() {
        return important;
    }
    /**
     * @param importantIn The important to set.
     */
    public void setImportant(Long importantIn) {
        this.important = importantIn;
    }
    /**
     * @return Returns the critical count.
     */
    public Long getModerate() {
        return moderate;
    }
    /**
     * @param moderateIn The moderate to set.
     */
    public void setModerate(Long moderateIn) {
        this.moderate = moderateIn;
    }
    /**
     * @return Returns the low count.
     */
    public Long getLow() {
        return low;
    }
    /**
     * @param lowIn The low to set.
     */
    public void setLow(Long lowIn) {
        this.low = lowIn;
    }
    /**
     * @return Returns the bug count.
     */
    public Long getBug() {
        return bug;
    }
    /**
     * @param bugIn The bug to set.
     */
    public void setBug(Long bugIn) {
        this.bug = bugIn;
    }
    /**
     * @return Returns the enhancement count.
     */
    public Long getEnhancement() {
        return enhancement;
    }
    /**
     * @param enhancementIn The enhancement to set.
     */
    public void setEnhancement(Long enhancementIn) {
        this.enhancement = enhancementIn;
    }
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }
    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }
    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }
    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

}
