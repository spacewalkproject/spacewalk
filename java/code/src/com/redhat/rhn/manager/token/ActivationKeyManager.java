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
package com.redhat.rhn.manager.token;

import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartSession;
import com.redhat.rhn.domain.rhnpackage.PackageArch;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroup;
import com.redhat.rhn.domain.server.ServerGroupType;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.MultipleChannelsWithPackageException;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.Profile;
import org.hibernate.Session;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ActivationKeyManager
 * @version $Rev$
 */
public class ActivationKeyManager {
    private static Logger log = Logger.getLogger(ActivationKeyManager.class);
    private static ActivationKeyManager instance = new ActivationKeyManager();
    //private constructor
    private ActivationKeyManager() {
    }

    /**
     * @return the static instance of this class.
     */
    public static ActivationKeyManager getInstance() {
        return instance;
    }

    /**
     * Look up an ActivationKey object by server
     * @param server The server in question
     * @param user needed for authentication
     * @return Returns the activation key for the server or null if one isn't found.
     */
    public List<ActivationKey> findByServer(Server server, User user) {
        List<ActivationKey> keys = ActivationKeyFactory.lookupByServer(server);
        Iterator i = keys.iterator();
        while (i.hasNext()) {
            ActivationKey key = (ActivationKey) i.next();
            validateCredentials(user, null, key);
        }
        return keys;
    }


    /**
     * Look up an ActivationKey object by it's key.
     * @param key The activation key we're searching for.
     * @param user needed for authentication..
     * @return Returns the activation key for the given key.
     */
    public ActivationKey lookupByKey(String key, User user) {
        ActivationKey ac = ActivationKeyFactory.lookupByKey(key);
        validateCredentials(user, key, ac);
        return ac;
    }




    /**
     * Create a new Re-ActivationKey object for a given user, server, and note
     * @param user The user creating the activation key
     * @param server The server for the activation key
     * @param note A note about the activation key
     * @param session the kickstart session associated with the key
     * @return Returns a newly created and filled out Activationkey
     */
    public ActivationKey createNewReActivationKey(User user, Server server,
                                       String note, KickstartSession session) {
        return createNewReActivationKey(user, server, "", note, new Long(0),
                null, false, session);
    }


    /**
     * Create a new Re-ActivationKey object for a given user, server, and note
     * @param user The user creating the activation key
     * @param server The server for the activation key
     * @param note A note about the activation key
     * @return Returns a newly created and filled out Activationkey
     */
    public ActivationKey createNewReActivationKey(User user, Server server,
                                                       String note) {
        return createNewReActivationKey(user, server, "", note, new Long(0), null,
                false, null);
    }

    /**
     * Create a new Re-ActivationKey object for a given user, server, and note.
     * @param user The user creating the activation key
     * @param server the server to create the key for
     * @param key Key to use, empty string to have one auto-generated
     * @param note A note about the activation key
     * @param usageLimit Usage limit for the activation key
     * @param baseChannel Base channel for the activation key
     * @param universalDefault Whether or not this key should be set as the universal
     *        default.
     * @param session the kickstart session to associate
     * @return Returns a newly created and filled out Activationkey
     */
    public ActivationKey createNewReActivationKey(User user, Server server,
            String key, String note, Long usageLimit, Channel baseChannel,
            boolean universalDefault, KickstartSession session) {
        if ((server == null && session == null) || (server != null &&
                SystemManager.lookupByIdAndUser(server.getId(), user) == null)) {
            throw new IllegalArgumentException("Either server or session can be null, " +
                    "but not both, otherwise use createNewActivationKey");
        }
        ActivationKey aKey =  ActivationKeyFactory.createNewKey(user, server, key,
                note, usageLimit, baseChannel, universalDefault);
        aKey.setKickstartSession(session);
        return aKey;
    }

    /**
     * Create a new ActivationKey object for a given user, and note.  If you are
     *      tying the activation key to a system (reactivation key) use
     *          createNewReActivationKey
     * @param user The user creating the activation key
     * @param note A note about the activation key
     * @return Returns a newly created and filled out Activationkey
     */
    public ActivationKey createNewActivationKey(User user, String note) {
        return createNewActivationKey(user,  "", note, new Long(0), null,
                false);
    }


