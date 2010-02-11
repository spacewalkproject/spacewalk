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
package com.redhat.rhn.frontend.dto;

/**
 * <code>PackageListItem</code> subclass specifically for carrying the extra information
 * of how many systems a package is installed on, for use in SSM.
 *
 * @version $Revision$
 */
public class SsmRemovePackageListItem extends PackageListItem {

    private Integer numSystems;

    /**
     * Indicates the number of systems the package is installed on.
     *
     * @return should be 1 or more
     */
    public Integer getNumSystems() {
        return numSystems;
    }

    /**
     * Sets the number of systems the package is installed on.
     *
     * @param numSystemsIn must not be <code>null</code>
     */
    public void setNumSystems(Integer numSystemsIn) {
        this.numSystems = numSystemsIn;
    }
}
