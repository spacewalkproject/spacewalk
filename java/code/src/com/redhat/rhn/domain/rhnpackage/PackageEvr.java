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

import com.redhat.rhn.common.util.RpmVersionComparator;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * PackageEvr
 * @version $Rev$
 */
public class PackageEvr implements Comparable {

    private static final RpmVersionComparator VERCMP = new RpmVersionComparator();
    private static final Integer ZERO = new Integer(0);

    private Long id;
    private String epoch;
    private String version;
    private String release;

    /**
     * Null constructor, needed for hibernate
     */
    public PackageEvr() {
        id = null;
        epoch = null;
        version = null;
        release = null;
    }

    /**
     * Complete constructor. Use PackageEvrFactory to create PackageEvrs if you
     * want to persist them to the Database. ONLY USE for non-persisting evr
     * objects.
     * @param epochIn epoch
     * @param versionIn version
     * @param releaseIn release
     */
    public PackageEvr(String epochIn, String versionIn, String releaseIn) {
        id = null;
        epoch = epochIn;
        version = versionIn;
        release = releaseIn;
    }

    /**
     * @return Returns the epoch.
     */
    public String getEpoch() {
        return epoch;
    }

    /**
     * @param e The epoch to set.
     */
    public void setEpoch(String e) {
        this.epoch = e;
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
     * @return Returns the release.
     */
    public String getRelease() {
        return release;
    }

    /**
     * @param r The release to set.
     */
    public void setRelease(String r) {
        this.release = r;
    }

    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }

    /**
     * @param v The version to set.
     */
    public void setVersion(String v) {
        this.version = v;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof PackageEvr)) {
            return false;
        }

        PackageEvr evr = (PackageEvr) obj;

        return new EqualsBuilder().append(this.getId(), evr.getId()).append(
                this.getEpoch(), evr.getEpoch())
                .append(this.getVersion(), evr.getVersion()).append(this.getRelease(),
                        evr.getRelease()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId()).append(this.getEpoch()).append(
                this.getVersion()).append(this.getRelease()).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(Object o) {
        // This method mirrors the perl function RHN::Manifest::vercmp
        // There is another perl function, RHN::DB::Package::vercmp which
        // does almost the same, but has a subtle difference when it comes
        // to null epochs (the RHN::DB::Package version does not treat null
        // epochs the same as epoch == 0, but sorts them as Integer.MIN_VALUE)
        PackageEvr other = (PackageEvr) o;
        int result = epochAsInteger().compareTo(other.epochAsInteger());
        if (result != 0) {
            return result;
        }
        if (getVersion() == null || other.getVersion() == null) {
            throw new IllegalStateException(
                    "To compare PackageEvr, both must have non-null versions");
        }
        result = VERCMP.compare(getVersion(), other.getVersion());
        if (result != 0) {
            return result;
        }
        // The perl code doesn't check for null releases, so we won't either
        // In the long run, a check might be in order, though
        return VERCMP.compare(getRelease(), other.getRelease());
    }

    private Integer epochAsInteger() {
        Integer result = ZERO;
        if (getEpoch() != null) {
            result = new Integer(getEpoch());
        }
        return result;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        String retval = "";
        if (this.getEpoch() != null) {
            retval = this.getEpoch() + ".";
        }
        retval = retval + this.getVersion() + "." + this.getRelease();
        return retval;
    }
}
