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

package com.redhat.rhn.domain.org;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.usergroup.UserGroup;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;

import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Class Org that reflects the DB representation of web_customer DB table:
 * web_customer
 * @version $Rev:67468 $
 */
public interface Org {

    // /** Static entitlement necessary for comparison within package */
    // OrgEntitlementType ENTITLEMENT_SW_MGR_PERSONAL2 = new OrgEntitlementType(
    // "sw_mgr_personal",
    // new Long(-1));
    // /** Static entitlement, mainly used to check on Management entitlements.
    // */
    // OrgEntitlementType ENTITLEMENT_ENTERPRISE2 = OrgFactory.
    // lookupEntitlementByLabel("sw_mgr_enterprise");
    //
    //    
    // /** Static entitlement, mainly used to check on Monitoring entitlements.
    // */
    // OrgEntitlementType ENTITLEMENT_MONTIORING2 = OrgFactory.
    // lookupEntitlementByLabel("rhn_monitor");
    //    
    // /** Static entitlement, mainly used to check on provisioning
    // entitlements. */
    // OrgEntitlementType ENTITLEMENT_PROVISIONING2 = OrgFactory.
    // lookupEntitlementByLabel("rhn_provisioning");

    /**
     * @return Returns the customDataKeys.
     */
    Set getCustomDataKeys();

    /**
     * @param customDataKeysIn The customDataKeys to set.
     */
    void setCustomDataKeys(Set customDataKeysIn);

    /**
     * @param keyIn The CustomDataKey to add to the customDataKeys set for this
     * org.
     */
    void addCustomDataKey(CustomDataKey keyIn);

    /**
     * @param label The label to check for
     * @return Returns true if the corresponding custom data key exists, false
     * otherwise.
     */
    boolean hasCustomDataKey(String label);

    /**
     * Gets the current value of id
     * @return Long the current value
     */
    Long getId();

    /**
     * Gets the current value of name
     * @return String the current value
     */
    String getName();

    /**
     * Sets the value of name to new value
     * @param nameIn New value for name
     */
    void setName(String nameIn);

    /**
     * Gets the current value of oracleCustomerId
     * @return Integer the current value
     */
    Integer getOracleCustomerId();

    /**
     * Sets the value of oracleCustomerId to new value
     * @param oracleIn New value for oracleCustomerId
     */
    void setOracleCustomerId(Integer oracleIn);

    /**
     * Gets the current value of oracleCustomerNumber
     * @return int the current value
     */
    Integer getOracleCustomerNumber();

    /**
     * Sets the value of oracleCustomerNumber to new value
     * @param oracleIn New value for oracleCustomerNumber
     */
    void setOracleCustomerNumber(Integer oracleIn);

    /**
     * Gets the current value of customerType
     * @return String the current value
     */
    String getCustomerType();

    /**
     * Sets the value of customerType to new value
     * @param customerTypeIn New value for customerType
     */
    void setCustomerType(String customerTypeIn);

    /**
     * Gets the current value of created
     * @return Date the current value
     */
    Date getCreated();

    /**
     * Sets the value of created to new value
     * @param createdIn New value for created
     */
    void setCreated(Date createdIn);

    /**
     * Gets the current value of creditApplicationCompleted
     * @return String the current value
     */
    String getCreditApplicationCompleted();

    /**
     * Sets the value of creditApplicationCompleted to new value
     * @param credIn New value for creditApplicationCompleted
     */
    void setCreditApplicationCompleted(String credIn);

    /**
     * Gets the current value of modified
     * @return Date the current value
     */
    Date getModified();

    /**
     * Sets the value of modified to new value
     * @param modifiedIn New value for modified
     */
    void setModified(Date modifiedIn);

    /**
     * Gets the roles assigned to this Org. The Map returned from this method
     * has been decorated with a call to
     * {@link java.util.Collections#unmodifiableMap} in order to enforce the
     * rule that roles are not changeable during runtime.
     * @return Set of Roles associated with this Org
     */
    Set<Role> getRoles();

    /**
     * Does the Org have the specified role
     * @param roleLabel the Role.label to check
     * @return boolean if the Org has Role
     */
    boolean hasRole(Role roleLabel);

    /**
     * Get the Org's UserGroup ID for the specified Role
     * @param roleLabel the Role.label to translate to a UserGroup.ID
     * @return the UserGroup if found, otherwise null.
     */
    UserGroup getUserGroup(Role roleLabel);

    /**
     * Add a Role to the Org.
     * @param roleLabel the role label we want to add to this Org
     */
    void addRole(Role roleLabel);

    /**
     * Set entitlements for this Org
     * @param entsIn new Set of Entitlements to update
     */
    void setEntitlements(Set entsIn);

