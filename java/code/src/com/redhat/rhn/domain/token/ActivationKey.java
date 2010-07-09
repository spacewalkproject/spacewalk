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
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerConstants;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.token.ActivationKeyManager;

import java.util.List;
import java.util.Set;

/**
 * ActivationKey
 * @version $Rev$
 */
public class ActivationKey extends BaseDomainHelper {

    private String key;
    private Token token = new Token();
    private KickstartSession kickstartSession;

    /**
     * @return Returns the key.
     */
    public String getKey() {
        return this.key;
    }

    /**
     * @param keyIn The key to set.
     */
    public void setKey(String keyIn) {
        this.key = keyIn;
    }

    /**
     * @return Returns the kickstartSession.
     */
    public KickstartSession getKickstartSession() {
        return this.kickstartSession;
    }

    /**
     * @param kickstartSessionIn The kickstartSession to set.
     */
    public void setKickstartSession(KickstartSession kickstartSessionIn) {
        this.kickstartSession = kickstartSessionIn;
    }

    /**
     * @return Returns the token.
     */
    public Token getToken() {
        return this.token;
    }

    /**
     * @param tokenIn The token to set.
     */
    protected void setToken(Token tokenIn) {
        this.token = tokenIn;
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return this.key;
    }

    /*
     * Token Convenience methods
     * This kind of sucks... the diff between an ActivationKey and RegToken is fuzzy
     * at best. Apparently the reason they are separated out into separate tables has
     * something to do with Kickstart sessions. But from what I gather, we never want
     * to deal with an ActivationKey without a token. So we'll hide the token from the
     * consumers of this class here.
     */

    /**
     * @param id The id to set
     */
    public void setId(Long id) {
        this.getToken().setId(id);
    }

    /**
     * @return Returns the token's id
     */
    public Long getId() {
        return this.getToken().getId();
    }

    /**
     * @param user The user to set
     */
    public void setCreator(User user) {
        this.getToken().setCreator(user);
    }

    /**
     * @return Returns the tokens user
     */
    public User getCreator() {
        return this.getToken().getCreator();
    }

    /**
     * @param org The org to set
     */
    public void setOrg(Org org) {
        this.getToken().setOrg(org);
    }

    /**
     * @return Returns the org
     */
    public Org getOrg() {
        return this.getToken().getOrg();
    }

    /**
     * @param server The server to set
     */
    public void setServer(Server server) {
        this.getToken().setServer(server);
    }

    /**
     * @return Returns the server
     */
    public Server getServer() {
        return this.getToken().getServer();
    }

    /**
     * @param note The note to set
     */
    public void setNote(String note) {
        this.getToken().setNote(note);
    }

    /**
     * @return Returns the tokens note
     */
    public String getNote() {
        return this.getToken().getNote();
    }

    /**
     * @param b Deploy configs
     */
    public void setDeployConfigs(boolean b) {
        if (b && b != getDeployConfigs()) {
            checkProvisioning();
            ActivationKeyManager.getInstance().
                    setupAutoConfigDeployment(this);
        }
        this.getToken().setDeployConfigs(b);

    }

    /**
     * @return Returns deploy configs
     */
    public boolean getDeployConfigs() {
        return this.getToken().getDeployConfigs();
    }

    /**
     * @param disabled The disabled to set
     */
    public void setDisabled(Long disabled) {
        this.getToken().setDisabled(disabled);
    }

    /**
     * @return Is this token disabled?
     */
    public boolean isDisabled() {
        return this.getToken().isTokenDisabled();
    }

    /**
     * @param limit The usage limit to set
     */
    public void setUsageLimit(Long limit) {
        this.getToken().setUsageLimit(limit);
    }

    /**
     * @return The usage limit for this token
     */
    public Long getUsageLimit() {
        return this.getToken().getUsageLimit();
    }

    /**
     * @param entitlementsIn The entitlements to set
     */
    public void setEntitlements(Set entitlementsIn) {
        this.getToken().setEntitlements(entitlementsIn);
    }

    /**
     * @return Returns the set of entitlements for this activation key
     */
    public Set<ServerGroupType> getEntitlements() {
        return this.getToken().getEntitlements();
    }

    /**
     * @param entitlementIn The entitlement to add to the tokens entitlements set.
     */
    public void addEntitlement(ServerGroupType entitlementIn) {
        this.getToken().addEntitlement(entitlementIn);
        if (ServerConstants.getServerGroupTypeVirtualizationEntitled().
                                                        equals(entitlementIn) ||
              ServerConstants.getServerGroupTypeVirtualizationPlatformEntitled().
                                              equals(entitlementIn)) {
            ActivationKeyManager.getInstance().setupVirtEntitlement(this);
        }
    }

