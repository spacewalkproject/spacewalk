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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.common.ProvisionState;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.entitlement.VirtualizationEntitlement;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.lang.builder.ToStringStyle;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.SystemRecord;

import java.sql.Timestamp;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

/**
 * Server - Class representation of the table rhnServer.
 * 
 * @version $Rev$
 */
public class Server extends BaseDomainHelper implements Identifiable {

    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(Server.class);

    private Boolean ignoreEntitlementsForMigration;

    private Long id;
    private Org org;
    private String digitalServerId;
    private String os;
    private String release;
    private String name;
    private String description;
    private String info;
    private String secret;
    private User creator;
    private String autoDeliver;
    private String autoUpdate;
    private String runningKernel;
    private Long lastBoot;
    private ServerArch serverArch;
    private ProvisionState provisionState;
    private Date channelsChanged;
    private Date created;
    private String cobblerId;
    private Set devices;
    private ServerInfo serverInfo;
    private CPU cpu;
    private ServerLock lock;
    private ServerUuid serverUuid;
    private Set notes;
    private Set networks;
    private Ram ram;
    private Dmi dmi;
    private Set networkInterfaces;
    private Set<CustomDataValue> customDataValues;
    private Set channels;
    private List configChannels = Collections.EMPTY_LIST;
    private Set localChannels = new HashSet();
    private Location serverLocation;
    private Set<VirtualInstance> guests = new HashSet();
    private VirtualInstance virtualInstance;
    private PushClient pushClient;
    private ConfigChannelListProcessor configListProc = new ConfigChannelListProcessor();
    private Set history;
    private Set packages;
    private ProxyInfo proxyInfo;

    /**
     * @return the proxyInfo
     */
    public ProxyInfo getProxyInfo() {
        return proxyInfo;
    }
    
    /**
     * the proxy information to set
     * @param proxy the proxyInfo to set
     */
    public void setProxyInfo(ProxyInfo proxy) {
        this.proxyInfo = proxy;
    }

    /**
     * Retrieves the local override channel associated with this system.
     * @return the Local Override Channel or create one if none exists
     */
    public ConfigChannel getLocalOverride() {
        return  findLocal(ConfigChannelType.local());
    }
    
    /**
     * Retrieves the local override channel associated with this system.
     * @return the Local Override Channel or NULL if there's none created yet
     */
    public ConfigChannel getLocalOverrideNoCreate() {
        ensureConfigManageable();
        ConfigChannel channel = null;
        for (Iterator itr = localChannels.iterator(); itr.hasNext();) {
            ConfigChannel ch = (ConfigChannel) itr.next();
            if (ch.getConfigChannelType().equals(ConfigChannelType.local())) {
                channel = ch;
                break;
            }
        }
        return channel;
    }

    /**
     * 
     * @param ch Override channel to set
     */
    public void setLocalOverride(ConfigChannel ch) {
        setLocalType(ch, ConfigChannelType.local());
    }
    
    private void setLocalType(ConfigChannel channel,
                                    ConfigChannelType cct) {
        
        ConfigChannel ch =  findLocal(cct);
        if (ch != null) {
            localChannels.remove(ch);
        }
        localChannels.add(channel);
    }    
    
    protected void setLocalChannels(Set chls) {
        localChannels = chls;
    }
    
    protected Set getLocalChannels() {
        return localChannels;
    }

    /**
     * Used for retrieving Local/Sandbox override channels since the process is
     *  exacly the same. Creates the channel if it does not exist.
     * @param cct Config Channel type .. (local or sandbox)
     * @return Config channel associated with the given type
     */    
    private ConfigChannel findLocal(ConfigChannelType cct) {
        
        assert localChannels.size() <= 2 : "More than two local override  channels" +
                                "Associated with this server." +
                                "There should be NO more than Two" +
                                    " Override Channels associated";
        ensureConfigManageable();
        for (Iterator itr = localChannels.iterator(); itr.hasNext();) {
            ConfigChannel ch = (ConfigChannel) itr.next();
            ConfigChannelType  item = ch.getConfigChannelType();
            if (cct.equals(item)) {
                return ch;
            }
        }
        
        //We automatically create local config channels, so
        //if we didn't find one, we just haven't created it yet.
        ConfigChannel channel = ConfigurationFactory.createNewLocalChannel(this, cct);
        
        //TODO: Adding the new channel to the set of local channels should
        //happen in the createNewLocalChannel method.  However, the way things
        //are currently set up, I have to work with the member variable, because using
        //accessors and mutators would create an infinite loop.  Fix this setup.
        localChannels.add(channel);
        setLocalChannels(localChannels);
        return channel;
    }
    
    /**
     * Retrieves the sandbox override channel associated with this system.
     * @return the Sandbox Override Channel or create one if none exists
     */
    public ConfigChannel getSandboxOverride() {
        return findLocal(ConfigChannelType.sandbox());
    }
    
    /**
     * Retrieves the sandbox override channel associated with this system.
     * @return the Sandbox Override Channel or NULL if there's none created yet
     */
    public ConfigChannel getSandboxOverrideNoCreate() {
        ensureConfigManageable();
        ConfigChannel channel = null;
        for (Iterator itr = localChannels.iterator(); itr.hasNext();) {
            ConfigChannel ch = (ConfigChannel) itr.next();
            if (ch.getConfigChannelType().equals(ConfigChannelType.sandbox())) {
                channel = ch;
                break;
            }
        }
        return channel;
    }

