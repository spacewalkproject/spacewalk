/**
 * Copyright (c) 2009--2015 Red Hat, Inc.
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
import com.redhat.rhn.domain.iss.IssSlave;
import com.redhat.rhn.domain.org.usergroup.UserGroup;
import com.redhat.rhn.domain.org.usergroup.UserGroupFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.server.EntitlementServerGroup;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.log4j.Logger;
import org.hibernate.Session;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
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
    private Set<UserGroup> usergroups;
    private Set<Channel> ownedChannels;
    private Set<CustomDataKey> customDataKeys;
    private Set<Org> trustedOrgs;
    private Set<IssSlave> allowedToSlaves;
    private Token token;
    private OrgAdminManagement orgAdminMgmt;

    private OrgConfig orgConfig;

    /**
     * Construct new Org
     */
    protected Org() {
        usergroups = new HashSet<UserGroup>();
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
    public void setCustomDataKeys(Set<CustomDataKey> customDataKeysIn) {
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
        for (Iterator<CustomDataKey> itr = customDataKeys.iterator(); itr.hasNext();) {
            CustomDataKey key = itr.next();
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
        Set<Role> orgRoles = new HashSet<Role>();
        for (Iterator<UserGroup> i = usergroups.iterator(); i.hasNext();) {
            UserGroup ug = i.next();
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
        for (Iterator<UserGroup> i = usergroups.iterator(); i.hasNext();) {
            UserGroup ug = i.next();
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
    public Set<UserGroup> getUserGroups() {
        return usergroups;
    }

    /**
     * Set UserGroups for this Org. This is used internally within this package
     * to map Roles to UserGroups
     * @param ugIn the new array
     */
    public void setUserGroups(Set<UserGroup> ugIn) {
        usergroups = ugIn;
    }

    /**
     * Set OrgConfig
     * @param orgConfigIn The new OrgConfig to set.
     */
    public void setOrgConfig(OrgConfig orgConfigIn) {
        orgConfig = orgConfigIn;
    }

    /**
     * Get OrgConfig for this Org
     * @return Get the OrgConfig for this Org
     */
    public OrgConfig getOrgConfig() {
        return orgConfig;
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
            this.ownedChannels = new HashSet<Channel>();
        }
        channelIn.setOrg(this);
        this.ownedChannels.add(channelIn);
    }

    /**
     * Set the channels for this org.
     * @param channelsIn The channels for this org
     */
    public void setOwnedChannels(Set<Channel> channelsIn) {
        this.ownedChannels = channelsIn;
    }

    /**
     * Get the set of channels associated with this org.
     * @return Returns the set of channels for this org.
     */
    public Set<Channel> getOwnedChannels() {
        return ownedChannels;
    }

    /**
     * Get the list of channels accessible for this org.
     * @return List of channels public or owned by this org.
     */
    public List<Channel> getAccessibleChannels() {
        return ChannelManager.getChannelsAccessibleByOrg(this.id);
    }

    private void manipulateChannelPerms(String modeName, Long uid, Long cid,
            String roleLabel) {
        WriteMode mode = ModeFactory.getWriteMode("Org_queries", modeName);
        Map<String, Object> params = new HashMap<String, Object>();
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
        Map<String, Object> params = new HashMap<String, Object>();
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
        Set<Entitlement> baseEntitlements = new HashSet<Entitlement>();

        Iterator<EntitlementServerGroup> i = getEntitledServerGroups().iterator();

        while (i.hasNext()) {
            ServerGroupType sgt = i.next().getGroupType();

            if (sgt.isBase()) {
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
        Set<Entitlement> addonEntitlements = new HashSet<Entitlement>();

        Iterator<EntitlementServerGroup> i = getEntitledServerGroups().iterator();

        while (i.hasNext()) {
            ServerGroupType sgt = i.next().getGroupType();

            if (!sgt.isBase()) {
                Entitlement ent = EntitlementManager.getByName(sgt.getLabel());
                if (ent != null) {
                    addonEntitlements.add(ent);
                }
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
        if (org != null) {
            org.trustedOrgs.add(this);
        }
    }

    /**
     * Remove a (bidirectional) trust relationship. This is really only used by
     * the TrustSet.
     * @param org A "trusted" organization to be removed.
     */
    public void removeTrust(Org org) {
        trustedOrgs.remove(org);
        if (org != null) {
            org.trustedOrgs.remove(this);
        }
    }

    /**
     * Gets the list of Slaves we're specifically allowed to be exported to
     * @return A set of IssSlaves
     */
    public Set<IssSlave> getAllowedToSlaves() {
        return allowedToSlaves;
    }

    /**
     * Set up slaves we can be exported to
     * @param inSlaves allowed slaves
     */
    protected void setAllowedToSlaves(Set<IssSlave> inSlaves) {
        allowedToSlaves = inSlaves;
    }


    /**
     * @return Returns the orgAdminMgmt.
     */
    public OrgAdminManagement getOrgAdminMgmt() {
        return orgAdminMgmt;
    }


    /**
     * @param orgAdminMgmtIn The orgAdminMgmt to set.
     */
    public void setOrgAdminMgmt(OrgAdminManagement orgAdminMgmtIn) {
        this.orgAdminMgmt = orgAdminMgmtIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object other) {
        if (!(other instanceof Org)) {
            return false;
        }
        Org otherOrg = (Org) other;
        return new EqualsBuilder()
            .append(getName(), otherOrg.getName())
            .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        return new HashCodeBuilder()
            .append(getName())
            .toHashCode();
    }
}
