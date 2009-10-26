/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.rhn.domain.kickstart;

import java.util.Date;
import java.io.Serializable;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import com.redhat.rhn.domain.rhnpackage.PackageName;

/**
 * KickstartPackage
 * @version $Rev$
 */
public class KickstartPackage
        implements Serializable, Comparable<KickstartPackage> {

    private Long position;
    private Date created;
    private Date modified;
    private KickstartData ksData;
    private PackageName packageName;

    /**
     *
     */
    public KickstartPackage() {
        super();
    }

    /**
     * @param ksdata
     * @param package_name_id
     */
    public KickstartPackage(KickstartData ksdata, PackageName package_name_id) {
        super();
        this.ksData = ksdata;
        this.packageName = package_name_id;
    }

    /**
     * @return Returns the position.
     */
    public Long getPosition() {
        return position;
    }

    /**
     * @param position The position to set.
     */
    public void setPosition(Long position) {
        this.position = position;
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param created The created to set.
     */
    public void setCreated(Date created) {
        this.created = created;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param modified The modified to set.
     */
    public void setModified(Date modified) {
        this.modified = modified;
    }

    /**
     * @return Returns the ksdata.
     */
    public KickstartData getKsData() {
        return ksData;
    }

    /**
     * @param ksdata The ksdata to set.
     */
    public void setKsData(KickstartData ksdata) {
        this.ksData = ksdata;
    }

    /**
     * @return Returns the packageName.
     */
    public PackageName getPackageName() {
        return packageName;
    }

    /**
     * @param pn The packageName to set.
     */
    public void setPackageName(PackageName pn) {
        this.packageName = pn;
    }

    public int compareTo(KickstartPackage that) {

        final int EQUAL = 0;

        if (this.equals(that)) {
            return EQUAL;
        }

        int comparism = this.getKsData().getId().compareTo(that.getKsData().getId());
        if (EQUAL != comparism) {
            return comparism;
        }

        comparism = this.getPosition().compareTo(that.getPosition());
        if (EQUAL != comparism){
            return comparism;
        }
        return this.getPackageName().compareTo(that.getPackageName());
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof KickstartPackage)) {
            return false;
        }
        KickstartPackage that = (KickstartPackage) other;
        return this.hashCode()== other.hashCode();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder()
            .append(getKsData().getId())
            .append(getPosition())
            .append(getPackageName())
            .toHashCode();
    }

    public String toString() {
        return "packageName: ".concat(this.getKsData().getId().toString())
            .concat(", ").concat(this.getPosition().toString())
            .concat(", ").concat(this.getPackageName().getName());
    }
}
