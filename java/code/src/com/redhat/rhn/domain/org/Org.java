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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFamily;
import com.redhat.rhn.domain.channel.ChannelFamilyFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.usergroup.UserGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Class Org that reflects the DB representation of web_customer DB table:
 * web_customer
 * @version $Rev:67468 $
 */
public class Org extends BaseDomainHelper {

    private static final String USER_ID_KEY = "user_id";
    private static final String ORG_ID_KEY = "org_id";

    protected static Logger log = Logger.getLogger(Org.class);

    private Long id;
    private String name;
    private Set usergroups;
    private Set entitlements;
    private Set ownedChannels;
    private Set customDataKeys;
    private Set<Org> trustedOrgs;
    private Token token;
    private boolean stagingContentEnabled;

    private OrgQuota orgQuota;

    private Set monitoringScouts;
    private Set contactGroups;

    /**
     * Construct new Org
     */
    protected Org() {
        usergroups = new HashSet();
        entitlements = new HashSet();
    }

    /**
     * @return Returns the customDataKeys.
     */
    public Set getCustomDataKeys() {
        return this.customDataKeys;
    }

    /**
     * @param customDataKeysIn The customDataKeys to set.
     */
    public void setCustomDataKeys(Set customDataKeysIn) {
        this.customDataKeys = customDataKeysIn;
    }

    /**
     * Convenience method that checks the set of customDataKeys for a custom
     * data key with the given label.
     * @param label The label to check for.
     * @return Returns true if the corresponding custom data key exists, false
     * otherwise.
     */
    public boolean hasCustomDataKey(String label) {
        // Check for null
        if (label == null) {
            return false;
        }
        // Loop through the custom data keys and check for the label
        for (Iterator itr = customDataKeys.iterator(); itr.hasNext();) {
            CustomDataKey key = (CustomDataKey) itr.next();
            if (label.equals(key.getLabel())) {
                // Found it! no need to check anything else.
                return true;
            }
        }
        // Org doesn't have a key defined with this label.
        return false;
    }

    /**
     * @param keyIn The CustomDataKey to add to the customDataKeys set for this
     * org.
     */
    public void addCustomDataKey(CustomDataKey keyIn) {
        customDataKeys.add(keyIn);
    }

    /**
     * Gets the current value of id
     * @return long the current value
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets the value of id to new value
     * @param idIn New value for id
     */
    protected void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Gets the current value of name
     * @return String the current value
     */
    public String getName() {
        return this.name;
    }

    /**
     * Sets the value of name to new value
     * @param nameIn New value for name
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * Gets the roles assigned to this Org. The Map returned from this method
     * has been decorated with a call to
     * {@link java.util.Collections#unmodifiableMap} in order to enforce the
     * rule that roles are not changeable during runtime.
     * @return Set of Roles associated with this Org
     */
    public Set<Role> getRoles() {
        Set orgRoles = new HashSet();
        for (Iterator i = usergroups.iterator(); i.hasNext();) {
            UserGroup ug = (UserGroup) i.next();
            orgRoles.add(ug.getRole());
        }
        return Collections.unmodifiableSet(orgRoles);
    }

    /**
     * Does the Org have the specified role
     * @param role the Role to check
     * @return boolean if the Org has Role
     */
    public boolean hasRole(Role role) {
        return getRoles().contains(role);
    }


    /**
     * Add a Role to the Org.
     * @param newRole the role label we want to add to this Org
     */
    public void addRole(Role newRole) {
        // Don't create and add a new group if the Org already has the
        // specified role.
        if (!hasRole(newRole)) {
            // Create a new UserGroup based on the Role specified
            UserGroup newGroup = UserGroupFactory
            .createUserGroup(this, newRole);
            usergroups.add(newGroup);
        }
    }


    /**
     * Get the Org's UserGroup ID for the specified Role
     * @param roleIn the Role.label to translate to a UserGroup.ID
     * @return the UserGroup if found, otherwise null.
     */
    public UserGroup getUserGroup(Role roleIn) {
        for (Iterator i = usergroups.iterator(); i.hasNext();) {
            UserGroup ug = (UserGroup) i.next();
            if (ug.getRole().equals(roleIn)) {
                return ug;
            }
        }
        return null;
    }

