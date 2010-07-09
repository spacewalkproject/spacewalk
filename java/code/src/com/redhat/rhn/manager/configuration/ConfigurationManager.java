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
package com.redhat.rhn.manager.configuration;

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.DataList;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigFileCount;
import com.redhat.rhn.domain.config.ConfigFileName;
import com.redhat.rhn.domain.config.ConfigFileType;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.dto.ConfigGlobalDeployDto;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.listview.PageControl;
import com.redhat.rhn.manager.BaseManager;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.system.SystemManager;

import org.apache.log4j.Logger;

import java.io.InputStream;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ConfigurationManager
 * @version $Rev$
 */
public class ConfigurationManager extends BaseManager {

    /**
     * Logger for this class
     */
    private static Logger log = Logger
            .getLogger(ConfigurationManager.class);

    private static final ConfigurationManager INSTANCE = new ConfigurationManager();

    // Used as keys into the Map returned by a file-content-validation error
    // see validateContent()
    public static final String KEY = "key";
    public static final String ARG0 = "arg0";
    public static final String ARG1 = "arg1";

    //These are used when enabling a system for configuration management
    //through our helpful user interface
    public static final int ENABLE_SUCCESS = 0;
    public static final int ENABLE_ERROR_PROVISIONING = 1;
    public static final int ENABLE_ERROR_RHNTOOLS = 2;
    public static final int ENABLE_ERROR_PACKAGES = 3;
    public static final int ENABLE_NEED_ORG_ADMIN = 4;

    public static final int FILES = 0;
    public static final int DIRECTORIES = 1;

    public static final String FEATURE_CONFIG = "ftr_config";
    /**
     * Prevent people for making objects of this class.
     */
    private ConfigurationManager() {

    }

    /**
     * @return the static object of this class.
     */
    public static ConfigurationManager getInstance() {
        return INSTANCE;
    }

