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

import java.util.HashSet;
import java.util.Set;

/**
 * PackageArch
 * @version $Rev$
 */
public class PackageProvider extends BaseDomainHelper implements
        Comparable<PackageProvider> {

    private Long id;
    private String name;
    private Set<PackageKey> keys = new HashSet<PackageKey>();

    /**
     * @return Returns the keys.
     */
    public Set<PackageKey> getKeys() {
        return keys;
    }

    /**
     * @param keysIn The keys to set.
     */
    public void setKeys(Set<PackageKey> keysIn) {
        this.keys = keysIn;
    }

    /**
     * Add a package key to this provider
     * @param key the key to add
     */
    public void addKey(PackageKey key) {
        this.getKeys().add(key);
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
        return new HashCodeBuilder().append(getName()).toHashCode();
    }

    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object archIn) {

        if (archIn instanceof PackageProvider) {
            PackageProvider arch = (PackageProvider) archIn;
            return new EqualsBuilder().append(this.name, arch.getName()).append(getId(),
                    arch.getId()).isEquals();
        }
        else {
            return false;
        }
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(PackageProvider o) {
        if (equals(o)) {
            return 0;
        }
        if (o == null) {
            return 1;
        }
        return getName().compareTo(o.getName());
    }
}
