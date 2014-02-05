/**
 * Copyright (c) 2014 Red Hat, Inc.
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
package com.redhat.rhn.domain.org.usergroup;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;


/**
 * UserGroupMembers
 * @version $Rev$
 */
public class UserGroupMembers extends BaseDomainHelper implements Serializable {

    private User user;
    private UserGroup userGroup;
    private boolean temporary;

    /**
     * Constructor
     */
    public UserGroupMembers() {
        temporary = false;
    }

    /**
     * Constructor
     * @param userIn user
     * @param ugIn user group
     */
    public UserGroupMembers(User userIn, UserGroup ugIn) {
        user = userIn;
        userGroup = ugIn;
        temporary = false;
    }

    /**
     * Constructor
     * @param userIn user
     * @param ugIn user group
     * @param tempIn temporary flag
     */
    public UserGroupMembers(User userIn, UserGroup ugIn, boolean tempIn) {
        user = userIn;
        userGroup = ugIn;
        temporary = tempIn;
    }

    /**
     * @return Returns the user.
     */
    public User getUser() {
        return user;
    }

    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        user = userIn;
    }

    /**
     * @return Returns the userGroup.
     */
    public UserGroup getUserGroup() {
        return userGroup;
    }

    /**
     * @param userGroupIn The userGroup to set.
     */
    public void setUserGroup(UserGroup userGroupIn) {
        userGroup = userGroupIn;
    }

    /**
     * @return Returns the temporary.
     */
    public boolean getTemporary() {
        return temporary;
    }

    /**
     * @param temporaryIn The temporary to set.
     */
    public void setTemporary(boolean temporaryIn) {
        temporary = temporaryIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (o == null || !(o instanceof UserGroupMembers)) {
            return false;
        }
        UserGroupMembers other = (UserGroupMembers) o;
        return new EqualsBuilder()
            .append(this.getUser(), other.getUser())
            .append(this.getUserGroup(), other.getUserGroup())
            .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder()
            .append(this.getUser())
            .append(this.getUserGroup())
            .append(this.getTemporary())
            .toHashCode();
    }
}