    /**
     * Create a new ActivationKey object for a given user,  and note.  If you are
     *      tying the activation key to a system (reactivation key) use
     *          createNewReActivationKey
     * @param user The user creating the activation key
     * @param key Key to use, empty string to have one auto-generated
     * @param note A note about the activation key
     * @param usageLimit Usage limit for the activation key
     * @param baseChannel Base channel for the activation key
     * @param universalDefault Whether or not this key should be set as the universal
     *        default.
     * @return Returns a newly created and filled out Activationkey
     */
    public ActivationKey createNewActivationKey(User user,
            String key, String note, Long usageLimit, Channel baseChannel,
            boolean universalDefault) {
        if (user.hasRole(RoleFactory.ACTIVATION_KEY_ADMIN)) {
            return ActivationKeyFactory.createNewKey(user, null, key,
                    note, usageLimit, baseChannel, universalDefault);
        }
        String msg = "Cannot create activation key with key = " + key +
                        ". The user = " + user.getLogin() +
                        " does not have requisite permissions to administer " +
                        "the given key";
        throw new IllegalArgumentException(msg);
    }

    /**
     * Update the given ActivationKey details.
     * @param target Key to update.
     * @param description New key description, null to leave unchanged.
     * @param baseChannel New base channel
     */
    public void update(ActivationKey target, String description,
            Channel baseChannel) {

        if (description != null) {
            target.setNote(description);
        }

        target.setBaseChannel(baseChannel);
    }

    /**
     * Add entitlements to an activation key.
     * @param key Activation key to be acted upon
     * @param entitlementLabels List of string entitlement labels for the activation key
     */
    public void addEntitlements(ActivationKey key, List <String> entitlementLabels) {
        validateAddOnEntitlements(entitlementLabels, true);
        for (Iterator it = entitlementLabels.iterator(); it.hasNext();) {
            String label = (String)it.next();
            ServerGroupType entitlement =
                ServerFactory.lookupServerGroupTypeByLabel(label);
            key.addEntitlement(entitlement);
        }
    }

    /**
     * Remove entitlements from an activation key. Entitlements the key does not actually
     * have will be ignored.
     *
     * @param key Activation key to be acted upon
     * @param entitlementLabels List of string entitlement labels for the activation key
     */
    public void removeEntitlements(ActivationKey key, List <String> entitlementLabels) {
        validateAddOnEntitlements(entitlementLabels, false);
        for (String label : entitlementLabels) {
            ServerGroupType entitlement =
                ServerFactory.lookupServerGroupTypeByLabel(label);
            key.removeEntitlement(entitlement);

            if (label.equals("provisioning_entitled")) {
                // Special case, clear all packages and configuration channels:
                key.clearPackages();
                key.clearConfigChannels();
                key.setDeployConfigs(false);
                // TODO: clear configuration channels as well
            }
        }
    }

    /**
     * Add a channel to an activation key.
     * @param key Activation key to be acted upon
     * @param channel Channel to add
     */
    public void addChannel(ActivationKey key, Channel channel) {
        key.addChannel(channel);
    }

    /**
     * Remove a channel from an activation key.
     * @param key Activation key to be acted upon
     * @param channel Channel to remove
     */
    public void removeChannel(ActivationKey key, Channel channel) {
        key.removeChannel(channel);
    }

    /**
     * Add a ServerGroup to an activation key.
     * @param key Activation key to be acted upon
     * @param group ServerGroup to add
     */
    public void addServerGroup(ActivationKey key, ManagedServerGroup group) {
        key.addServerGroup(group);
    }

    /**
     * Remove a ServerGroup from an activation key.
     * @param key Activation key to be acted upon
     * @param group ServerGroup to remove
     */
    public void removeServerGroup(ActivationKey key, ServerGroup group) {
        key.removeServerGroup(group);
    }

    /**
     * Add a package to an activation key using the PackageName and PackageArch
     * provided.  If desired, PackageArch may be null.
     * @param key Activation key to be acted upon
     * @param packageName PackageName to add
     * @param packageArch PackageArch to add
     */
    public void addPackage(ActivationKey key, PackageName packageName,
            PackageArch packageArch) {
        key.addPackage(packageName, packageArch);
    }

