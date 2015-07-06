/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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

import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.server.NetworkInterface;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartUrlHelper;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.Network;
import org.cobbler.Profile;
import org.cobbler.SystemRecord;
import org.cobbler.XmlRpcException;

import java.util.ArrayList;
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
    private final Server server;
    private String mediaPath;
    private String profileName;
    private String activationKeys;
    private String kickstartHost;
    private String kernelOptions;
    private String postKernelOptions;
    private String networkInterface;
    private boolean isDhcp;
    private boolean useIpv6Gateway;
    private String ksDistro;
    private boolean setupBridge;
    private String bridgeName;
    private List<String> bridgeSlaves;
    private String bridgeOptions;
    private String bridgeAddress;
    private String bridgeNetmask;
    private String bridgeGateway;
    private boolean isBridgeDhcp;
    /**
     * @param dhcp true if the network type is dhcp
     * @param networkInterfaceIn The name of the network interface
     * @param useIpv6GatewayIn whether to use ipv6 gateway
     * @param ksDistroIn distro to be provisioned
     */
    public void setNetworkInfo(boolean dhcp, String networkInterfaceIn,
            boolean useIpv6GatewayIn, String ksDistroIn) {
        isDhcp = dhcp;
        networkInterface = networkInterfaceIn;
        useIpv6Gateway = useIpv6GatewayIn;
        ksDistro = ksDistroIn;
    }

    /**
     * @param doBridge boolean, whether or not to set up a bridge post-install
     * @param name string, name of the bridge
     * @param slaves string array, nics to use as slaves
     * @param options string, bridge options
     * @param isBridgeDhcpIn boolean, if the bridge will use dhcp to obtain an ip address
     * @param address string, ip address for the bridge (if isDhcp is false)
     * @param netmask string, netmask for the bridge (if isDhcp is false)
     * @param gateway string, gateway for the bridge (if isDhcp is false)
     */
    public void setBridgeInfo(boolean doBridge, String name,
            List<String> slaves, String options, boolean isBridgeDhcpIn,
            String address, String netmask, String gateway) {
        setupBridge = doBridge;
        bridgeName = name;
        bridgeSlaves = slaves;
        bridgeOptions = options;
        isBridgeDhcp = isBridgeDhcpIn;
        bridgeAddress = address;
        bridgeNetmask = netmask;
        bridgeGateway = gateway;
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
                createNewReActivationKey(UserFactory.findRandomOrgAdmin(
                        server.getOrg()), server, note);
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

    protected SystemRecord lookupExisting() {
        if (server.getCobblerId() != null) {
            SystemRecord rec;
            rec = SystemRecord.lookupById(CobblerXMLRPCHelper.getConnection(user),
                    server.getCobblerId());
            if (rec != null) {
                return rec;
            }
        }
        //lookup by ID failed, so lets try by mac

        Map sysmap = getSystemMapByMac();
        if (sysmap != null) {
            log.debug("getSystemHandleByMAC.found match.");
            String uid = (String) sysmap.get("uid");
            SystemRecord rec;
            rec = SystemRecord.lookupById(CobblerXMLRPCHelper.getConnection(user),
                    uid);
            if (rec != null) {
                return rec;
            }
        }
        return null;
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
    @Override
    public ValidatorError store() {
        return store(true);
    }

    /**
     * Store the System to cobbler
     * @param saveCobblerId false if CobblerVirtualSystemCommand is calling, true otherwise
     * @return ValidatorError if the store failed.
     */
    public ValidatorError store(boolean saveCobblerId) {
        Profile profile = Profile.lookupByName(getCobblerConnection(), profileName);
        // First lookup by MAC addr
        SystemRecord rec = lookupExisting();
        if (rec == null) {
            // Next try by name
            rec = SystemRecord.lookupByName(getCobblerConnection(user),
                    getCobblerSystemRecordName());
        }

        // Else, lets make a new system
        if (rec == null) {
            rec = SystemRecord.create(getCobblerConnection(),
                    getCobblerSystemRecordName(), profile);
        }
        try {
            processNetworkInterfaces(rec, server);
        }
        catch (XmlRpcException e) {
            if (e.getCause() != null && e.getCause().getMessage() != null &&
                    e.getCause().getMessage().contains("IP address duplicated")) {
                return new ValidatorError(
                        "frontend.actions.systems.virt.duplicateipaddressvalue");
            }
            throw e;
        }
        rec.enableNetboot(true);
        rec.setProfile(profile);

        if (isDhcp) {
            rec.setIpv6Autoconfiguration(true);
        }
        else {
            rec.setIpv6Autoconfiguration(false);
        }

        if (this.activationKeys == null || this.activationKeys.length() == 0) {
            log.error("This cobbler profile does not " +
                    "have a redhat_management_key set ");
        }
        else {
            rec.setRedHatManagementKey(activationKeys);
        }
        if (!StringUtils.isBlank(getKickstartHost())) {
            rec.setServer(getKickstartHost());
        }
        else {
            rec.setServer("");
        }

        // Setup the kickstart metadata so the URLs and activation key are setup
        Map<String, Object> ksmeta = rec.getKsMeta();
        if (ksmeta == null) {
            ksmeta = new HashMap<String, Object>();
        }

        if (!StringUtils.isBlank(mediaPath)) {
            ksmeta.put(KickstartUrlHelper.COBBLER_MEDIA_VARIABLE,
                    this.mediaPath);
        }
        if (!StringUtils.isBlank(getKickstartHost())) {
            ksmeta.put(SystemRecord.REDHAT_MGMT_SERVER,
                    getKickstartHost());
        }
        ksmeta.remove(KickstartFormatter.STATIC_NETWORK_VAR);
        ksmeta.put(KickstartFormatter.USE_IPV6_GATEWAY,
                this.useIpv6Gateway ? "true" : "false");
        if (this.ksDistro != null) {
            ksmeta.put(KickstartFormatter.KS_DISTRO, this.ksDistro);
        }
        rec.setKsMeta(ksmeta);
        if (getServer().getHostname() != null) {
            rec.setHostName(getServer().getHostname());
        }
        else if (getServer().getName() != null) {
            rec.setHostName(getServer().getName());
        }
        rec.setKernelOptions(kernelOptions);
        rec.setKernelOptionsPost(postKernelOptions);
        try {
            rec.save();
        }
        catch (XmlRpcException e) {
            if (e.getCause() != null && e.getCause().getMessage() != null &&
                    e.getCause().getMessage().contains("IP address duplicated")) {
                return new ValidatorError(
                        "frontend.actions.systems.virt.duplicateipaddressvalue");
            }
            throw e;
        }

        /*
         * This is a band-aid for the problem revealed in bug 846221. However
         * the real fix involves creating a new System for the virtual guest
         * instead of re-using the host System object, and I am unsure of what
         * effects that would have. The System object is used when creating
         * reActivation keys and setting up the cobbler SystemRecord network
         * info among other things. No bugs have been reported in those areas
         * yet, so I don't want to change something that has the potential to
         * break a lot of things.
         */
        if (saveCobblerId) {
            server.setCobblerId(rec.getId());
        }
        return null;
    }

    /**
     * Get the cobbler system record name for a system
     * @return String name of cobbler system record
     */
    public String getCobblerSystemRecordName() {
        return CobblerSystemCreateCommand.getCobblerSystemRecordName(this.server);
    }

    /**
     * Get the cobbler system record name for a system
     * @param serverIn the server to get the name from
     * @return String name of cobbler system record
     */
    public static String getCobblerSystemRecordName(Server serverIn) {
        String sep = ConfigDefaults.get().getCobblerNameSeparator();
        String name = serverIn.getName().replace(' ', '_');
        name = name.replace(' ', '_').replaceAll("[^a-zA-Z0-9_\\-\\.]", "");
        return name + sep + serverIn.getOrg().getId();
    }

    protected void processNetworkInterfaces(SystemRecord rec,
            Server serverIn) {
        List <Network> nics = new LinkedList<Network>();
        if (serverIn.getNetworkInterfaces() != null) {
            for (NetworkInterface n : serverIn.getNetworkInterfaces()) {
                // don't create a physical network device for a bond
                if (n.isPublic() && !n.isVirtBridge() && !n.isBond()) {
                    Network net = new Network(getCobblerConnection(),
                            n.getName());
                    net.setIpAddress(n.getIpaddr());
                    net.setMacAddress(n.getHwaddr());
                    net.setNetmask(n.getNetmask());
                    if (!StringUtils.isBlank(networkInterface) &&
                            n.getName().equals(networkInterface)) {
                        net.setStaticNetwork(!isDhcp);
                    }

                    ArrayList<String> ipv6Addresses = n.getGlobalIpv6Addresses();
                    if (ipv6Addresses.size() > 0) {
                        net.setIpv6Address(ipv6Addresses.get(0));
                        ipv6Addresses.remove(0);
                    }
                    if (ipv6Addresses.size() > 0) {
                        net.setIpv6Secondaries(ipv6Addresses);
                    }
                    if (setupBridge && bridgeSlaves.contains(n.getName())) {
                        net.makeBondingSlave();
                        net.setBondingMaster(bridgeName);
                    }

                    nics.add(net);
                }
                else if (setupBridge && bridgeSlaves.contains(n.getName())) {
                    Network net = new Network(getCobblerConnection(),
                            n.getName());
                    net.setMacAddress(n.getHwaddr());
                    net.makeBondingSlave();
                    net.setBondingMaster(bridgeName);
                    nics.add(net);
                }
            }
            if (setupBridge) {
                Network net = new Network(getCobblerConnection(), bridgeName);
                net.makeBondingMaster();
                net.setBondingOptions(bridgeOptions);
                net.setStaticNetwork(!isBridgeDhcp);
                if (!isBridgeDhcp) {
                    net.setNetmask(bridgeNetmask);
                    net.setIpAddress(bridgeAddress);
                    rec.setGateway(bridgeGateway);
                }
                nics.add(net);
            }
        }
        rec.setNetworkInterfaces(nics);
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
