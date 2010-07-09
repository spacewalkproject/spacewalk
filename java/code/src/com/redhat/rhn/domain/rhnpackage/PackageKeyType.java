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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * PackageArch
 * @version $Rev$
 */
public class PackageKeyType extends BaseDomainHelper implements Comparable<PackageKeyType> {

    private Long id;
    private String label;

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
    public String getLabel() {
        return label;
    }

    /**
     * @param n The name to set.
     */
    public void setLabel(String n) {
        this.label = n;
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getLabel()).toHashCode();
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean equals(Object keyType) {

        if (keyType instanceof PackageKeyType) {
            PackageKeyType type = (PackageKeyType) keyType;
            return new EqualsBuilder().append(this.label, type.getLabel()).append(getId(),
                    type.getId()).isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(PackageKeyType o) {
        if (equals(o)) {
            return 0;
        }
        if (o == null) {
            return 1;
        }
        return getLabel().compareTo(o.getLabel());
    }

}