    /**
     * 
     * @param ch sets the sandbox override channel
     */
    public void setSandboxOverride(ConfigChannel ch) {
        setLocalType(ch, ConfigChannelType.sandbox());
    }

    /**
     * ONLY TO BE USED FOR/BY HIBERNATE
     * @param configChannelsIn The configChannels to set.
     */
    protected void setConfigChannelsHibernate(List configChannelsIn) {
        configChannels = configChannelsIn;
        for (Iterator itr = configChannels.iterator(); itr.hasNext();) {
            if (itr.next() == null) {
                itr.remove();
            }
        }
    }

    /**
     * ONLY TO BE USED FOR/BY HIBERNATE
     *
     * @return List of config channels
     */
    protected List getConfigChannelsHibernate() {
        return configChannels;
    }
    
    /**
     * @return Returns the ServerConfigChannels mappings currently available
     * to the server based on it's entitlements.
     */
    public List <ConfigChannel> getConfigChannels() {
        ensureConfigManageable();
        return getConfigChannelsHibernate();
    }

    /**
     * @return Returns the number of configuration channels associated with
     * the server.
     */
    public int getConfigChannelCount() {
        return configChannels.size();
    }
    
    private void ensureConfigManageable() {
        if (!getIgnoreEntitlementsForMigration()) {
            ConfigurationManager.getInstance().ensureConfigManageable(this);
        }
    }
    
    /**
     * subscribes a channel to a system, giving it the
     * highest value for the  position (or the lowest priority)
     * @param cc The config channel to subscribe to 
     */
    public void subscribe(ConfigChannel cc) {
        configListProc.add(getConfigChannels(), cc);
    }
    /**
     * subscribes a channel to a system at the given position
     * @param cc the channel to subscribe
     * @param position the positon/ranking of the channel in the system list,
     *                  must be > 0 
     */
    public void subscribeAt(ConfigChannel cc, int position) {
        configListProc.add(getConfigChannels(), cc, position);
    }
    
    /**
     * @param cc the ConfigChannel to unsubscribe
     * @return returns true if the remove operation succeeded
     */
    public boolean unsubscribe(ConfigChannel cc) {
        return configListProc.remove(getConfigChannels(), cc);
    }
    
    /**
     * Protected constructor
     */
    protected Server() {
        devices = new HashSet();
        notes = new HashSet();
        networks = new HashSet();
        networkInterfaces = new HashSet();
        customDataValues = new HashSet();

        ignoreEntitlementsForMigration = new Boolean(Boolean.FALSE);
    }

    /**
     * @return Returns the serverInfo.
     */
    public ServerInfo getServerInfo() {
        return serverInfo;
    }
    /**
     * @param serverInfoIn The serverInfo to set.
     */
    public void setServerInfo(ServerInfo serverInfoIn) {
        this.serverInfo = serverInfoIn;
    }
    /**
     * Gets the last checkin date for this server
     * @return last checkin date
     */
    public Date getLastCheckin() {
        return serverInfo.getCheckin();
    }
    /**
     * Gets the number of times this server has checked in
     * @return number of times this server has checked in.
     */
    public Long getCheckinCount() {
        return serverInfo.getCheckinCounter();
    }
    /**
     * Getter for id
     * 
     * @return Long to get
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * 
     * @param idIn to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }

    /**
     * @param o The org to set.
     */
    public void setOrg(Org o) {
        this.org = o;
    }

    /**
     * Getter for digitalServerId
     * 
     * @return String to get
     */
    public String getDigitalServerId() {
        return this.digitalServerId;
    }

    /**
     * Setter for digitalServerId
     * 
     * @param digitalServerIdIn to set
     */
    public void setDigitalServerId(String digitalServerIdIn) {
        this.digitalServerId = digitalServerIdIn;
    }

    /**
     * Getter for os
     * 
     * @return String to get
     */
    public String getOs() {
        return this.os;
    }

    /**
     * Setter for os
     * 
     * @param osIn to set
     */
    public void setOs(String osIn) {
        this.os = osIn;
    }

    /**
     * Getter for release
     * 
     * @return String to get
     */
    public String getRelease() {
        return this.release;
    }

    /**
     * Setter for release
     * 
     * @param releaseIn to set
     */
    public void setRelease(String releaseIn) {
        this.release = releaseIn;
    }

    /**
     * Getter for name
     * 
     * @return String to get
     */
    public String getName() {
        return this.name;
    }

    /**
     * Setter for name
     * 
     * @param nameIn to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * Getter for description
     * 
     * @return String to get
     */
    public String getDescription() {
        return this.description;
    }

    /**
     * Setter for description
     * 
     * @param descriptionIn to set
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * Getter for info
     * 
     * @return String to get
     */
    public String getInfo() {
        return this.info;
    }

    /**
     * Setter for info
     * 
     * @param infoIn to set
     */
    public void setInfo(String infoIn) {
        this.info = infoIn;
    }

