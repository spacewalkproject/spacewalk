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
package com.redhat.rhn.manager.kickstart;

import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.user.User;

/**
 * KickstartPackageProfileCommand - Command for adding/removing package profiles to sync
 * with a KickstartData.
 * @version $Rev$
 */
public class KickstartPackageProfileCommand extends BaseKickstartCommand {

    /**
     * Construct a  KickstartPackageProfileCommand used for associating
     * package profiles with a Kickstart.
     * @param ksidIn of the KickstartData we want to edit.
     * @param userIn who is editing the KickstartData.
     */
    public KickstartPackageProfileCommand(Long ksidIn, User userIn) {
        super(ksidIn, userIn);
    }

    /**
     * Set the Profile associated with this Kickstart
     * @param profileIn to set.
     */
    public void setProfile(Profile profileIn) {
        this.ksdata.getKickstartDefaults().setProfile(profileIn);
    }



}
