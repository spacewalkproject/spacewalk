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
package com.redhat.rhn.domain.kickstart;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.Date;

/**
 * KickstartSessionState - Class representation of the table rhnkickstartsessionstate.
 * @version $Rev: 1 $
 */
public class KickstartSessionState {

    public static final String CREATED                 = "created";
    public static final String DEPLOYED                = "deployed";
    public static final String INJECTED                = "injected";
    public static final String RESTARTED               = "restarted";
    public static final String CONFIGURATION_ACCESSED  = "configuration_accessed";
    public static final String STARTED                 = "started";
    public static final String IN_PROGRESS             = "in_progress";
    public static final String REGISTERED              = "registered";
    public static final String PACKAGE_SYNCH           = "package_synch";
    public static final String PACKAGE_SYNCH_SCHEDULED = "package_synch_scheduled";
    public static final String CONFIGURATION_DEPLOY    = "configuration_deploy";
    public static final String COMPLETE                = "complete";
    public static final String FAILED                  = "failed";

    private Long id;
    private String label;
    private String name;
    private String description;
    private Date created;
    private Date modified;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
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
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof KickstartSessionState)) {
            return false;
        }
        KickstartSessionState castOther = (KickstartSessionState) other;
        return new EqualsBuilder().append(this.getId(),
                castOther.getId()).append(this.getLabel(),
                castOther.getLabel()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId()).
            append(this.getLabel()).toHashCode();
    }

}
