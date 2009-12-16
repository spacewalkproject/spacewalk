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
package com.redhat.rhn.frontend.xmlrpc.system.config;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.config.ConfigChannelListProcessor;
import com.redhat.rhn.domain.config.ConfigChannelType;
import com.redhat.rhn.domain.config.ConfigFile;
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ConfigFileDto;
import com.redhat.rhn.frontend.dto.ConfigFileNameDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.configchannel.XmlRpcConfigChannelHelper;
import com.redhat.rhn.frontend.xmlrpc.serializer.ConfigFileNameDtoSerializer;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.configuration.ConfigurationManager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * ServerConfigChannelHandler
 * @version $Rev$
 * @xmlrpc.namespace system.config
 * @xmlrpc.doc Provides methods to access and modify many aspects of 
 * configuration channels and server association.
 * basically system.config name space
 */
public class ServerConfigHandler extends BaseHandler {
    /**
     * List files in a given server
     * @param sessionKey the session key
     * @param sid the server id
     * @param listLocal true if a list of paths in local override is desired
     *                  false if  list of paths in sandbox channel is desired
     * @return a list of dto's holding this info.
     *
     * @xmlrpc.doc Return the list of files in a given channel.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("int","serverId")
     * @xmlrpc.param #param("int","listLocal")
     *      #options()
     *          #item_desc ("1", "to return configuration files 
     *              in the system's local override configuration channel")
     *          #item_desc ("0", "to return configuration files 
     *              in the system's sandbox configuration channel")
     *      #options_end()
     *  
     * @xmlrpc.returntype
     * #array()
     * $ConfigFileNameDtoSerializer
     * #array_end()
     */
    public List<ConfigFileNameDto> listFiles(String sessionKey, 
                                            Integer sid, boolean listLocal) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        ConfigurationManager cm = ConfigurationManager.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, sid);
        if (listLocal) {
            DataResult<ConfigFileNameDto> dtos = 
                           cm.listFileNamesForSystem(loggedInUser, server, null);
            dtos.elaborate();
            return dtos;
        }
        else {
            List<ConfigFileNameDto> files = new LinkedList<ConfigFileNameDto>();
            List <ConfigFileDto> currentFiles = cm.listCurrentFiles(loggedInUser, 
                                                    server.getSandboxOverride(), null); 
            for (ConfigFileDto dto : currentFiles) {
                files.add(ConfigFileNameDtoSerializer.toNameDto(dto,
                                            ConfigChannelType.SANDBOX, null));
            }
            return files;
        }
    }
    
    /**
     * Creates a NEW path(file/directory) with the given path or updates an existing path 
     * with the given contents in a given server.
     * @param sessionKey User's session key.
     * @param sid the server id.
     * @param path the path of the given text file. 
     * @param isDir true if this is a directory path, false if its to be a file path
     * @param data a map containing properties pertaining to the given path..
     * for directory paths - 'data' will hold values for ->
     *  owner, group, permissions 
     * for file paths -  'data' will hold values for-> 
     *  contents, owner, group, permissions, macro-start-delimiter, macro-end-delimiter 
     * @param commitToLocal true if we want to commit the file to 
     * the server's local channel false if we want to commit it to sandbox.
     * @return returns the new created or updated config revision..
     * @since 10.2
     * 
     * @xmlrpc.doc Create a new file (text or binary) or directory with the given path, or 
     * update an existing path on a server.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("int","serverId")
     * @xmlrpc.param #param_desc("string","path",
     *                          "the configuration file/directory path")
     * @xmlrpc.param #param( "boolean", "isDir")
     *      #options()
     *          #item_desc ("True", "if the path is a directory")
     *          #item_desc ("False", "if the path is a file")
     *      #options_end()
     * @xmlrpc.param 
     *   #struct("path info")
     *      #prop_desc("string","contents",
     *              "Contents of the file (text or base64 encoded if binary).
     *                   (ignored for directories)")
     *      #prop_desc("string","owner", "Owner of the file/directory.")
     *      #prop_desc("string","group", "Group name of the file/directory.")
     *      #prop_desc("string","permissions", 
     *                          "Octal file/directory permissions (eg: 644)")
     *      #prop_desc("string","macro-start-delimiter", 
     *                  "Config file macro end delimiter. Use null or empty string  
     *              to accept the default. (ignored if working with a directory)") 
     *      #prop_desc("string","macro-end-delimiter",
     *                   "Config file macro end delimiter. Use null or empty string  
     *              to accept the default. (ignored if working with a directory)")
     *      #prop_desc("string","selinux_ctx",
     *                   "SeLinux context (optional)")
     *
     *  #struct_end()
     * @xmlrpc.param #param("int","commitToLocal")
     *      #options()
     *          #item_desc ("1", "to commit configuration files 
     *              to the system's local override configuration channel")
     *          #item_desc ("0", "to commit configuration files 
     *              to the system's sandbox configuration channel")
     *      #options_end()
     * @xmlrpc.returntype 
     *              $ConfigRevisionSerializer
     */    
    public ConfigRevision createOrUpdatePath(String sessionKey, 
                                            Integer sid,
                                            String path,
                                            boolean isDir,
                                            Map<String, Object> data,
                                            boolean commitToLocal) {

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

        User user = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(user, sid);
        ConfigChannel channel;
        if (commitToLocal) {
            channel = server.getLocalOverride();
        }
        else {
            channel = server.getSandboxOverride();
        }
        XmlRpcConfigChannelHelper configHelper = XmlRpcConfigChannelHelper.getInstance();
        return configHelper.createOrUpdatePath(user, channel, path, isDir, data);
    }
    
    /**
     * Given a list of paths and a server the method returns details about the latest
     * revisions of the paths.
     * @param sessionKey the session key
     * @param sid the server id
     * @param paths a list of paths to examine.
     * @param searchLocal true look at local overrides, false 
     *              to look at sandbox overrides 
     * @return a list containing the latest config revisions of the requested paths.
     * @since 10.2
     * 
     * @xmlrpc.doc Given a list of paths and a server, returns details about 
     * the latest revisions of the paths.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("int","serverId")
     * @xmlrpc.param #array_single("string","paths to lookup on.")
     * @xmlrpc.param #param("int","searchLocal")
     *      #options()
     *          #item_desc ("1", "to search configuration file paths 
     *              in the system's local override configuration or
     *              systems subscribed central channels")
     *          #item_desc ("0", "to search configuration file paths 
     *              in the system's sandbox configuration channel")
     *      #options_end()
     * @xmlrpc.returntype 
     *      #array()
     *          $ConfigRevisionSerializer
     *      #array_end()
     */
    public List<ConfigRevision> lookupFileInfo(String sessionKey,
        Integer sid, List<String> paths, boolean searchLocal) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
        Server server = sysHelper.lookupServer(loggedInUser, sid);
        ConfigurationManager cm = ConfigurationManager.getInstance();
        List <ConfigRevision> revisions = new LinkedList<ConfigRevision>();
        for (String path : paths) {
            ConfigFile cf;
            if (searchLocal) {
                cf = cm.lookupConfigFile(loggedInUser,
                                    server.getLocalOverride().getId(), path);
                if (cf == null) {
                    for (ConfigChannel cn : server.getConfigChannels()) {
                        cf = cm.lookupConfigFile(loggedInUser, cn.getId(), path);
                        if (cf != null) {
                            revisions.add(cf.getLatestConfigRevision());
                            break;
                        }
                    }
                }
            }
            else {
                cf = cm.lookupConfigFile(loggedInUser,
                        server.getSandboxOverride().getId(), path);            
            }
            if (cf != null) {
                revisions.add(cf.getLatestConfigRevision());
            }
        }
        return revisions;
    }

    /**
     * Removes a list of paths from a local or sandbox channel of a server..
     * @param sessionKey the session key
     * @param sid the server id to remove the files from..
     * @param paths the list of paths to delete.
     * @param deleteFromLocal true if we want to delete form local channel
     *                         false if we want to delete from sandbox..
     * @return 1 if successful with the operation errors out otherwise.
     * 
     * 
     * @xmlrpc.doc Removes file paths from a local or sandbox channel of a server.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int","serverId") 
     * @xmlrpc.param #array_single("string","paths to remove.")
     * @xmlrpc.param #param("boolean","deleteFromLocal")
     *      #options()
     *          #item_desc ("True", "to delete configuration file paths 
     *              from the system's local override configuration channel")
     *          #item_desc ("False", "to delete configuration file paths 
     *              from the system's sandbox configuration channel")
     *      #options_end()
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int deleteFiles(String sessionKey,
                                       Integer sid,
                                       List <String> paths,
                                       boolean deleteFromLocal) {
       User loggedInUser = getLoggedInUser(sessionKey);
       XmlRpcSystemHelper sysHelper = XmlRpcSystemHelper.getInstance();
       ConfigurationManager cm = ConfigurationManager.getInstance();
       Server server = sysHelper.lookupServer(loggedInUser, sid);
       for (String path : paths) {
           ConfigFile cf;
           if (deleteFromLocal) {
               cf = cm.lookupConfigFile(loggedInUser,
                                   server.getLocalOverride().getId(), path);
           }
           else {
               cf = cm.lookupConfigFile(loggedInUser,
                       server.getSandboxOverride().getId(), path);            
           }
           cm.deleteConfigFile(loggedInUser, cf);
       }
       return 1;
   }    
    
    
    /**
     * Schedules a deploy action for all the configuration files 
     * of a given list of servers.
     * 
     * @param sessionKey User's session key.
     * @param serverIds  list of IDs of the server to schedule the deploy action
     * @param date date of the deploy action..
     * @return 1 on success, raises exceptions otherwise.
     * 
     * @xmlrpc.doc Schedules a deploy action for all the configuration files
     * on the given list of systems.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #array_single("int",
     *              "id of the systems to schedule configuration files deployment")
     * @xmlrpc.param #param_desc($date, "date",
     *                               "Earliest date for the deploy action.")
     * @xmlrpc.returntype #return_int_success()
     */    
    public int deployAll(String sessionKey, List<Number> serverIds, Date date) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        List <Server> servers = new ArrayList<Server>(serverIds.size()); 
        for (Number sid : serverIds) {
            servers.add(helper.lookupServer(loggedInUser, sid));
        }
        ConfigurationManager manager = ConfigurationManager.getInstance();
        try {
            manager.deployConfiguration(loggedInUser, servers, date);
        }
        catch (MissingCapabilityException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingCapabilityException(
                e.getCapability(), e.getServer());
        }
        return 1;
    }
    
    /**
     * List all the global channels associated to a system 
     * in the order of their ranking. 
     * @param sessionKey User's session key.
     * @param sid a system id
     * @return a list of global config channels associated to the given 
     *          system in the order of their ranking..
     * 
     * @xmlrpc.doc List all global configuration channels associated to a 
     *              system in the order of their ranking.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #param("int","serverId") 
     * @xmlrpc.returntype
     *  #array()
     *  $ConfigChannelSerializer
     *  #array_end()
     */
    public List<ConfigChannel> listChannels(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        Server server = helper.lookupServer(loggedInUser, sid);
        return server.getConfigChannels();
    }
    
    /**
     * Given a list of servers and configuration channels, 
     * this method inserts the configuration channels to either the top or
     * the bottom (whichever you specify) of a system's subscribed 
     * configuration channels list. The ordering of the configuration channels
     * provided in the add list is maintained while adding.
     * If one of the configuration channels in the 'add' list 
     * has been previously subscribed by a server, the
     * subscribed channel will be re-ranked to the appropriate place.    
     * @param sessionKey the sessionkey needed for authentication 
     * @param serverIds a list of ids of servers to add the configuration channels to.
     * @param configChannelLabels set of configuration channels labels
     * @param addToTop if true inserts the configuration channels list to 
     *                  the top of the configuration channels list of a server 
     * @return 1 on success 0 on failure
     * 
     * @xmlrpc.doc Given a list of servers and configuration channels, 
     * this method appends the configuration channels to either the top or
     * the bottom (whichever you specify) of a system's subscribed 
     * configuration channels list. The ordering of the configuration channels
     * provided in the add list is maintained while adding.
     * If one of the configuration channels in the 'add' list 
     * has been previously subscribed by a server, the
     * subscribed channel will be re-ranked to the appropriate place.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #array_single("int",
     *              "IDs of the systems to add the channels to.")
     * @xmlrpc.param #array_single("string",
     *              "List of configuration channel labels in the ranked order.")
     * @xmlrpc.param #param("boolean","addToTop")
     *      #options()
     *          #item_desc ("true", "to prepend the given channels 
     *          list to the top of the configuration channels list of a server") 
     *              to the system's local override configuration channel")
     *          #item_desc ("false", "to append the given  channels 
     *          list to the bottom of the configuration channels list of a server")
     *      #options_end()
     *
     * @xmlrpc.returntype #return_int_success()
     */    
    public int addChannels(String sessionKey, List<Number> serverIds, 
                            List<String> configChannelLabels, boolean addToTop) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        List <Server> servers = helper.lookupServers(loggedInUser, serverIds);
        XmlRpcConfigChannelHelper configHelper = 
                            XmlRpcConfigChannelHelper.getInstance();
        List <ConfigChannel> channels = configHelper.
                             lookupGlobals(loggedInUser, configChannelLabels);
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        if (addToTop) {
            Collections.reverse(channels);  
        }
        
        for (Server server : servers) {
            for (ConfigChannel chan : channels) {
                if (addToTop) {
                    proc.add(server.getConfigChannels(), chan, 0);
                }
                else {
                    proc.add(server.getConfigChannels(), chan);
                }
            }
        }
        return 1;
    }
    
    /**
     * replaces the existing set of config channels for a given 
     * list of servers.
     * Note: it ranks these channels according to the array order of 
     * configChannelLabels method parameter
     * @param sessionKey the sessionkey needed for authentication 
     * @param serverIds a list of ids of servers to change the config files for..
     * @param configChannelLabels sets channels labels
     * @return 1 on success 0 on failure
     * 
     * @xmlrpc.doc Replace the existing set of config channels on the given servers.
     * Channels are ranked according to their order in the configChannelLabels
     * array. 
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #array_single("int",
     *              "IDs of the systems to set the channels on.")
     * @xmlrpc.param #array_single("string",
     *              "List of configuration channel labels in the ranked order.")
     *              
     * @xmlrpc.returntype #return_int_success()
     */
    public int setChannels(String sessionKey, List<Number> serverIds, 
                                        List<String> configChannelLabels) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        List <Server> servers = helper.lookupServers(loggedInUser, serverIds);
        XmlRpcConfigChannelHelper configHelper = 
                            XmlRpcConfigChannelHelper.getInstance();
        List <ConfigChannel> channels = configHelper.
                             lookupGlobals(loggedInUser, configChannelLabels);
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        for (Server server : servers) {
            proc.replace(server.getConfigChannels(), channels);
        }
        return 1;
    }
    
    /**
     * removes selected channels from list of config channels provided 
     * for a given list of servers.
     * @param sessionKey the sessionkey needed for authentication 
     * @param serverIds the list of server ids.
     * @param configChannelLabels sets channels labels
     * @return 1 on success 0 on failure
     * 
     * @xmlrpc.doc Remove config channels from the given servers.
     * @xmlrpc.param #session_key() 
     * @xmlrpc.param #array_single("int", "the IDs of the systems from which you 
     *              would like to remove configuration channels..")
     * @xmlrpc.param #array_single("string",
     *              "List of configuration channel labels to remove.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeChannels(String sessionKey, List<Number> serverIds, 
                            List<String> configChannelLabels) {
        User loggedInUser = getLoggedInUser(sessionKey);
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        List<Server> servers = helper.lookupServers(loggedInUser, serverIds);
        XmlRpcConfigChannelHelper configHelper = 
            XmlRpcConfigChannelHelper.getInstance();
        List <ConfigChannel> channels = configHelper.
             lookupGlobals(loggedInUser, configChannelLabels);
        ConfigChannelListProcessor proc = new ConfigChannelListProcessor();
        boolean success = true;
        for (Server server : servers) {
            success =  success && proc.remove(server.getConfigChannels(), channels);
        }
        if (success) {
            return 1;    
        }
        return 0;
        
    }    
}
