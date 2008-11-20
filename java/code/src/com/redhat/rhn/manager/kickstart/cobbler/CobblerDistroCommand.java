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

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;



/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerDistroCommand extends CobblerCommand {
    
    private static Logger log = Logger.getLogger(CobblerDistroCommand.class);
    
    protected KickstartableTree tree;
    
    /**
     * @param userIn - user wanting to sync with cobbler 
     */
    public CobblerDistroCommand(User userIn) {
        super(userIn);
    }

    /**
     * @param ksTreeIn - KickstartableTree to sync
     * @param userIn - user wanting to sync with cobbler 
     */
    public CobblerDistroCommand(KickstartableTree ksTreeIn, User userIn) {
        super(userIn);
        this.tree = ksTreeIn;
    }

    /**
     * Get the distribution associated with the current KickstartData
     * @return Map of cobbler distro fields.
     */
    public Map getDistroMap() {
        List < String > args = new ArrayList();
        args.add(this.tree.getCobblerDistroName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_distro", args);
        return retval;
    }
    
    protected void updateCobblerFields(String handle) {
        // String kernel = ksData.getKsdefault().getKstree().getBasePath()
        
        String filePath = Config.get().getKickstartMountPoint() +
                    this.tree.getBasePath() + "/images/pxeboot/";
        String kernelPath = filePath + "vmlinuz";
        log.debug("kernel path: " + kernelPath);
        String[] args = new String[]{handle, "kernel", kernelPath, xmlRpcToken}; 
        invokeXMLRPC("modify_distro", Arrays.asList(args));
        
        String initrdPath = filePath + "initrd.img";
        log.debug("initrdPath: " + kernelPath);
        args = new String[]{handle, "initrd", initrdPath, xmlRpcToken}; 
        invokeXMLRPC("modify_distro", Arrays.asList(args));
    }

}
