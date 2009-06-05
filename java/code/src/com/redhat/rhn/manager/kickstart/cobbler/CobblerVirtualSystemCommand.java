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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;

import org.apache.log4j.Logger;
import org.cobbler.SystemRecord;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;


/**
 * 
 * @version $Rev$
 */
public class CobblerVirtualSystemCommand extends CobblerSystemCreateCommand {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(CobblerVirtualSystemCommand.class);

    private String guestName;

    /**
     * Constructor
     * @param serverIn to create in cobbler
     * @param cobblerProfileName to use
     * @param guestNameIn the guest name to create
     * @param ksData the kickstart data to associate
     *      system with
     */
    public CobblerVirtualSystemCommand(Server serverIn,
            String cobblerProfileName, String guestNameIn, KickstartData ksData) {
        super(serverIn, cobblerProfileName, ksData);
        guestName = guestNameIn;
    }

    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param ksDataIn profile to associate with with server.
     * @param mediaPathIn mediaPath to override in the server profile.
     * @param activationKeysIn to add to the system record.  Used when the system
     * @param guestNameIn the guest name to create
     * re-registers to Spacewalk
     */
    public CobblerVirtualSystemCommand(User userIn, Server serverIn, 
            KickstartData ksDataIn, String mediaPathIn,
                            String activationKeysIn, String guestNameIn) {
        super(userIn, serverIn, ksDataIn, mediaPathIn, activationKeysIn);
        guestName = guestNameIn;
    }
    
    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param nameIn profile nameIn to associate with with server.
     */
    public CobblerVirtualSystemCommand(User userIn, Server serverIn, 
            String nameIn) {
        super(userIn, serverIn, nameIn);
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public String getCobblerSystemRecordName() {
        return super.getCobblerSystemRecordName() + ":" + guestName;
    }

    @Override
    protected void processNetworkInterfaces(String handleIn,
            String xmlRpcTokenIn, Server serverIn) {
        log.debug("processNetworkInterfaces called.");

        String newMac = (String) invokeXMLRPC("get_random_mac", Collections.EMPTY_LIST);
        Map inet = new HashMap();
        inet.put("macaddress-" + "eth0", newMac);

        Object[] args = new Object[]{handleIn, "modify-interface",
                inet, xmlRpcTokenIn};
        invokeXMLRPC("modify_system", Arrays.asList(args));
    }


    protected String lookupExisting() {
        log.debug("lookupExisting called.");

        SystemRecord rec = SystemRecord.lookupByName(
                CobblerXMLRPCHelper.getConnection(user), getCobblerSystemRecordName());
        if (rec == null) {
            return null;
        }
        else {
            return (String) invokeXMLRPC("get_system_handle",
                    rec.getName(), xmlRpcToken);
        }
    }

  
}