    /**
     * Removes all packages from the activation key that match the PackageName
     * and PackageArch given.
     * @param key Activation key to be acted upon
     * @param packageName PackageName to remove
     * @param packageArch PackageArch to remove
     */
    public void removePackage(ActivationKey key, PackageName packageName,
            PackageArch packageArch) {
        key.removePackage(packageName, packageArch);
    }

    /**
     * Finds all activation keys visible to user.
     * @param requester User requesting the list.
     * @return All activation keys visible to user.
     */
    public List <ActivationKey> findAll(User requester) {
        Session session = null;
        session = HibernateFactory.getSession();
        return session.getNamedQuery("ActivationKey.findByOrg")
           .setEntity("org", requester.getOrg())
           .setCacheable(true)
           .list();
    }

    /**
     * Returns true if the the given user can
     * administer activation keys..
     * This should be the baseline for us to load activation keys.
     * @param user the user to check on
     * @param key the activation key to authenticate.
     * @return true if a key can be administered. False otherwise.
     */
    private boolean canAdministerKeys(User user, ActivationKey key) {
        return user != null && key != null &&
                 user.getOrg().equals(key.getOrg()) &&
                    user.hasRole(RoleFactory.ACTIVATION_KEY_ADMIN);
    }

    /**
     * validates that the given user can administer
     * the given activation key. Raises a permission exception
     * if the combination is invalid..
     * @param user the user to authenticate
     * @param keyStr Key string used for lookup. Null if none was used. (i.e. lookup
     * by server)
     * @param key the key to authenticate
     */
    public void validateCredentials(User user, String keyStr, ActivationKey key) {
        if (!canAdministerKeys(user, key)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e;
            if (keyStr != null) {
                e = new LookupException("Could not find activation key: " +
                        keyStr);
            }
            else {
                e = new LookupException("Could not find activation key");
            }

            e.setLocalizedTitle(ls.getMessage("lookup.activationkey.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.activationkey.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.activationkey.reason2"));
            throw e;
        }
    }

    /**
     * Removes an activation key. The fact the an ActivationKey Object
     * was generated implies that the user credentials have been
     * verified...
     * @param key the key to remove
     * @param user TODO
     */
    public void remove(ActivationKey key, User user) {
        changeCobblerProfileKey(key, key.getKey(), "", user);
        ActivationKeyFactory.removeKey(key);
    }

    /**
     * Validate the requested entitlements. At this juncture only the add-on entitlements
     * are to be set via the API.
     *
     * @param entitlements List of string entitlement labels to be validated.
     * @param adding True if adding entitlements, false if removing.
     */
    public void validateAddOnEntitlements(List <String> entitlements, boolean adding) {

        if (adding && entitlements.contains(
                EntitlementManager.VIRTUALIZATION_ENTITLED) &&
                entitlements.contains(EntitlementManager.
                        VIRTUALIZATION_PLATFORM_ENTITLED)) {
            ValidatorResult ve = new ValidatorResult();
            ve.addError(new ValidatorError("system.entitle.alreadyvirt"));
            throw new ValidatorException(ve);
        }

        ValidatorResult ve = new ValidatorResult();
        for (String entitlementLabel : entitlements) {
            Entitlement ent = EntitlementManager.getByName(entitlementLabel);
            if (ent == null || ent.isBase()) {
                ve.addError(new ValidatorError(
                        "system.entitle.invalid_addon_entitlement", entitlementLabel));
            }
        }
        if (ve.getErrors().size() > 0) {
            throw new ValidatorException(ve);
        }
    }


    /**
     * Renames a given key to new key. This operation
     * is crucial when we are doing things like renaming
     * and activation key after edit by prepending its org_id to it.
     * @param newKey the key to rename to
     * @param key the key object to be renamed
     * @param user TODO
     */
    public void changeKey(String newKey, ActivationKey key, User user) {
        newKey = newKey.trim().replace(" ", "");
        String oldKey = key.getKey();
        if (!newKey.equals(key.getKey())) {
            ActivationKeyFactory.validateKeyName(newKey);
            WriteMode m = ModeFactory.getWriteMode("General_queries",
                                    "update_activation_key");
            Map params = new HashMap();
            params.put("old_key", key.getKey());
            params.put("new_key", newKey);
            m.executeUpdate(params);
        }
        changeCobblerProfileKey(key, oldKey, newKey, user);

    }


