/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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
package com.redhat.rhn.frontend.events;

import java.util.Date;
import java.util.Set;

/**
 * Event fired to carry the information necessary to schedule package installations on
 * systems in the SSM.
 */
public class SsmInstallPackagesEvent extends SsmPackageEvent {

    protected Set<String> packages;
    protected Long        channelId;

    /**
     * Creates a new event to install a set of packages on systems in the SSM.
     *
     * @param userIdIn user making the changes; cannot be <code>null</code>
     * @param earliestIn earliest time to perform the installation; can be
     *            <code>null</code>
     * @param packagesIn set of package IDs being installed; cannot be <code>null</code>
     * @param channelIdIn identifies the channel the packages are installed from; cannot
     *            be <code>null</code>
     */
    public SsmInstallPackagesEvent(Long userIdIn, Date earliestIn,
        Set<String> packagesIn, Long channelIdIn) {
        super(userIdIn, earliestIn);
        if (packagesIn == null) {
            throw new IllegalArgumentException("packagesIn cannot be null");
        }

        if (channelIdIn == null) {
            throw new IllegalArgumentException("channelIdIn cannot be null");
        }
        this.packages = packagesIn;
        this.channelId = channelIdIn;
    }

    /**
     * @return will not be <code>null</code>
     */
    public Set<String> getPackages() {
        return packages;
    }

    /**
     * @return will not be <code>null</code>
     */
    public Long getChannelId() {
        return channelId;
    }

    /** {@inheritDoc} */
    public String toString() {
        return "SsmInstallPackagesEvent [" + super.toString() + ", numPkgs=" +
                packages.size() + ", " + "channelId=" + channelId + "]";
    }
}