    /**
     * Getter for secret
     * 
     * @return String to get
     */
    public String getSecret() {
        return this.secret;
    }

    /**
     * Setter for secret
     * 
     * @param secretIn to set
     */
    public void setSecret(String secretIn) {
        this.secret = secretIn;
    }

    /**
     * @return Returns the creator.
     */
    public User getCreator() {
        return creator;
    }

    /**
     * @param c The creator to set.
     */
    public void setCreator(User c) {
        this.creator = c;
    }

    /**
     * Getter for autoDeliver
     * 
     * @return String to get
     */
    public String getAutoDeliver() {
        return this.autoDeliver;
    }

    /**
     * Setter for autoDeliver
     * 
     * @param autoDeliverIn to set
     */
    public void setAutoDeliver(String autoDeliverIn) {
        this.autoDeliver = autoDeliverIn;
    }

    /**
     * Getter for autoUpdate
     * 
     * @return String to get
     */
    public String getAutoUpdate() {
        return this.autoUpdate;
    }

    /**
     * Setter for autoUpdate
     * 
     * @param autoUpdateIn to set
     */
    public void setAutoUpdate(String autoUpdateIn) {
        this.autoUpdate = autoUpdateIn;
    }

    /**
     * Getter for runningKernel
     * 
     * @return String to get
     */
    public String getRunningKernel() {
        return this.runningKernel;
    }

    /**
     * Setter for runningKernel
     * 
     * @param runningKernelIn to set
     */
    public void setRunningKernel(String runningKernelIn) {
        this.runningKernel = runningKernelIn;
    }

    /**
     * Getter for lastBoot
     * 
     * @return Long to get
     */
    public Long getLastBoot() {
        return this.lastBoot;
    }
    
    /**
     * Getter for lastBoot as a date
     * 
     * @return lastBoot time as a Date object
     */
    public Date getLastBootAsDate() {
        return new Date(this.lastBoot.longValue() * 1000);
    }

    /**
     * Setter for lastBoot
     * 
     * @param lastBootIn to set
     */
    public void setLastBoot(Long lastBootIn) {
        this.lastBoot = lastBootIn;
    }

    /**
     * @return Returns the serverArch.
     */
    public ServerArch getServerArch() {
        return serverArch;
    }

    /**
     * @param s The serverArch to set.
     */
    public void setServerArch(ServerArch s) {
        this.serverArch = s;
    }

    /**
     * @return Returns the provisionState.
     */
    public ProvisionState getProvisionState() {
        return provisionState;
    }

    /**
     * @param p The provisionState to set.
     */
    public void setProvisionState(ProvisionState p) {
        this.provisionState = p;
    }

    /**
     * Getter for channelsChanged
     * 
     * @return Date to get
     */
    public Date getChannelsChanged() {
        return this.channelsChanged;
    }

    /**
     * Setter for channelsChanged
     * 
     * @param channelsChangedIn to set
     */
    public void setChannelsChanged(Date channelsChangedIn) {
        this.channelsChanged = channelsChangedIn;
    }

    /**
     * The set of ServerGroup(s) that this Server is a member of
     * @return Returns the serverGroups.
     */
    public List getEntitledGroups() {
        return ServerGroupFactory.listEntitlementGroups(this);
    }

    /**
     * The set of ServerGroup(s) that this Server is a member of
     * @return Returns the serverGroups.
     */
    public List<ManagedServerGroup> getManagedGroups() {
        return ServerGroupFactory.listManagedGroups(this);
    }
    
    /**
     * Returns the set of devices attached to this server.
     * @return Returns the list of devices attached to this server.
     */
    public Set getDevices() {
        return devices;
    }
    /**
     * Sets the set of devices.
     * @param devicesIn The devices to set.
     */
    protected void setDevices(Set devicesIn) {
        devices = devicesIn;
    }
    
    /**
     * Adds a device to the list of devices for this server.
     * @param device Device to add
     */
    public void addDevice(Device device) {
        device.setServer(this);
        devices.add(device);
    }
    
    /**
     * @return Returns the notes.
     */
    public Set getNotes() {
        return notes;
    }
    
    /**
     * @param n The notes to set.
     */
    public void setNotes(Set n) {
        this.notes = n;
    }

    /**
     * Adds a note to the notes set
     * @param note The note to add
     */
    public void addNote(Note note) {
        note.setServer(this);
        notes.add(note);
    }
    
    /**
     * Adds a note to the notes set.
     * @param user The user creating the note
     * @param subject The subject for the note
     * @param body The body for the note
     */
    public void addNote(User user, String subject, String body) {
        Note note = new Note();
        note.setCreator(user);
        note.setSubject(subject);
        note.setNote(body);
        note.setCreated(new Date());
        
        addNote(note);
    }
    
    /**
     * @return Returns the networks
     */
    public Set<Network> getNetworks() {
        return networks;
    }
    
    /**
     * Sets teh set of networks
     * @param n The networks to set
     */
    public void setNetworks(Set n) {
        this.networks = n;
    }
    
    /**
     * Adds a network to the set of networks for this server.
     * @param network The network to add.
     */
    public void addNetwork(Network network) {
        network.setServer(this);
        networks.add(network);
    }
    
