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
package com.redhat.rhn.domain.user;

import java.util.Date;

/**
 * UserServerPreference - Class representation of the table rhnUserServerprefs.
 * @version $Rev: 1 $
 */
public class UserServerPreference {
    private UserServerPreferenceId id;
    private String value;
    private Date created;
    private Date modified;

    /**
     * Getter for value
     * @return String to get
    */
    public String getValue() {
        return this.value;
    }

    /**
     * Setter for value
     * @param valueIn to set
    */
    public void setValue(String valueIn) {
        this.value = valueIn;
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
     * @return Returns the id.
     */
    public UserServerPreferenceId getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(UserServerPreferenceId idIn) {
        this.id = idIn;
    }

}
