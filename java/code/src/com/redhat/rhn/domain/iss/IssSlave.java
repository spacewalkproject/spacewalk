/**
 * Copyright (c) 2013 Red Hat, Inc.
 * All Rights Reserved.
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
 *
 */
package com.redhat.rhn.domain.iss;

import java.util.Date;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * IssSlave - Class representation of the table rhnissslave.
 *
 * @version $Rev: 1 $
 */
public class IssSlave extends BaseDto {
    public static final long NEW_SLAVE_ID = -1L;
    public static final String ID = "id";
    public static final String FQDN = "fqdn";
    public static final String ENABLED = "enabled";
    public static final String ALLOWED_ALL_ORGS = "allowAllOrgs";
    public static final String CREATED = "created";
    public static final String MODIFIED = "modified";

    /** salve-id parameter name */
    public static final String SID = "sid";

    private Long id;
    private String fqdn;
    private String enabled;
    private String allowAllOrgs;
    private Date created;
    private Date modified;

    /**
     * Getter for id
     *
     * @return Long to get
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     *
     * @param idIn
     *            to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for Fqdn
     *
     * @return String to get
     */
    public String getFqdn() {
        return this.fqdn;
    }

    /**
     * Setter for fqdn
     *
     * @param fqdnIn
     *            to set
     */
    public void setFqdn(String fqdnIn) {
        this.fqdn = fqdnIn;
    }

    /**
     * Getter for enabled
     *
     * @return true if enabled = 'Y', false otherwise
     */
    public String getEnabled() {
        return this.enabled;
    }

    /**
     * Setter for enabled
     *
     * @param enabledIn
     *            to set
     */
    public void setEnabled(String enabledIn) {
        this.enabled = enabledIn;
    }

    /**
     * Getter for allowAllOrgs
     *
     * @return String to get
     */
    public String getAllowAllOrgs() {
        return this.allowAllOrgs;
    }

    /**
     * Setter for allowAllOrgs
     *
     * @param allowAllOrgsIn
     *            to set
     */
    public void setAllowAllOrgs(String allowAllOrgsIn) {
        this.allowAllOrgs = allowAllOrgsIn;
    }

    /**
     * Getter for created
     *
     * @return Date to get
     */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     *
     * @param createdIn
     *            to set
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     *
     * @return Date to get
     */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     *
     * @param modifiedIn
     *            to set
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

}