    /**
     * @param entitlementIn The entitlement to remove from the tokens entitlements set.
     */
    public void removeEntitlement(ServerGroupType entitlementIn) {
        this.getToken().removeEntitlement(entitlementIn);
    }

    /**
     * Add a Channel to this ActivationKey
     * @param channelIn to add
     */
    public void addChannel(Channel channelIn) {
       this.getToken().addChannel(channelIn);
    }

    /**
     * Remove a Channel from this ActivationKey
     * @param channelIn to remove
     */
    public void removeChannel(Channel channelIn) {
       this.getToken().removeChannel(channelIn);
    }

    /**
     * Clear all channels associated with this token.
     */
    public void clearChannels() {
        this.getToken().clearChannels();
    }

    /**
     * Get the Set of Channels associated with this ActivationKey
     * @return Set of Channel objects.
     */
    public Set<Channel> getChannels() {
        return this.getToken().getChannels();
    }

    /**
     * Add a ServerGroup to this ActivationKey
     * @param serverGroupIn to add
     */
    public void addServerGroup(ManagedServerGroup serverGroupIn) {
       this.getToken().addServerGroup(serverGroupIn);
    }

    /**
     * Remove a ServerGroup from this ActivationKey
     * @param serverGroupIn to remove
     */
    public void removeServerGroup(ServerGroup serverGroupIn) {
       this.getToken().removeServerGroup(serverGroupIn);
    }

    /**
     * Get the Set of ServerGroup objects associated with this ActivationKey
     * @return Set of ServerGroup objects.
     */
    public Set<ServerGroup> getServerGroups() {
        return this.getToken().getServerGroups();
    }

    /**
     * Add a package to this ActivationKey using PackageName only
     * @param packageNameIn PackageName of package to add
     * @param packageArchIn PackageArch of package to add
     */
    public void addPackage(PackageName packageNameIn, PackageArch packageArchIn) {
       this.getToken().addPackage(packageNameIn, packageArchIn);
    }

    /**
     * Remove packages from the ActivationKey that match the PackageName
     * and PackageArch given.
     * @param packageNameIn PackageName of package to remove
     * @param packageArchIn PackageArch of package to remove
     */
    public void removePackage(PackageName packageNameIn, PackageArch packageArchIn) {
       this.getToken().removePackage(packageNameIn, packageArchIn);
    }

    /**
     * Add a package to this ActivationKey
     * @param packageNameIn TokenPackage to add
     */
    public void addPackage(TokenPackage packageNameIn) {
       this.getToken().addPackage(packageNameIn);
    }

    /**
     * Remove a package from this ActivationKey
     * @param packageNameIn Package name to remove
     */
    public void removePackage(TokenPackage packageNameIn) {
       this.getToken().removePackage(packageNameIn);
    }

    /**
     * Get the Set of TokenPackage objects associated with this ActivationKey
     * @return Set of TokenPackage objects.
     */
    public Set<TokenPackage> getPackages() {
        return this.getToken().getPackages();
    }

    /**
     * Clear all packages associated with this activation key.
     */
    public void clearPackages() {
        this.getToken().clearPackages();
    }

    /**
     * Clear all config channel associated with this activation key.
     */
    public void clearConfigChannels() {
        this.getToken().clearConfigChannels();
    }
    /**
     * Returns the config channels associated to this activation key
     * Throws a LookupException if the user does NOT have permissson to
     * access/deal with these channels.
     * @param user the user needed to ensure credentials
     * @return the config channels associated to this activation key
     */
    public List <ConfigChannel> getConfigChannelsFor(User user) {
        checkProvisioning();
        return getToken().getConfigChannelsFor(user);
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
     * sets the base channel.. clears child channels if it has to
     * @param chan the base channel associated to this activation key.
     */
    public void setBaseChannel(Channel chan) {
        getToken().setBaseChannel(chan);
    }

    /**
     * Return the base channel or null if none exists
     * @return the base channel.
     */
    public Channel getBaseChannel() {
        return getToken().getBaseChannel();
    }

    /**
     * Sets the universal default.
     * @param def the universal default
     */
    public void setUniversalDefault(boolean def) {
        this.getToken().setOrgDefault(def);
    }

    /**
     * Returns true if this token is the org default.
     * @return tru if its the org defaul false otherwise
     */
    public boolean isUniversalDefault() {
        return getToken().isOrgDefault();
    }

    /**
     * Makes the Activation key prefix that will get
     *  added to the base key
     * @param org the org of the activation key
     * @return the key prefix.
     */
    public static String makePrefix(Org org) {
        return org.getId() + "-";
    }
}