    /**
     * Get the primary ip address for this server
     * @return Returns the primary ip for this server
     */
    public String getIpAddress() {
        // First search networkInterfaces because they are
        // better defined (name and ip address)
        NetworkInterface ni = findPrimaryNetworkInterface();
        if (ni != null) {
            log.debug("Found a NetworkInterface: " + ni.getIpaddr());
            return ni.getIpaddr();
        }
        Network n = findPrimaryNetwork();
        if (n != null) {
            log.debug("Found a Network: " + n.getIpaddr());
            return n.getIpaddr();
        }
        return null;
    }
    
    
    /**
     * Return the NetworkInterface which Spacewalk is guessing is
     * the primary.  Order of preference:
     * 
     * eth0, eth0*, eth1, eth1*, after that its first match that is 
     * not 127.0.0.1
     * 
     * @return NetworkInterface in order of preference: eth0, eth0*, 
     * eth1, eth1*, after that its first match that is not 127.0.0.1
     */
    public NetworkInterface findPrimaryNetworkInterface() {
        if (!networkInterfaces.isEmpty()) {
            Iterator i = networkInterfaces.iterator();
            // First pass look for names
            while (i.hasNext()) {
                NetworkInterface n = (NetworkInterface) i.next();
                boolean notEmpty = !n.isDisabled();
                if (n.getName().equals("eth0") && notEmpty) {
                    log.debug("Found eth0");
                    return n;
                }
                if (n.getName().startsWith("eth0") && notEmpty) {
                    log.debug("Found eth0*");
                    return n;
                }
                if (n.getName().equals("eth1") && notEmpty) {
                    log.debug("Found eth1");
                    return n;
                }
                if (n.getName().startsWith("eth1") && notEmpty) {
                    log.debug("Found eth1*");
                    return n;
                }
            }
            // Second pass look for localhost
            i = networkInterfaces.iterator();
            while (i.hasNext()) {
                NetworkInterface n = (NetworkInterface) i.next();
                String addr = n.getIpaddr();
                if (addr != null && 
                    !addr.equals("127.0.0.1")) {
                    log.debug("Found NetworkInterface !localhost");
                    return n;
                }
            }
            // If we didnt match any of the above criteria
            // just give up and return the 1st one.
            log.debug("just returning 1st network interface");
            return (NetworkInterface) networkInterfaces.iterator().next();
        }
        return null;
    }
    
    
    // Sometimes java really annoys me
    private Network findPrimaryNetwork() {
        if (!networks.isEmpty()) {
            Iterator i = networks.iterator();
            while (i.hasNext()) {
                Network n = (Network) i.next();
                String addr = n.getIpaddr();
                if (addr != null && 
                        !addr.equals("127.0.0.1")) {
                    log.debug("returning Network that is !localhost");
                    return n;
                }
            }
            log.debug("giving up, returning 1st Network");
            return (Network) networks.iterator().next();
        }
        return null;
    }
    
    

    /**
     * Get the primary MAC/hardware address for this server
     * @return Returns the primary MAC/hardware for this server
     */
    public String getHardwareAddress() {
        NetworkInterface network = findPrimaryNetworkInterface();
        if (network != null) {
            return network.getHwaddr();
        }
        return null;
    }

    /**
     * Get the primary hostname for this server
     * @return Returns the primary hostname for this server
     */
    public String getHostname() {
        if (!networks.isEmpty()) {
            Network net = (Network) networks.iterator().next();
            return net.getHostname();
        }
        return null;
    }
    
    /**
     * @return Returns the networkInterfaces.
     */
    public Set<NetworkInterface> getNetworkInterfaces() {
        return networkInterfaces;
    }
    
    /**
     * @param n The networkInterfaces to set.
     */
    public void setNetworkInterfaces(Set<NetworkInterface> n) {
        this.networkInterfaces = n;
    }
    
    /**
     * Adds a network interface to the set of network interfaces
     * for this server.
     * @param netIn The NetworkInterface to add
     */
    public void addNetworkInterface(NetworkInterface netIn) {
        netIn.setServer(this);
        networkInterfaces.add(netIn);
    }
    
    /**
     * Returns the total amount of ram for this server.
     * @return the total amount of ram for this server.
     */
    public long getRam() {
        if (ram == null) {
            return 0;
        }
        return ram.getRam();
    }
    
    /**
     * Convenience method for formatting the Ram as a String value.
     * @return String of RAM.
     */
    public String getRamString() {
        return new Long(getRam()).toString();
    }
    
    /**
     * the total amount of ram for this server.
     * @param ramIn The ram to set.
     */
    public void setRam(long ramIn) {
        initializeRam();
        ram.setRam(ramIn);
    }
    
    /**
     * Returns the  amount of swap for this server.
     * @return the  amount of swap for this server.
     */
    public long getSwap() {
        if (ram == null) {
            return 0;
        }
        return ram.getSwap();
    }
    
    /**
     * the amount of swap for this server.
     * @param swapIn the amount of swap for this server.
     */
    public void setSwap(long swapIn) {
        initializeRam();
        ram.setSwap(swapIn);
    }
    
    /**
     * @return Returns the cpu.
     */
    public CPU getCpu() {
        return cpu;
    }
    