    /**
     * Get entitlements for this Org
     * @return Set of entitlements for this Org
     */
    Set getEntitlements();

    /**
     * Does this org have the requested entitlement
     * @param ent Entitlement to check
     * @return boolean if or not the org has the Ent
     */
    boolean hasEntitlement(OrgEntitlementType ent);

    /**
     * Get the set of EntitlementServerGroups that this Org is a member of.
     * 
     * @return List of ServerGroup classes
     */
    List getEntitledServerGroups();

    /**
     * Get the set of ManagedServerGroups that this Org is a member of.
     * 
     * @return List of ServerGroup classes
     */
    List getManagedServerGroups();

    /**
     * TODO: get rid of Role label and pass in the class Reset channel
     * permissions for a user/channel/role combination
     * @param uid User ID to reset
     * @param cid Channel ID
     * @param roleLabel label of Role to reset
     */
    void resetChannelPermissions(Long uid, Long cid, String roleLabel);

    /**
     * TODO: get rid of Role label and pass in the class Remove all channel
     * permissions for a user/channel/role combination
     * @param uid User ID to reset
     * @param cid Channel ID
     * @param roleLabel label of Role to reset
     */
    void removeChannelPermissions(Long uid, Long cid, String roleLabel);

    /**
     * Returns true if the Org is a paying customer, or false if it's a demo
     * account.
     * @return true if the Org is a paying customer, or false if it's a demo
     * account.
     */
    boolean isPayingCustomer();

    /**
     * Add a Quota to this Org
     * @param totalIn the total size of the quota
     */
    void addOrgQuota(Long totalIn);

    /**
     * Get the quota object associated with this org.
     * @return an OrgQuota object.
     */
    OrgQuota getOrgQuota();

    /**
     * Get the value of the OrgQuota's TOTAL allowed
     * @return Long value of the Org's Quota total - null if there isnt one
     */
    Long getQuotaTotal();

    /**
     * Gets the number of active org admins in this org.
     * @return Returns the number of active org admins in this org.
     */
    int numActiveOrgAdmins();

    /**
     * Gets the list of active org admins (com.redhat.rhn.domain.user.User
     * objects) in this org.
     * @return Returns the set of active org admins in this org.
     */
    List <User> getActiveOrgAdmins();

    /**
     * Gets the com.redhat.rhn.domain.monitoring.satcluster.SatClusters
     * associated with this Org. Null if there are none or is not a Monitoring
     * Sat.
     * @return Set of SatClusters (Monitoring Scouts) associated with Org
     */
    Set getMonitoringScouts();

    /**
     * Get the Set of com.redhat.rhn.domain.monitoring.notification.ContactGroup
     * objects associated with this Org.
     * @return Set of ContactGroups
     */
    Set getContactGroups();

    /**
     * Adds a new channel to the orgs set of channels
     * @param channelIn The Channel to add
     */
    void addOwnedChannel(Channel channelIn);

    /**
     * Set the channels for this org.
     * @param channelsIn The channels for this org
     */
    void setOwnedChannels(Set channelsIn);

    /**
     * Get the set of channels associated with this org.
     * @return Returns the set of channels for this org.
     */
    Set getOwnedChannels();

    /**
     * Get the list of channels accessible for this org.
     * @return List of channels public or owned by this org.
     */
    List getAccessibleChannels();

    /**
     * Returns the channelFamilies.
     * @return the channelFamilies.
     */
    ChannelFamily getPrivateChannelFamily();

    /**
     * Returns if the given org has a demo entitlement
     * @return true if entitled, false if not.
     */
    boolean isDemoEntitled();

    /**
     * Set of Entitlements that can be a BaseEntitlement available to the Org
     * @return Set of Entitlements
     */
    Set<Entitlement> getValidBaseEntitlementsForOrg();

    /**
     * Set of Entitlements that can be an add-on entitlement available to the
     * Org
     * @return Set of Entitlements
     */
    Set<Entitlement> getValidAddOnEntitlementsForOrg();

    /**
     * Returns the default registration token for this organization.
     * @return default token, null if none exists.
     */
    Token getToken();

    /**
     * Sets the default registration token for this organization.
     * @param tokenIn Default token.
     */
    void setToken(Token tokenIn);

    /**
     * Gets the list of trusted orgs.
     * @return A set of trusted orgs.
     */
    Set<Org> getTrustedOrgs();

    /**
     * Add a (bidirectional) trust relationship. This is really only used by the
     * TrustSet.
     * @param org A "trusted" organization to add.
     */
    void addTrust(Org org);

    /**
     * Remove a (bidirectional) trust relationship. This is really only used by
     * the TrustSet.
     * @param org A "trusted" organization to be removed.
     */
    void removeTrust(Org org);
}
