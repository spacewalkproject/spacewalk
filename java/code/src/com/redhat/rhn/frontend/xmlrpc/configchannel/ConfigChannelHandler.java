/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.configchannel;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ConfigChannelDto;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ConfigSystemDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.configuration.ConfigChannelCreationHelper;
import com.redhat.rhn.manager.configuration.ConfigurationManager;
import com.redhat.rhn.manager.system.SystemManager;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ConfigHandler
 * @version $Rev$
 * @xmlrpc.namespace configchannel
 * @xmlrpc.doc Provides methods to access and modify many aspects of 
 * configuration channels.
 */
public class ConfigChannelHandler extends BaseHandler {
    
    /**
     * Creates a new global config channel based on the values provided..
     * @param sessionKey User's session key.
     * @param label label of the config channel
     * @param name name of the config channel
     * @param description description of the config channel
     * @return the newly created config channel
     * 
     * @xmlrpc.doc Create a new global config channel. Caller must be at least a 
     * config admin or an organization admin.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.param #param("string", "channelName")
     * @xmlrpc.param #param("string", "channelDescription")
     * @xmlrpc.returntype 
     * $ConfigChannelSerializer
     */
    public ConfigChannel create(String sessionKey, String label,
                                            String name, 
                                            String description) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);
        
        ConfigChannelCreationHelper helper = new ConfigChannelCreationHelper();
        try {
            helper.validate(label, name, description);
            ConfigChannel cc = helper.create(loggedInUser);
            helper.update(cc, name, label, description);
            helper.save(cc);
            return cc;
        }
        catch (ValidatorException ve) {
            String msg = "Exception encountered during channel creation.\n" +
                            ve.getMessage();
            throw new FaultException(1021, "ConfigChannelCreationException", msg);
        }
        
    }
    
    /**
     * Return a struct of config channel details.
     * @param sessionKey User's session key.
     * @param configChannelLabel Config channel label.
     * @return the Config channel details
     * 
     * @xmlrpc.doc Lookup config channel details.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype
     *   $ConfigChannelSerializer
     */
    public ConfigChannel getDetails(String sessionKey, String configChannelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ConfigurationManager manager = ConfigurationManager.getInstance();
        return manager.lookupConfigChannel(loggedInUser, configChannelLabel, 
                ConfigChannelType.global());
    }
    
    /**
     * Return a struct of config channel details.
     * @param sessionKey User's session key.
     * @param configChannelId Config channel ID.
     * @return the Config channel details
     * 
     * @xmlrpc.doc Lookup config channel details.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param int channelId
     * @xmlrpc.returntype
     *    $ConfigChannelSerializer
     */
    public ConfigChannel getDetails(String sessionKey, Integer configChannelId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ConfigurationManager manager = ConfigurationManager.getInstance();
        
        Long id = configChannelId.longValue();
        return manager.lookupConfigChannel(loggedInUser, id);
    }

    /**
     *Updates a global config channel based on the values provided.. 
     * @param sessionKey User's session key.
     * @param label label of the config channel
     * @param name name of the config channel
     * @param description description of the config channel
     * @return the newly created config channel
     * 
     * @xmlrpc.doc Update a global config channel. Caller must be at least a 
     * config admin or an organization admin, or have access to a system containing this
     * config channel.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param string channelLabel
     * @xmlrpc.param string channelName 
     * @xmlrpc.param string description 
     * @xmlrpc.returntype
     * $ConfigChannelSerializer
     */
    public ConfigChannel update(String sessionKey, String label, 
                                            String name , 
                                            String description) {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        ConfigurationManager manager = ConfigurationManager.getInstance();
        ConfigChannel cc = manager.lookupConfigChannel(loggedInUser, label,
                                        ConfigChannelType.global());

        ConfigChannelCreationHelper helper = new ConfigChannelCreationHelper();
        
        try {
            helper.validate(label, name, description);
            cc.setName(name);
            cc.setDescription(description);
            helper.save(cc);
            return cc;
        }
        catch (ValidatorException ve) {
            String msg = "Exception encountered during channel creation.\n" +
                            ve.getMessage();
            throw new FaultException(1021, "ConfigChannelCreationException", msg);
        }        
    }

    /**
     * Lists details on a list channels given their channel labels. 
     * @param sessionKey the session key
     * @param labels the list of channel labels to lookup on
     * @return a list of config channels.
     * 
     * @xmlrpc.doc Lists details on a list channels given their channel labels.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param 
     * #array_single("string","configuration channel label")
     * @xmlrpc.returntype 
     * #array()
     *  $ConfigChannelSerializer
     * #array_end()
     */
    public List<ConfigChannel> lookupChannelInfo(String sessionKey, 
                                                    List<String> labels) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper helper = XmlRpcConfigChannelHelper.getInstance();
        return helper.lookupGlobals(loggedInUser, labels);
    }
    
    /**
     * List all the global channels accessible to the logged-in user
     * @param sessionKey User's session key.
     * @return a list of accessible global config channels 
     * 
     * @xmlrpc.doc List all the global config channels accessible to the logged-in user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype  
     * #array()
     *  $ConfigChannelDtoSerializer
     * #array_end()
     */
    public List<ConfigChannelDto> listGlobals(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ConfigurationManager manager = ConfigurationManager.getInstance();
        DataResult<ConfigChannelDto> list = manager.
                                    listGlobalChannels(loggedInUser, null);
        list.elaborate(list.getElaborationParams());
        return  list;
    }

    /**
     * Creates a NEW path(file/directory) with the given path or updates an existing path 
     * with the given contents in a given channel.
     * @param sessionKey User's session key.
     * @param channelLabel the label of the config channel.
     * @param path the path of the given text file. 
     * @param isDir true if this is a directory path, false if its to be a file path
     * @param data a map containing properties pertaining to the given path..
     * for directory paths - 'data' will hold values for ->
     *  owner, group, permissions 
     * for file paths -  'data' will hold values for-> 
     *  contents, owner, group, permissions, macro-start-delimiter, macro-end-delimiter 
     * @return returns the new created or updated config revision..
     * @since 10.2
     * 
     * @xmlrpc.doc Create a new file or directory with the given path, or 
     * update an existing path.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "configChannelLabel")
     * @xmlrpc.param #param("string", "path") 
     * @xmlrpc.param #param_desc("boolean","isDir", 
     *              "True if the path is a directory, False if it is a file.")
     * @xmlrpc.param
     *  #struct("path info")
     *      #prop_desc("string","contents",
     *              "Contents of the file (text or base64 encoded if binary).
     *                   (ignored for directories)")
     *      #prop_desc("string", "owner", "Owner of the file/directory.")
     *      #prop_desc("string", "group", "Group name of the file/directory.")
     *      #prop_desc("string", "permissions", 
     *                              "Octal file/directory permissions (eg: 644)")
     *      #prop_desc("string", "selinux_ctx", "SELinux Security context (optional)")
     *      #prop_desc("string", "macro-start-delimiter", 
     *                  "Config file macro start delimiter. Use null or empty 
     *                  string to accept the default. (ignored if working with a
     *                   directory)")
     *      #prop_desc("string", "macro-end-delimiter", 
     *              "Config file macro end delimiter. Use null or 
     *  empty string to accept the default. (ignored if working with a directory)")    
     *      
     *  #struct_end()
     * @xmlrpc.returntype 
     * $ConfigRevisionSerializer
     */    
    public ConfigRevision createOrUpdatePath(String sessionKey, 
                                                String channelLabel,
                                                String path,
                                                boolean isDir,
                                                Map<String, Object> data) {

        // confirm that the user only provided valid keys in the map
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("contents");
        validKeys.add("owner");
        validKeys.add("group");
        validKeys.add("permissions");
        validKeys.add("selinux_ctx");
        validKeys.add("macro-start-delimiter");
        validKeys.add("macro-end-delimiter");
        validateMap(validKeys, data);

        if (data.get("selinux_ctx") == null) {
            data.put("selinux_ctx", "");
        }

        User user = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper helper = XmlRpcConfigChannelHelper.getInstance();
        ConfigChannel channel = helper.lookupGlobal(user, channelLabel);
        return helper.createOrUpdatePath(user, channel, path, isDir, data);
    }

    
    /**
     * Given a list of paths and a channel the method returns details about the latest
     * revisions of the paths.
     * @param sessionKey the session key
     * @param channelLabel the channel label
     * @param paths a list of paths to examine.
     * @return a list containing the latest config revisions of the requested paths.
     * @since 10.2
     * 
     * @xmlrpc.doc Given a list of paths and a channel, returns details about 
     * the latest revisions of the paths.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param_desc("string", "channelLabel", 
     *                          "label of config channel to lookup on")
     * @xmlrpc.param 
     *          #array_single("string", "List of paths to examine.")
     * @xmlrpc.returntype
     * #array()
     * $ConfigRevisionSerializer
     * #array_end()
     */
    public List<ConfigRevision> lookupFileInfo(String sessionKey,
                                                String channelLabel, 
                                                List<String> paths
                                                ) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        ConfigChannel channel = configHelper.lookupGlobal(loggedInUser, 
                                                                channelLabel);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        List <ConfigRevision> revisions = new LinkedList<ConfigRevision>();
        for (String path : paths) {
            ConfigFile cf = cm.lookupConfigFile(loggedInUser, channel.getId(), path);
            revisions.add(cf.getLatestConfigRevision());
        }
        return revisions;
    }
    
    /**
     * List files in a given channel
     * @param sessionKey the session key
     * @param channelLabel the label of the config channel
     * @return a list of dto's holding this info.
     *
     * @xmlrpc.doc Return a list of files in a channel.
     * @xmlrpc.param  #session_key() 
     * @xmlrpc.param #param_desc("string", "channelLabel", 
     *                          "label of config channel to list files on.") 
     * @xmlrpc.returntype 
     * #array()
     * $ConfigFileDtoSerializer
     * #array_end()
     */
    public List<ConfigFileDto> listFiles(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        ConfigChannel channel = configHelper.lookupGlobal(loggedInUser, 
                                                                channelLabel);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        return cm.listCurrentFiles(loggedInUser, channel, null);
    }
    

    
    /**
     * Deletes a list of  global channels..
     * Need to be a config admin to do this operation. 
     * @param sessionKey the session
     *  key
     * @param channelLabels the the list of global channels.
     * @return 1 if successful with the operation errors out otherwise.
     * 
     * @xmlrpc.doc Delete a list of global config channels.
     * Caller must be a config admin. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param
     * #array_single("string","configuration channel labels to delete.")
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int deleteChannels(String sessionKey, List<String> channelLabels) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        List <ConfigChannel> channels = configHelper.lookupGlobals(loggedInUser, 
                                                                channelLabels);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        for (ConfigChannel channel : channels) {
            cm.deleteConfigChannel(loggedInUser, channel);    
        }
        return 1;
    }
    
    /**
     * Removes a list of paths from a global channel..
     * @param sessionKey the session key
     * @param channelLabel the channel to remove the files from..
     * @param paths the list of paths to delete.
     * @return 1 if successful with the operation errors out otherwise.
     * 
     * 
     * @xmlrpc.doc Remove file paths from a global channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string","channelLabel",
     *                       "Channel to remove the files from.")
     * @xmlrpc.param
     * #array_single("string","file paths to remove.")
     * @xmlrpc.returntype #return_int_success()
     */
     public int deleteFiles(String sessionKey, String channelLabel, List <String> paths) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        ConfigChannel channel = configHelper.lookupGlobal(loggedInUser, 
                                                                channelLabel);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        for (String path : paths) {
            ConfigFile cf = cm.lookupConfigFile(loggedInUser, channel.getId(), path);
            cm.deleteConfigFile(loggedInUser, cf);
        }
        return 1;
     }
     
     /**
      * Schedule a comparison of the latest revision of a file 
      * against the version deployed on a list of systems.
      * @param sessionKey the session key
      * @param channelLabel label of the config channel
      * @param path the path of file to be compared
      * @param serverIds the list of server ids that the comparison will be
      * performed on
      * @return the id of the action scheduled
      * 
      * 
      * @xmlrpc.doc Schedule a comparison of the latest revision of a file 
      * against the version deployed on a list of systems.
      * @xmlrpc.param #session_key()
      * @xmlrpc.param #param_desc("string", "channelLabel",
      *                       "Label of config channel")
      * @xmlrpc.param #param_desc("string", "path", "File path") 
      * @xmlrpc.param #array_single("long","The list of server id that the 
      * comparison will be performed on")
      * @xmlrpc.returntype int actionId - The action id of the scheduled action
      */
     public Integer scheduleFileComparisons(String sessionKey, String channelLabel, 
             String path, List<Integer> serverIds) {
         
         User loggedInUser = getLoggedInUser(sessionKey);
         
         XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
         ConfigChannel channel = configHelper.lookupGlobal(loggedInUser, channelLabel);
         ConfigurationManager cm = ConfigurationManager.getInstance();

         // obtain the latest revision for the file provided by 'path'
         Set<Long> revisions = new HashSet<Long>();
         ConfigFile cf = cm.lookupConfigFile(loggedInUser, channel.getId(), path);
         revisions.add(cf.getLatestConfigRevision().getRevision());
         
         // schedule the action for the servers specified
         Set<Long> sids = new HashSet<Long>();
         for (Integer sid : serverIds) {
             sids.add(sid.longValue());
         }
         
         Action action = ActionManager.createConfigDiffAction(loggedInUser, revisions, 
                 sids);
         ActionFactory.save(action);

         return action.getId().intValue();
    }

    /**
     * Check for the existence of the config channel provided.
     * @param sessionKey the session key
     * @param channelLabel the channel to check for.
     * @return 1 if exists, 0 otherwise.
     *
     * @xmlrpc.doc Check for the existence of the config channel provided.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string","channelLabel",
     *                       "Channel to check for.")
     * @xmlrpc.returntype 1 if exists, 0 otherwise.
     */
    public int channelExists(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ConfigurationManager manager = ConfigurationManager.getInstance();
        DataResult<ConfigChannelDto> list = manager.
                                    listGlobalChannels(loggedInUser, null);

        for (ConfigChannelDto channel : list) {
            if (channel.getLabel().equals(channelLabel)) {
                return 1;
            }
        }
        return 0;
    }


    /**
     * Schedule a configuration deployment for all systems in a config channel immediately
     * @param sessionKey the session key
     * @param channelLabel the channel to remove the files from..
     * @return 1 if successful with the operation errors out otherwise.
     *
     *
     * @xmlrpc.doc Schedule an immediate configuration deployment for all systems
     *    subscribed to a particular configuration channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string","channelLabel",
     *                       "The configuration channel's label.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deployAllSystems(String sessionKey, String channelLabel) {
        return deployAllSystems(sessionKey, channelLabel, new Date());
    }


    /**
     * Schedule a configuration deployment for all systems in a config channel
     * @param sessionKey the session key
     * @param channelLabel the channel to remove the files from..
     * @param date the date to schedule
     * @return 1 if successful with the operation errors out otherwise.
     *
     *
     * @xmlrpc.doc Schedule a configuration deployment for all systems
     *    subscribed to a particular configuration channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string","channelLabel",
     *                       "The configuration channel's label.")
     * @xmlrpc.param #param_desc($date, "The date to schedule the action")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deployAllSystems(String sessionKey, String channelLabel, Date date) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        ConfigurationManager manager = ConfigurationManager.getInstance();

        ConfigChannel channel = configHelper.lookupGlobal(loggedInUser,
                channelLabel);
        List<ConfigSystemDto> dtos = manager.listChannelSystems(loggedInUser, channel, null);
        List<Server> servers = new ArrayList<Server>();
        for (ConfigSystemDto m : dtos) {
            Server s = SystemManager.lookupByIdAndUser((Long) m.getId(), loggedInUser);
            if (s != null) {
                servers.add(s);
            }
        }

        try {
            manager.deployConfiguration(loggedInUser, servers, date);
        }
        catch (MissingCapabilityException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingCapabilityException(
                e.getCapability(), e.getServer());
        }
        return 1;

    }
}
