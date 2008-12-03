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

package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * This command finds profiles that have been changed on the cobbler server and syncs 
 *  those changes to the satellite
 * @version $Rev$
 */
public class CobblerProfileSyncCommand extends CobblerCommand {
    private String host;
    /**
     * Command to sync unsynced Kickstart profiles to cobbler. 
     * @param kickstartHost the kickstart host
     * @param u the user object
     */
    public CobblerProfileSyncCommand(String kickstartHost, User u) {
        super(u);
        host = kickstartHost;
    }
    /**
     * 
     * @return a list of cobbler profile names 
     */
    private Set<String> getProfileNames() {
        Set <String> profileNames = new HashSet<String>();
        List<Map> distros = (List<Map>)invokeXMLRPC("get_profiles", xmlRpcToken);
        for (Map distro : distros) {
            profileNames.add((String)distro.get("name"));
        }
        return profileNames;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public ValidatorError store() {
        List <KickstartData> profiles = KickstartFactory.
                            listKickstartDataByOrg(user.getOrg());
        Set<String> profileNames = getProfileNames();
        for (KickstartData profile : profiles) {
            if (!profileNames.contains(CobblerCommand.makeCobblerName(profile))) {
                createProfile(profile);
            }
        }
        
        return null;
    }
    
    private void createProfile(KickstartData profile) {
        KickstartUrlHelper helper = new KickstartUrlHelper(profile, host);
        CobblerProfileCreateCommand creator = new CobblerProfileCreateCommand(profile, 
                                        user, helper.getKickstartFileUrl());
        creator.store();
    }


}