    /**
     * Get UserGroups for this Org. This is used internally within this package
     * to map Roles to UserGroups
     * @return userGroup array
     */
    public Set getUserGroups() {
        return usergroups;
    }

    /**
     * Set UserGroups for this Org. This is used internally within this package
     * to map Roles to UserGroups
     * @param ugIn the new array
     */
    public void setUserGroups(Set ugIn) {
        usergroups = ugIn;
    }

    /**
     * Set entitlements for this Org
     * @param entsIn new Set of Entitlements to update
     */
    public void setEntitlements(Set entsIn) {
        entitlements = entsIn;
    }

    /**
     * Get entitlements for this Org
     * @return Set of entitlements for this Org
     */
    public Set getEntitlements() {
        return entitlements;
    }

    /**
     * Get the set of EntitlementServerGroups that this Org is a member of.
     *
     * @return List of ServerGroup classes
     */
    public List<EntitlementServerGroup> getEntitledServerGroups() {
        return ServerGroupFactory.listEntitlementGroups(this);
    }

    /**
     * Get the set of ManagedServerGroups that this Org is a member of.
     *
     * @return List of ServerGroup classes
     */
    public List<ManagedServerGroup> getManagedServerGroups() {
        return ServerGroupFactory.listManagedGroups(this);
    }

    /**
     * Adds a new channel to the orgs set of channels
     * @param channelIn The Channel to add
     */
    public void addOwnedChannel(Channel channelIn) {
        if (this.ownedChannels == null) {
            this.ownedChannels = new HashSet();
        }
        channelIn.setOrg(this);
        this.ownedChannels.add(channelIn);
    }

    /**
     * Set the channels for this org.
     * @param channelsIn The channels for this org
     */
    public void setOwnedChannels(Set channelsIn) {
        this.ownedChannels = channelsIn;
    }

    /**
     * Get the set of channels associated with this org.
     * @return Returns the set of channels for this org.
     */
    public Set getOwnedChannels() {
        return ownedChannels;
    }

    /**
     * Get the list of channels accessible for this org.
     * @return List of channels public or owned by this org.
     */
    public List getAccessibleChannels() {
        return ChannelManager.getChannelsAccessibleByOrg(this.id);
    }

    /**
     * Does this org have the requested entitlement
     * @param ent Entitlement to check
     * @return boolean if or not the org has the Ent
     */
    public boolean hasEntitlement(OrgEntitlementType ent) {
        if (!OrgFactory.isValidEntitlement(ent)) {
            throw new IllegalArgumentException("Invalid Entitlement specified");
        }
        // This is really bogus, but sw_mgr_personal isn't stored in the DB.
        // The rule is that if you don't have the sw_mgr_enterprise entitlement,
        // then you have the sw_mgr_personal one. So add that logic here.

        if (ent.equals(OrgFactory.getEntitlementSwMgrPersonal())) {
            if (!entitlements.contains(OrgFactory.getEntitlementEnterprise())) {
                return true;
            }
        }
        return entitlements.contains(ent);
    }

    private void manipulateChannelPerms(String modeName, Long uid, Long cid,
            String roleLabel) {
        WriteMode mode = ModeFactory.getWriteMode("Org_queries", modeName);
        Map params = new HashMap();
        params.put(USER_ID_KEY, uid);
        params.put("cid", cid);
        params.put("role_label", roleLabel);

        mode.executeUpdate(params);
    }

    /**
     * TODO: get rid of Role label and pass in the class Reset channel
     * permissions for a user/channel/role combination
     * @param uid User ID to reset
     * @param cid Channel ID
     * @param roleLabel label of Role to reset
     */
    public void resetChannelPermissions(Long uid, Long cid, String roleLabel) {
        manipulateChannelPerms("reset_channel_permissions", uid, cid, roleLabel);
    }