    /**
     * @param cpuIn The cpu to set.
     */
    public void setCpu(CPU cpuIn) {
        this.cpu = cpuIn;
    }

    /**
     * @return Returns the dmi.
     */
    public Dmi getDmi() {
        return dmi;
    }
    
    /**
     * @param dmiIn The dmi to set.
     */
    public void setDmi(Dmi dmiIn) {
        dmi = dmiIn;
    }
    
    /**
     * @return Returns the serverLocation associated with the server.
     */
    public Location getLocation() {
        return serverLocation;
    }
    
    /**
     * @param locationIn Location to associate with the server.
     */
    public void setLocation(Location locationIn) {
        serverLocation = locationIn;
    }
    
    private void initializeRam() {
        if (ram == null) {
            ram = new Ram();
            ram.setServer(this);
        }
    }
    
    /**
     * @return Returns the customDataValues.
     */
    public Set<CustomDataValue> getCustomDataValues() {
        return customDataValues;
    }
    
    /**
     * @param customDataValuesIn The customDataValues to set.
     */
    public void setCustomDataValues(Set customDataValuesIn) {
        this.customDataValues = customDataValuesIn;
    }
    
    /**
     * Adds a custom data value to the set of custom data values
     * for this server.
     * @param value The CustomDataValue to add
     */
    public void addCustomDataValue(CustomDataValue value) {
        value.setServer(this);
        customDataValues.add(value);
    }
    
    /**
     * Adds a custom data value to the set of custom data values
     * @param key The CustomDataKey for this value
     * @param value The value to set
     * @param user The user doing the setting
     */
    public void addCustomDataValue(CustomDataKey key, String value, User user) {
        // Check for null key values. 
        if (key == null || key.getLabel() == null) {
            throw new 
                UndefinedCustomDataKeyException("CustomDataKey can not be null.");
        }
        
        // Make sure this org has this particular CustomDataKey defined
        if (!org.hasCustomDataKey(key.getLabel())) {
            throw new
                UndefinedCustomDataKeyException("CustomDataKey: " + key.getLabel() + 
                    " is not defined for this org.");
        }
        
        // get the CustomDataValue
        CustomDataValue customValue = getCustomDataValue(key);
        
        // does the server already have this key defined?
        if (customValue != null) {
            // update the value
            customValue.setValue(value);
            // update last modifier
            customValue.setLastModifier(user);
        } 
        // server doesn't have this key defined
        else {
            // create a new CustomDataValue object
            customValue = new CustomDataValue();
            customValue.setCreator(user);
            customValue.setKey(key);
            customValue.setValue(value);
        }
        // add customValue to customDataValues set
        addCustomDataValue(customValue);
    }
    
    /**
     * Adds a custom data value to the set of custom data values
     * @param keyLabel The label for the CustomDataKey for this value
     * @param value The value to set
     * @param user The user doing the setting
     */
    public void addCustomDataValue(String keyLabel, String value, User user) {
        // look up CustomDataKey by keyLabel
        CustomDataKey key = OrgFactory.lookupKeyByLabelAndOrg(keyLabel, user.getOrg());
        addCustomDataValue(key, value, user);
    }
    
    /**
     * Retrieves a specific CustomDataValue from the customDataValues set
     * @param key The Key for the value you're looking up
     * @return Returns a CustomDataValue if it exists for this server. null otherwise.
     */
    public CustomDataValue getCustomDataValue(CustomDataKey key) {
        return ServerFactory.getCustomDataValue(key, this);
    }
    
    /**
     * Returns the set of Channels this Server is subscribed to.
     * @return the set of Channels this Server is subscribed to.
     */
    public Set<Channel> getChannels() {
        return channels;
    }
    
    protected void setChannels(Set chans) {
        channels = chans;
    }
    
    /**
     * Adds the given channel to this Server.
     * @param c Channel to be added.
     */
    public void addChannel(Channel c) {
        channels.add(c);
    }

    /**
     * Returns the base channel for this server or null if not set.
     * @return Returns the base channel for this server or null if not set.
     */
    public Channel getBaseChannel() {
        /*
         * The base channel for a given server is designated in the database by
         * parent_channel == null. Since the number of channels for a given server is 
         * relatively small, loop through the channels set and look for one without a
         * parentChannel instead of going back to the db.
         */
        for (Iterator itr = channels.iterator(); itr.hasNext();) {
            Channel channel = (Channel) itr.next();
            if (channel.getParentChannel() == null) {
                // This is the base channel
                return channel;
            }
        }
        // Either we have no channels or all channels have a parent_channel. In either
        // case, the base channel cannot be determined for this server.
        return null;
    }
    
    /**
     * Checks to see if this server is Solaris 
     * @return Returns true if System is Solaris.
     */
    public boolean isSolaris() {
        return this.getServerArch().getArchType().getLabel().equals("sysv-solaris");
    }
    
    /**
     * Returns true if this is a satellite server.
     * @return true if this is a satellite server.
     */
    public boolean isSatellite() {
        return false;
    }
    
    /**
     * Returns true if this is a proxy server.
     * @return true if this is a proxy server.
     */
    public boolean isProxy() {
        return getProxyInfo() != null;
    }
    
