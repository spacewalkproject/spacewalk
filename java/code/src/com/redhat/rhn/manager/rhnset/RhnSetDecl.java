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
package com.redhat.rhn.manager.rhnset;

import com.redhat.rhn.common.util.Asserts;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.SetCleanup;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.SetLabels;
import com.redhat.rhn.frontend.action.monitoring.ProbeSuiteHelper;

import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.HashMap;
import java.util.Map;

/**
 * The declaration of an {@link RhnSet}. This combines the name of the set with
 * the security information needed to ensure that users only put items into the
 * set they actually have permission to see. All sets must be declared as
 * constants in this class; to load a set, you can simply say
 * <code>RhnSetDecl.SYSTEMS.get(user)</code>.
 * <p>
 * To create a new set, you need to first define the needed cleanup as a
 * constant in {@link SetCleanup} and then declare the set with a new constant
 * in this class.
 * 
 * @version $Rev$
 */
public class RhnSetDecl {

    private static final Map<String, RhnSetDecl> DECLS = new HashMap<String, RhnSetDecl>();

    // set of actions by action_id
    public static final RhnSetDecl ACTIONS_COMPLETED = make(
            "completed_action_list", SetCleanup.UNOWNED_ACTIONS);

    // set of actions by action_id
    public static final RhnSetDecl ACTIONS_FAILED = make("failed_action_list",
            SetCleanup.UNOWNED_ACTIONS);

    // set of actions by action_id
    public static final RhnSetDecl ACTIONS_PENDING = make(
            "pending_action_list", SetCleanup.UNOWNED_ACTIONS);

    // set of servers by server_id
    public static final RhnSetDecl ACTIONS_UNSCHEDULE = make(
            "unscheduleaction", SetCleanup.UNOWNED_SERVERS);

    // set of channels by channel_id
    public static final RhnSetDecl CHANNELS_FOR_ERRATA = make(
            "channels_for_errata", SetCleanup.UNOWNED_CHANNELS);

    // set of errata by errata_id
    public static final RhnSetDecl ERRATA = make("errata_list",
            SetCleanup.ILLEGAL_ERRATA);

    // set of errata by errata_id
    public static final RhnSetDecl ERRATA_CLONE = make("clone_errata_list",
            SetCleanup.UNOWNED_NONRHN_ERRATA);

    // set of errata by errata_id; needs new cleanup
    public static final RhnSetDecl ERRATA_TO_DELETE = make("errata_to_delete",
            SetCleanup.UNOWNED_ERRATA);

    // set of errata by errata_id; needs new cleanup
    public static final RhnSetDecl ERRATA_TO_DELETE_BULK = make("errata_to_delete_bulk",
            SetCleanup.UNOWNED_ERRATA);

    // set of errata by errata_id; needs new cleanup
    public static final RhnSetDecl ERRATA_TO_SYNC = make("errata_to_sync",
            SetCleanup.UNOWNED_ERRATA);

    public static final RhnSetDecl ERRATA_PACKAGES_TO_SYNC = make("errata_packages_to_sync",
            SetCleanup.UNOWNED_PACKAGES);

    // set of file list: needs new cleanup
    public static final RhnSetDecl FILE_LISTS = make("file_lists",
            SetCleanup.UNOWNED_FILE_LIST);

    // mmccune to provide cleanup
    public static final RhnSetDecl FILTER_EXPIRE = make("filter_expire_list",
            SetCleanup.UNOWNED_FILTERS);

    // set of packages by package_id
    public static final RhnSetDecl PACKAGES_FOR_SYSTEM_SYNC = make(
            "packages_for_system_sync", SetCleanup.NOOP);

