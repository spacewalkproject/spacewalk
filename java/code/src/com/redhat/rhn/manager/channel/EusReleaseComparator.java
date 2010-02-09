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

package com.redhat.rhn.manager.channel;

import com.redhat.rhn.common.util.RpmVersionComparator;
import com.redhat.rhn.frontend.dto.EssentialChannelDto;

import org.apache.commons.lang.StringUtils;

import java.util.Comparator;

/**
 * EusReleaseComparator
 *
 * Compare two RHEL releases, where the behavior can differ depending on which version
 * of RHEL we're dealing with. (RHEL 4 in particular needs special attention.)
 *
 * "Release" in this context ends up appearing more like what we'd call a version,
 * i.e. 5.3.0.3. Thus a simple string comparison will not suffice. (5.10 > 5.9)
 *
 * Additionally, for all versions of RHEL, we may need to trim pieces of the version
 * off to do the comparison.
 *
 * Sample releases:
 *   RHEL 4: 7.6, 8, 9
 *   RHEL 5: 5.1.0.1, 5.2.0.2, 5.3.0.3
 */
public class EusReleaseComparator implements Comparator<EssentialChannelDto> {
    private final String rhelVersion;

    /**
     * Constructor
     *
     * @param rhelVersionIn RHEL version we're comparing release for. (5Server, 4AS, 4ES)
     */
    public EusReleaseComparator(String rhelVersionIn) {
        this.rhelVersion = rhelVersionIn;
    }

    /**
     * Compare two EUS channel releases.
     *
     * @param chan1 First channel.
     * @param chan2 Second channel.
     * @return 1 if first is > second, 0 if they are equal, -1 is first is < second.
     */
    public int compare(EssentialChannelDto chan1, EssentialChannelDto chan2) {
        return compare(chan1.getRelease(), chan2.getRelease());
    }

    /**
     * Compare two EUS channel releases.
     *
     * @param rhelRelease1 First channel release.
     * @param rhelRelease2 Second channel release.
     * @return 1 if first is > second, 0 if they are equal, -1 is first is < second.
     */
    public int compare(String rhelRelease1, String rhelRelease2) {
        // Here we normalize the release to drop extra parts of the version:
        rhelRelease1 = ChannelManager.normalizeRhelReleaseForMapping(rhelVersion,
                rhelRelease1);
        rhelRelease2 = ChannelManager.normalizeRhelReleaseForMapping(rhelVersion,
                rhelRelease2);

        RpmVersionComparator cmp = new RpmVersionComparator();
        int c = cmp.compare(StringUtils.defaultString(rhelRelease1),
                        StringUtils.defaultString(rhelRelease2));
        return c;
    }
}