    /**
     * TODO: get rid of Role label and pass in the class Remove all channel
     * permissions for a user/channel/role combination
     * @param uid User ID to reset
     * @param cid Channel ID
     * @param roleLabel label of Role to reset
     */
    public void removeChannelPermissions(Long uid, Long cid, String roleLabel) {
        manipulateChannelPerms("remove_channel_permissions", uid, cid,
                roleLabel);
    }

    /**
     * Set the OrgQuota.
     * @param quotaIn the new quota to set.
     */
    public void setOrgQuota(OrgQuota quotaIn) {
        this.orgQuota = quotaIn;
    }

    /**
     * Get the OrgQuota
     * @return OrgQuota object
     */
    public OrgQuota getOrgQuota() {
        return this.orgQuota;
    }

    /**
     * Add a Quota to this Org
     * @param totalIn the total size of the quota
     */
    public void addOrgQuota(Long totalIn) {
        if (orgQuota == null) {
            orgQuota = new OrgQuota();
            orgQuota.setCreated(new Date());
            orgQuota.setModified(new Date());
            orgQuota.setOrg(this);
            orgQuota.setBonus(new Long(0));
            orgQuota.setUsed(new Long(0));
        }
        orgQuota.setTotal(totalIn);
    }

    /**
     * Get the value of the OrgQuota's TOTAL allowed
     * @return Long value of the Org's Quota total - null if there isnt one
     */
    public Long getQuotaTotal() {
        if (orgQuota == null) {
            return null;
        }
        return orgQuota.getTotal();
    }

    /**
     * Gets the number of active org admins in this org.
     * @return Returns the number of active org admins in this org.
     */
    public int numActiveOrgAdmins() {
        Session session = HibernateFactory.getSession();
        List list = session.getNamedQuery("Org.numOfOrgAdmins")
        .setParameter("org_id", this.getId())
        // Retrieve from cache if there
        .list();
        if (list != null) {
            return list.size();
        }
        return 0;
    }

    /**
     * Gets the list of active org admins (com.redhat.rhn.domain.user.User
     * objects) in this org.
     * @return Returns the set of active org admins in this org.
     */
    public List<User> getActiveOrgAdmins() {
        SelectMode m = ModeFactory.getMode("User_queries", "active_org_admins");
        Map params = new HashMap();
        params.put(ORG_ID_KEY, this.getId());
        DataResult dr = m.execute(params);
        if (dr == null) {
            return null;
        }
        return getUsers(dr);
    }

    /**
     * Gets the list of com.redhat.rhn.domain.user.User objects taking in
     * DataResult. Do we need to make this public?
     * @param dataresult the dataresult object containing the results of a query
     * @return Returns the userList
     */
    private List<User> getUsers(DataResult dataresult) {
        List userList = new ArrayList();
        Collection userIds = getListFromResult(dataresult, USER_ID_KEY);

        if (!userIds.isEmpty()) {
            userList = UserFactory.lookupByIds(userIds);
        }
        return userList;
    }

    /**
     * Gets the list user ids(Long) taking in DataResult and the key Do we need
     * to make this public?
     * @param dataresult the dataresult object containing the results of a query
     * @param key the key for fetching the value
     * @return Returns the userIds
     */
    private List getListFromResult(DataResult dataresult, String key) {
        List userIds = new ArrayList();
        Iterator iter = dataresult.iterator();
        while (iter.hasNext()) {
            // convert these to Longs
            Long bd = (Long) ((HashMap) iter.next()).get(key);
            userIds.add(bd);
        }
        return userIds;
    }

    /**
     * Gets the com.redhat.rhn.domain.monitoring.satcluster.SatClusters
     * associated with this Org. Null if there are none or is not a Monitoring
     * Sat.
     * @return Set of SatClusters (Monitoring Scouts) associated with Org
     */
    public Set getMonitoringScouts() {
        return monitoringScouts;
    }

    /**
     * Sets the monitoring Scouts for this Org.
     * @param monitoringScoutsIn the new set of Monitoring scouts
     */
    public void setMonitoringScouts(Set monitoringScoutsIn) {
        this.monitoringScouts = monitoringScoutsIn;
    }