    /**
     * List all of the global channels a given user can see.
     * @param user The user looking at channels.
     * @param pc A page control for this user.
     * @return A list of the channels in DTO format.
     */
    public DataResult<ConfigChannelDto> listGlobalChannels(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "overview_config_channels");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }


    /**
     * List all of the global channels a given user can see
     *  in the activaiton keys page.
     * @param key Activation Key whose channesl are to be ignored
     * @param user The user looking at channels.
     * @return A list of the channels in DTO format.
     */
    public DataResult<ConfigChannelDto>
                        listGlobalChannelsForActivationKeySubscriptions
                                                (ActivationKey key, User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                        "overview_config_channels_for_act_key_subscriptions");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("tid", key.getToken().getId());
        Map elabParams = new HashMap();
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * List the global channels in a activation key.
     * used in the ActivationKey config channel subscription page.
     * @param key Activation Key to look up on.
     * @param user The user looking at channels.
     * @return A list of the channels in DTO format.
     */
    public DataResult<ConfigChannelDto>
                        listGlobalChannelsForActivationKey(ActivationKey key,
                                                            User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "overview_config_channels_for_act_key");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("tid", key.getToken().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * This query basically lists  all the global channels
     * a user can see along with info on whether the
     * channels are subscribed to a given server
     * Basically used in SDC Subscribe Channels page
     * @param server the server to check the channels
     *                                      subscriptions on
     * @param user The user looking at channels.
     * @param pc A page control for this user.
     * @return A list of the channels in DTO format.
     */
    public DataResult<ConfigChannelDto>
                                listGlobalChannelsForSystemSubscriptions(Server server,
                                    User user,
                                    PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "config_channels_for_system_subscriptions");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("sid", server.getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Lists all of the configuration files in RHN for a single org.
     * @param user The user requesting to view configuration files.
     * @param pc A page control for this user.
     * @return A list of configuration files in DTO format.
     */
    public DataResult listAllFilesWithTotalSize(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "org_configfile_size_totals");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Lists all configuration managed systems along with counts for how many
     * files and channels they are managed by.
     * @param user The user requesting to view managed systems
     * @param pc A page control for this user.
     * @return A list of configged systems in DTO format.
     */
    public DataResult listManagedSystemsAndFiles(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "config_managed_systems");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Returns the given system is config enabled.
     * @param server The system we care abt finding config capability info on
     * @param user The user requesting to view target systems
     * @return true of the system is config capable.
     */
    public boolean isConfigEnabled(Server server, User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                        "system_config_enabled_check");
         Map params = new HashMap();
         params.put("user_id", user.getId());
         params.put("sid", server.getId());
         DataResult<Map<String, ? extends Number>> dr = m.execute(params);
         return dr.get(0).get("count").intValue() > 0;
    }


    /**
     * Lists all systems visible to a user that are not configuration managed.
     * Also includes whether the system is currently capable for configuration management.
     * @param user The user requesting to view target systems
     * @param pc A page control for this user.
     * @return A list of non config managed systems in DTO format.
     */
    public DataResult listNonManagedSystems(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries", "non_config_managed_systems");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Lists all systems visible to a user that are not configuration managed that are in
     * the given set.
     * Also includes whether the system is currently capable for configuration management
     * and what actions are needed in order to make it so.
     * @param user The user requesting to view target systems
     * @param pc A page control for this user.
     * @param set The label for the desired RhnSet
     * @return A list of non config managed systems in DTO format.
     */
    public DataResult listNonManagedSystemsInSet(User user, PageControl pc, String set) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "non_config_managed_systems_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set", set);
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Lists all systems visible to a user that are not configuration managed that are in
     * the given set.  Elaborates all of them so that the required actions for enabling
     * config management are given in the list.
     * @param user The user about to enable things
     * @param set The name of the set.
     * @return An elaborated list of non-configuration managed systems in the given set.
     */
    public DataResult listNonManagedSystemsInSetElaborate(User user, String set) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "non_config_managed_systems_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set", set);
        DataResult dr = m.execute(params);
        dr.setTotalSize(dr.size());
        dr.elaborate(new HashMap());
        return dr;
    }

    /**
     * Lists all the revisions of the given file other than the given revision.
     * @param user The user requesting a list of revisions.
     * @param file The file that the revisions should be for.
     * @param current The current revision that should not be included in the list.
     * @param pc A PageControl for this user
     * @return A list of revisions.
     */
    public DataResult listRevisionsForCompare(User user, ConfigFile file,
            ConfigRevision current, PageControl pc) {
        if (!current.getConfigFile().getId().equals(file.getId())) {
            throw new IllegalArgumentException("Current revision is not for given file");
        }
        if (!user.getOrg().equals(file.getConfigChannel().getOrg())) {
            throw new IllegalArgumentException("User and file are in different orgs.");
        }
        SelectMode m = ModeFactory.getMode("config_queries",
            "compare_revision_list");
        Map params = new HashMap();
        params.put("cfid", file.getId());
        params.put("crid", current.getId());
        params.put("user_id", user.getId());
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }

    /**
     * Lists all the alternatives for a given file in other config channels.
     * @param user The user requesting a list of alternate files.
     * @param current The current file that should not be included in the list.
     * @param pc A PageControl for this user
     * @return A list of alternate files.
     */
    public DataResult listAlternateFilesForCompare(User user, ConfigFile current,
            PageControl pc) {
        if (!user.getOrg().equals(current.getConfigChannel().getOrg())) {
            throw new IllegalArgumentException("User and file are in different orgs.");
        }
        SelectMode m = ModeFactory.getMode("config_queries",
            "compare_alternate_file_list");
        Map params = new HashMap();
        params.put("cfid", current.getId());
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }

    /**
     * Lists all the other channels in this org.
     * @param user The user requesting a list of channels.
     * @param pc A PageControl for this user
     * @return A list of channels.
     */
    public DataResult listChannelsForFileCompare(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
            "compare_other_channel_list");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }

    /**
     * Gets a list of files (not directories) in the given config channel.
     * @param user The user requesting a list of files.
     * @param channel The config channel
     * @param pc A page control for the user.
     * @return a list of config files in DTO format
     */
    public DataResult listFilesInChannel(User user, ConfigChannel channel, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
            "compare_other_file_list");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("ccid", channel.getId());
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }


    /**
     * Get a list of systems for a config file diff action.
     * @param user The user requesting a list of systems.
     * @param cfnid The config file name identifier for the file to diff.
     * @param pc A PageControl for this user.
     * @return A list of systems in DTO format
     */
    public DataResult listSystemsForFileCompare(User user, Long cfnid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries", "systems_for_diff");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("cfnid", cfnid);
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Get a list of systems to whose local or sandbox channel one could copy a cfg-file
     * @param user The user requesting a list of systems.
     * @param cfnid The config file name identifier for the file to diff.
     * @param chnlType ConfigChannelType to look for (LOCAL or SANDBOX)
     * @param pc A PageControl for this user.
     * @return A list of systems in DTO format
     */
    public DataResult listSystemsForFileCopy(
            User user, Long cfnid, ConfigChannelType chnlType, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries", "systems_for_copy");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("cfnid", cfnid);
        elabParams.put("label", chnlType.getLabel());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }
    /**
     * Lists the file names of all files subscribed to by systems in the
     * given user's system_list set.
     * @param user The user requesting the list of file names.
     * @param pc A PageControl for this user.
     * @return A list of config file names in DTO format.
     */
    public DataResult listFileNamesForSsm(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries", "configfiles_for_ssm");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the systems in the given user's system_list set that are subscribed to a
     * config channel that contains a config file with the given config file name id.
     * @param user The user requesting a list of systems.
     * @param cfnid The identifier of the config file name
     * @param pc A PageControl for this user.
     * @return A list of systems in DTO format.
     */
    public DataResult listSystemsForFileName(User user, Long cfnid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "systems_in_set_with_file_name");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("cfnid", cfnid);
        params.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("cfnid", cfnid);
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the systems in the given user's system_list set that are subscribed to a
     * config channel with the given config channel id.
     * @param user The user requesting a list of systems.
     * @param ccid The identifier of the config channel
     * @param pc A PageControl for this user.
     * @return A list of systems in DTO format.
     */
    public DataResult listSystemsForConfigChannel(User user, Long ccid, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "systems_for_channel_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("ccid", ccid);
        params.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("ccid", ccid);
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the file names in the user's config file name set relevant to the
     * given server. Finds the deployable revisions for each file name.
     * @param user The user requesting a list of file names
     * @param server The server to which these files must be relevant
     * @param pc A PageControl for this user
     * @return A list of config file names in DTO format.
     */
    public DataResult listFileNamesInSetForSystem(User user, Server server,
            PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "file_names_in_set_for_system");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", server.getId());
        params.put("name_set_label", RhnSetDecl.CONFIG_FILE_NAMES.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("sid", server.getId());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the file names in the user's config file name set whether or not they
     * are relevant to the given server. Finds the deployable revisions for each
     * file name for the given server.
     * @param user The user requesting a list of file names
     * @param server The server to which these files may be relevant
     * @param setLabel The DB label of the config file name set.
     * @param pc A PageControl for this user
     * @return A list of config file names in DTO format.
     */
    public DataResult listFileNamesInSet(User user, Server server, String setLabel,
            PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "file_names_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("name_set_label", setLabel);
        Map elabParams = new HashMap();
        elabParams.put("sid", server.getId());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the file names to which the given server is subscribed
     * Finds the deployable revisions for each file name.
     * @param server The server to which these files must be relevant
     * @return A list of config file names in DTO format.
     */
    public DataResult <ConfigFileNameDto> listAllFileNamesForSystem(Server server) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "automated_file_names_for_system");
        Map params = new HashMap();
        Map elabParams = new HashMap();
        params.put("sid", server.getId());
        elabParams.put("sid", server.getId());
        DataResult dr = makeDataResult(params, elabParams, null, m);
        dr.elaborate();
        return dr;
    }

    /**
     * Lists the file names to which the given server is subscribed
     * Finds the deployable revisions for each file name.
     * @param user The user requesting a list of file names
     * @param server The server to which these files must be relevant
     * @param pc A PageControl for this user
     * @return A list of config file names in DTO format.
     */
    public DataResult <ConfigFileNameDto> listFileNamesForSystem(User user,
                                                    Server server, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "file_names_for_system");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", server.getId());
        Map elabParams = new HashMap();
        elabParams.put("sid", server.getId());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the config channels in the user's config channel set to which the
     * given server is subscribed. Finds the deployable files for each channel.
     * @param user The user requesting a list of config channels
     * @param server The server subscribed to these channels
     * @param pc A PageControl for this user
     * @return A list of config channels in DTO format.
     */
    public DataResult listConfigChannelsForSystem(User user,
            Server server, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "channels_in_set_for_system");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("sid", server.getId());
        params.put("channel_set_label", RhnSetDecl.CONFIG_CHANNELS.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("sid", server.getId());
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Lists the systems in the user's system_list set that are subscribed to
     * files whose names are in the user's config file name set.
     * @param user The user requesting the list of file names.
     * @param pc A PageControl for this user.
     * @param feature acl off the list by selecting a config mgmt specific feature
     *          like (configfiles.deploy/configfiles.diff)
     * @return A list of systems in DTO format.
     */
    public DataResult<ConfigSystemDto> listSystemsForConfigAction(User user,
            PageControl pc, String feature) {
        SelectMode m = ModeFactory.getMode("config_queries", "config_systems_for_ssm");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        params.put("name_set_label", RhnSetDecl.CONFIG_FILE_NAMES.getLabel());
        params.put("feature", feature);

        Map elabParams = new HashMap();
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * List all of the global channels to which systems in the current user's
     * system_list are subscribed.
     * @param user The user looking at channels.
     * @param pc A page control for this user.
     * @return A list of the channels in DTO format.
     */
    public DataResult ssmChannelList(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "ssm_config_channels");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Lists all the global configuration channels to which the given user can subscribe
     * systems. Only channels that it makes sense to subscribe to will be listed. In other
     * words, if all of the servers in the SSM are already subscribed to a channel, it
     * will not be returned. To get this list of already subscribed channels, use
     * {@link #ssmChannelListForSubscribeAlreadySubbed(User)}
     *
     * @param user The user looking at channels.
     * @param pc A page control for this user.
     * @return a list of {@link ConfigChannelDto} objects
     */
    public DataResult ssmChannelListForSubscribe(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "ssm_channels_for_subscribe_choose");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        elabParams.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns configuration channels that <em>every</em> system in the SSM is subscribed
     * to. This is effectively the complement of
     * {@link #ssmChannelListForSubscribe(User, PageControl)}.
     *
     * @param user the user working with the channels
     * @return a list of {@link ConfigChannelDto} objects
     */
    public DataResult ssmChannelListForSubscribeAlreadySubbed(User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "ssm_channels_for_subscribe_already_sub");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        elabParams.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        return makeDataResult(params, elabParams, null, m);
    }

    /**
     * List all the global channels to which the given user can subscribe
     * systems.
     * @param user The user looking at channels.
     * @return A list of the channels in DTO format.
     */
    public List ssmChannelsInSetForSubscribe(User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "ssm_channels_for_subscribe_in_set");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("channel_set_label", RhnSetDecl.CONFIG_CHANNELS_RANKING.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        elabParams.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        return DataList.getDataList(m, params, elabParams);
    }

    /**
     * List the systems in your system set along with the number
     * of channels selected to which they are already subscribed.
     * @param user The user looking at channels.
     * @return A list of the systems in DTO format.
     */
    public List ssmSystemsForSubscribe(User user) {
        SelectMode m = ModeFactory.getMode("config_queries",
                "ssm_systems_for_subscribe");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        elabParams.put("channel_set_label",
                RhnSetDecl.CONFIG_CHANNELS_RANKING.getLabel());
        return DataList.getDataList(m, params, elabParams);
    }

    /**
     * List all systems in the given user's system_list subscribed to at
     * least one channel in the user's config channel set
     * @param user The user requested a list of systems
     * @param pc A PageControl for this user
     * @return A list of systems in DTO format
     */
    public DataResult ssmSystemListForChannels(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "ssm_systems_for_config_channels");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("system_set_label", RhnSetDecl.SYSTEMS.getLabel());
        params.put("channel_set_label", RhnSetDecl.CONFIG_CHANNELS.getLabel());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        elabParams.put("channel_set_label", RhnSetDecl.CONFIG_CHANNELS.getLabel());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Get a summary of configuration enablement.
     * @param user The user asking for a summary
     * @param pc A PageControl object for this user.
     * @param set The label for the RhnSet where the summary is located.
     * @return The summary for each system in Dto format.
     */
    public DataResult getEnableSummary(User user, PageControl pc, String set) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new IllegalArgumentException("User is not a config admin.");
        }
        SelectMode m = ModeFactory.getMode("config_queries",
                "enable_config_summary");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("set", set);
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }

    /**
     * Lists all global config files in this user's org that this user can view
     * along with system count and overridden count.
     * @param user The user requesting to view config files
     * @param pc A page control for this user.
     * @return A list of global config files that this user can view in DTO format.
     */
    public DataResult listGlobalConfigFiles(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "global_configfiles_for_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Lists all local config files in this user's org that this user can view.
     * @param user The user requesting to view config files
     * @param pc A page control for this user.
     * @return A list of local config files that this user can view in DTO format.
     */
    public DataResult listLocalConfigFiles(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                           "local_configfiles_for_user");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * Lists all global config channels in this user's org except the one that
     * contains the given config file.
     * Includes information about files with the same path as the given file in
     * the channels listed.
     * @param user The user requesting to view config files
     * @param current The file to be copied for which we should look for
     *                alternatives in the listed channels.
     *                The list will exclude the channel that this file is in.
     * @param type The database type for the channel.
     *             A label from ConfigurationFactory.CONFIG_CHANNEL_TYPE_*
     * @param pc A page control for this user.
     * @return A list of global config channels in this org in DTO format.
     */
    public DataResult listChannelsForFileCopy(User user, ConfigFile current,
            String type, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries",
                                                "channels_for_file_copy");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("ccid", current.getConfigChannel().getId());
        params.put("type", type);
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("name", current.getConfigFileName().getPath());
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * List cfg-channels OTHER THAN the specified one, that are of the specified type,
     * and are accessible to the specified user
     * @param user user making the request
     * @param cc config-channel of interest
     * @param ccType channel-type of interest
     * @return DataResult of ConfigChannelDto's
     */
    public List listChannelsForCopy(User user, ConfigChannel cc, String ccType) {
        SelectMode m = ModeFactory.getMode("config_queries", "other_channels");
        Map params = new HashMap();
        params.put("org_id", user.getOrg().getId());
        params.put("ccid", cc.getId());
        params.put("type", ccType);
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("user_id", user.getId());
        return DataList.getDataList(m, params, elabParams);
    }

    /**
     * List systems accessible to the specified user
     * @param user user making the request
     * @param pc page-control
     * @return DataResult of ConfigSystemDto's
     */
    public DataResult listSystemsForCopy(User user, PageControl pc) {
        SelectMode m = ModeFactory.getMode("config_queries", "list_available_systems");
        Map params = new HashMap();
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        DataResult dr = makeDataResult(params, elabParams, pc, m);
        return dr;
    }

    /**
     * Return the number of systems subscribed to the specified channel.
     * @param user user making the request
     * @param channel channel of interest
     * @return number of systems subscribed to channel
     */
    public int getSystemCount(User user, ConfigChannel channel)  {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        SelectMode m = ModeFactory.getMode("config_queries",
                "systems_subscribed_to_channel");
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("user_id", user.getId());
        DataResult dr = m.execute(params);
        Map row = (Map)dr.get(0);
        Long count = (Long)row.get("num_systems");
        return count.intValue();
    }

    // Utility for executing the files_in_channel query given
    // that you've specified the kind-of files you're interested in
    private int doCountFiles(Map params) {
        SelectMode m = ModeFactory.getMode("config_queries", "files_in_channel");
        DataResult dr = m.execute(params);
        Map row = (Map)dr.get(0);
        Long count = (Long)row.get("num_files");
        return count.intValue();
    }

    /**
     * Return the number of bytes used for all revisions of the specified ConfigFile
     * @param user User making the request
     * @param file File of interest
     * @return total bytes of all ConfigRevisions (0 for directories)
     */
    public int getFileStorage(User user, ConfigFile file) {
        Map params = new HashMap();
        params.put("cfid", file.getId());
        params.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode("config_queries", "configfile_revisions_size");
        DataResult dr = m.execute(params);
        Map row = (Map)dr.get(0);
        Long count = (Long)row.get("total_file_size");
        return count.intValue();
    }

    /**
     * Return the number of Symlinks in this config-channel
     * @param user user making the request
     * @param channel channel of interest
     * @return number of symlinks in this channel
     */
    public int getSymlinkCount(User user, ConfigChannel channel) {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("filetype", "symlink");
        params.put("user_id", user.getId());
        return doCountFiles(params);
    }

    /**
     * Return the number of Directories in this config-channel
     * @param user user making the request
     * @param channel channel of interest
     * @return number of directories in this channel
     */
    public int getDirCount(User user, ConfigChannel channel)  {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("filetype", "directory");
        params.put("user_id", user.getId());
        return doCountFiles(params);
    }

    /**
     * Return the number of Files in this config-channel
     * @param user user making the request
     * @param channel channel of interest
     * @return number of files in this channel
     */
    public int getFileCount(User user, ConfigChannel channel)  {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("filetype", "file");
        params.put("user_id", user.getId());
        return doCountFiles(params);
    }

    /**
     * List systems subscribed to this channel, sorted by date-modified (descending)
     * @param user user making the request
     * @param channel channel of interest
     * @return List of Maps with keys ('id','name','modified')
     */
    public DataResult getSystemInfo(User user, ConfigChannel channel) {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode("config_queries", "systems_subscribed_by_date");
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * List files controlled by this channel, sorted by date-modified (descending)
     * @param user user making the request
     * @param channel channel of interest
     * @return List of Maps with keys ('id','path','modified')
     */
    public DataResult getFileInfo(User user, ConfigChannel channel) {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode("config_queries", "files_by_date");
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Lists the last n most recently modified configuration files visible
     * by a user where n is the results param and user is the user param.
     * @param user The user listing files
     * @param results The number of files to list
     * @return List of recently modified files in DTO format.
     */
    public DataResult getRecentlyModifiedConfigFiles(User user, Integer results) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("num", results);
        SelectMode m = ModeFactory
                .getMode("config_queries", "recent_modified_config_files_for_user");
        DataResult dr = m.execute(params);
        return dr;
    }

    /**
     * Lists the last n most recent config deploy actions visible
     * by a user where n is the results param and user is the user param.
     * @param user The user listing deploy actions
     * @param results The number of actions to list
     * @return List of recently config deploy actions in DTO format.
     */
    public DataResult getRecentConfigDeployActions(User user, Integer results) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        params.put("num", results);

        //To reduce the time it takes to sort the set, we only want things that are
        //      less than a week old.  here is the oracle string we conver to:
        //          'YYYY-MM-DD HH24:MI:SS'
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.WEEK_OF_YEAR, -1);
        SimpleDateFormat format = new SimpleDateFormat();
        format.applyPattern("yyyy-MM-dd HH:mm:ss");
        params.put("date", format.format(cal.getTime()));

        SelectMode m = ModeFactory
                .getMode("config_queries", "recent_config_deploy_actions_for_user");
        DataResult dr = m.execute(params);
        return dr;

    }

    /**
     * Return ChannelSummary info - see ChannelOverview
     * @param user user making the request
     * @param channel channel of interest
     * @return summary information for this channel
     */
    public ChannelSummary getChannelSummary(User user, ConfigChannel channel) {
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] has no access to channel [" + channel.getId() + "]");
        }
        ChannelSummary summary = new ChannelSummary();
        summary.setNumSystems(getSystemCount(user, channel));
        summary.setNumDirs(getDirCount(user, channel));
        summary.setNumFiles(getFileCount(user, channel));
        summary.setNumSymlinks(getSymlinkCount(user, channel));

        DataResult dr = getFileInfo(user, channel);
        if (dr != null && dr.size() > 0) {
            ConfigFileDto mostRecent = (ConfigFileDto)dr.get(0);
            Long revid = new Long(mostRecent.getId().longValue());
            ConfigRevision rev =
                ConfigurationManager.getInstance().lookupConfigRevision(user, revid);
            summary.setMostRecentMod(rev);
            String fileDate = StringUtil.categorizeTime(rev.getModified().getTime(),
                    StringUtil.WEEKS_UNITS);
            summary.setRecentFileDate(fileDate);
        }

        dr = getSystemInfo(user, channel);
        if (dr != null && dr.size() > 0) {
            ConfigSystemDto mostRecent = (ConfigSystemDto)dr.get(0);
            Long sysid = new Long(mostRecent.getId().longValue());
            Server sys = ServerFactory.lookupById(sysid);
            summary.setMostRecentSystem(sys);
            Date modDate = mostRecent.getModified();
            String modifiedDate = StringUtil.categorizeTime(modDate.getTime(),
                    StringUtil.WEEKS_UNITS);
            summary.setSystemDate(modifiedDate);
        }
        return summary;
    }

    /**
     * List current files for channel withOUT using a set
     * @param user user making the request
     * @param channel channel of interest
     * @param pc pagination control (if any)
     * @return list of com.redhat.rhn.frontend.dto.ConfigFileDto
     */
    public DataResult<ConfigFileDto> listCurrentFiles(User user,
                                    ConfigChannel channel, PageControl pc) {
        return listCurrentFiles(user, channel, pc, null);
    }

     /**
      * List latest revisions controlled by this channel, sorted by date-modified
      * (descending), optionally constrained by the specified set
      * @param user user making the request
      * @param channel channel of interest
      * @param pc controller/elaborator for the list
      * @param setLabel label of set we care about, or NULL if we don't want to use a set
      * @return list of com.redhat.rhn.frontend.dto.ConfigFileDto
      */
     public DataResult listCurrentFiles(
             User user, ConfigChannel channel, PageControl pc, String setLabel) {
         Map params = new HashMap();
         params.put("ccid", channel.getId());
         params.put("user_id", user.getId());
         SelectMode m = null;
         if (setLabel != null) {
             m = ModeFactory.getMode("config_queries", "latest_files_in_namespace_set");
             params.put("set_label", setLabel);
         }
         else {
             m = ModeFactory.getMode("config_queries", "latest_files_in_namespace");
         }
         DataResult<ConfigFileDto> dr = makeDataResult(params, new HashMap(), pc, m);
         return dr;
     }

     /**
      * List revisions for the given file
      * @param user user making the request
      * @param file config file for which we are listing revisions
      * @param pc controller/elaborator for the list
      * @return List of revisions in dto format.
      */
     public DataResult listRevisionsForFile(User user, ConfigFile file, PageControl pc) {
         Map params = new HashMap();
         params.put("cfid", file.getId());
         params.put("user_id", user.getId());
         SelectMode m = ModeFactory.getMode("config_queries", "configfile_revisions");
         DataResult dr = makeDataResult(params, new HashMap(), pc, m);
         return dr;
     }

     /**
      * List systems subscribed to this channel, sorted by date added (descending)
      * @param user user making the request
      * @param channel channel of interest
      * @param pc controller/elaborator for the list
      * @return List of Maps with keys ('id', 'name', 'modified')
      */
     public DataResult listChannelSystems(User user, ConfigChannel channel,
             PageControl pc) {
         Map params = new HashMap();
         params.put("ccid", channel.getId());
         params.put("user_id", user.getId());
         SelectMode m = ModeFactory.getMode("config_queries", "systems_subscribed_by_date");
         DataResult dr = makeDataResult(params, new HashMap(), pc, m);
         return dr;
     }

    /**
     * List global config channels for a system. Used in the sdc
     * @param user The user requesting for a list of config channels
     * @param server The server subscribed to the config channels
     * @param pc A PageControl for this user
     * @return A list of config channels in DTO format.
     */
    public DataResult listChannelsForSystem(User user, Server server, PageControl pc) {
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("user_id", user.getId());
        Map elabParams = new HashMap();
        elabParams.put("sid", server.getId());
        SelectMode m = ModeFactory.getMode("config_queries", "config_channels_for_system");
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Returns a map of summary information.
     * The keys of this map are as follows:
     * <ol>
     *  <li>systems - The number of configuration managed
     *                systems viewable by this user.</li>
     *  <li>channels - The number central configuration
     *                 channels viewable by this user.</li>
     *  <li>global_files - The number of centrally-managed
     *                     configuration files viewable by
     *                     this user.</li>
     *  <li>local_files - The number of locally-managed
     *                    configuration files viewable by
     *                    this user.</li>
     *  <li>quota - The amount of unused quota available for
     *              configuration files.  This is returned as
     *              a localized string with units.</li>
     * </ol>
     * @param user The user requesting information
     * @return A map with the keys {systems,channels,
     *         global_files,local_files,quota}
     */
    public Map getOverviewSummary(User user) {
        Map retval = new HashMap();
        retval.put("systems", getNumSystemsWithFiles(user));
        retval.put("channels", getNumConfigChannels(user));
        retval.put("global_files", getNumGlobalFiles(user));
        retval.put("local_files", getNumLocalFiles(user));
        return retval;
    }

    /**
     * List systems NOT subscribed to this channel, sorted by name
     * @param user user making the request
     * @param channel channel of interest
     * @param pc controller/elaborator for the list
     * @return List of Maps with keys ('id', 'name')
     */
    public DataResult listSystemsNotInChannel(User user, ConfigChannel channel,
            PageControl pc) {
        Map params = new HashMap();
        params.put("ccid", channel.getId());
        params.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                "managed_systems_not_in_channel");
        DataResult dr = makeDataResult(params, new HashMap(), pc, m);
        return dr;
    }

    private Long getNumSystemsWithFiles(User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                "count_managed_servers_for_user");
        DataResult dr = m.execute(params);
        return (Long)((Map)dr.get(0)).get("count");
    }

    private Long getNumConfigChannels(User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                "count_config_channels_for_user");
        DataResult dr = m.execute(params);
        return (Long)((Map)dr.get(0)).get("count");
    }

    private Long getNumGlobalFiles(User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                "count_global_config_files_for_user");
        DataResult dr = m.execute(params);
        return (Long)((Map)dr.get(0)).get("count");
    }

    private Long getNumLocalFiles(User user) {
        Map params = new HashMap();
        params.put("user_id", user.getId());
        params.put("org_id", user.getOrg().getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                "count_local_config_files_for_user");
        DataResult dr = m.execute(params);
        return (Long)((Map)dr.get(0)).get("count");
    }

    /**
     * Deletes a config channel. Performs checking to determine whether
     * the user actually can delete the config channel
     * @param user The user requesting to delete the channel
     * @param channel The channel to be deleted.
     * @throws IllegalArgumentException if user is not allowed to delete this
     *         config channel (different org or not config admin).
     */
    public void deleteConfigChannel(User user, ConfigChannel channel) {
        //first make sure that the user has permission to delete this channel
        if (!user.getOrg().equals(channel.getOrg())) {
            throw new IllegalArgumentException("Cannot delete config channel. User" +
                    " and channel are in different orgs");
        }
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new IllegalArgumentException("User is not a config admin.");
        }
        //remove the channel
        ConfigurationFactory.removeConfigChannel(channel);
    }

    /**
     * Creates a new config revision object.  Looks up the config file from the id given
     * and decides if the user given has access to that file. If both those steps go ok,
     * it creates a new revision and makes it the newest for the file.
     * @param user The user requesting to create the revision
     * @param input The stream containing the revision's content
     * @param cfid The identifier for the parent config file.
     * @param size The size of the given input stream
     * @return The newly created config revision object
     */
    public ConfigRevision createNewRevision(User user, InputStream input,
            Long cfid, Long size) {
        if (input == null) {
            return null;
        }

        //look up the config file
        ConfigFile file = lookupConfigFile(user, cfid);
        if (file == null) {
            //this should never happen because if the file doesn't exist
            //the access should be denied already.
            throw new NullPointerException("ConfigFile is null while attempting" +
                    " to create a new revision.");
        }

        return createNewRevision(user, input, file, size);
    }

    /**
     * Creates a new config revision object.  Looks up the config file from the id given
     * and decides if the user given has access to that file. If both those steps go ok,
     * it creates a new revision and makes it the newest for the file.
     * @param user The user requesting to create the revision
     * @param input The stream containing the revision's content
     * @param file The parent config file.
     * @param size The size of the given input stream
     * @return The newly created config revision object
     */
    public ConfigRevision createNewRevision(User user, InputStream input,
            ConfigFile file, Long size) {
        if (input == null) {
            return null;
        }
        return ConfigurationFactory.createNewRevisionFromStream(user, input, size, file);
    }
    /**
     * Deletes a config revision. Performs checking to determine whether
     * the user actually can delete the config revision
     * @param user The user requesting to delete the revision
     * @param revision The revision to be deleted.
     * @return whether the parent file was also deleted.
     * @throws IllegalArgumentException if user is not allowed to delete this
     *         config revision (different org or not config admin).
     */
    public boolean deleteConfigRevision(User user, ConfigRevision revision) {
        //first make sure that the user has permission to delete this revision
        if (!user.getOrg().equals(revision.getConfigFile().getConfigChannel().getOrg())) {
            throw new IllegalArgumentException("Cannot delete config revision. User [" +
                user.getId() + "] and revision [" +
                revision.getId() + "] are in different orgs");
        }

        if (!accessToRevision(user.getId(), revision.getId())) {
            throw new IllegalArgumentException("Cannot delete config revision. User [" +
                user.getId() +
                "] is not allowed access to revision [" + revision.getId() + "]");
        }
        //remove the channel
        return ConfigurationFactory.removeConfigRevision(revision, user.getOrg().getId());
    }

    /**
     * Deletes a config file. Performs checking to determine whether
     * the user actually can delete the config file
     * @param user The user requesting to delete the file
     * @param file The file to be deleted.
     * @throws IllegalArgumentException if user is not allowed to delete this
     *         config file (different org or not config admin).
     */
    public void deleteConfigFile(User user, ConfigFile file) {
        //first make sure that the user has permission to delete this file
        if (!user.getOrg().equals(file.getConfigChannel().getOrg())) {
            throw new IllegalArgumentException("Cannot delete config file. User" +
                    " and file are in different orgs");
        }
        if (!accessToFile(user.getId(), file.getId())) {
            throw new IllegalArgumentException(
                "User [" + user.getId() +
                "] does not have access to file [" + file.getId() + "].");
        }
        //remove the file
        ConfigurationFactory.removeConfigFile(file);
    }

    /**
     * Copies a config file. Performs checking to determine whether
     * the user actually can delete the config file.
     * Only copies the revision of the file given. Puts the revision into a config
     * file with the same deploy path in the new channel, or creates a config file if
     * a candidate file does not exist.
     * @param revision The revision of the file to be copied.
     * @param channel The channel to which to copy.
     * @param user The user requesting to copy the file
     * @throws IllegalArgumentException if user is not allowed to copy this
     *         config file (different org or not config admin).
     */
    public void copyConfigFile(ConfigRevision revision, ConfigChannel channel,
            User user) {
        //first make sure that the user has permissions to the revision and channel
        if (!user.getOrg().equals(revision.getConfigFile().getConfigChannel().getOrg()) ||
                !user.getOrg().equals(channel.getOrg())) {
            throw new IllegalArgumentException("Cannot copy config file. User," +
                    " revision, and channel are in different orgs");
        }
        if (!accessToChannel(user.getId(), channel.getId())) {
            throw new IllegalArgumentException("User [" + user.getId() +
                    "] does not have access to channel [" + channel.getId() + "].");
        }
        //copy the file
        ConfigurationFactory.copyRevisionToChannel(user, revision, channel);
    }


    /**
     * For a given filename and server, find all the successful deploys of a file with that
     * name
     * @param usr User making the request
     * @param cfn name of interest
     * @param srv server of interest
     * @return list of LastDeployDtos
     */
    public DataResult getSuccesfulDeploysTo(User usr, ConfigFileName cfn, Server srv) {
        // Validate params
        if (usr == null || cfn == null || srv == null) {
            throw new IllegalArgumentException("User, name, and server cannot be null.");
        }

        //first make sure that the user has permissions to the system
        if (!usr.getOrg().equals(srv.getOrg())) {
            throw new IllegalArgumentException("Cannot examine deploys; " +
                    "user and system are in different orgs.");
        }
        Map params = new HashMap();
        params.put("cfnid", cfn.getId());
        params.put("sid", srv.getId());
        params.put("user_id", usr.getId());
        SelectMode m = ModeFactory
                .getMode("config_queries", "successful_deploys_for");
        DataResult dr = m.execute(params);
        return dr;
    }

   /**
    * For a specified channel, return info about all config-files that the
    * user has access to that are NOT already in that channel
    * @param usr User making the request
    * @param cc ConfigChannel of interest
    * @param pc A page control for this user.
    * @return DataResult; entities are cfid, path, ccid, name, and modified
    */
    public DataResult listFilesNotInChannel(User usr, ConfigChannel cc, PageControl pc) {
        // Validate params
        if (usr == null || cc == null) {
            throw new IllegalArgumentException("User and channel cannot be null.");
        }

        Map params = new HashMap();
        params.put("ccid", cc.getId());
        params.put("user_id", usr.getId());
        params.put("orgid", usr.getOrg().getId());
        SelectMode m = ModeFactory
                .getMode("config_queries", "config_files_not_in_channel");
        return makeDataResult(params, new HashMap(), pc, m);
    }

    /**
     * For a specified ConfigChannel, return overview info for the systems that are
     * subscribed to that channel.
     * @param usr User making the request
     * @param cc ConfigChannel of interest
     * @param pc PageControl (if we're paginating)
     * @return DataResult of ConfigSystemDtos, with id,name,outrankedCount and
     * overriddenCount filled in
     */
    public DataResult listSystemInfoForChannel(User usr, ConfigChannel cc, PageControl pc) {
        return listSystemInfoForChannel(usr, cc, pc, false);
    }

    /**
     * For a specified ConfigChannel, return overview info for the systems that are
     * subscribed to that channel.
     * @param usr User making the request
     * @param cc ConfigChannel of interest
     * @param pc PageControl (if we're paginating)
     * @param useSet true if we should limit by set_label, false if we want ALL systems
     * in the channel
     * @return DataResult of ConfigSystemDtos, with id,name,outrankedCount and
     * overriddenCount filled in
     */
    public DataResult listSystemInfoForChannel(
            User usr, ConfigChannel cc, PageControl pc, boolean useSet) {
        // Validate params
        if (usr == null || cc == null) {
            throw new IllegalArgumentException("User and channel cannot be null.");
        }

        Map params = new HashMap();
        params.put("ccid", cc.getId());
        params.put("user_id", usr.getId());

        Map elabParams = new HashMap();
        elabParams.put("ccid", cc.getId());
        SelectMode m = null;

        if (useSet) {
            params.put("set_label", RhnSetDecl.CONFIG_CHANNEL_DEPLOY_SYSTEMS.getLabel());
            m = ModeFactory.getMode("config_queries", "systems_in_channel_info_set");
        }
        else {
            m = ModeFactory.getMode("config_queries", "systems_in_channel_info");
        }
        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * For a specified channel, return info about all systems that the
     * user has access to that are NOT already in that channel
     * @param usr User making the request
     * @param cc ConfigChannel of interest
     * @param pc A page control for this user.
     * @return DataResult; entities are
     */
     public DataResult listAvailableFilesNotInChannel(User usr, ConfigChannel cc,
             PageControl pc) {
         // Validate params
         if (usr == null || cc == null) {
             throw new IllegalArgumentException("User and channel cannot be null.");
         }

         Map params = new HashMap();
         params.put("ccid", cc.getId());
         params.put("user_id", usr.getId());
         params.put("orgid", usr.getOrg().getId());
         SelectMode m = ModeFactory
                 .getMode("config_queries", "config_files_not_in_channel");
         return makeDataResult(params, new HashMap(), pc, m);
     }

    /**
     * Provides a list of 'Unique' paths (ConfigFileNameDto's)
     * for a given server and channel type. The returned list
     * takes care of the channel priority ordering and stuff like that..
     * This is mainly used in the View/Modify files page
     * of the SDC.
     * @param server the server who's paths are to be retrieved
     * @param user the user needed for permission checking
     * @param type config channel type that holds the files
     * @return a list of unique'ly named paths sorted by the name of
     *          type com.redhat.rhn.frontend.dto.ConfigFileNameDto
     */
    public List< ? extends ConfigFileNameDto> listManagedPathsFor(Server server,
                                                User user,
                                                ConfigChannelType type) {
        Map params = new HashMap();
         params.put("sid", server.getId());
         params.put("user_id", user.getId());
         params.put("channel_type", type.getLabel());
         String modeQuery = "central_managed_files_for_sdc";
         if (ConfigChannelType.sandbox().equals(type)) {
             modeQuery = "sandbox_managed_files_for_sdc";
         }
         else if (ConfigChannelType.local().equals(type)) {
             modeQuery = "local_managed_files_for_sdc";
         }
         SelectMode m = ModeFactory
                 .getMode("config_queries", modeQuery);

         Map elabParams = new HashMap();
         elabParams.put("sid", server.getId());
         elabParams.put("channel_type", type.getLabel());
         DataResult result = m.execute(params);
         result.elaborate(elabParams);
         return result;
    }

    /**
     *  Returns the number of files, and directories
     *  that were on a applied to server by a given config action
     *  This is method is mainly used to show the number
     *  of files and directories that were deployed/diff'd
     *  Note this method doesnot check whether the Action is
     *  visible to the user. It is assumed that whomever is
     *  calling this has already ensured that the Action
     *  is visible to the user.
     * @param server The server for whom the count of files
     *              is desired.
     * @param action the action for whom the number of files
     *              and dirs are desired.
     * @return ConfigFileCount object holding the files and dirs
     */
    public ConfigFileCount countAllActionPaths(Server server,
                                        Action action) {
        return countActionPaths(server,
                                    action,
                                    "count_paths_in_action");
    }

    /**
     *  Returns the number of files, and directories
     *  that were SUCCESSFULLY applied to server by a given config action
     *  This is method is mainly used to show the number
     *  of files and directories that were scheduled for comparison
     *  Returns the number of files
     *  that were selected successfully for comparison
     *  in a config DIFF action.
     *  In other words this method subtracts the missing files
     *  from the total for a given diff action..
     *  Note this method doesnot check whether the Action is
     *  visible to the user. It is assumed that whomever is
     *  calling this has already ensured that the Action
     *  is visible to the user.
     * @param server The server for whom the count of files
     *              is desired.
     * @param action the action for whom the number of files
     *              and dirs are desired.
     * @return ConfigFileCount object holding the number of
     *                          NON Missing files/dirs
     *                          that were selected for comparison
     */
    public ConfigFileCount countSuccessfulCompares(Server server,
                                        Action action) {
        return countActionPaths(server,
                                  action,
                                  "count_successfully_compared_paths");
    }


    /**
     *  Returns the number of files on the server that differed
     *  in content from the files in RHN - Managed
     *  Note this method doesnot check whether the Action is
     *  visible to the user. It is assumed that whomever is
     *  calling this has already ensured that the Action
     *  is visible to the user.
     * @param server The server for whom the count of files
     *              is desired.
     * @param action the action for whom the number of files
     *              and dirs are desired.
     * @return ConfigFileCount object holding the files and dirs
     */
    public ConfigFileCount countDifferingPaths(Server server,
                                        Action action) {
        return countActionPaths(server,
                                  action,
                                  "count_differing_paths");
    }
    private ConfigFileCount countActionPaths(Server server,
            Action action, String query) {
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("aid", action.getId());
        return processCountedFilePathQueries(query, params);
    }

    /**
     *  Returns the number of files, and directories
     *  that are managed in the local override channel or Sandbox channel
     *  of a given server..
     * @param server The server for whom the count of files
     *              is desired.
     * @param user The user required for permission purposes
     * @param cct The local channel type of the to look at (local/sandbox)
     * @return ConfigFileCount object holding the files and dirs
     *
     */
    public ConfigFileCount countLocallyManagedPaths(Server server,
                                        User user,
                                        ConfigChannelType cct) {

        boolean isLocal = ConfigChannelType.local().equals(cct) ||
                ConfigChannelType.sandbox().equals(cct);
        assert isLocal : "Passing in a NON-LOCAL  channel type";
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("user_id", user.getId());
        params.put("cct_label", cct.getLabel());
        return processCountedFilePathQueries("count_locally_managed_file_paths",
                                                                params);
    }

    private ConfigFileCount processCountedFilePathQueries(String query, Map params) {
        SelectMode m = ModeFactory.getMode("config_queries", query);
        List results = m.execute(params);
        long files = 0, dirs = 0, symlinks = 0;

        for (Iterator itr = results.iterator(); itr.hasNext();) {
            Map map = (Map)itr.next();
            Long count = (Long)map.get("count");
            String fileType = (String)map.get("file_type");

            if (ConfigFileType.file().getLabel().equals(fileType)) {
                files = count.longValue();
            }
            else if (ConfigFileType.symlink().getLabel().equals(fileType)) {
                symlinks = count.longValue();
            }
            else {
                dirs = count.longValue();
            }
        }

        return ConfigFileCount.create(files, dirs, symlinks);
    }

    /**
     *  Returns the sum of files, and directories
     *  that are present in the all the centrally managed channels
     *  in a given server.
     *  This method strips out all the duplicate file paths before counting,
     *  and accounts for channel priorities..
     *  For example if a path /tmp/foo is a file in channel A and a directory
     *  in channel B and our Server subscribes to both channels,
     *  Then this method would take into account the priority of the channels
     *  before incrementing File count or Directory count.
     *
     * @param server The server for whom the count of files
     *              is desired.
     * @param user The user required for permission purposes
     * @return  a ConfigFileCount object holding the files and dirs
     */
    public ConfigFileCount countCentrallyManagedPaths(Server server, User user) {
        return countManagedPaths(server, user, "centrally_managed_file_paths");
    }

    /**
     *  Returns the sum of all the 'Deployable' files, and directories
     *  that are present in the all the centrally managed channels
     *  in a given server. This is similar to 'countCentrallyManagedPaths'
     *  except that it also takes into account the file/directory path intersections
     *  between the local override channel and all the centrally managed channels
     *  (basically subtracting them from the central list).
     *   In clearer terms, for a system A
     *  num_of_centrally_deployable_files(A) =  countCentrallyManagedPaths (A)
     *                                     - count(
     *                         centrallyManagedPaths(A) ^ locallyManagedPaths(A)
     *                                              )
     *
     * @param server The server for whom the count of files
     *              is desired.
     * @param user The user required for permission purposes
     * @return ConfigFileCount object holding the files and dirs
     *
     */
    public ConfigFileCount countCentrallyDeployablePaths(Server server, User user) {
        return countManagedPaths(server, user, "centrally_deployable_file_paths");
    }

    /**
     * Returns the count of files and directories after execting a mode query
     * basically used by  countCentrallyManagedPaths & countCentrallyDeployablePaths.
     * It expects the result set to be a list of path, and file_type
     * It partitions this list removes, duplicates and does extra
     * processing.
     * @param server The server for whom the count of files
     *              is desired.
     * @param user The user required for permission purposes
     * @param mode
     * @return a ConfigFileCount object holding the files and dirs
     *
     */
    private ConfigFileCount countManagedPaths(Server server, User user, String mode) {
        SelectMode m = ModeFactory.getMode("config_queries", mode);
        Map params = new HashMap();
        params.put("sid", server.getId());
        params.put("user_id", user.getId());
        List pathList = m.execute(params);
        Set files = new HashSet();
        Set dirs = new HashSet();
        Set symlinks = new HashSet();
        for (Iterator itr = pathList.iterator(); itr.hasNext();) {
            Map map = (Map) itr.next();
            String path = (String) map.get("path");
            String fileType = (String)map.get("file_type");
            if (ConfigFileType.file().getLabel().equals(fileType)) {
                if (!dirs.contains(path) && !symlinks.contains(path)) {
                    files.add(path);
                }
            }
            else if (ConfigFileType.symlink().getLabel().equals(fileType)) {
                if (!dirs.contains(path) && !files.contains(path)) {
                    symlinks.add(path);
                }
            }
            else if (!files.contains(path) && !symlinks.contains(path)) {
                dirs.add(path);
            }
        }
        return ConfigFileCount.create(files.size(), dirs.size(), symlinks.size());
    }


    /**
     * Looks up a config channel, if the given user has access to it.
     * @param user The user requesting to lookup a config channel.
     * @param id The identifier for the config channel
     * @return The sought for config channel.
     */
    public ConfigChannel lookupConfigChannel(User user, Long id) {
        if (!accessToChannel(user.getId(), id)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find config channel with id=" + id);
            e.setLocalizedTitle(ls.getMessage("lookup.configchan.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.configchan.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.configchan.reason2"));
            throw e;
        }
        return ConfigurationFactory.lookupConfigChannelById(id);
    }

    /**
     * Looks up a config channel, if the given user has access to it.
     * @param user The user requesting to lookup a config channel.
     * @param label The label for the ConfigChannel
     * @param cct the config channel type of the config channel.
     * @return The sought for config channel.
     */
    public ConfigChannel lookupConfigChannel(User user,
                                                String label,
                                                ConfigChannelType cct) {
        ConfigChannel cc = ConfigurationFactory.
                               lookupConfigChannelByLabel(label,
                                                           user.getOrg(),
                                                            cct);

        if (cc == null || !accessToChannel(user.getId(), cc.getId())) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find config channel " +
                                                "with label=" + label);
            e.setLocalizedTitle(ls.getMessage("lookup.configchan.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.configchan.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.configchan.reason2"));
            throw e;
        }
        return cc;
    }

    /**
     * Looks up a config file, if the given user has access to it.
     * @param user The user requesting to lookup a config file.
     * @param id The identifier for the config file.
     * @return The sought for config file.
     */
    public ConfigFile lookupConfigFile(User user, Long id) {
        log.debug("lookupConfigFile: " + id);
        if (!accessToFile(user.getId(), id)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find config file with id=" + id);
            e.setLocalizedTitle(ls.getMessage("lookup.configfile.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.configfile.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.configfile.reason2"));
            throw e;
        }
        return ConfigurationFactory.lookupConfigFileById(id);
    }

    /**
     * Look up a config-file with a specified name in a specified cfg-channel.
     * If the specified path is not yet in the system, it will be created as a
     * ConfigFileName (under the assumption that if we're asking this,
     * chances are good we're going to want to create a ConfigFile with this
     * path Real Soon Now...)
     *
     * @param user User making the request
     * @param ccid ID of tyhe cohnfig-channel of interest
     * @param path file-path of interest
     * @return ConfigFile if found, or null if it doesn't exist or if the user doesn't
     * have sufficient access
     */
    public ConfigFile lookupConfigFile(User user, Long ccid, String path) {
        if (!accessToChannel(user.getId(), ccid)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find config file with id=" + ccid);
            e.setLocalizedTitle(ls.getMessage("lookup.configfile.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.configfile.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.configfile.reason2"));
            throw e;
        }
        ConfigFileName cfn = ConfigurationFactory.lookupOrInsertConfigFileName(path);
        return ConfigurationFactory.lookupConfigFileByChannelAndName(ccid, cfn.getId());
    }

    /**
     * Looks up a config revision, if the given user has access to it.
     * @param user The user requesting to lookup a config revision.
     * @param id The identifier for the config revision.
     * @return The sought for config revision.
     */
    public ConfigRevision lookupConfigRevision(User user, Long id) {
        if (!accessToRevision(user.getId(), id)) {
            LocalizationService ls = LocalizationService.getInstance();
            LookupException e =
                new LookupException("Could not find config revision with id=" + id);
            e.setLocalizedTitle(ls.getMessage("lookup.configrev.title"));
            e.setLocalizedReason1(ls.getMessage("lookup.configrev.reason1"));
            e.setLocalizedReason2(ls.getMessage("lookup.configrev.reason2"));
            throw e;
        }
        return ConfigurationFactory.lookupConfigRevisionById(id);
    }

    /**
     * @param uid The user id
     * @param ccid The config channel id
     * @return whether the user with the given id can view the
     *         config channel with the given id.
     */
    public boolean accessToChannel(Long uid, Long ccid) {
        return accessToObject(uid, "channel_id", ccid, "user_channel_access");
    }

    private boolean accessToFile(Long uid, Long cfid) {
        return accessToObject(uid, "file_id", cfid, "user_file_access");
    }

    private boolean accessToRevision(Long uid, Long crid) {
        return accessToObject(uid, "revision_id", crid, "user_revision_access");
    }

    private boolean accessToObject(Long uid, String name, Long oid, String mode) {
        log.debug("accessToObject :: uid: " + uid + " name: " + name +
                " oid: " + oid + " mode: " + mode);
        CallableMode m = ModeFactory.getCallableMode("config_queries", mode);
        Map inParams = new HashMap();
        inParams.put("user_id", uid);
        inParams.put(name, oid);

        Map outParams = new HashMap();
        outParams.put("access", new Integer(Types.NUMERIC));

        Map result = m.execute(inParams, outParams);
        int access = ((Long)result.get("access")).intValue();
        return (access == 1);
    }

    /**
     * Returns the config revision id for a config file with the given config
     * file name id.  The config revision is one is the highest priority config channel
     * for the server with the given id.
     * @param cfnid The config file name id
     * @param sid The server id
     * @return The deployable config revision for the given server with the given name.
     */
    public Long getDeployableRevisionForFileName(Long cfnid, Long sid) {
        if (cfnid == null || sid == null) {
            return null;
        }
        Map params = new HashMap();
        params.put("cfnid", cfnid);
        params.put("sid", sid);
        SelectMode m = ModeFactory.getMode("config_queries",
                "deployable_revision_for_system");
        DataResult dr = m.execute(params);
        if (dr.size() < 1) {
            return null;
        }
        Object id = ((Map)dr.get(0)).get("id");
        if (id == null) {
            return null;
        }
        return (Long)id;
    }

    /**
     * Enable the set of systems given for configuration management.
     * @param set The set that contains systems selected for enablement
     * @param user The user requesting to enable systems
     * @param earliest The earliest time package actions will be scheduled.
     */
    public void enableSystems(RhnSetDecl set, User user, Date earliest) {
        EnableConfigHelper helper = new EnableConfigHelper(user);
        helper.enableSystems(set.getLabel(), earliest);
    }

    /**
     * List the info for the systems subscribed to the specified channel,
     * for which we might want to schedule a deploy of the specified file,
     * without being constrained by a selected set of systems
     * @param usr logged-in user
     * @param cc cfg-channel of interest
     * @param cf cfg=file of interest
     * @param pc paging control for UI control
     * @return list of ConfigGlobalDeployDtos
     */
    public DataResult<ConfigGlobalDeployDto> listGlobalFileDeployInfo(
            User usr, ConfigChannel cc,
            ConfigFile cf, PageControl pc) {
        return listGlobalFileDeployInfo(usr, cc, cf, pc, null);
    }

    /**
     * List the info for the systems subscribed to the specified channel,
     * for which we might want to schedule a deploy of the specified file,
     * optionally constrained by a selected set of systems
     * @param usr User making the request
     * @param cc Config Channel File is in
     * @param cf ConfigFile of interest
     * @param pc page-control for UI paging
     * @param setLabel label of limiting set, or NULL if not set-limited
     * @return DataResult of ConfigGlobalDeployDtos
     */
    public DataResult<ConfigGlobalDeployDto> listGlobalFileDeployInfo(
            User usr, ConfigChannel cc,
            ConfigFile cf, PageControl pc,
            String setLabel) {
        // Validate params
        if (usr == null || cc == null || cf == null) {
            throw new IllegalArgumentException(
                "User, channel, and config-file cannot be null.");
        }
        Map params = new HashMap();
        Map elabParams = new HashMap();

        SelectMode m = null;
        if (setLabel != null) {
            m = ModeFactory.getMode("config_queries", "global_file_deploy_set_info");
            params.put("user_id", usr.getId());
            params.put("ccid", cc.getId());
            params.put("set_label", setLabel);
            elabParams.put("ccid", cc.getId());
            elabParams.put("cfnid", cf.getConfigFileName().getId());
        }
        else {
            m = ModeFactory.getMode("config_queries", "global_file_deploy_info");
            params.put("user_id", usr.getId());
            params.put("ccid", cc.getId());
            params.put("cfnid", cf.getConfigFileName().getId());
        }

        return makeDataResult(params, elabParams, pc, m);
    }

    /**
     * Schedules deploys of all the configuration files or dirs
     * associated to a list of servers
     *
     * @param user User needed for authentication purposes..
     * @param servers The list of servers, to whom the deploy action
     *                  needs to be scheduled
     * @param datePicked date to deploy or null for the earliest date
     */
    public void deployConfiguration(User user,
                                        Collection <Server> servers,
                                        Date datePicked) {
        if (datePicked == null) {
            datePicked = new Date();
        }
        for (Server server : servers) {
            ensureConfigManageable(server);
            List <ConfigFileNameDto> names = listFileNamesForSystem(user,
                                                                server, null);
            Set <Server> system = new HashSet<Server>();
            system.add(server);
            Set <Long> revs = new HashSet<Long>();
            for (ConfigFileNameDto dto : names) {
                revs.add(getDeployableRevisionForFileName(dto.getId().longValue(),
                                                                    server.getId()));
            }

            Action act = ActionManager.createConfigActionForServers(
                                            user, revs, system,
                                                ActionFactory.TYPE_CONFIGFILES_DEPLOY,
                                                datePicked);
            ActionFactory.save(act);
        }
    }

    /**
     * Deploy revisions to systems.
     * For each system, make sure the specified revisions are all the top-priority
     * files - if they're not, flag an error and continue.
     * @param usr User requesting the deploy
     * @param fileIds Revisions to be deployed
     * @param systemIds Systems to deploy to
     * @param datePicked Date to schedule the deploy for
     * @return Map<String,Long> describing "success"|"override"|"failure"
     */
    public Map deployFiles(User usr, Set fileIds, Set systemIds, Date datePicked) {

        int revOverridden = 0;
        int revSucceeded = 0;

        // First, map revid to cfnid once, so we don't have to do it per system
        Map nameMap = mapFileToName(fileIds);
        Map fileMap = mapFileToRevId(fileIds);

        // For all systems
        for (Iterator itr = systemIds.iterator(); itr.hasNext();) {
            Long sysId = (Long)itr.next();
            Set system = new HashSet();
            system.add(sysId);
            Set revs = new HashSet();
            // For each revision....
            for (Iterator fItr = fileIds.iterator(); fItr.hasNext();) {
                Long file = (Long)fItr.next();
                Long rev = (Long)fileMap.get(file);
                Long cfnid = (Long)nameMap.get(file);
                Long deployableRev = getDeployableRevisionForFileName(cfnid, sysId);
                revs.add(deployableRev);
                if (rev.equals(deployableRev)) {
                    revSucceeded++;
                }
                else {
                    revOverridden++;
                }
            }
            Action act = ActionManager.createConfigAction(
                    usr, revs, system, ActionFactory.TYPE_CONFIGFILES_DEPLOY, datePicked);
            ActionFactory.save(act);
        }

        Map m = new HashMap();

        if (revSucceeded > 0) {
            m.put("success", new Long(revSucceeded));
        }
        if (revOverridden > 0) {
            m.put("override", new Long(revOverridden));
        }
        return m;
    }

    /**
     * From file id, get file.fileName and map to file-id
     * @param fileIds set of file-ids of interest
     * @return Map<Long,Long> of file-id to cfn-id
     */
    private Map mapFileToName(Set fileIds) {
        Map m = new HashMap();
        for (Iterator itr = fileIds.iterator(); itr.hasNext();) {
            Long id = (Long)itr.next();
            ConfigFile cf = ConfigurationFactory.lookupConfigFileById(id);
            if (cf != null) {
                m.put(id, cf.getConfigFileName().getId());
            }
        }
        return m;
    }

    /**
     * From file id, get file.latest-rev and map to file-id
     * @param fileIds set of file-ids of interest
     * @return Map<Long,Long> of file-id to cr-id
     */
    private Map mapFileToRevId(Set fileIds) {
        Map m = new HashMap();
        for (Iterator itr = fileIds.iterator(); itr.hasNext();) {
            Long id = (Long)itr.next();
            ConfigFile cf = ConfigurationFactory.lookupConfigFileById(id);
            if (cf != null) {
                m.put(id, cf.getLatestConfigRevision().getId());
            }
        }
        return m;
    }

    /**
     * Method to ensure  config management features are available for a given system
     *   are available..
     * @param server the server to check.
     */
    public void ensureConfigManageable(Server server) {
        if (server == null) {
            throw new LookupException("Server doesn't exist");
        }

        if (!SystemManager.serverHasFeature(server.getId(),
                                    FEATURE_CONFIG)) {
            String msg = "Config feature needs to be enabled on the server" +
                            " for handling Config Management. The provided server [%s]" +
                             " does not have have this enabled. Add provisioning" +
                             " capabilities to the system to enable this..";
            throw new PermissionException(String.format(msg, server));
        }
    }


    /**
     * Returns the server id associated to a local/sandbox channel
     * @param cc the local or sandbox channel
     * @param user the logged in user.
     * @return the server id associated to a local/sandbox channel
     */
    public Long getServerIdFor(ConfigChannel cc, User user) {
        if (cc.isLocalChannel() || cc.isSandboxChannel()) {
            Long sid = null;
            DataResult dr =  listChannelSystems(user, cc, null);
            if (dr == null || dr.size() == 0) {
                return null;
            }
            else {
                ConfigSystemDto csd = (ConfigSystemDto)dr.get(0);
                sid = csd.getId().longValue();
            }
            return sid;
        }
        else {
            return null;
        }
    }

    /**
     * Returns the config channel id of a channel given
     * a user, a channel label, an org and a channel tpye
     * @param user User who is looking up
     * @return the config channel id or null of nothing exists
     */


    /**
     * Returns true if there already exists
     * a config channel with the same label, cc type and org.
     * @param label Label of the config channel
     * @param cct the contig channel type
     * @param org the org of the current user
     * @return true if there already exists such a channel/false otherwise.
     */
    public boolean isDuplicated(String label, ConfigChannelType cct,
                                Org org) {
        Map params = new HashMap();
        params.put("cc_label", label);
        params.put("cct_label", cct.getLabel());
        params.put("org_id", org.getId());
        SelectMode m = ModeFactory.getMode("config_queries",
                                    "lookup_id_by_label_org_channel_type");
        DataResult dr = m.execute(params);
        return !dr.isEmpty();
    }

}
