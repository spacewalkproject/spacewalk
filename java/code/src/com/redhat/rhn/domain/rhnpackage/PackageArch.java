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
import com.redhat.rhn.domain.common.ArchType;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * PackageArch
 * @version $Rev$
 */
public class PackageArch extends BaseDomainHelper implements Comparable<PackageArch> {

    private ArchType archType;
    private Long id;
    private String label;
    private String name;

    /**
     * @return Returns the archType.
     */
    public ArchType getArchType() {
        return archType;
    }

    /**
     * @param a The archType to set.
     */
    public void setArchType(ArchType a) {
        this.archType = a;
    }

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
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param l The label to set.
     */
    public void setLabel(String l) {
        this.label = l;
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
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getName()).append(getLabel()).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("id", this.getId()).append("label", this.getLabel()).append("name",
                this.getName());

        if (this.getArchType() != null) {
            builder.append("archType", this.getArchType());
        }
        return builder.toString();
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean equals(Object archIn) {

        if (archIn instanceof PackageArch) {
            PackageArch arch = (PackageArch) archIn;
            return new EqualsBuilder().append(this.name, arch.getName()).append(getLabel(),
                    arch.getLabel()).append(getId(), arch.getId()).append(getArchType(),
                    arch.getArchType()).isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(PackageArch o) {
        if (equals(o)) {
            return 0;
        }
        if (o == null) {
            return 1;
        }
        return getLabel().compareTo(o.getLabel());
    }
}