    /**
     * Returns true if the server has the given Entitlement.
     * @param entitlement Entitlement to verify.
     * @return true if the server has the given Entitlement.
     */
    public boolean hasEntitlement(Entitlement entitlement) {
        List grps = getEntitledGroups();
        for (Iterator itr = grps.iterator(); itr.hasNext();) {
            ServerGroup g = (ServerGroup) itr.next();

            // The server's group type can be null if the user has created some
            // custom server groups.  If so, we won't check it against the 
            // given entitlement.

            ServerGroupType groupType = g.getGroupType();
            if (groupType.getLabel().equals(entitlement.getLabel())) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Give a set of the entitlements a server has.
     * This is entirely based on the server groups, but server
     * groups also contain user defined groups.
     * @return a set of Entitlement objects
     */
    public Set<Entitlement> getEntitlements() {
        Set<Entitlement> entitlements = new HashSet<Entitlement>();
        
        Iterator i = getEntitledGroups().iterator();
        while (i.hasNext()) {
            ServerGroup grp = (ServerGroup)i.next();
               entitlements.add(EntitlementManager.getByName(
                        grp.getGroupType().getLabel()));
        }
        return entitlements;
    }
    
    /**
     * Base entitlement for the Server.
     * @return Entitlement that is the base entitlement for the server
     */
    public Entitlement getBaseEntitlement() {
        Entitlement baseEntitlement = null;
        Iterator i = getEntitledGroups().iterator();
        
        while (i.hasNext() && baseEntitlement == null) {
            ServerGroupType sgt = ((ServerGroup) i.next()).getGroupType();
            
            if (sgt.isBase()) {
                baseEntitlement = EntitlementManager.getByName(sgt.getLabel());
            }
        }
        
        return baseEntitlement;
    }
    
    /**
     * Base entitlement for the Server.
     * @param baseIn to update to
     */
    public void setBaseEntitlement(Entitlement baseIn) {
        ServerGroupType verify = ServerFactory.
            lookupServerGroupTypeByLabel(baseIn.getLabel());
        if (!verify.isBase()) {
            throw new IllegalArgumentException("baseIn is not a base entitlement");
        }
        
        Entitlement baseEntitlement = this.getBaseEntitlement();
        if (baseEntitlement != null && baseIn.equals(baseEntitlement)) {
            // noop if there is no change
            return;
        }
        if (baseEntitlement != null) {
            this.getEntitlements().remove(baseEntitlement);
            SystemManager.removeServerEntitlement(this.getId(), baseEntitlement);
        }
        
        SystemManager.entitleServer(this, baseIn);
    }    
    
    /**
     * Set of add-on entitlements for the Server.
     * @return Set of entitlements that are add-on entitlements for the server
     */
    public Set getAddOnEntitlements() {
        Set s = new HashSet();
        
        Iterator i = getEntitledGroups().iterator();
        
        while (i.hasNext()) {
            ServerGroupType sgt = ((ServerGroup) i.next()).getGroupType();
            
            if (!sgt.isBase()) {
                s.add(EntitlementManager.getByName(sgt.getLabel()));
            }
        }
        
        return s;
    }

    /**
     * Returns a comma-delimted list of add-on entitlements with their human readable
     * labels.
     * 
     * @return A comma-delimted list of add-on entitlements with their human readable
     * labels.
     */
    public String getAddOnEntitlementsAsText() {
        Set addOnEntitlements = getAddOnEntitlements();
        Iterator iterator = addOnEntitlements.iterator();
        StringBuffer buffer = new StringBuffer();
        Entitlement entitlement = null;
        
        while (iterator.hasNext()) {
            entitlement = (Entitlement)iterator.next();
            buffer.append(entitlement.getHumanReadableLabel()).append(", ");
        }
        
        if (!addOnEntitlements.isEmpty()) {
            buffer.delete(buffer.length() - 2, buffer.length());
        }
        
        return buffer.toString();
    }
 
    /**
     * Return <code>true</code> if this is a virtual host, <code>false</code> otherwise.
     * If this is a host system, {@link #getVirtualInstance()} will always be <code>null
     * </code> since we are not supporting/implementing guests of guest in the RHN 500
     * release.
     * 
     * @return true if the system is a virtual host
     */
    public boolean isVirtualHost() {
        return hasVirtualizationEntitlement();
    }
   
    /**
     * Return <code>true</code> if this a guest system, <code>false</code> otherwise. If
     * this system is a guest, {@link #getVirtualInstance()} will be non-<code>null</code>.
     * 
     * @return <code>true</code> if this a guest system, <code>false</code> otherwise.
     */
    public boolean isVirtualGuest() {
        return getVirtualInstance() != null;
    }
    
    /**
     * Return <code>true</code> if this system has virtualization entitlements, 
     * <code>false</code> otherwise.
     * @return <code>true</code> if this system has virtualization entitlements,
     *      <code>false</code> otherwise.
     */
    public boolean hasVirtualizationEntitlement() {
        return hasEntitlement(EntitlementManager.VIRTUALIZATION) ||
            hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM);
    }
    
    private boolean hasGuests() {
        return getGuests().size() > 0;
    }
    
    /**
     * 
     * @return the virtual guests
     */
    private Set<VirtualInstance> getVirtualGuests() {
        return guests;
    }
    
    private void setVirtualGuests(Set<VirtualInstance> virtualGuests) {
        this.guests = virtualGuests;
    }
    
    /**
     * Returns a read-only collection of VirtualInstance objects.
     * @return A read-only collection of VirtualInstance objects.
     */
    public Collection<VirtualInstance> getGuests() {
        Set<VirtualInstance> retval = new HashSet<VirtualInstance>();
        for (VirtualInstance vi : getVirtualGuests()) {
            // Filter out the hosts that sometimes show up in this table.
            // Hosts have no UUID defined.
            if (vi.getUuid() != null) {
                retval.add(vi);
            }
        }
        return Collections.unmodifiableCollection(retval);
    }
    
    /**
     * 
     * @param guest the guest to add
     */
    public void addGuest(VirtualInstance guest) {
        guest.setHostSystem(this);
        guests.add(guest);
    }
    
    /**
     * Removes the virtual instance guest from this server. If the guest is registered,
     * then the guest server will be deleted from the virtual instance.
     *  
     * @param guest The virtual instance to delete
     *  
     * @return <code>true</code> if the guest is deleted, <code>false</code> otherwise.
     */
    public boolean deleteGuest(VirtualInstance guest) {
        if (canDeleteGuest(guest)) {
            guest.deleteGuestSystem();
            return removeGuest(guest);
        }
        return false;
    }
    
    private boolean canDeleteGuest(VirtualInstance guest) {
        for (VirtualInstance g : guests) {
            if (g.getId().equals(guest.getId())) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Remove the association between a guest and this server, but do not delete the 
     * guest server.
     * 
     * @param guest Guest to remove from this server.
     * @return <code>true</code> if the guest is deleted, <code>false</code> otherwise.
     */
    public boolean removeGuest(VirtualInstance guest) {
        boolean deleted = false;
        for (Iterator<VirtualInstance> it = guests.iterator(); it.hasNext();) {
            VirtualInstance g = it.next();
            if (g.getId().equals(guest.getId())) {
                guest.setHostSystem(null);
                
                it.remove();
                deleted = true;
                break;
            }
        }
        
        return deleted;
    }

    
    /**
     * Return the virtual instance that owns this server when the server is a virtual guest.
     * 
     * @return The virtual instance that owns this server when the server is a virtual 
     * guest. If the server is not a guest, the method returns <code>null</code>.
     */
    public VirtualInstance getVirtualInstance() {
        return virtualInstance;
    }
    
    /**
     * Sets the owning virtual instance for this server, which effectively makes this a
     * guest system.
     * 
     * @param instance The owning virtual instance
     */
    // Note that while the relationship between guest and virtual instance needs to be 
    // bi-directional, we want to manage the relationship (add/delete) from the virtual
    // instance since it is the owner/parent. Hence, the reason for package visibility on
    // this method.
    void setVirtualInstance(VirtualInstance instance) {
        virtualInstance = instance;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof Server)) {
            return false;
        }
        Server castOther = (Server) other;

        return new EqualsBuilder().append(os, castOther.getOs())
                                  .append(release, castOther.getRelease())
                                  .append(name, castOther.getName())
                                  .append(description, castOther.getDescription())
                                  .append(info, castOther.getInfo())
                                  .append(secret, castOther.getSecret())
                                  .append(autoDeliver, castOther.getAutoDeliver())
                                  .append(autoUpdate, castOther.getAutoUpdate())
                                  .append(runningKernel, castOther.getRunningKernel())
                                  .append(lastBoot, castOther.getLastBoot())
                                  .append(channelsChanged, castOther.getChannelsChanged())
                                  .append(getProxyInfo(), castOther.getProxyInfo())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id).append(digitalServerId).append(os)
                                    .append(release).append(name).append(description)
                                    .append(info).append(secret).append(autoDeliver)
                                    .append(autoUpdate).append(runningKernel)
                                    .append(lastBoot).append(channelsChanged).
                                    append(getProxyInfo())
                                    .toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.DEFAULT_STYLE).append(
                "id", id).append("org", org).append("name", name).append(
                "description", description).toString();
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * @return Returns the lock.
     */
    public ServerLock getLock() {
        return lock;
    }

