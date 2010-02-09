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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.common.ArchType;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.server.ServerArch;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Set;

/**
 * ChannelArch
 * @version $Rev$
 */
public class ChannelArch extends BaseDomainHelper {

    private Long id;
    private String label;
    private String name;
    private ArchType archType;
    private Set compatibleServerArches;
    private Set compatiblePackageArches;

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
     * Returns the set of server architectures compatible with this channel
     * architecture.
     * @return the set of server architectures compatible with this channel
     * architecture.
     */
    public Set getCompatibleServerArches() {
        return compatibleServerArches;
    }

    /**
     * Returns the set of package architectures compatible with this channel
     * architecture.
     * @return the set of package architectures compatible with this channel
     * architecture.
     */
    public Set getCompatiblePackageArches() {
        return compatiblePackageArches;
    }

    /**
     * Returns true if the given server architecture is compatible with this
     * channel architecture. False if the server architecture is null or not
     * compatible.
     * @param arch Server architecture to be verified.
     * @return true if compatible; false if null or not compatible.
     */
    public boolean isCompatible(ServerArch arch) {
        Set compats = getCompatibleServerArches();
        if (compats == null) {
            return false;
        }

        return compats.contains(arch);
    }

    /**
     * Returns true if the given package architecture is compatible with this
     * channel architecture. False if the package architecture is null or not
     * compatible.
     * @param arch Package architecture to be verified.
     * @return true if compatible; false if null or not compatible.
     */
    public boolean isCompatible(PackageArch arch) {
        Set compats = getCompatiblePackageArches();
        if (compats == null) {
            return false;
        }

        return compats.contains(arch);
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ChannelArch)) {
            return false;
        }

        ChannelArch castOther = (ChannelArch) other;
        return new EqualsBuilder().append(this.getId(), castOther.getId()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId()).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("id", this.getId()).append("label",
                this.getLabel()).append("name", this.getName()).append("archType",
                this.getArchType()).toString();
    }

    /**
     * @param arches The compatible package arches to set.
     */
    public void setCompatiblePackageArches(Set<PackageArch> arches) {
        compatiblePackageArches = arches;
    }

}
