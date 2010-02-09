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
package com.redhat.rhn.manager.kickstart.cobbler;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.log4j.Logger;
import org.cobbler.Distro;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * KickstartCobblerCommand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerDistroCreateCommand extends CobblerDistroCommand {
    
    private static Logger log = Logger.getLogger(CobblerDistroCreateCommand.class);
    private boolean syncProfiles;
    /**
     * Constructor
     * @param ksTreeIn to sync
     */
    public CobblerDistroCreateCommand(KickstartableTree ksTreeIn) {
        super(ksTreeIn);
    }
    
    /**
     * Constructor
     * @param ksTreeIn to sync
     * @param userIn - user wanting to sync with cobbler
     */
    public CobblerDistroCreateCommand(KickstartableTree ksTreeIn,
            User userIn) {
        super(ksTreeIn, userIn);
    }

    /**
     * Constructor
     * @param ksTreeIn to sync
     * @param userIn - user wanting to sync with cobbler
     * @param syncProfilesIn - true if you want the distro command
     *                          to run a CobblerProfileSync
     *                          when storing.
     */
    public CobblerDistroCreateCommand(KickstartableTree ksTreeIn,
            User userIn, boolean syncProfilesIn) {
        this(ksTreeIn, userIn);
        syncProfiles = syncProfilesIn;
    }
    
     /**
     * Save the Cobbler profile to cobbler.
     * @return ValidatorError if there was a problem
     */
    public ValidatorError store() {
        log.debug("Token : [" + xmlRpcToken + "]");

        Map ksmeta = new HashMap();
        KickstartUrlHelper helper = new KickstartUrlHelper(this.tree);
        ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE, 
                helper.getKickstartMediaPath());
        if (!tree.isRhnTree()) {
            ksmeta.put("org", tree.getOrgId().toString());
        }
        
        Distro distro = Distro.create(CobblerXMLRPCHelper.getConnection(user), 
                tree.getCobblerDistroName(), tree.getKernelPath(), 
                tree.getInitrdPath(), ksmeta);
        // Setup the kickstart metadata so the URLs and activation key are setup
        tree.setCobblerId((String) distro.getUid());
        invokeCobblerUpdate();
        
        if (tree.doesParaVirt()) {
            Distro distroXen = Distro.create(CobblerXMLRPCHelper.getConnection(user), 
                tree.getCobblerXenDistroName(), tree.getKernelXenPath(), 
                tree.getInitrdXenPath(), ksmeta); 
            tree.setCobblerXenId(distroXen.getUid());
        }
        
        if (syncProfiles) {
            List<KickstartData> profiles = KickstartFactory.
                                            lookupKickstartDatasByTree(tree);
            for (KickstartData profile : profiles) {
                createProfile(profile);
            }
        }
        return null;
    }

    private void createProfile(KickstartData profile) {
        CobblerProfileCreateCommand creator = new CobblerProfileCreateCommand(profile);
        creator.store();
    }
}