    // set of packages by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PACKAGES_REMOVABLE = make(
            "removable_package_list", SetCleanup.NOOP);

    // set of packages by package_id
    public static final RhnSetDecl PACKAGES_TO_ADD = make("packages_to_add",
            SetCleanup.UNOWNED_PACKAGES);

    // set of packages by package_id
    public static final RhnSetDecl PACKAGES_TO_PUSH = make(
            "update_package_list", SetCleanup.UNOWNED_PACKAGES);

    // set of packages by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PACKAGES_TO_INSTALL = make(
            "install_package_list", SetCleanup.NOOP);

    // set of packages by name_id/evr_id; can not be cleaned
    // set of package_ids for deleting packages (from manage software packages)
    public static final RhnSetDecl PACKAGES_TO_REMOVE = make(
            "packages_to_remove", SetCleanup.NOOP);

    // set of packages by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PACKAGES_UPGRADABLE = make(
            SetLabels.PACKAGE_UPGRADE_SET, SetCleanup.NOOP);

    // set of packages by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PACKAGES_VERIFY = make(
            "verify_package_list", SetCleanup.NOOP);

    // set of patches by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PATCH_INSTALL = make(
            SetLabels.PATCH_INSTALL_SET, SetCleanup.NOOP);

    // set of patches by name_id/evr_id; can not be cleaned
    public static final RhnSetDecl PATCH_REMOVE = make(
            SetLabels.PATCH_REMOVE_SET, SetCleanup.NOOP);

    // set of servers by server_id
    public static final RhnSetDecl PROBE_SUITE_SYSTEMS = make(
            "probe_suite_systems_list", SetCleanup.UNOWNED_SERVERS);

    // set of servers by server_id
    public static final RhnSetDecl PROBE_SUITE_SYSTEMS_EDIT = make(
            "probe_suite_systems_edit_list", SetCleanup.UNOWNED_SERVERS);

    // set of probe suites to delete
    public static final RhnSetDecl PROBE_SUITES_TO_DELETE = make(
            ProbeSuiteHelper.DELETE_SUITES_LIST_NAME, SetCleanup.UNOWNED_SUITES);

    // set of probe suites to delete
    public static final RhnSetDecl SUITE_PROBES_TO_DELETE = make(
            ProbeSuiteHelper.DELETE_PROBES_LIST_NAME, SetCleanup.NOOP);

    // set of servers by server_id
    public static final RhnSetDecl SYSTEMS = make(SetLabels.SYSTEM_LIST,
            SetCleanup.ILLEGAL_SERVERS);

    // set of servers by server_id
    public static final RhnSetDecl SYSTEMS_AFFECTED = make(
            SetLabels.AFFECTED_SYSTEMS_LIST, SetCleanup.UNOWNED_SERVERS);

    // set of servers by server_id
    public static final RhnSetDecl SYSTEM_ENTITLEMENTS = make(
            SetLabels.SYSTEM_ENTITLEMENTS, SetCleanup.UNOWNED_SERVERS);

    // set of servers by server_id
    public static final RhnSetDecl SYSTEMS_FAILED = make("failed_system_list",
            SetCleanup.UNOWNED_SERVERS);

    // set of system groups by group id
    public static final RhnSetDecl SYSTEM_GROUPS = make("system_group_list",
            SetCleanup.UNOWNED_SYSTEM_GROUPS);

    public static final RhnSetDecl TEST = make("test action", SetCleanup.NOOP);

    // set of users by user_id
    public static final RhnSetDecl USERS = make("user_list",
            SetCleanup.UNOWNED_USERS);

    // Set of contact methods in an org
    public static final RhnSetDecl METHODS_IN_ORG = make("methods_in_org",
            SetCleanup.UNOWNED_METHODS);

    // set of kickstart profiles
    public static final RhnSetDecl KICSKTART_IPRANGES = make(
            "kickstart_ipranges", SetCleanup.NOOP);

    public static final RhnSetDecl ACTIVATION_KEYS = make("activation_keys",
            SetCleanup.UNOWNED_ACTIVATION_KEYS);

    public static final RhnSetDecl KICKSTART_ACTIVATION_KEYS =
        make("kickstart_activation_keys", SetCleanup.UNOWNED_ACTIVATION_KEYS);    
    
    public static final RhnSetDecl GPGSSL_KEYS = 
        make("gpgssl_keys", SetCleanup.UNOWNED_GPGSSL_KEYS);

    public static final RhnSetDecl PACKAGE_PROFILES = make("package_profiles",
            SetCleanup.UNOWNED_PACKAGE_PROFILES);

    // Set of systems subscribed to a specified config-channel
    public static final RhnSetDecl CONFIG_SYSTEMS = make(
            "config_subscribed_systems", SetCleanup.UNOWNED_SERVERS);

    // Set of systems subscribable, but not yet subscribed, to a specified
    // config-channel
    public static final RhnSetDecl CONFIG_TARGET_SYSTEMS = make(
            "config_target_systems", SetCleanup.UNOWNED_SERVERS);

    public static final RhnSetDecl CONFIG_ENABLE_SYSTEMS = make(
            "enable_config_systems", SetCleanup.UNOWNED_SERVERS);

    public static final RhnSetDecl CONFIG_CHANNELS = make("config_channels",
            SetCleanup.INACCESSIBLE_CONFIG_CHANNELS);

    public static final RhnSetDecl CONFIG_CHANNELS_RANKING = make(
            "config_channels_rankings", SetCleanup.INACCESSIBLE_CONFIG_CHANNELS);

    public static final RhnSetDecl CONFIG_CHANNELS_TO_UNSUBSCRIBE = make(
            "config_channels_to_unsubscribe",
            SetCleanup.INACCESSIBLE_CONFIG_CHANNELS);

    // Set of files contained within a specified config-channel
    public static final RhnSetDecl CONFIG_FILES = make("config_files",
            SetCleanup.INACCESSIBLE_CONFIG_FILES);

    public static final RhnSetDecl CONFIG_FILE_NAMES = make(
            "config_file_names", SetCleanup.NOOP); // always a no-op

    public static final RhnSetDecl ORG_LIST = make("org_list", SetCleanup.NOOP);

    // set of config file names to be uploaded from the server.
    // must have a no-op set cleanup because the file names might be new
    public static final RhnSetDecl CONFIG_IMPORT_FILE_NAMES = make(
            "config_import_names", SetCleanup.NOOP);

    public static final RhnSetDecl CONFIG_REVISIONS = make("config_revisions",
            SetCleanup.INACCESSIBLE_CONFIG_REVISIONS);

    // Set of systems a given config-file could be deployed to
    public static final RhnSetDecl CONFIG_FILE_DEPLOY_SYSTEMS = make(
            "config_deploy_systems", SetCleanup.NOOP);

    // Set of config-revisions to be deployed from a specified config-channel
    public static final RhnSetDecl CONFIG_CHANNEL_DEPLOY_REVISIONS =
        make("config_channel_deploy_revisions", SetCleanup.NOOP);
    
    // Set of systems subscribed to a channel to deploy CONFIG_CHANNEL_DEPLOY_REVISIONS to
    public static final RhnSetDecl CONFIG_CHANNEL_DEPLOY_SYSTEMS =
        make("config_channel_deploy_systems", SetCleanup.NOOP);
    
    // Set of channels we're subscribing to/unsubscribing from in the SSM
    public static final RhnSetDecl SSM_CHANNEL_LIST =
        make("channel_list", SetCleanup.UNOWNED_CHANNELS);

    // Set of packages being removed from packages in the SSM (this is used by the
    // query but the UI uses SessionSet)
    public static final RhnSetDecl SSM_REMOVE_PACKAGES_LIST =
        make("ssm_remove_packages_list", SetCleanup.NOOP);
    
    // Set of packages being upgraded from packages in the SSM (this is used by the
    // query but the UI uses SessionSet)
    public static final RhnSetDecl SSM_UPGRADE_PACKAGES_LIST =
        make("ssm_upgrade_packages_list", SetCleanup.NOOP);
    
    // Set of packages being verified from packages in the SSM (this is used by the
    // query but the UI uses SessionSet)
    public static final RhnSetDecl SSM_VERIFY_PACKAGES_LIST =
        make("ssm_verify_packages_list", SetCleanup.NOOP);
    
    // This cleanser is for when the set contains rhnVirtualInstance.id
    // instead of rhnServer.id
    public static final RhnSetDecl VIRTUAL_SYSTEMS = make("virtual_systems",
            SetCleanup.UNOWNED_VIRTUAL_SERVERS);

    public static final RhnSetDecl REMOVE_SYSTEMS_LIST = make(
            "remove_systems_list", SetCleanup.NOOP);
    
    public static final RhnSetDecl REPOSITORY_CHANNEL_MAPS = make(
            "repository_channel_maps", SetCleanup.NOOP);

    public static final RhnSetDecl CHANNEL_SUBSCRIPTION_PERMS = make(
            "channel_subscription_perms", SetCleanup.NOOP);

    public static final RhnSetDecl TARGET_SYSTEMS_FOR_CHANNEL = make(
            "target_systems_for_channel", SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGE_DOWNLOADABLE_LIST = make(
            "package_downloadable_list", SetCleanup.NOOP);

    public static final RhnSetDecl PATCHES_TO_ADD = make("patches_to_add",
            SetCleanup.NOOP);

    public static final RhnSetDecl PATCHES_TO_REMOVE = make(
            "patches_to_remove", SetCleanup.NOOP);

    public static final RhnSetDecl ERRATA_TO_REMOVE = make("errata_to_remove",
            SetCleanup.NOOP);

    public static final RhnSetDecl ERRATA_TO_ADD = make("errata_to_add",
            SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGE_TO_ADD = make("packages_to_add",
            SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGES_FOR_MERGE = make(
            "packages_for_merge", SetCleanup.NOOP);

    public static final RhnSetDecl PATCHSETS_TO_ADD = make("patchsets_to_add",
            SetCleanup.NOOP);

    public static final RhnSetDecl PATCHSETS_TO_REMOVE = make(
            "patchsets_to_remove", SetCleanup.NOOP);

    public static final RhnSetDecl CHANNEL_MANAGEMENT_PERMS = make(
            "channel_management_perms", SetCleanup.NOOP);

    public static final RhnSetDecl TARGET_SYSTEMS = make("target_systems",
            SetCleanup.NOOP);

    public static final RhnSetDecl DELETABLE_PACKAGE_LIST = make(
            "deletable_package_list", SetCleanup.NOOP);

    public static final RhnSetDecl SCOUT_LIST = make("scout_list",
            SetCleanup.NOOP);

    public static final RhnSetDecl REMOVEABLE_SYSTEM_LIST = make(
            "removable_system_list", SetCleanup.NOOP);

    public static final RhnSetDecl PATCH_INSTALLABLE_LIST = make(
            "patch_installable_list", SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGE_INSTALLABLE_LIST = make(
            "package_installable_list", SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGE_ANSWER_FILE_LIST = make(
            "package_answer_file_list", SetCleanup.NOOP);

    public static final RhnSetDecl PACKAGE_UPGRADABLE_LIST = make(
            "package_upgradable_list", SetCleanup.NOOP);

    public static final RhnSetDecl PATCHSET_INSTALLABLE_LIST = make(
            "patchset_installable_list", SetCleanup.NOOP);

    public static final RhnSetDecl REMOVE_SYSTEM_FROM_GROUPS = make(
            "remove_system_from_groups", SetCleanup.NOOP);

    public static final RhnSetDecl TARGET_GROUPS_FOR_SYSTEM = make(
            "target_groups_for_system", SetCleanup.NOOP);

    public static final RhnSetDecl SCHEDULE_ACTION_LIST = make(
            "schedule_action_list", SetCleanup.NOOP);

    public static final RhnSetDecl REMOVABLE_SNAPSHOT_TAG_LIST = make(
            "removable_snapshot_tag_list", SetCleanup.NOOP);

    public static final RhnSetDecl SYSTEMS_AFFECTED_BY_ERRATA = make(
            "systems_affected_by_errata", SetCleanup.NOOP);

    public static final RhnSetDecl SSCD_REMOVABLE_PATCH_LIST = make(
            "sscd_removable_patch_list", SetCleanup.NOOP);

    public static final RhnSetDecl SSCD_VERIFY_PACKAGE_LIST = make(
            "sscd_verify_package_list", SetCleanup.NOOP);

    public static final RhnSetDecl SSCD_REMOVABLE_PACKAGE_LIST = make(
            "sscd_removable_package_list", SetCleanup.NOOP);

    public static final RhnSetDecl MULTIORG_TRUST_LIST = make(
            "multiorg_trust_list", SetCleanup.NOOP);       

    public static final RhnSetDecl SSM_CHANNEL_SUBSCRIBE = make(
            "ssm_channel_subscribe", SetCleanup.NOOP);
    
    public static final RhnSetDecl SSM_CHANNEL_UNSUBSCRIBE = make(
            "ssm_channel_unsubscribe", SetCleanup.NOOP);
    
    private SetCleanup cleanup;
    private String label;

    private RhnSetDecl(String label0, SetCleanup cleanup0) {
        label = label0;
        cleanup = cleanup0;
    }

    /**
     * Clear the set for user <code>u</code>
     * @param u the user whose set to clear
     */
    public void clear(User u) {
        RhnSetManager.deleteByLabel(u.getId(), label);
    }

    /**
     * Create a new, empty set
     * @param u the user for whom to create the set
     * @return the created set
     */
    public RhnSet create(User u) {
        Asserts.assertNotNull(u, "u");
        return RhnSetManager.createSet(u.getId(), label, cleanup);
    }

    /**
     * Load the set for user <code>u</code>. If the set for this user does
     * not exist yet, a new one is created. In other words, this method will
     * always return a non-null value.
     * @param u the user for whom to get the set
     * @return the set for user <code>u</code>
     */
    public RhnSet get(User u) {
        Asserts.assertNotNull(u, "u");
        RhnSet s = lookup(u);
        if (s == null) {
            s = create(u);
        }
        return s;
    }

    /**
     * The label of the set
     * @return the label of the set
     */
    public String getLabel() {
        return label;
    }

    /**
     * Look the set for user <code>u</code> up from the database. If the user
     * has no entries in the set, return <code>null</code>
     * @param u the user for whom to look the set up
     * @return the set or <code>null</code> if the user has nothing in the set
     */
    public RhnSet lookup(User u) {
        return RhnSetManager.findByLabel(u.getId(), label, cleanup);
    }
    
    /**
     * Creates new Declaration based on the selections for this set.
     * @param suffix suffix to make this set declaration unique
     * @return the newly created set declaration.
     */
    public RhnSetDecl createCustom(Object... suffix) {
        String customName = generateCustomSetName(this, suffix);
        return make(customName, cleanup);
    }

    /**
     * Make a new set declaration with the given <code>label</code> and
     * <code>cleanup</code>
     * @param label the label of the set
     * @param cleanup the cleanup
     * @return a new set declaration
     */
    private static RhnSetDecl make(String label, SetCleanup cleanup) {
        RhnSetDecl result = new RhnSetDecl(label, cleanup);
        DECLS.put(label, result);
        return result;
    }

    /**
     * DO NOT USE THIS METHOD. IT IS ONLY PROVIDED TO SUPPORT LEGACY USES. Looks
     * up an existing set declaration for the given <code>label</code>. If
     * one exists, <code>cleanup</code> is ignored. Otherwise, a declaration
     * with the given <code>cleanup</code> and <code>label</code> is
     * created.
     * @deprecated
     * @param label the label for the set
     * @param cleanup the cleanup to use
     * @return the set declaration
     */
    public static RhnSetDecl findOrCreate(String label, SetCleanup cleanup) {
        RhnSetDecl result = DECLS.get(label);
        if (result == null) {
            result = new RhnSetDecl(label, cleanup);
        }
        return result;
    }

    /**
     * Retrieves the set declaration associated to the given label
     * @param label the label for the set
     * @return the set declaration or null if none exists
     */
    public static RhnSetDecl find(String label) {
        return DECLS.get(label);
    }
    
    /**
     * get the set for Channel Errata cloning
     * @param chan the Channel passed in
     * @return the Set decl
     */
    public static RhnSetDecl setForChannelErrata(Channel chan) {
        return make("errata_clone_list" + chan.getId(), SetCleanup.ILLEGAL_ERRATA);
    }
    
    /**
     * get the set for Channel package pushing
     * @param chan the Channel passed in
     * @return the Set decl
     */
    public static RhnSetDecl setForChannelPackages(Channel chan) {
        return make("package_clone_list" + chan.getId(), SetCleanup.NOOP);
    }

    /**
     * Generates a new set name based on an existing set and one or more variables.
     *
     * @param base   the generation will use the label from this set
     * @param suffix used as entropy in the custom name
     * @return name suitable for an RhnSet that is a derivative of the base set
     */
    public static String generateCustomSetName(RhnSetDecl base, Object... suffix) {
        HashCodeBuilder builder = new HashCodeBuilder();
        for (Object o : suffix) {
            builder.append(o);
        }

        String customName = base.getLabel() + builder.toHashCode();
        return customName;
    }
}
