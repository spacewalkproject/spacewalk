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
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.SystemRecord;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 
 * Login to Cobbler's XMLRPC API and get a token
 * @version $Rev$
 */
public class CobblerSystemCreateCommand extends CobblerCommand {

    private static Logger log = Logger.getLogger(CobblerSystemCreateCommand.class);
    private Action scheduledAction;
    private Server server;
    private String mediaPath;
    private String profileName;
    private String activationKeys;
    private String kickstartHost;
    private String kernelOptions;
    private String postKernelOptions;
    private String staticNetwork;

    /**
     * @param staticNetworkIn The staticNetwork to set.
     */
    public void setStaticNetwork(String staticNetworkIn) {
        staticNetwork = staticNetworkIn;
    }

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
            profileName = ksDataIn.getCobblerObject(user).getName();
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
     * @param ksData the kickstart data to associate the system with
     */
    public CobblerSystemCreateCommand(Server serverIn, String cobblerProfileName,
                                                            KickstartData ksData) {
        super(serverIn.getCreator());
        this.server = serverIn;
        this.mediaPath = null;
        this.profileName = cobblerProfileName;
        String note = "Reactivation key for " + server.getName() + ".";
        ActivationKey key = ActivationKeyManager.getInstance().
                    createNewReActivationKey(server.getCreator(), server, note);
        log.debug("created reactivation key: " + key.getKey());
        String keys = key.getKey();
        if (ksData != null) {
            for (Token token : ksData.getDefaultRegTokens()) {
                ActivationKey keyTmp = ActivationKeyFactory.lookupByToken(token);
                if (keyTmp != null) {
                    keys += "," + keyTmp.getKey();
                }
            }
        }
        this.activationKeys = keys;
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
        profileName = nameIn;
    }    
  
    protected String lookupExisting() {
        String sysname = null;
        if (server.getCobblerId() != null) {
            SystemRecord rec;
            rec = SystemRecord.lookupById(CobblerXMLRPCHelper.getConnection(user),
                    server.getCobblerId());
            if (rec != null) {
                sysname = rec.getName();
            }
        }
        //lookup by ID failed, so lets try by mac
        if (sysname == null) {
            Map sysmap = getSystemMapByMac();
            if (sysmap != null) {
                log.debug("getSystemHandleByMAC.found match.");
                sysname = (String) sysmap.get("name");
            }
        }
        return sysname;
    }
    
    private Map getSystemMapByMac() {
        // Build up list of mac addrs
        List macs = new LinkedList();
        for (NetworkInterface n : server.getNetworkInterfaces()) {
            // Skip localhost and non real interfaces
            if (!n.isValid()) {
                log.debug("Skipping.  not a real interface");
            }
            else {
                macs.add(n.getHwaddr().toLowerCase());
            }
            
        }

        List <String> args = new ArrayList();
        args.add(xmlRpcToken);
        List<Map> systems = (List) invokeXMLRPC("get_systems", args);
        for (Map row : systems) {
            Set ifacenames = ((Map) row.get("interfaces")).keySet();
            log.debug("Ifacenames: " + ifacenames);
            Map ifaces = (Map) row.get("interfaces");
            log.debug("ifaces: " + ifaces);
            Iterator names = ifacenames.iterator();
            while (names.hasNext()) {
                String name = (String) names.next();
                log.debug("Name: " + name);
                Map iface = (Map) ifaces.get(name);
                log.debug("iface: " + iface);
                String mac = (String) iface.get("mac_address");
                log.debug("getSystemMapByMac.ROW: " + row + 
                        " looking for: " + macs);
                
                if (mac != null && 
                        macs.contains(mac.toLowerCase())) {
                    log.debug("getSystemMapByMac.found match.");
                    return row;
                }
            }
        }
        return null;
        
    }


    /**
     * Store the System to cobbler
     * @return ValidatorError if the store failed.
     */
    public ValidatorError store() {
        // First lookup by MAC addr
        String sysName = lookupExisting();
        if (sysName == null) {
            // Next try by name
            try {
                String handle = (String) invokeXMLRPC("get_system_handle",
                        getCobblerSystemRecordName(), xmlRpcToken);
                if (!StringUtils.isBlank(handle)) {
                    sysName = getCobblerSystemRecordName();
                }
                log.debug("Did we find handle by name: " + handle);
            } 
            catch (RuntimeException e) {
                log.debug("No system by that name either.  create a new one");
            }
        }
        if (!StringUtils.isBlank(sysName)) {
            invokeXMLRPC("remove_system", sysName, xmlRpcToken);
            invokeCobblerUpdate();
        }
        String handle = (String) invokeXMLRPC("new_system", xmlRpcToken);
        log.debug("handle: " + handle);
        invokeXMLRPC("modify_system", handle, "name", getCobblerSystemRecordName(),
                                     xmlRpcToken);
        
        if (this.server.getNetworkInterfaces() != null &&
                !this.server.getNetworkInterfaces().isEmpty()) {
            processNetworkInterfaces(handle, xmlRpcToken, server);
        }

        Object[] args = new String[]{handle, "profile", 
                profileName, xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));
        
