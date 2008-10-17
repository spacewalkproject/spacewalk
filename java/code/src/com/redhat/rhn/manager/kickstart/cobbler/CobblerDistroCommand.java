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

import com.redhat.rhn.domain.kickstart.KickstartableTree;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;



/**
 * CobblerProfileComand - class to contain logic to communicate with cobbler
 * @version $Rev$
 */
public abstract class CobblerDistroCommand extends CobblerCommand {

    protected KickstartableTree tree;
    
    /**
     * @param cobblerTokenIn - xmlrpc token for cobbler 
     */
    public CobblerDistroCommand(String cobblerTokenIn) {
        super(cobblerTokenIn);
    }

    /**
     * @param ksTreeIn - KickstartableTree to sync
     * @param cobblerTokenIn - xmlrpc token for cobbler 
     */
    public CobblerDistroCommand(KickstartableTree ksTreeIn, String cobblerTokenIn) {
        super(cobblerTokenIn);
        this.tree = ksTreeIn;
    }

    /**
     * Get the distribution associated with the current KickstartData
     * @return Map of cobbler distro fields.
     */
    public Map getDistro() {
        List < String > args = new ArrayList();
        args.add(this.tree.getCobblerDistroName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_distro", args);
        return retval;
    }

}
