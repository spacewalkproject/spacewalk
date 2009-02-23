/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;

import org.apache.log4j.Logger;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;



/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public class CobblerDistroCommand extends CobblerCommand {
    
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
     * @param ksTreeIn - KickstartableTree to sync
     */
    public CobblerDistroCommand(KickstartableTree ksTreeIn) {
        super();
        this.tree = ksTreeIn;
    }

    /**
     * Get the distribution associated with the current KickstartData
     * @return Map of cobbler distro fields.
     */
    public Map getDistroMap() {
        log.debug("getDistroMap()");
        return lookupCobblerDistro(this.tree);
    }
    
    
    protected void updateCobblerFields(String handle) {
        log.debug("kernel path: " + tree.getKernelPath());
        invokeXMLRPC("modify_distro", handle, "kernel", 
                                tree.getKernelPath(), xmlRpcToken);

        // Setup the kickstart metadata so the URLs and activation key are setup
        Map ksmeta = new HashMap();
        KickstartUrlHelper helper = new KickstartUrlHelper(this.tree);
        ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE, 
                helper.getKickstartMediaPath());

        if (tree.getOrgId() != null) {
            ksmeta.put("org", tree.getOrg().getId());
        }
        
        Object[] args = new Object[]{handle, "ksmeta", 
                ksmeta, xmlRpcToken};
        invokeXMLRPC("modify_distro", Arrays.asList(args));
        
        log.debug("kernel path: " + tree.getInitrdPath());
        invokeXMLRPC("modify_distro", handle, "initrd",
                            tree.getInitrdPath(), xmlRpcToken);
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        throw new UnsupportedOperationException();
    }

}
