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
package com.redhat.rhn.domain.server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;


/**
 * EntitledServerGroup
 * @version $Rev$
 */
public class EntitlementServerGroup extends ServerGroup {
    private Long maxMembers;

    /**
     * returns true if this group is user managed, false
     * otherwise.
     * @return true if this group is user managed, false
     * otherwise.
     */
    public boolean isUserManaged() {
        return false;
    }

    /**
     * Getter for maxMembers
     * @return Long to get
    */
    public Long getMaxMembers() {
        return this.maxMembers;
    }

    /**
     * Setter for maxMembers
     * @param maxMembersIn to set
    */
    public void setMaxMembers(Long maxMembersIn) {
        this.maxMembers = maxMembersIn;
    }


    /**
     * Report the number of systems that can currently be added to this group.
     * @return ServerGroup.UNLIMITED if infinite.
     *         (maxmembers - current members) otherwise
     */
    public long getAvailableSlots() {
        if (getMaxMembers() == null) {
            return UNLIMITED;
        }
        //Now do the actual math.
        return getMaxMembers().longValue() - getCurrentMembers().longValue();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(super.hashCode())
                                    .append(getMaxMembers())
                                    .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object other) {
        if (!(other instanceof EntitlementServerGroup)) {
            return false;
        }
        EntitlementServerGroup castOther = (EntitlementServerGroup) other;
        if (!super.equals(other)) {
            return false;
        }
        return new EqualsBuilder().append(getMaxMembers(), castOther.getMaxMembers())
                                  .append(getCurrentMembers(),
                                              castOther.getCurrentMembers())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append(super.toString()).
                    append("maxMembers", getMaxMembers()).append("currentMembers",
                                    getCurrentMembers()).toString();
    }
}
