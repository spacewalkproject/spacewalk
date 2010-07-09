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
package com.redhat.rhn.domain.monitoring.command;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * Metric - Class representation of the table rhn_metrics.
 * @version $Rev: 1 $
 */
public class Metric implements Serializable {

    private String metricId;
    private String storageUnitId;
    private String description;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private String label;

    private String commandClass;
    /**
     * Getter for metricId
     * @return String to get
    */
    public String getMetricId() {
        return this.metricId;
    }

    /**
     * Setter for metricId
     * @param metricIdIn to set
    */
    public void setMetricId(String metricIdIn) {
        this.metricId = metricIdIn;
    }

    /**
     * Getter for storageUnitId
     * @return String to get
    */
    public String getStorageUnitId() {
        return this.storageUnitId;
    }

    /**
     * Setter for storageUnitId
     * @param storageUnitIdIn to set
    */
    public void setStorageUnitId(String storageUnitIdIn) {
        this.storageUnitId = storageUnitIdIn;
    }

    /**
     * Getter for description
     * @return String to get
    */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * @param descriptionIn to set
    */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for label
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /**
     * Setter for label
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Metric)) {
            return false;
        }
        Metric castOther = (Metric) other;
        return new EqualsBuilder().append(metricId, castOther.getMetricId()).append(
                commandClass, castOther.getCommandClass()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(metricId).append(commandClass)
                .toHashCode();
    }

    /**
     * @return Returns the commandClassTest.
     */
    public String getCommandClass() {
        return commandClass;
    }
    /**
     * @param commandClassIn The commandClassIn to set.
     */
    public void setCommandClass(String commandClassIn) {
        this.commandClass = commandClassIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("metricId", metricId).append(
                "storageUnitId", storageUnitId).append("description",
                description).append("lastUpdateUser", lastUpdateUser).append(
                "lastUpdateDate", lastUpdateDate).append("label", label)
                .append("commandClass", commandClass).append(
                        "commandClass", commandClass).toString();
    }

}