    /**
     * @param lockIn The lock to set.
     */
    public void setLock(ServerLock lockIn) {
        this.lock = lockIn;
    }

    /**
     * @return Returns the uuid.
     */
    public ServerUuid getServerUuid() {
        return this.serverUuid;
    }

    /**
     * @param serverUuidIn The uuid to set.
     */
    public void setServerUuid(ServerUuid serverUuidIn) {
        this.serverUuid = serverUuidIn;
    }

    /** 
     * Business method to check if the system is considered 'inactive'
     * @return boolean if it hasn't checked in recently.
     */
    public boolean isInactive() {
        Date lastCheckin = this.getLastCheckin();
        long millisInDay = (1000 * 60 * 60 * 24);
        long threshold = Config.get().getInt(ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD, 1);
        Date yesterday = new Timestamp(System.currentTimeMillis() - 
                (millisInDay * threshold));
        return lastCheckin.before(yesterday);
    }
    
    
    /**
     * Get the Set of Child Channel objects associated with this server.  This 
     * is just a convenience method.  Basically the channels associated with this
     * server that are not base channels. 
     * 
     * @return Set of Child Channels.  null of none found.
     */
    public Set<Channel> getChildChannels() {
        // Make sure we return NULL if none are found
        if (this.getChannels() != null) {
            Set<Channel> retval = new HashSet<Channel>();
            for (Channel c : this.getChannels()) {
                // add non base channels (children)
                // to return set.
                if (!c.isBaseChannel()) {
                    retval.add(c);
                }
            }
            if (retval.size() == 0) {
                return null;
            }
            else {
                return retval;
            }
        }
        return null;
    }

