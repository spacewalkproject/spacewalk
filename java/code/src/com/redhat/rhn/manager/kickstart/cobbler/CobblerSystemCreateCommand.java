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
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * 
 * Login to Cobbler's XMLRPC API and get a token
 * @version $Rev$
 */
public class CobblerSystemCreateCommand extends CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerSystemCreateCommand.class);
    
    private Server server;
    private String mediaPath;
    private String name;
    private String activationKeys;
    
    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param ksDataIn profile to associate with with server.
     * @param mediaPathIn mediaPath to override in the server profile.
     * @param activationKeysIn to add to the system record.  Used when the system
     * re-registers to Spacewalk
     */
    public CobblerSystemCreateCommand(User userIn, Server serverIn, 
            KickstartData ksDataIn, String mediaPathIn, String activationKeysIn) {
        super(userIn);
        this.server = serverIn;
        this.mediaPath = mediaPathIn;
        if (ksDataIn != null) {
            name = (String)lookupCobblerProfile(ksDataIn).get("name");
        }
        else {
            throw new NullPointerException("ksDataIn cant be null");
        }
        this.activationKeys = activationKeysIn;
    }
    
    /**
     * Constructor to be used for a system outside tthe context 
     * of actually kickstarting it to a specific profile.  
     * @param serverIn profile we want to create in cobbler
     * @param cobblerProfileName the name of the cobbler profile 
     * to associate with system
     */
    public CobblerSystemCreateCommand(Server serverIn, String cobblerProfileName) {
        super(serverIn.getCreator());
        this.server = serverIn;
        this.mediaPath = null;
        this.name = cobblerProfileName;
        String note = "Reactivation key for " + server.getName() + ".";
        ActivationKey key = ActivationKeyManager.getInstance().
                    createNewReActivationKey(server.getCreator(), server, note);
        log.debug("created reactivation key: " + key.getKey());
        this.activationKeys = key.getKey();
    }
    

    
    /**
     * Constructor
     * @param userIn who is requesting the sync
     * @param serverIn profile we want to create in cobbler
     * @param nameIn profile nameIn to associate with with server.
     */
    public CobblerSystemCreateCommand(User userIn, Server serverIn, 
            String nameIn) {
        super(userIn);
        this.server = serverIn;
        name = nameIn;
    }    
        


    /**
     * Store the System to cobbler
     * @return ValidatorError if the store failed.
     */
    public ValidatorError store() {
        String handle = null;
        log.debug("Map null?: " + (getSystemMap() != null));
        
        Map systemMp = getSystemMap();
        if (systemMp != null && !systemMp.isEmpty()) {
            handle = (String) invokeXMLRPC("get_system_handle",
                    this.getCobblerSystemRecordName(), xmlRpcToken);
        }
        else {
            handle = (String) invokeXMLRPC("new_system", xmlRpcToken);
        }
        
        log.debug("handle: " + handle);
        invokeXMLRPC("modify_system", handle, "name", getCobblerSystemRecordName(),
                                 xmlRpcToken);
        
        if (this.server.getNetworkInterfaces() == null ||
                this.server.getNetworkInterfaces().isEmpty()) {
            return new ValidatorError("kickstart.no.network.error");
        }

        processNetworkInterfaces(handle, xmlRpcToken, server);
        
        Object[] args = new String[]{handle, "profile", 
                name, xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));
        
        if (this.activationKeys == null || this.activationKeys.length() == 0) {
            log.error("This cobbler profile does not " +
                "have a redhat_management_key set ");
        }
        else {
            args = new Object[]{handle, "redhat_management_key", 
                    this.activationKeys, xmlRpcToken};
        }

        invokeXMLRPC("modify_system", Arrays.asList(args));
        
        // Setup the kickstart metadata so the URLs and activation key are setup
        Map ksmeta = new HashMap();
        if (!StringUtils.isBlank(mediaPath)) {
            ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE,
                                                    this.mediaPath);            
        }

        args = new Object[]{handle, "ksmeta", 
                ksmeta, xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));
        
        invokeXMLRPC("save_system", handle, xmlRpcToken);
        
        Map cSystem = getSystemMap();
        server.setCobblerId((String)cSystem.get("uid"));
        return null;
    }

    /**
     * Get the cobbler system record name for this system.
     * @return String name of cobbler system record. 
     */
    public String getCobblerSystemRecordName() {
        return this.server.getName() + ":" + 
            this.server.getOrg().getId();
    }
    
    protected void processNetworkInterfaces(String handleIn, 
            String xmlRpcTokenIn,
            Server serverIn) {
        Iterator i = serverIn.getNetworkInterfaces().iterator();
        Map inet = new HashMap();
        while (i.hasNext()) {
            NetworkInterface n = (NetworkInterface) i.next();
            inet.put("macaddress-" + n.getName(), n.getHwaddr());
        }
        log.debug("Networks: " + inet);
        
        Object[] args = new Object[]{handleIn, "modify-interface", 
                inet, xmlRpcTokenIn};
        invokeXMLRPC("modify_system", Arrays.asList(args));

    }

    /**
     * @return the system
     */
    public Server getServer() {
        return server;
    }

    /**
     * Get the Cobbler map representation fo the system
     * @return Map of system
     */
    public Map getSystemMap() {
        List < String > args = new ArrayList();
        args.add(getCobblerSystemRecordName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_system", args);
        return retval;
    }
}
