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

package com.redhat.rhn.domain.role;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * Class Role that reflects the DB representation of RHNUSERGROUP
 * DB table: RHNUSERGROUP
 * @version $Rev$
 */
public class RoleImpl extends BaseDomainHelper implements Role {

    private Long id;
    private String name;
    private String label;


    /**
     * Protected constructor
     */
    protected RoleImpl() {
    }

    /** {@inheritDoc} */
    public Long getId() {
        return this.id;
    }

    /** Setter for id */
    protected void setId(Long idIn) {
        this.id = idIn;
    }

    /** {@inheritDoc} */
    public String getLabel() {
        return this.label;
    }

    /** {@inheritDoc} */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /** {@inheritDoc} */
    public String getName() {
        return this.name;
    }

    /** {@inheritDoc} */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** {@inheritDoc} */
    public String toString() {
        return "RoleImpl.label: " + label;
    }

    /** {@inheritDoc} */
    public boolean equals(final Object other) {
        if (!(other instanceof RoleImpl)) {
            return false;
        }
        RoleImpl castOther = (RoleImpl) other;
        return new EqualsBuilder().append(getName(),
                castOther.getName()).append(getLabel(),
                castOther.getLabel()).isEquals();
    }

    /** {@inheritDoc} */
    public int hashCode() {
        return new HashCodeBuilder().append(getName()).
            append(getLabel()).toHashCode();
    }

}