        if (this.activationKeys == null || this.activationKeys.length() == 0) {
            log.error("This cobbler profile does not " +
                "have a redhat_management_key set ");
        }
        else {
            invokeXMLRPC("modify_system", handle, "redhat_management_key",
                                            this.activationKeys, xmlRpcToken);
        }


        if (!StringUtils.isBlank(getKickstartHost())) {
            invokeXMLRPC("modify_system", handle, "server",
                                getKickstartHost(), xmlRpcToken);
        }
        else {
            invokeXMLRPC("modify_system", handle, "server",
                    "", xmlRpcToken);
        }

        // Setup the kickstart metadata so the URLs and activation key are setup
        Map ksmeta = new HashMap();
        if (!StringUtils.isBlank(mediaPath)) {
            ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE,
                                                    this.mediaPath);            
        }
        if (!StringUtils.isBlank(getKickstartHost())) {
            ksmeta.put(SystemRecord.REDHAT_MGMT_SERVER,
                    getKickstartHost());
        }

        args = new Object[]{handle, "ksmeta", 
                ksmeta, xmlRpcToken};
        invokeXMLRPC("modify_system", Arrays.asList(args));
        
        invokeXMLRPC("save_system", handle, xmlRpcToken);
        Map cSystem = getSystemMapByMac();
        // Virt system records have no mac/interfaces setup so we search on name
        if (cSystem == null) {
            cSystem = getSystemMapByName();
        }
        server.setCobblerId((String)cSystem.get("uid"));        
        SystemRecord record = SystemRecord.lookupById(getCobblerConnection(),
                server.getCobblerId());
        record.setKernelOptions(kernelOptions);
        record.setKernelPostOptions(postKernelOptions);
        
        record.save();
        return null;
    }

    private Map getSystemMapByName() {
        List < String > args = new ArrayList();
        args.add(getCobblerSystemRecordName());
        args.add(xmlRpcToken);
        Map retval = (Map) invokeXMLRPC("get_system", args);
        return retval;
    }

    /**
     * Get the cobbler system record name for this system.
     * @return String name of cobbler system record. 
     */
    public String getCobblerSystemRecordName() {
        String name = this.server.getName().replace(' ', '_');
        return name + ":" +
            this.server.getOrg().getId();
    }
    
    protected void processNetworkInterfaces(String handleIn, 
            String xmlRpcTokenIn,
            Server serverIn) {
        Map inet = new HashMap();
        for (NetworkInterface n : serverIn.getNetworkInterfaces()) {
            if (n.isValid()) {
                inet.put("macaddress-" + n.getName(), n.getHwaddr());
                if (!StringUtils.isBlank(n.getIpaddr())) {
                    inet.put("ipaddress-" + n.getName(), n.getIpaddr());
                }
                if (!StringUtils.isBlank(n.getNetmask())) {
                    inet.put("subnet-" + n.getName(), n.getNetmask());
                }
                inet.put("static-" + n.getName(),
                        !StringUtils.isBlank(staticNetwork) &&
                        n.getName().equals(staticNetwork));                
            }
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
     * @return Returns the kickstartHost.
     */
    public String getKickstartHost() {
        return kickstartHost;
    }


    /**
     * @param kickstartHostIn The kickstartHost to set.
     */
    public void setKickstartHost(String kickstartHostIn) {
        this.kickstartHost = kickstartHostIn;
    }

    /**
     * @param kernelOptionsIn The kernelOptions to set.
     */
    public void setKernelOptions(String kernelOptionsIn) {
        this.kernelOptions = kernelOptionsIn;
    }
    
    /**
     * @param postKernelOptionsIn The postKernelOptions to set.
     */
    public void setPostKernelOptions(String postKernelOptionsIn) {
        this.postKernelOptions = postKernelOptionsIn;
    }

    /**
     * Set the scheduled action associated to this command.
     * @param kickstartAction ks action associated to this command
     */
    public void setScheduledAction(Action kickstartAction) {
        scheduledAction = kickstartAction;
    }
    
    protected Action getScheduledAction() {
        return scheduledAction;
    }
}