    /**
     * helper method to change an activation keys' key.
     *  This loops through all associated kickstart profiles and makes
     *  the change in cobbler
     */
    private static void changeCobblerProfileKey(ActivationKey key,
                                    String oldKey, String newKey, User user) {
        List<KickstartData> kss = ActivationKeyFactory.listAssociatedKickstarts(key);
        for (KickstartData ks : kss) {
            if (ks.getCobblerId() != null) {
                Profile prof = Profile.lookupById(CobblerXMLRPCHelper.getConnection(user),
                                                                    ks.getCobblerId());
                Set oldSet = new HashSet();
                if (!StringUtils.isEmpty(oldKey)) {
                    oldSet.add(oldKey);
                }
                Set newSet = new HashSet();
                if (!StringUtils.isEmpty(newKey)) {
                    newSet.add(newKey);
                }
                prof.syncRedHatManagementKeys(oldSet, newSet);
                prof.save();
            }
        }
    }


    /**
     * Subscribe an activation key to the first child channel
     *  of its base channel that contains
     * the packagename passed in.  Returns false if it can't be subscribed.
     *
     * @param key activationKey to be subbed
     * @param packageName to use to lookup the channel with.
     * @return true if subscription was successful false otherwise
     */
    private boolean subscribeToChildChannelWithPackageName(
                            ActivationKey key, String packageName) {

        log.debug("subscribeToChildChannelWithPackageName: " + key.getId() +
                " name: " + packageName);
        /*
         * null base channel implies Red Hat default
         * so we have to subscribe all the child channels
         * with the package name
         */
        List <Long> cids;
        if (key.getBaseChannel() == null) {
            cids = ChannelManager.findChildChannelsWithPackage(packageName, key.getOrg());
        }
        else {
            //we know its the channel we want if it has the rhncfg package in it.
            Long bcid = key.getBaseChannel().getId();
            log.debug("found basechannel: " + bcid);
            Long cid;
            try {
              cid = ChannelManager.findChildChannelWithPackage(key.getOrg(), bcid,
                    packageName);
            }
            catch (MultipleChannelsWithPackageException mcwpe) {
                log.debug("can not subscribe due to multiple channels have package " +
                        packageName);
                return false;
            }
            if (cid == null) { // Didnt find it ..
                log.debug("didnt find a child channel with the package.");
                return false;
            }
            cids = new LinkedList<Long>();
            cids.add(cid);

        }
        for (Long cid : cids) {
            Channel channel = ChannelFactory.lookupById(cid);
            key.addChannel(channel);
        }
        return !cids.isEmpty();
    }

    private void addConfigMgmtPackages(ActivationKey key) {
        String [] names = { PackageManager.RHNCFG,
                            PackageManager.RHNCFG_CLIENT,
                            PackageManager.RHNCFG_ACTIONS};
        for (String name : names) {
            key.addPackage(PackageManager.lookupPackageName(name), null);
        }
    }

    /**
     * setups auto deployment of config files
     * basically does things like adding config mgmt packages
     * and subscribing to config channels...
     * @param key the activation key to be updated.
     */
    public void setupAutoConfigDeployment(ActivationKey key) {
        if (subscribeToChildChannelWithPackageName(key,
                ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME)) {
            addConfigMgmtPackages(key);
        }
    }

    /**
     * Enables the activation key to be virtualization ready
     * Adds the virt channel, the tools channel
     * and adds the rn-virtualization-host package
     * @param key the activation key to be updated.
     */
    public void setupVirtEntitlement(ActivationKey key) {
        if (subscribeToChildChannelWithPackageName(key,
                ChannelManager.TOOLS_CHANNEL_PACKAGE_NAME)) {
            key.addPackage(PackageManager.lookupPackageName(ChannelManager.
                    RHN_VIRT_HOST_PACKAGE_NAME), null);
        }
        subscribeToChildChannelWithPackageName(key,
                ChannelManager.VIRT_CHANNEL_PACKAGE_NAME);
    }
}
