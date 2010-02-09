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
package com.redhat.rhn.domain.action;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * ActionStatus
 * @version $Rev$
 */
public class ActionStatus {
    
    private Long id;
    private String name;
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param n The name to set.
     */
    public void setName(String n) {
        this.name = n;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof ActionStatus)) {
            return false;
        }
        ActionStatus other = (ActionStatus)o;
        return new EqualsBuilder().append(this.getName(), other.getName())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        StringBuffer result = new StringBuffer();
        result.append(name);
        return result.toString();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getName())
                                    .toHashCode();
    }
}
