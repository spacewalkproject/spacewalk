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
package com.redhat.rhn.domain.token;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.Identifiable;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * Token
 * @version $Rev$
 */
public class Token implements Identifiable {

    private Long id;
    private String note;
    private Long disabled;
    private boolean deployConfigs;
    private Long usageLimit;
    private Org org;
    private User creator;
    private Server server;
    private Set <Server> activatedSystems = new HashSet<Server>();
    private List <ConfigChannel> configChannels = new LinkedList <ConfigChannel>();
    private Set<ServerGroupType> entitlements = new HashSet<ServerGroupType>();
    private Set<Channel> channels = new HashSet<Channel>();
    private Set<ServerGroup> serverGroups = new HashSet<ServerGroup>();
    private Set<TokenPackage> packages = new HashSet<TokenPackage>();
    
    /**
     * @return Returns the entitlements.
     */
    public Set<ServerGroupType> getEntitlements() {
        return this.entitlements;
    }
    
    /**
     * @param entitlementsIn The entitlements to set.
     */
    public void setEntitlements(Set entitlementsIn) {
        this.entitlements = entitlementsIn;
    }

    /**
     * Add a server group type to the set of entitlements
     * @param sgtIn The server group type to add.
     */
    public void addEntitlement(ServerGroupType sgtIn) {
        getEntitlements().add(sgtIn);
    }
    
    /**
     * Remove a server group type from the set of entitlements
     * @param sgtIn The server group type to remove.
     */
    public void removeEntitlement(ServerGroupType sgtIn) {
        getEntitlements().remove(sgtIn);
    }
    
    /**
     * Removes all system entitlements associtated to this activation key. 
     */
    public void clearEntitlements() {
        getEntitlements().clear();
    }
    
    
    /**
     * @return Returns the deployConfigs.
     */
    public boolean getDeployConfigs() {
        return deployConfigs;
    }
    
    /**
     * @param d The deployConfigs to set.
     */
    public void setDeployConfigs(boolean d) {
        this.deployConfigs = d;
    }
    
    /**
     * Convenience method to make this field more sensible
     * @return Returns true if disabled == 1
     */
    public boolean isTokenDisabled() {
        return getDisabled().equals(new Long(1));
    }
    
    /**
     * Convenience method to make this field more sensible
     * Sets the disabled attribute to 1
     */
    public void disable() {
        setDisabled(new Long(1));
    }
    
    /**
     * Convenience method to set the disabled 
     * attribute to 0 
     */
    public void enable() {
        setDisabled(new Long(0));
    }
    
    /**
     * @return Returns the disabled.
     */
    public Long getDisabled() {
        return disabled;
    }
    
    /**
     * @param d The disabled to set.
     */
    public void setDisabled(Long d) {
        this.disabled = d;
    }
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the note.
     */
    public String getNote() {
        return note;
    }
    