    /**
     * @return The push client for this server.
     */
    public PushClient getPushClient() {
        return pushClient;
    }

    /**
     * @param pushClientIn The push client to be used for this server.
     */
    public void setPushClient(PushClient pushClientIn) {
        this.pushClient = pushClientIn;
    }
    
    /**
     * Simple check to see if the Server is subscribed to the passed in channel already.
     * @param channelIn to check
     * @return boolean true false if subbed or not.
     */
    public boolean isSubscribed(Channel channelIn) {
        Set childChannels = this.channels;
        if (childChannels != null) {
            return childChannels.contains(channelIn);
        }
        return false;
    }
    
    /**
     * Check to see if the passed in entitlement can be applied to this server.
     * @param entIn to check
     * @return boolean if its compatible with this server.
     */
    public boolean isEntitlementAllowed(Entitlement entIn) {
        // Check virt entitlements.
        if (this.isVirtualGuest()) {
            if (entIn instanceof VirtualizationEntitlement) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Get the Set of valid addon Entitlements for this server.
     * 
     * @return Set of valid addon Entitlement instances for this server
     */
    public Set getValidAddonEntitlementsForServer() {
        Set retval = new HashSet();
        Iterator i = this.getOrg().getValidAddOnEntitlementsForOrg().iterator();
        while (i.hasNext()) {
            Entitlement ent = (Entitlement) i.next();
            if (this.isEntitlementAllowed(ent)) {
                retval.add(ent);
            }
        }
        return retval;

    }
    /**
     * An adapter method that transforms a Server into a HostAndGuestCountView.
     * 
     * @return A HostAndGuestCountView from which the Server was transformed
     */
    public HostAndGuestCountView asHostAndGuestCountView() {
        return new HostAndGuestCountView(getId(), getName(), getGuests().size());
                
    }

    /**
     * @return this list of history events for this server
     */
    public Set getHistory() {
        return history;
    }

    /**
     * Set the history events for this server
     * @param historyIn the List of history events
     */
    public void setHistory(Set historyIn) {
        this.history = historyIn;
    }
    
    /**
     * @return Returns the packages.
     */
    public Set getPackages() {
        return packages;
    }

    
    /**
     * @param packagesIn The packages to set.
     */
    public void setPackages(Set packagesIn) {
        this.packages = packagesIn;
    }

    /**
     * Returns the "Release" package associated to this server
     * This has useful information like the Rhel release, and evr 
     * @return the Redhat release Installed Package 
     */
    public InstalledPackage getReleasePackage() {
        return PackageManager.lookupReleasePackageFor(this);
    }

    /**
     * @return Returns the cobblerId.
     */
    public String getCobblerId() {
        return cobblerId;
    }

    /**
     * @param cobblerIdIn The cobblerId to set.
     */
    public void setCobblerId(String cobblerIdIn) {
        this.cobblerId = cobblerIdIn;
    }

    /**
     * @return Returns the ignoreEntitlementsForMigration.
     */
    public Boolean getIgnoreEntitlementsForMigration() {
        return ignoreEntitlementsForMigration;
    }

    /**
     * This method should ONLY be used for system migrations, hence the long method name.
     *
     * This method will set a local flag (i.e. not Hibernate-related) that if set will
     * result in skipping entitlement checking on various methods.
     *
     * @param ignoreIn  Set to true to override entitlement sestings.
     */
    public void setIgnoreEntitlementsForMigration(Boolean ignoreIn) {
        this.ignoreEntitlementsForMigration = ignoreIn;
    }

    /**
     * Get the NetworkInteface with the given name (i.e. eth0)
     * @param ifName the interface name (i.e. eth0)
     * @return the NetworkInterface, otherwise null
     */
    public NetworkInterface getNetworkInterface(String ifName) {
        for (NetworkInterface nic : getNetworkInterfaces()) {
            if (nic.getName().equals(ifName)) {
                return nic;
            }
        }
        return null;
    }

    /**
     * Returns the cobbler object associated to 
     * to this server.
     * @param user the user object needed for connection,
     *              enter null if you want to use the 
     *              automated connection as provided by
     *              taskomatic.
     * @return the SystemRecord associated to this server
     */
    public SystemRecord getCobblerObject(User user) {
        if (StringUtils.isBlank(getCobblerId())) {
            return null;
        }
        CobblerConnection con;
        if (user == null) {
            con = CobblerXMLRPCHelper.getAutomatedConnection();
        }
        else {
            con = CobblerXMLRPCHelper.getConnection(user);
        }
        return SystemRecord.lookupById(con, getCobblerId());
    }

}
