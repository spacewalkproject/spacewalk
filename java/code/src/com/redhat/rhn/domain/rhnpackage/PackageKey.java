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
public class PackageKey extends BaseDomainHelper implements Comparable<PackageKey> {

    private Long id;
    private String key;
    private PackageProvider provider;
    private PackageKeyType type;

    /**
     * @return Returns the type.
     */
    public PackageKeyType getType() {
        return type;
    }

    /**
     * @param typeIn The type to set.
     */
    public void setType(PackageKeyType typeIn) {
        this.type = typeIn;
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
     * @return Returns the name.
     */
    public String getKey() {
        return key;
    }

    /**
     * @param n The name to set.
     */
    public void setKey(String n) {
        this.key = n;
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getKey()).toHashCode();
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean equals(Object archIn) {

        if (archIn instanceof PackageKey) {
            PackageKey arch = (PackageKey) archIn;
            return new EqualsBuilder().append(this.key, arch.getKey()).append(getId(),
                    arch.getId()).isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(PackageKey o) {
        if (equals(o)) {
            return 0;
        }
        if (o == null) {
            return 1;
        }
        return getKey().compareTo(o.getKey());
    }

    /**
     * gets the provider associated with the gpg key
     * @return the provider
     */
    public PackageProvider getProvider() {
        return provider;
    }

    /**
     * sets the provider
     * @param providerIn the provider
     */
    public void setProvider(PackageProvider providerIn) {
        this.provider = providerIn;
    }
}
