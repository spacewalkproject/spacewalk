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
package com.redhat.rhn.domain.token;

import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * TokenPackage
 * @version $Rev$
 */
public class TokenPackage implements Identifiable {

    private Long id;
    private Token token;
    private PackageName packageName;
    private PackageArch packageArch;

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
     * @return Returns the token.
     */
    public Token getToken() {
        return token;
    }

    /**
     * @param t The token to set.
     */
    public void setToken(Token t) {
        this.token = t;
    }

    /**
     * @return Returns the package name.
     */
    public PackageName getPackageName() {
        return packageName;
    }

    /**
     * @param n The package name to set.
     */
    public void setPackageName(PackageName n) {
        this.packageName = n;
    }

    /**
     * @return Returns the package name.
     */
    public PackageArch getPackageArch() {
        return packageArch;
    }

    /**
     * @param a The package arch to set.
     */
    public void setPackageArch(PackageArch a) {
        this.packageArch = a;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        ToStringBuilder builder = new ToStringBuilder(this);
        builder.append("id", getId())
               .append("token", getToken())
               .append("packageName", getPackageName());

        if (this.getPackageArch() != null) {
            builder.append("packageArch", getPackageArch());
        }
        return builder.toString();
    }

    /**
     *
     * {@inheritDoc}
     */
    public boolean equals(Object other) {

        if (!(other instanceof TokenPackage)) {
            return false;
        }
        TokenPackage otherPack = (TokenPackage) other;

        EqualsBuilder builder = new EqualsBuilder();
        builder.append(getToken(), otherPack.getToken());
        builder.append(getPackageName(), otherPack.getPackageName());
        builder.append(getPackageArch(), otherPack.getPackageArch());

        return builder.isEquals();
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {

        HashCodeBuilder builder = new HashCodeBuilder();
        builder.append(getToken());
        builder.append(getPackageName());
        builder.append(getPackageArch());

        return builder.toHashCode();
    }
}