    /**
     * @param n The note to set.
     */
    public void setNote(String n) {
        this.note = n;
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
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * @param s The server to set.
     */
    public void setServer(Server s) {
        this.server = s;
    }
    
    /**
     * @return Returns the usageLimit.
     */
    public Long getUsageLimit() {
        return usageLimit;
    }
    
    /**
     * @param u The usageLimit to set.
     */
    public void setUsageLimit(Long u) {
        if (u != null && u < 0) {
            u = null;
        }
        this.usageLimit = u;
    }
    
    /**
     * @return Returns the user.
     */
    public User getCreator() {
        return creator;
    }
    
    /**
     * @param u The user to set.
     */
    public void setCreator(User u) {
        this.creator = u;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof Token)) {
            return false;
        }
        Token castOther = (Token) other;
        return new EqualsBuilder().append(getId(), castOther.getId())
                                  .append(getDisabled(), castOther.getDisabled())
                                  .append(getDeployConfigs(), 
                                                      castOther.getDeployConfigs())
                                  .append(getNote(), castOther.getNote())
                                  .append(getOrg(), castOther.getOrg())
                                  .append(getServer(), castOther.getServer())
                                  .append(getCreator(), castOther.getCreator())
                                  .append(getUsageLimit(), castOther.getUsageLimit())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getId())
                                    .append(getDisabled())
                                    .append(getDeployConfigs())
                                    .append(getNote())
                                    .append(getOrg())
                                    .append(getServer())
                                    .append(getCreator())
                                    .append(getUsageLimit())
                                    .toHashCode();
    }

    /**
     * @return Returns the channels.
     */
    public Set<Channel> getChannels() {
        return channels;
    }

    /**
     * @param channelsIn The channels to set.
     */
    public void setChannels(Set channelsIn) {
        this.channels = channelsIn;
    }

    /**
     * Clear all channels associated with this token.
     */
    public void clearChannels() {
        this.channels = new HashSet();
    }
    
    /**
     * Add a channel to this Token
     * @param channelIn to add
     */
    public void addChannel(Channel channelIn) {
        //If the channelIn is null, there are a few things we could do.
        // One: add it to the set (will cause DB exception)
        // Two: ignore it.
        // Three: throw our own exception.
        //I chose number 3 because I don't know what the consequences of
        // ignoring it is, and 3 is definitely better than 1. (bug #201561)
        
        if (channelIn == null) {
            throw new NullPointerException("A token cannot have a null channel.");
        }
        this.getChannels().add(channelIn);
    }
    
    /**
     * Remove a channel from this Token
     * @param channelIn to remove
     */
    public void removeChannel(Channel channelIn) {
        this.getChannels().remove(channelIn);
    }

    /**
     * @return Returns the server groups
     */
    public Set<ServerGroup> getServerGroups() {
        return serverGroups;
    }

    /**
     * @param serverGroupsIn The server groups to set.
     */
    public void setServerGroups(Set serverGroupsIn) {
        this.serverGroups = serverGroupsIn;
    }

    /**
     * Add a ServerGroup to this Token
     * @param serverGroupIn Server group to add
     */
    public void addServerGroup(ManagedServerGroup serverGroupIn) {
        if (serverGroupIn == null) {
            throw new NullPointerException("A token cannot have a null server group.");
        }
        this.getServerGroups().add(serverGroupIn);
    }
    
    /**
     * Remove a ServerGroup from this Token
     * @param serverGroupIn Server group to remove
     */
    public void removeServerGroup(ServerGroup serverGroupIn) {
        this.getServerGroups().remove(serverGroupIn);
    }

    /**
     * Add a package to this Token using the PackageName given.
     * @param packageNameIn PackageName to add
     * @param packageArchIn PackageArch to add
     */
    public void addPackage(PackageName packageNameIn, PackageArch packageArchIn) {
        if (packageNameIn == null) {
            throw new NullPointerException("A token cannot have a null packageName.");
        }
        TokenPackage tokenPackage = new TokenPackage();
        tokenPackage.setToken(this);
        tokenPackage.setPackageName(packageNameIn);
        tokenPackage.setPackageArch(packageArchIn);

        this.getPackages().add(tokenPackage);
    }

    /**
     * Remove a PackageName from this Token
     * @param packageNameIn Package name to remove
     * @param packageArchIn Package arch to remove (optional)
     */
    public void removePackage(PackageName packageNameIn, PackageArch packageArchIn) {

        // a package cannot exist w/o a name; therefore, no need to go further
        if (packageNameIn == null) {
            return;
        }

        // a package associated with a token may or may not have an arch associated with it
        if (packageArchIn != null) {
            // if there is an arch, only 1 package may exist
            TokenPackage tokenPackage = TokenPackageFactory.lookupPackage(this,
                    packageNameIn, packageArchIn);

            if (tokenPackage != null) {
                this.getPackages().remove(tokenPackage);
            }
        }
        else {
            // if no arch is provided, it is possible that we could get multiple packages
            // with the name specified; however, only 1 of those may have an arch of null
            List<TokenPackage> tokenPackages = TokenPackageFactory.lookupPackages(this,
                    packageNameIn);

            for (TokenPackage tokenPackage : tokenPackages) {
                if (tokenPackage.getPackageArch() == packageArchIn) {
                    this.getPackages().remove(tokenPackage);
                    break;  //stop searching...
                }
            }
        }
    }
    
    /**
     * Add a package to this Token
     * @param packageIn package to add
     */
    public void addPackage(TokenPackage packageIn) {
        if (packageIn == null) {
            throw new NullPointerException("A token cannot have a null package.");
        }
        this.getPackages().add(packageIn);
    }
    
    /**
     * Remove a package from this Token
     * @param packageIn package to remove
     */
    public void removePackage(TokenPackage packageIn) {
        this.getPackages().remove(packageIn);
    }

    /**
     * @return Returns the packages
     */
    public Set<TokenPackage> getPackages() {
        return packages;
    }

    /**
     * @param packagesIn The packages to set.
     */
    public void setPackages(Set packagesIn) {
        this.packages = packagesIn;
    }

    /**
     * Clear all packages associated with this token.
     */
    public void clearPackages() {
        getPackages().clear();
    }

    /**
     * @return Returns the activated systems
     */
    public Set<Server> getActivatedServers() {
        return activatedSystems;
    }

    /**
     * @param servers the activated servers to set.
     */
    protected void setActivatedServers(Set<Server> servers) {
        this.activatedSystems = servers;
    }    
    
    /**
     * @return the configChannels
     */
    protected List getConfigChannels() {
        return configChannels;
    }
    
    /**
     * This method should only be called by hibernate..!
     * @param cfgChannels the configChannels to set
     */
    protected void setConfigChannels(List cfgChannels) {
        this.configChannels = cfgChannels;
    }

    /**
     * Returns the config channels associated to this activation key
     * It requires User info for credential checking.. 
     * This method raises a Lookup Exception if the passed in user
     * does NOT have access to the config channels. 
     * @param user the User object needed for access credentials
     * @return the list of config channels assign to this user
     */
    public List <ConfigChannel> getConfigChannelsFor(User user) {
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        proc.validateUserAccess(user, getConfigChannels());
        return getConfigChannels();    
    }
    
    private void checkProvisioning() {
        if (!getEntitlements().contains(ServerConstants.
                getServerGroupTypeProvisioningEntitled())) {
            String msg = String.format("The activation key '%s' needs" +
                        "  provisioning capabilities to be able to facilitate " +
                        " the config channel functionality", this);
                throw new PermissionException(msg); 
        }        
    }    
    
    /**
     * Removes all the config channels associated to this activation key.
     */
    public void clearConfigChannels() {
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        proc.clear(getConfigChannels());
    }
    
    /**
     * Returns the base channel associated to this token  
     * @return the base channel of this token or null if none exists
     */
    public Channel getBaseChannel() {
        for (Channel ch : getChannels()) {
            if (ch.isBaseChannel()) {
                return ch;
            }
        }
        return null;
    }
    
    /**
     * Updates the base channel associated to this token.
     * Note this method clears existing child channels if base channel 
     * passed in is different from what it already has.
     * It also accepts null for base channel == redhat default
     * @param channel sets the base channel of this token. 
     */
    public void setBaseChannel(Channel channel) {
        if (channel != null && !channel.isBaseChannel()) {
            String msg = "The channel [%s] is NOT a base channel";
            throw new IllegalArgumentException(String.format(msg, channel.toString()));
        }
        Channel existing = getBaseChannel();
        if (existing != channel) {
            if (existing != null && channel != null && 
                    !existing.getId().equals(channel.getId())) {
                clearChannels();
                getChannels().add(channel);
            }
            else if (existing == null) {
                clearChannels();
                getChannels().add(channel);
            }
            else if (channel == null) {
                clearChannels();
            }
        }

    }

    /**
     * Returns true if this token is the org default.
     * @return true if its the org defaul false otherwise
     */
    public boolean isOrgDefault() {
        return equals(getOrg().getToken());
    }

    /**
     * Sets this token as the universal default.
     * @param orgDefault true if this activation key is the org default.
     */
    public void setOrgDefault(boolean orgDefault) {
        if (orgDefault && !this.isOrgDefault()) {
            getOrg().setToken(this);    
        }
        else if (!orgDefault && isOrgDefault())  {
            getOrg().setToken(null);
        }
    }    
}
