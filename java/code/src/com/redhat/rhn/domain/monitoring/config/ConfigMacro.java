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
package com.redhat.rhn.domain.monitoring.config;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ConfigMacro - Class representation of the table rhn_config_macro.
 * @version $Rev: 1 $
 */
public class ConfigMacro implements Serializable {

    private String name;
    private String definition;
    private String description;
    private String editable;
    private String lastUpdateUser;
    private Date lastUpdateDate;

    /** 
     * Getter for name 
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for definition 
     * @return String to get
    */
    public String getDefinition() {
        return this.definition;
    }

    /** 
     * Setter for definition 
     * @param definitionIn to set
    */
    public void setDefinition(String definitionIn) {
        this.definition = definitionIn;
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
     * Getter for editable 
     * @return String to get
    */
    public String getEditable() {
        return this.editable;
    }

    /** 
     * Setter for editable 
     * @param editableIn to set
    */
    public void setEditable(String editableIn) {
        this.editable = editableIn;
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
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(name)
                .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ConfigMacro)) {
            return false;
        }
        ConfigMacro castOther = (ConfigMacro) other;
        return new EqualsBuilder()
                .append(name, castOther.name).isEquals();
    }

}
