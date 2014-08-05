/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * KickstartInstallType
 * @version $Rev$
 */
public class KickstartInstallType extends BaseDomainHelper {

    public static final String RHEL_21 = "rhel_2.1";
    public static final String RHEL_3 = "rhel_3";
    public static final String RHEL_4 = "rhel_4";
    public static final String RHEL_5 = "rhel_5";
    public static final String RHEL_6 = "rhel_6";
    public static final String RHEL_7 = "rhel_7";
    public static final String FEDORA = "fedora";
    public static final String GENERIC = "generic";
    public static final String SUSE = "suse";
    public static final String REDHAT = "redhat";

    private Long id;
    private String label;
    private String name;

    /**
     * @return if this installer type is rhel 7 or greater (for rhel8)
     */
    public boolean isRhel7OrGreater() {
        return (isRhel6OrGreater() && !isRhel6());
    }

    /**
     * @return if this installer type is rhel 6 or greater (for rhel7)
     */
    public boolean isRhel6OrGreater() {
        return (isRhel5OrGreater() && !isRhel5());
    }

    /**
     * @return if this installer type is rhel 5 or greater (for rhel6)
     */
    public boolean isRhel5OrGreater() {
        // we need to reverse logic here
        return (!isRhel2() && !isRhel3() && !isRhel4() && !isFedora() && !isGeneric());
    }

    /**
     * @return true if the installer type is rhel 7
     */
    public boolean isRhel7() {
        return RHEL_7.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel 6
     */
    public boolean isRhel6() {
        return RHEL_6.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel 5
     */
    public boolean isRhel5() {
        return RHEL_5.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel 4
     */
    public boolean isRhel4() {
        return RHEL_4.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel 53
     */
    public boolean isRhel3() {
        return RHEL_3.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel 2
     */
    public boolean isRhel2() {
        return RHEL_21.equals(getLabel());
    }

    /**
     * @return true if the installer type is rhel
     */
    public boolean isRhel() {
        return isRhel2() || isRhel3() || isRhel4() || isRhel5() || isRhel6() || isRhel7();
    }

    /**
     * @return true if the installer type is Fedora
     */
    public boolean isFedora() {
        return getLabel().startsWith(FEDORA);
    }

    /**
     * @return true if the installer type is generic.
     */
    public boolean isGeneric() {
        return GENERIC.equals(getLabel());
    }

    /**
     * @return true if the installer type is suse.
     */
    public boolean isSUSE() {
        return SUSE.equals(getLabel());
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
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof KickstartInstallType)) {
            return false;
        }
        KickstartInstallType that = (KickstartInstallType) o;
        return getLabel().equals(that.getLabel());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder().append(getLabel()).toHashCode();
    }

    /**
     * get the string cobbler understands as breed
     * @return cobbler breed compatible string
     */
    public String getCobblerBreed() {
        String breed = REDHAT;

        if (getLabel().equals("generic_rpm")) {
            breed = GENERIC;
        }
        else if (getLabel().equals(SUSE)) {
            breed = SUSE;
        }

        return breed;
    }

    /**
     * get the string cobbler understands as os_version
     * @return cobbler os_version compatible string
     */
    public String getCobblerOsVersion() {
        if (this.getCobblerBreed().equals(REDHAT)) {
            return this.getLabel().replace("_", "");
        }
        return "generic26";
    }

}