    /**
     * Get the Set of com.redhat.rhn.domain.monitoring.notification.ContactGroup
     * objects associated with this Org.
     * @return Set of ContactGroups
     */
    public Set getContactGroups() {
        return contactGroups;
    }

    /**
     * @param contactGroupsIn The contactGroups to set.
     */
    protected void setContactGroups(Set contactGroupsIn) {
        this.contactGroups = contactGroupsIn;
    }

    /**
     * Returns the channelFamilies.
     * @return the channelFamilies.
     */
    public ChannelFamily getPrivateChannelFamily() {
        return ChannelFamilyFactory.lookupOrCreatePrivateFamily(this);
    }

    /**
     * Set of Entitlements that can be a BaseEntitlement available to the Org
     * @return Set of Entitlements
     */
    public Set<Entitlement> getValidBaseEntitlementsForOrg() {
        Set<Entitlement> baseEntitlements = new HashSet();

        Iterator i = getEntitledServerGroups().iterator();

        while (i.hasNext()) {
            ServerGroupType sgt = ((ServerGroup) i.next()).getGroupType();

            // Filter out the update entitlement for satellite:
            if (sgt.isBase() && !sgt.getLabel().equals(
                    EntitlementManager.UPDATE.getLabel())) {
                baseEntitlements.add(EntitlementManager.getByName(sgt
                        .getLabel()));
            }
        }

        return baseEntitlements;
    }

    /**
     * Set of Entitlements that can be an add-on entitlement available to the
     * Org
     * @return Set of Entitlements
     */
    public Set<Entitlement> getValidAddOnEntitlementsForOrg() {
        Set<Entitlement> addonEntitlements = new HashSet();

        Iterator i = getEntitledServerGroups().iterator();

        while (i.hasNext()) {
            ServerGroupType sgt = ((ServerGroup) i.next()).getGroupType();

            if (!sgt.isBase()) {
                addonEntitlements.add(EntitlementManager.getByName(sgt
                        .getLabel()));
            }
        }

        return addonEntitlements;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", this.getId()).append(
                "name", this.getName()).toString();
    }

    /**
     * Returns the default registration token for this organization.
     * @return default token, null if none exists.
     */
    public Token getToken() {
        return this.token;
    }

    /**
     * Sets the default registration token for this organization.
     * @param tokenIn Default token.
     */
    public void setToken(Token tokenIn) {
        this.token = tokenIn;
    }

    /**
     * Gets the list of trusted orgs.
     * @return A set of trusted orgs.
     */
    public Set<Org> getTrustedOrgs() {
        return new TrustSet(this, trustedOrgs);
    }

    /**
     * Add a (bidirectional) trust relationship. This is really only used by the
     * TrustSet.
     * @param org A "trusted" organization to add.
     */
    public void addTrust(Org org) {
        trustedOrgs.add(org);
        if (org instanceof Org) {
            Org impl = org;
            impl.trustedOrgs.add(this);
        }
    }

    /**
     * Remove a (bidirectional) trust relationship. This is really only used by
     * the TrustSet.
     * @param org A "trusted" organization to be removed.
     */
    public void removeTrust(Org org) {
        trustedOrgs.remove(org);
        if (org instanceof Org) {
            Org impl = org;
            impl.trustedOrgs.remove(this);
        }
    }

    /**
     * @return Returns the stageContentEnabled.
     */
    public boolean isStagingContentEnabled() {
        return stagingContentEnabled;
    }


    /**
     * @param stageContentEnabledIn The stageContentEnabled to set.
     */
    public void setStagingContentEnabled(boolean stageContentEnabledIn) {
        stagingContentEnabled = stageContentEnabledIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Org other = (Org) obj;
        if (getId() == null) {
            if (other.getId() != null) {
                return false;
            }
        }
        else if (!getId().equals(other.getId())) {
            return false;
        }
        return true;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((getId() == null) ? 0 : getId().hashCode());
        return result;
    }
}
