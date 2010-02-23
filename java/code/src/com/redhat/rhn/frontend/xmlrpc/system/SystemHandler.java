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
package com.redhat.rhn.frontend.xmlrpc.system;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.client.ClientCertificate;
import com.redhat.rhn.common.client.ClientCertificateDigester;
import com.redhat.rhn.common.client.InvalidCertificateException;
import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.common.validator.ValidatorResult;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.rhnpackage.PackageAction;
import com.redhat.rhn.domain.action.script.ScriptAction;
import com.redhat.rhn.domain.action.script.ScriptActionDetails;
import com.redhat.rhn.domain.action.script.ScriptResult;
import com.redhat.rhn.domain.action.script.ScriptRunAction;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSetMemoryAction;
import com.redhat.rhn.domain.action.virtualization.VirtualizationSetVcpusAction;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.NoBaseChannelFoundException;
import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.org.CustomDataKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.profile.DuplicateProfileNameException;
import com.redhat.rhn.domain.rhnpackage.profile.Profile;
import com.redhat.rhn.domain.rhnpackage.profile.ProfileFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.CPU;
import com.redhat.rhn.domain.server.CustomDataValue;
import com.redhat.rhn.domain.server.Dmi;
import com.redhat.rhn.domain.server.InstalledPackage;
import com.redhat.rhn.domain.server.Location;
import com.redhat.rhn.domain.server.ManagedServerGroup;
import com.redhat.rhn.domain.server.Note;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.ServerGroupFactory;
import com.redhat.rhn.domain.server.VirtualInstance;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.token.ActivationKeyFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ActivationKeyDto;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.ServerPath;
import com.redhat.rhn.frontend.dto.SystemOverview;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidActionTypeException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelListException;
import com.redhat.rhn.frontend.xmlrpc.InvalidEntitlementException;
import com.redhat.rhn.frontend.xmlrpc.InvalidErrataException;
import com.redhat.rhn.frontend.xmlrpc.InvalidPackageException;
import com.redhat.rhn.frontend.xmlrpc.InvalidProfileLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidSystemException;
import com.redhat.rhn.frontend.xmlrpc.MethodInvalidParamException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchActionException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchCobblerSystemRecordException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchPackageException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchSystemException;
import com.redhat.rhn.frontend.xmlrpc.NotEnoughEntitlementsException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.ProfileNameTooLongException;
import com.redhat.rhn.frontend.xmlrpc.ProfileNameTooShortException;
import com.redhat.rhn.frontend.xmlrpc.ProfileNoBaseChannelException;
import com.redhat.rhn.frontend.xmlrpc.RhnXmlRpcServer;
import com.redhat.rhn.frontend.xmlrpc.SystemIdInstantiationException;
import com.redhat.rhn.frontend.xmlrpc.SystemsNotDeletedException;
import com.redhat.rhn.frontend.xmlrpc.UndefinedCustomFieldsException;
import com.redhat.rhn.frontend.xmlrpc.UnrecognizedCountryException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;
import com.redhat.rhn.frontend.xmlrpc.user.XmlRpcUserHelper;
import com.redhat.rhn.manager.MissingCapabilityException;
import com.redhat.rhn.manager.MissingEntitlementException;
import com.redhat.rhn.manager.action.ActionManager;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.entitlement.EntitlementManager;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartScheduleCommand;
import com.redhat.rhn.manager.kickstart.ProvisionVirtualInstanceCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerSystemCreateCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;
import com.redhat.rhn.manager.profile.ProfileManager;
import com.redhat.rhn.manager.rhnpackage.PackageManager;
import com.redhat.rhn.manager.system.ServerGroupManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;
import com.redhat.rhn.manager.system.UpdateChildChannelsCommand;
import com.redhat.rhn.manager.system.VirtualizationActionCommand;
import com.redhat.rhn.manager.token.ActivationKeyManager;
import com.redhat.rhn.manager.user.UserManager;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.SystemRecord;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.StringReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Blob;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * SystemHandler
 * @version $Rev$
 * @xmlrpc.namespace system
 * @xmlrpc.doc Provides methods to access and modify registered system.
 */
public class SystemHandler extends BaseHandler {
    
    private static Logger log = Logger.getLogger(SystemHandler.class);
    
    /**
     * Get a reactivation key for this server.
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns the reactivation key string for the given server
     * @throws FaultException A FaultException is thrown if:
     *   - The server corresponding to the sid cannot be found
     *   - The server doesn't have the "agent smith" feature
     *
     * @xmlrpc.doc Obtains a reactivation key for this server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype string
     */
    public String obtainReactivationKey(String sessionKey, Integer sid) 
        throws FaultException {
        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        //check for agent smith feature... 
        if (!SystemManager.serverHasFeature(server.getId(), "ftr_agent_smith")) {
            throw new PermissionCheckFailureException();
        }

        // if there are any existing reactivation keys, remove them before 
        // creating a new one... there should only be 1; however, earlier
        // versions of the API did not remove the existing reactivation keys;
        // therefore, it is possible that multiple will be returned...
        List<ActivationKey> existingKeys = ActivationKeyFactory.lookupByServer(server);
        for (ActivationKey key : existingKeys) {
            ActivationKeyFactory.removeKey(key);
        }
        
        String note = "Reactivation key for " + server.getName() + ".";
        ActivationKey key = ActivationKeyManager.getInstance().
                    createNewReActivationKey(loggedInUser, server, note);

        key.setUsageLimit(new Long(1));

        // Return the "key" for this activation key :-/
        return key.getKey();
    }
    
    /**
     * Adds an entitlement to a given server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @param entitlementLevel The entitlement to add to the server
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The server corresponding to the sid cannot be found
     *   - The logged in user cannot access the system
     *   - The entitlement cannot be found
     *   - The server cannot be entitled with the given entitlement
     *   - There are no available slots for the entitlement.
     *
     * @xmlrpc.doc Adds an entitlement to a given server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "entitlementName", "One of:  
     *          'enterprise_entitled', 'provisioning_entitled', 'monitoring_entitled',  
     *          'nonlinux_entitled', 'virtualization_host', or 
     *          'virtualization_host_platform'.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int upgradeEntitlement(String sessionKey, Integer sid, String entitlementLevel)
        throws FaultException {
        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        Entitlement entitlement = EntitlementManager.getByName(entitlementLevel);
        
        // Make sure we got a valid entitlement and the server can be entitled to it
        if (entitlement == null) {
            throw new InvalidEntitlementException();
        }
        if (!SystemManager.canEntitleServer(server, entitlement)) {
            throw new PermissionCheckFailureException();
        }
        
        long availableSlots = ServerGroupFactory
                .lookupEntitled(entitlement, loggedInUser.getOrg()).getAvailableSlots();
        if (availableSlots < 1) {
            throw new NotEnoughEntitlementsException();
        }
        
        SystemManager.entitleServer(server, entitlement);
        
        return 1;
    }
    
    /**
     * Subscribe the given server to the child channels provided.  This
     * method will unsubscribe the server from any child channels that the server
     * is currently subscribed to, but that are not included in the list.  The user may
     * provide either a list of channel ids (int) or a list of channel labels (string) as
     * input.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @param channelIdsOrLabels The list of channel ids or labels this server should
     * be subscribed to.
     * @return Returns 1 if successful, exception otherwise.
     * @throws FaultException A FaultException is thrown if: 
     *   - the server corresponding to sid cannot be found.
     *   - the channel corresponding to cid is not a valid child channel.
     *   - the user doesn't have subscribe access to any one of the current or 
     *     new child channels.
     *
     * @xmlrpc.doc Subscribe the given server to the child channels provided.  This
     * method will unsubscribe the server from any child channels that the server
     * is currently subscribed to, but that are not included in the list.  The user may
     * provide either a list of channel ids (int) or a list of channel labels (string) as
     * input.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int (deprecated) or string", "channelId (deprecated)
     * or channelLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setChildChannels(String sessionKey, Integer sid, List channelIdsOrLabels)
        throws FaultException {

        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);

        // Determine if user passed in a list of channel ids or labels... note: the list
        // must contain all ids or labels (i.e. not a combination of both)
        boolean receivedLabels = false;
        if (channelIdsOrLabels.size() > 0) {
            if (channelIdsOrLabels.get(0) instanceof String) {
                receivedLabels = true;
            }

            // check to make sure that the objects are all the same type
            for (Object object : channelIdsOrLabels) {
                if (receivedLabels) {
                    if (!(object instanceof String)) {
                        throw new InvalidChannelListException();
                    }
                }
                else {
                    if (!(object instanceof Integer)) {
                        throw new InvalidChannelListException();
                    }
                }
            }
        }

        List<Long> channelIds = new ArrayList<Long>();
        if (receivedLabels) {
            channelIds = ChannelFactory.getChannelIds(channelIdsOrLabels);

            // if we weren't able to retrieve channel ids for all labels provided,
            // one or more of the labels must be invalid...
            if (channelIds.size() != channelIdsOrLabels.size()) {
                throw new InvalidChannelLabelException();
            }
        }
        else {
            // unfortunately, the interface only allows Integer input (not Long);
            // therefore, convert the input to Long, since channel ids are
            // internally represented as Long
            for (Object channelId : channelIdsOrLabels) {
                channelIds.add(new Long((Integer) channelId));
            }
        }

        UpdateChildChannelsCommand cmd = new UpdateChildChannelsCommand(loggedInUser, 
                server, channelIds);
        cmd.store();

        return 1;
    }
    
    /**
     * Sets the base channel for the given server to the given channel
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the server
     * @param cid The id for the channel
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if: 
     *   - the server corresponding to sid cannot be found.
     *   - the channel corresponding to cid is not a base channel.
     *   - the user doesn't have subscribe access to either the current or 
     *     the new base channel.
     * @deprecated being replaced by system.setBaseChannel(string sessionKey,
     * int serverId, string channelLabel)
     *     
     * @xmlrpc.doc Assigns the server to a new baseChannel.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("int", "channelId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setBaseChannel(String sessionKey, Integer sid, Integer cid) 
        throws FaultException {
        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        UpdateBaseChannelCommand cmd = 
            new UpdateBaseChannelCommand(loggedInUser, server, new Long(cid.longValue()));
        cmd.store();
        return 1;
    }
    
    /**
     * Sets the base channel for the given server to the given channel
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the server
     * @param channelLabel The id for the channel
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - the server corresponding to sid cannot be found.
     *   - the channel corresponding to cid is not a base channel.
     *   - the user doesn't have subscribe access to either the current or
     *     the new base channel.
     *
     * @xmlrpc.doc Assigns the server to a new base channel.  If the user provides an empty
     * string for the channelLabel, the current base channel and all child channels will
     * be removed from the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setBaseChannel(String sessionKey, Integer sid, String channelLabel)
        throws FaultException {

        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);

        UpdateBaseChannelCommand cmd = null;
        if (StringUtils.isEmpty(channelLabel)) {
            // if user provides an empty string for the channel label, they are requesting
            // to remove the base channel
            cmd = new UpdateBaseChannelCommand(loggedInUser, server, new Long(-1));
        }
        else {
            List<String> channelLabels = new ArrayList<String>();
            channelLabels.add(channelLabel);

            List<Long> channelIds = new ArrayList<Long>();
            channelIds = ChannelFactory.getChannelIds(channelLabels);

            if (channelIds.size() > 0) {
                cmd = new UpdateBaseChannelCommand(loggedInUser, server, channelIds.get(0));
            }
            else {
                throw new InvalidChannelLabelException();
            }
        }
        cmd.store();
        return 1;
    }

    /**
     * Gets a list of base channels subscribable by the logged in user for the server with 
     * the given id.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns an array of maps representing the base channels the logged in user
     * can subscribe this system to.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * @deprecated being replaced by listSubscribableBaseChannels(string sessionKey,
     * int serverId)
     * 
     * @xmlrpc.doc Returns a list of subscribable base channels.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * 
     * @xmlrpc.returntype
     *  #array()
     *      #struct("channel")
     *          #prop_desc("int" "id" "Base Channel ID.")
     *          #prop_desc("string" "name" "Name of channel.")
     *          #prop_desc("string" "label" "Label of Channel")
     *          #prop_desc("int", "current_base", "1 indicates it is the current base 
     *                                      channel")
     *      #struct_end()
     *  #array_end()
     * 
     */
    public Object[] listBaseChannels(String sessionKey, Integer sid) throws FaultException {

        return listSubscribableBaseChannels(sessionKey, sid);
    }

    /**
     * Gets a list of base channels subscribable by the logged in user for the server with
     * the given id.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns an array of maps representing the base channels the logged in user
     * can subscribe this system to.
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     *
     * @xmlrpc.doc Returns a list of subscribable base channels.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     *
     * @xmlrpc.returntype
     *  #array()
     *      #struct("channel")
     *          #prop_desc("int" "id" "Base Channel ID.")
     *          #prop_desc("string" "name" "Name of channel.")
     *          #prop_desc("string" "label" "Label of Channel")
     *          #prop_desc("int", "current_base", "1 indicates it is the current base
     *                                      channel")
     *      #struct_end()
     *  #array_end()
     *
     */
    public Object[] listSubscribableBaseChannels(String sessionKey, Integer sid)
        throws FaultException {

        //Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid); 
        Channel baseChannel = server.getBaseChannel();
        List returnList = new ArrayList();
        
        if (baseChannel != null) {
            //Add the current base channel to the list
            Map base = new HashMap();
            
            base.put("id", baseChannel.getId());
            base.put("name", baseChannel.getName());
            base.put("label", baseChannel.getLabel());
            base.put("current_base", new Integer(1));
            returnList.add(base);
        }
        
        DataResult dr = ChannelManager.userSubscribableBaseChannelsForSystem(loggedInUser, 
                                                                             server);
        //Loop through the results and put into returnList. This is because we have to 
        //set the CURRENT_BASE field.
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map map = (Map) itr.next();
            if (baseChannel != null && 
                baseChannel.getId().intValue() == ((Long) map.get("id")).intValue()) {
                continue; //we've already added the base channel
            }
            
            returnList.add(createChannelMap(map));
        }
    
        return returnList.toArray();
    }

    /**
     * Gets a list of all systems visible to user
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns an array of maps representing all systems visible to user
     *
     * @throws FaultException A FaultException is thrown if a valid user can not be found
     * from the passed in session key
     *
     * @xmlrpc.doc Returns a list of all servers visible to the user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype
     *      #array()
     *          $SystemOverviewSerializer
     *      #array_end()
     */
    public Object[] listSystems(String sessionKey) throws FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
        DataResult<SystemOverview> dr = SystemManager.systemListShort(loggedInUser, null);
        dr.elaborate();
        return dr.toArray();
    }

    /**
     * Gets a list of all active systems visible to user 
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns an array of maps representing all active systems visible to user
     * 
     * @throws FaultException A FaultException is thrown if a valid user can not be found
     * from the passed in session key
     * 
     * @xmlrpc.doc Returns a list of active servers visible to the user. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype 
     *      #array()
     *          $SystemOverviewSerializer
     *      #array_end()
     */
    public Object[] listActiveSystems(String sessionKey) throws FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
        DataResult<SystemOverview> dr = SystemManager.systemList(loggedInUser, null);
        dr.elaborate();
        List<SystemOverview> returnList = new ArrayList();
 
        for (SystemOverview so : dr) {
            if (isSystemInactive(so)) {
                continue;
            }
            returnList.add(so);
        }
        return returnList.toArray();
    }
    
    
    
    private Map createChannelMap(Map map) {
        Map ret = new HashMap();
        
        ret.put("ID", map.get("id"));
        ret.put("NAME", map.get("name"));
        ret.put("LABEL", map.get("label"));
        ret.put("CURRENT_BASE", new Integer(0));
        
        ret.put("id", map.get("id"));
        ret.put("name", map.get("name"));
        ret.put("label", map.get("label"));
        ret.put("current_base", new Integer(0));
        return ret;
    }
    
    /**
     * List the child channels that this system can subscribe to.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the channels this server could 
     * subscribe too.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * @deprecated being replaced by listSubscribableChildChannels(string sessionKey,
     * int serverId)
     *
     * @xmlrpc.doc Returns a list of subscribable child channels.  This only shows channels
     * the system is *not* currently subscribed to.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *          #struct("child channel")
     *              #prop("int", "id")
     *              #prop("string", "name")
     *              #prop("string", "label")
     *              #prop("string", "summary")
     *              #prop("string", "has_license")
     *              #prop("string", "gpg_key_url")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listChildChannels(String sessionKey, Integer sid) 
            throws FaultException {

        return listSubscribableChildChannels(sessionKey, sid);
    }

    /**
     * List the child channels that this system can subscribe to.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the channels this server could
     * subscribe too.
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     *
     * @xmlrpc.doc Returns a list of subscribable child channels.  This only shows channels
     * the system is *not* currently subscribed to.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("child channel")
     *              #prop("int", "id")
     *              #prop("string", "name")
     *              #prop("string", "label")
     *              #prop("string", "summary")
     *              #prop("string", "has_license")
     *              #prop("string", "gpg_key_url")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listSubscribableChildChannels(String sessionKey, Integer sid)
            throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid); 
        Channel baseChannel = server.getBaseChannel();
        List returnList = new ArrayList();
        
        //make sure channel is not null
        if (baseChannel == null) {
            //return empty array since we can't have any child channels without a base
            return returnList.toArray();
        }
        
        DataResult dr = SystemManager.subscribableChannels(server.getId(), 
                            loggedInUser.getId(), baseChannel.getId());
        
        //TODO: This should go away once we teach marquee how to deal with nulls in a list.
        //      Luckily, this list shouldn't be too long.
        for (Iterator itr = dr.iterator(); itr.hasNext();) {
            Map row = (Map) itr.next();
            Map channel = new HashMap();
            
            channel.put("id", row.get("id"));
            channel.put("label", row.get("label"));
            channel.put("name", row.get("name"));
            channel.put("summary", row.get("summary"));
            channel.put("has_license", StringUtils.defaultString(
                                           (String) row.get("has_license")));
            channel.put("gpg_key_url", StringUtils.defaultString(
                                           (String) row.get("gpg_key_url")));            
            
            returnList.add(channel);
        }
        
        return returnList.toArray();
    }

    /**
     * Given a package name + version + release + epoch, returns the list of
     * packages installed on the system w/ the same name that are older. 
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system you're checking
     * @param name The name of the package you're checking
     * @param version The version of the package
     * @param release The release of the package
     * @param epoch The epoch of the package
     * @return Returns a list of packages installed on the system with the same
     * name that     * are older.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found or if no package with the given name is found.
     * 
     * @xmlrpc.doc Given a package name, version, release, and epoch, returns
     * the list of packages installed on the system with the same name that are
     * older. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "name", "Package name.")
     * @xmlrpc.param #param_desc("string", "version", "Package version.")
     * @xmlrpc.param #param_desc("string", "release", "Package release.")
     * @xmlrpc.param #param_desc("string", "epoch",  "Package epoch.")
     * @xmlrpc.returntype 
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listOlderInstalledPackages(String sessionKey, Integer sid,
                        String name, String version, String release, String epoch) 
                        throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid); 

        List toCheck = packagesToCheck(server, name);
        
        List returnList = new ArrayList();
        /*
         * Loop through the packages to check and compare the evr parts to what was
         * passed in from the user. If the package is older, add it to returnList.
         */
        for (Iterator itr = toCheck.iterator(); itr.hasNext();) {
            Map pkg = (Map) itr.next();

            String pkgName    = (String) pkg.get("name");
            String pkgVersion = (String) pkg.get("version");
            String pkgRelease = (String) pkg.get("release");
            String pkgEpoch   = (String) pkg.get("epoch");
            
            int c = PackageManager.verCmp(pkgEpoch, pkgVersion, pkgRelease,
                                          epoch, version, release);
            if (0 > c) {
                returnList.add(fillOutPackage(pkgName, pkgVersion, pkgRelease, pkgEpoch));
            }
        }
        
        return returnList.toArray();
    }
    
    /**
     * Given a package name + version + release + epoch, returns the list of
     * packages installed on the system w/ the same name that are newer. 
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system you're checking
     * @param name The name of the package you're checking
     * @param version The version of the package
     * @param release The release of the package
     * @param epoch The epoch of the package
     * @return Returns a list of packages installed onNAME the system with the same
     * name that are newer.
     * @throws FaultException A FaultException is thrown if the server
     * corresponding to sid cannot be found or if no package with the given name
     * is found.
     * 
     * @xmlrpc.doc Given a package name, version, release, and epoch, returns the
     * list of packages installed on the system w/ the same name that are newer. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "name", "Package name.")
     * @xmlrpc.param #param_desc("string", "version", "Package version.")
     * @xmlrpc.param #param_desc("string", "release", "Package release.")
     * @xmlrpc.param #param_desc("string", "epoch",  "Package epoch.")
     * @xmlrpc.returntype 
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listNewerInstalledPackages(String sessionKey, Integer sid, 
                        String name, String version, String release, String epoch) 
                        throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        List toCheck = packagesToCheck(server, name);
        List returnList = new ArrayList();
        /*
         * Loop through the packages to check and compare the evr parts to what was
         * passed in from the user. If the package is newer, add it to returnList.
         */
        for (Iterator itr = toCheck.iterator(); itr.hasNext();) {
            Map pkg = (Map) itr.next();
            String pkgName    = (String) pkg.get("name");
            String pkgVersion = (String) pkg.get("version");
            String pkgRelease = (String) pkg.get("release");
            String pkgEpoch   = (String) pkg.get("epoch");
            
            int c = PackageManager.verCmp(pkgEpoch, pkgVersion, pkgRelease,
                                          epoch, version, release);
            if (0 < c) {
                returnList.add(fillOutPackage(pkgName, pkgVersion, pkgRelease, pkgEpoch));
            }
        }
        
        return returnList.toArray();
    }
    
    /**
     * Private helper method to retrieve a list of packages by package name
     * @param server The server the packages are installed on
     * @param name The name of the package
     * @return Returns a list of packages with the given name installed on the give server
     * @throws NoSuchPackageException A no such package exception is thrown when no packages
     * with the given name are installed on the server.
     */
    private List packagesToCheck(Server server, String name) throws NoSuchPackageException {
        DataResult installed = SystemManager.installedPackages(server.getId());
        
        List toCheck = new ArrayList();
        // Get a list of packages with matching name
        for (Iterator itr = installed.iterator(); itr.hasNext();) {
            Map pkg = (Map) itr.next();
            String pkgName = StringUtils.trim((String) pkg.get("name"));
            if (pkgName.equals(StringUtils.trim(name))) {
                toCheck.add(pkg);
            }
        }
        
        if (toCheck.isEmpty()) {
            throw new NoSuchPackageException();
        }
        
        return toCheck;
    }
    
    /**
     * Private helper method to fillout a map representing a package
     * @param pkgName The name of the package
     * @param pkgVersion The version of the package
     * @param pkgRelease The release of the package
     * @param pkgEpoch The epoch of the package
     * @return Returns a map representing a package
     */
    private Map fillOutPackage(String pkgName, String pkgVersion, String pkgRelease, 
                               String pkgEpoch) {
        Map map = new HashMap();
        map.put("name", StringUtils.defaultString(pkgName));
        map.put("version", StringUtils.defaultString(pkgVersion));
        map.put("release", StringUtils.defaultString(pkgRelease));
        map.put("epoch", StringUtils.defaultString(pkgEpoch));
        return map;
    }
    
    /**
     * Is the package with the given NVRE installed on given system
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The sid for the server in question
     * @param name The name of the package
     * @param version The version of the package
     * @param release The release of the package
     * @return Returns 1 if package is installed, 0 if not.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Check if the package with the given NVRE is installed on given system. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "name", "Package name.") 
     * @xmlrpc.param #param_desc("string", "version","Package version.")
     * @xmlrpc.param #param_desc("string", "release", "Package release.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int isNvreInstalled(String sessionKey, Integer sid, String name,
                       String version, String release) throws FaultException {
        //Set epoch to an empty string
        return isNvreInstalled(sessionKey, sid, name, version, release, null);
    }
    
    /**
     * Is the package with the given NVRE installed on given system
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The sid for the server in question
     * @param name The name of the package
     * @param version The version of the package
     * @param release The release of the package
     * @param epoch The epoch of the package
     * @return Returns 1 if package is installed, 0 if not.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Is the package with the given NVRE installed on given system. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "name", "Package name.")
     * @xmlrpc.param #param_desc("string", "version", "Package version.")
     * @xmlrpc.param #param_desc("string", "release", "Package release.")
     * @xmlrpc.param #param_desc("string", "epoch",  "Package epoch.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int isNvreInstalled(String sessionKey, Integer sid, String name, 
                       String version, String release, String epoch) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        DataResult packages = SystemManager.installedPackages(server.getId());
        
        /*
         * Loop through the packages for this system and check each attribute. Use 
         * StringUtils.trim() to disregard whitespace on either ends of the string.
         */
        for (Iterator itr = packages.iterator(); itr.hasNext();) {
            Map pkg = (Map) itr.next();

            //Check name
            String pkgName = StringUtils.trim((String) pkg.get("name"));
            if (!pkgName.equals(StringUtils.trim(name))) {
                continue;
            }
            
            //Check version
            String pkgVersion = StringUtils.trim((String) pkg.get("version"));
            if (!pkgVersion.equals(StringUtils.trim(version))) {
                continue;
            }
            
            //Check release
            String pkgRelease = StringUtils.trim((String) pkg.get("release"));
            if (!pkgRelease.equals(StringUtils.trim(release))) {
                continue;
            }
            
            //Check epoch
            String pkgEpoch = StringUtils.trim((String) pkg.get("epoch"));
            // If epoch is null, we arrived here from the isNvreInstalled(...n,v,r) method;
            // therefore, just skip the comparison
            if ((epoch != null) && !pkgEpoch.equals(StringUtils.trim(epoch))) {
                continue;
            }
            
            // If we get here, NVRE matches so return true
            return 1;
        }

        //package not installed
        return 0;
    }
    
    /**
     * Get the list of latest upgradable packages for a given system
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the system in question
     * @return Returns an array of maps representing the latest upgradable packages
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Get the list of latest upgradable packages for a given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #struct("package")
     *          #prop("string", "name")
     *          #prop("string", "from_version")
     *          #prop("string", "from_release")
     *          #prop("string", "from_epoch")
     *          #prop("string", "to_version")
     *          #prop("string", "to_release")
     *          #prop("string", "to_epoch")
     *          #prop("string", "to_package_id")
     *      #struct_end()
     */
    public Object[] listLatestUpgradablePackages(String sessionKey, Integer sid) 
                        throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        DataResult dr = SystemManager.latestUpgradablePackages(server.getId());
        
        return dr.toArray();
    }
    
    /**
     * Get the list of latest installable packages for a given system.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the system in question
     * @return Returns an array of maps representing the latest installable packages
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Get the list of latest installable packages for a given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #struct("package")
     *          #prop("string", "name")
     *          #prop("string", "version")
     *          #prop("string", "release")
     *          #prop("string", "epoch")
     *          #prop("int", "id")
     *          #prop("string", "arch_label")
     *      #struct_end()
     */
    public Object[] listLatestInstallablePackages(String sessionKey, Integer sid)
                        throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        DataResult dr = SystemManager.latestInstallablePackages(server.getId());
        
        return dr.toArray();
    }
    
    /**
     * Gets the entitlements for a given server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the system in question
     * @return Returns an array of entitlement labels for the system
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Gets the entitlements for a given server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype #array_single("string", "entitlement_label")
     */
    public Object[] getEntitlements(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        // A list of entitlements to return
        List entitlements = new ArrayList();
        
        // Loop through the entitlement objects for this server and stick
        // label into the entitlements list to return
        for (Iterator itr = server.getEntitlements().iterator(); itr.hasNext();) {
            Entitlement entitlement = (Entitlement) itr.next();
            entitlements.add(entitlement.getLabel());
        }
        
        return entitlements.toArray();
    }
    
    /**
     * Get the system_id file for a given server
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns the system_id file for the server
     * @throws FaultException A FaultException is thrown if the server
     * corresponding to sid cannot be found or if the system_id file cannot
     * be generated.
     * 
     * @xmlrpc.doc Get the system ID file for a given server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype string 
     */
    public String downloadSystemId(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        // Try to generate the cert. 
        try {
            ClientCertificate cert = SystemManager.createClientCertificate(server);
            return cert.asXml();
        }
        catch (InstantiationException e) {
            // Convert to fault exception
            throw new SystemIdInstantiationException();
        }
    }
    
    /**
     * List the installed packages for a given system.
     * @xmlrpc.doc List the installed packages for a given system. The attribute
     * installtime is returned since API version 10.10.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the packages installed on a system
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc List the installed packages for a given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *          #struct("package")
     *                 #prop("string", "name")
     *                 #prop("string", "version")
     *                 #prop("string", "release")
     *                 #prop("string", "epoch")
     *                 #prop("string", "arch")
     *                 #prop("string", "installtime")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listPackages(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        DataResult dr = SystemManager.installedPackages(server.getId());
        return dr.toArray();
    }
    
    /**
     * Delete systems given a list of system ids
     * @param sessionKey The sessionKey containing the logged in user
     * @param systemIds A list of systems ids to delete
     * @return Returns the number of systems deleted if successful, fault exception 
     * containing ids of systems not deleted otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Delete systems given a list of system ids.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #array_single("int", "serverId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteSystems(String sessionKey, List systemIds) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        
        // Keep track of the number of systems deleted and the number that were skipped.
        int numDeleted = 0;
        List skippedSids = new ArrayList();
        
        // Loop through the sids and try to delete the server
        for (Iterator sysIter = systemIds.iterator(); sysIter.hasNext();) {
            Integer sidAsInt = (Integer) sysIter.next();
            Long sid = new Long(sidAsInt.longValue());
            try {
                SystemManager.deleteServer(loggedInUser, sid);
                numDeleted++;
            }
            catch (Exception e) {
                System.out.println("Exception: " + e);
                e.printStackTrace();
                skippedSids.add(sidAsInt);
            }
        }
        
        // If we skipped any systems, create an error message and throw a FaultException
        if (skippedSids.size() > 0) {
            StringBuffer msg = new StringBuffer("The following systems were NOT deleted: ");
            for (Iterator itr = skippedSids.iterator(); itr.hasNext();) {
                Integer sid = (Integer) itr.next();
                msg.append("\n" + sid);
            }
            throw new SystemsNotDeletedException(msg.toString());
        }
        
        // Else return the number of systems that were deleted.
        return numDeleted;
    }
    
    /**
     * Get the IP and hostname for a given server
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns a map containing the servers IP and hostname attributes
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Get the IP address and hostname for a given server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          #struct("network info")
     *              #prop_desc("string", "ip", "IP address of server")
     *              #prop_desc("string", "hostname", "Hostname of server")
     *          #struct_end()
     */
    public Map getNetwork(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);

        // Get the ip and hostname for the server
        String ip = server.getIpAddress();
        String hostname = server.getHostname();
        
        // Stick in a map and return
        Map network = new HashMap();
        network.put("ip", StringUtils.defaultString(ip));
        network.put("hostname", StringUtils.defaultString(hostname));
        
        return network;
    }
    
    /**
     * Get a list of network devices for a given server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns an array of maps representing a network device for the server. 
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     * 
     * @xmlrpc.doc Returns the network devices for the given server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *          $NetworkInterfaceSerializer
     *      #array_end()
     */
    public List getNetworkDevices(String sessionKey, Integer sid) 
        throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        Set devices = server.getNetworkInterfaces();
        return new ArrayList(devices);
    }
    
    /**
     * Set a servers membership in a given group
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @param sgid The id of the server group
     * @param member Should this server be a member of this group?
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Set a servers membership in a given group.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("int", "serverGroupId")
     * @xmlrpc.param #param_desc("boolean", "member",  "'1' to assign the given server to 
     * the given server group, '0' to remove the given server from the given server 
     * group.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setGroupMembership(String sessionKey, Integer sid, Integer sgid, 
                                  boolean member) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureSystemGroupAdmin(loggedInUser);
        Server server = lookupServer(loggedInUser, sid);
        ServerGroupManager manager = ServerGroupManager.getInstance();
        try {
            ManagedServerGroup group = manager.lookup(new Long(sgid.longValue()),
                    loggedInUser);

    
             List servers = new ArrayList(1);
             servers.add(server);
    
             if (member) {
             //add to server group
             manager.addServers(group, servers, loggedInUser);
             }
             else {
             //remove from server group
             manager.removeServers(group, servers, loggedInUser);
             }
        }
        catch (LookupException le) {
            throw new PermissionCheckFailureException(le);
        }
        
        return 1;
    }
    
    /**
     * List the available groups for a given system
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the server in question
     * @return Returns an array of maps representing a system group
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc List the available groups for a given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype array
     *      #struct("system group")
     *          #prop_desc("int", "id", "server group id")
     *          #prop_desc("int", "subscribed", "1 if the given server is subscribed
     *               to this server group, 0 otherwise")
     *          #prop_desc("string", "system_group_name", "Name of the server group")
     *          #prop_desc("string", "sgid", "server group id (Deprecated)")
     *      #struct_end()
     */
    public Object[] listGroups(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        DataResult groups = SystemManager.availableSystemGroups(server, loggedInUser);
        List returnList = new ArrayList();
        
                
        // More stupid data munging...
        for (Iterator itr = groups.iterator(); itr.hasNext();) {
            Map map = (Map) itr.next();
            Map row = new HashMap();
            
            row.put("id", map.get("id"));
            row.put("sgid", map.get("id").toString());
            row.put("system_group_name",
                    StringUtils.defaultString((String) map.get("group_name")));
            row.put("subscribed", map.get("is_system_member"));
            returnList.add(row);
        }
        
        return returnList.toArray();
    }
    
    /**
     * List systems for a given user
     * @param sessionKey The sessionKey containing the logged in user
     * @param login The login for the target user
     * @return Returns an array of maps representing a system
     * @throws FaultException A FaultException is thrown if the user doesn't have access
     * to lookup the user corresponding to login or if the user does not exist.
     * 
     * @xmlrpc.doc List systems for a given user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "login", "User's login name.")
     * @xmlrpc.returntype 
     *          #array()
     *              $SystemOverviewSerializer
     *          #array_end()
     */
    public List listUserSystems(String sessionKey, String login) throws FaultException {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        return SystemManager.systemListShort(target, null);
    }
    
    /**
     * List systems for the logged in user
     * @param sessionKey The sessionKey containing the logged in user
     * @return Returns an array of maps representing a system
     * 
     * @xmlrpc.doc List systems for the logged in user.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype 
     *          #array()
     *              $SystemOverviewSerializer
     *          #array_end()
     */
    public List listUserSystems(String sessionKey) {
        // Get the logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        return SystemManager.systemListShort(loggedInUser, null);
    }
    
    /**
     * Private helper method to get a list of systems for a particular user
     *   The query used is very inefficient.  Only use it when you need a lot
     *   of information about the systems.
     * @param user The user to lookup
     * @return An array of SystemOverview objects representing a system
     */
    private List<SystemOverview> getUserSystemsList(User user) {
        return  UserManager.visibleSystemsAsDto(user); 
    }
    
    /**
     * Set custom values for the specified server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @param values A map containing the new set of custom data values for this server
     * @return Returns a 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Set custom values for the specified server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param 
     *    #struct("Map of custom labels to custom values")
     *      #prop("string", "custom info label")
     *      #prop("string", "value")
     *    #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setCustomValues(String sessionKey, Integer sid, Map values) 
            throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        Org org = loggedInUser.getOrg();
        List skippedKeys = new ArrayList();
        
        /*
         * Loop through the map the user sent us. Check to make sure that the org has the
         * corresponding custom data key. If so, update the value, if not, add the key to 
         * the skippedKeys list so we can throw a fault exception later and tell the user
         * which keys were skipped.
         */
        Set keys = values.keySet();
        for (Iterator itr = keys.iterator(); itr.hasNext();) {
            String label = (String) itr.next();
            if (org.hasCustomDataKey(label)) {
                server.addCustomDataValue(label, values.get(label).toString(), 
                        loggedInUser);
            }
            else {
                // Add label to skippedKeys list
                skippedKeys.add(label);
            }
        }

        // If we skipped any keys, we need to throw an exception and let the user know.
        if (skippedKeys.size() > 0) {
            // We need to throw an exception. Append each undefined key to the 
            // exception message.
            StringBuffer msg = new StringBuffer("One or more of the following " +
                                                "custom info fields was not defined: ");

            for (Iterator itr = skippedKeys.iterator(); itr.hasNext();) {
                String label = (String) itr.next();
                msg.append("\n" + label);
            }
            
            throw new UndefinedCustomFieldsException(msg.toString());
        }

        return 1;
    }

    /**
     * Get the custom data values defined for the server
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @return Returns a map containing the defined custom data values for the given server.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found or if the name is invalid.
     * 
     * @xmlrpc.doc Get the custom data values defined for the server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #struct("custom value")
     *          #prop("string", "custom info label")
     *      #struct_end()
     */
    public Map getCustomValues(String sessionKey, Integer sid) throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        Set customDataValues = server.getCustomDataValues();
        Map returnMap = new HashMap();
        
        /*
         * Loop through the customDataValues set for the server. We're only interested in
         * the key and value information from the CustomDataValue object.
         */
        for (Iterator itr = customDataValues.iterator(); itr.hasNext();) {
            CustomDataValue val = (CustomDataValue) itr.next();
            if (val.getValue() != null) {
                returnMap.put(val.getKey().getLabel(), val.getValue());
            }
            else {
                returnMap.put(val.getKey().getLabel(), new String(""));
            }
        }
        
        return returnMap;
    }

    /**
     * Delete the custom values defined for the custom system information keys
     * provided from the given system.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server in question
     * @param keys A list of custom data labels/keys to delete from the server
     * @return Returns a 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     *
     * @xmlrpc.doc Delete the custom values defined for the custom system information keys
     * provided from the given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param  #array_single("string", "customInfoLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteCustomValues(String sessionKey, Integer sid, List<String> keys)
            throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        Org org = loggedInUser.getOrg();
        List<String> skippedKeys = new ArrayList<String>();

        /*
         * Loop through the list the user sent us. Check to make sure that the org has the
         * corresponding custom data key. If so, remove the value, if not, add the key to
         * the skippedKeys list so we can throw a fault exception later and tell the user
         * which keys were skipped.
         */
        for (String label : keys) {
            CustomDataKey key = OrgFactory.lookupKeyByLabelAndOrg(label,
                loggedInUser.getOrg());

            // Does the custom data key exist?
            if (key == null || key.getLabel() == null) {
                // Add label to skippedKeys list
                skippedKeys.add(label);
            }
            else {
                ServerFactory.removeCustomDataValue(server, key);
            }
        }

        // If we skipped any keys, we need to throw an exception and let the user know.
        if (skippedKeys.size() > 0) {
            // We need to throw an exception. Append each undefined key to the
            // exception message.
            StringBuffer msg = new StringBuffer("One or more of the following " +
                                                "custom info fields was not defined: ");

            for (String label : skippedKeys) {
                msg.append("\n" + label);
            }
            throw new UndefinedCustomFieldsException(msg.toString());
        }
        return 1;
    }

    /**
     * Set the profile name for the server
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the server in question 
     * @param name The new profile name for the server
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found or if the name is invalid.
     * 
     * @xmlrpc.doc Set the profile name for the server. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "name", "Name of the profile.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setProfileName(String sessionKey, Integer sid, String name) 
            throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        //Do some validation on the name string
        name = StringUtils.trim(name); //trim the whitespace
        validateProfileName(name);
        server.setName(name);
        SystemManager.storeServer(server);
        
        return 1;
    }
    
    
    private void validateProfileName(String name) throws FaultException {
        if (name == null || name.length() < 2) { //too short
            throw new ProfileNameTooShortException();
        }
        
        if (name.length() > 128) { //too long
            throw new ProfileNameTooLongException();
        }        
    }
    
    /**
     * Add a new note to the given server
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the server to add the note to
     * @param subject The subject of the note
     * @param body The body for the note
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Add a new note to the given server. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "subject", "What the note is about.")
     * @xmlrpc.param #param_desc("string", "body", "Content of the note.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addNote(String sessionKey, Integer sid, String subject, String body) 
            throws FaultException {
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        server.addNote(loggedInUser, subject, body);
        SystemManager.storeServer(server);
        
        return 1;
    }

    /**
     * Deletes the given note from the server.
     * 
     * @param sessionKey identifies the logged in user
     * @param sid        identifies the server on which the note resides
     * @param nid        identifies the note to delete         
     * @return 1 if successful, exception otherwise
     * @throws NoSuchSystemException A NoSuchSystemException is thrown if the server
     * corresponding to sid cannot be found.
     * 
     * @xmlrpc.doc Deletes the given note from the server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("int", "noteId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteNote(String sessionKey, Integer sid, Integer nid) {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (sid == null) {
            throw new IllegalArgumentException("sid cannot be null");
        }

        if (nid == null) {
            throw new IllegalArgumentException("nid cannot be null");
        }
                
        User loggedInUser = getLoggedInUser(sessionKey);

        SystemManager.deleteNote(loggedInUser, sid.longValue(), nid.longValue());

        return 1;
    }
    
    /**
     * Deletes all notes from the server.
     * 
     * @param sessionKey identifies the logged in user
     * @param sid        identifies the server on which the note resides
     * @return 1 if successful, exception otherwise
     * @throws NoSuchSystemException A NoSuchSystemException is thrown if the server
     * corresponding to sid cannot be found.
     * 
     * @xmlrpc.doc Deletes all notes from the server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteNotes(String sessionKey, Integer sid) {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (sid == null) {
            throw new IllegalArgumentException("sid cannot be null");
        }
        
        User loggedInUser = getLoggedInUser(sessionKey);

        SystemManager.deleteNotes(loggedInUser, sid.longValue());
        
        return 1;
    }
    
    /**
     * List Events for a given server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the server you are wanting to lookup 
     * @return Returns an array of maps representing a system
     * @since 10.8
     * 
     * @xmlrpc.doc List all system events for given server. This includes *all* events
     * for the server since it was registered.  This may require the caller to
     * filter the results to fetch the specific events they are looking for.
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of system.
     * @xmlrpc.returntype 
     *  #array()
     *      #struct("action")
     *          #prop_desc("int", "failed_count", "Number of times action failed.")
     *          #prop_desc("string", "modified", "Date modified. (Deprecated by
     *                     modified_date)")
     *          #prop_desc($date, "modified_date", "Date modified.")
     *          #prop_desc("string", "created", "Date created. (Deprecated by
     *                     created_date)")
     *          #prop_desc($date, "created_date", "Date created.")
     *          #prop("string", "action_type")
     *          #prop_desc("int", "successful_count",
     *                     "Number of times action was successful.")
     *          #prop_desc("string", "earliest_action", "Earliest date this action
     *                     will occur.")
     *          #prop_desc("int", "archived", "If this action is archived. (1 or 0)")
     *          #prop("string", "scheduler_user")
     *          #prop_desc("string", "prerequisite", "Pre-requisite action. (optional)")
     *          #prop_desc("string", "name", "Name of this action.")
     *          #prop_desc("int", "id", "Id of this action.")
     *          #prop_desc("string", "version", "Version of action.")
     *          #prop_desc("string", "completion_time", "The date/time the event was
     *                     completed. Format ->YYYY-MM-dd hh:mm:ss.ms
     *                     Eg ->2007-06-04 13:58:13.0. (optional)
     *                     (Deprecated by completed_date)")
     *          #prop_desc($date, "completed_date", "The date/time the event was completed.
     *                     (optional)")
     *          #prop_desc("string", "pickup_time", "The date/time the action was picked
     *                     up. Format ->YYYY-MM-dd hh:mm:ss.ms
     *                     Eg ->2007-06-04 13:58:13.0. (optional)
     *                     (Deprecated by pickup_date)")
     *          #prop_desc($date, "pickup_date", "The date/time the action was picked up.
     *                     (optional)")
     *          #prop_desc("string", "result_msg", "The result string after the action
     *                     executes at the client machine. (optional)")
     *          #prop_array_begin_desc("additional_info", "This array contains additional
     *              information for the event, if available.")
     *              #struct("info")
     *                  #prop_desc("string", "detail", "The detail provided depends on the
     *                  specific event.  For example, for a package event, this will be the
     *                  package name, for an errata event, this will be the advisory name
     *                  and synopsis, for a config file event, this will be path and
     *                  optional revision information...etc.")
     *                  #prop_desc("string", "result", "The result (if included) depends
     *                  on the specific event.  For example, for a package or errata event,
     *                  no result is included, for a config file event, the result might
     *                  include an error (if one occurred, such as the file was missing)
     *                  or in the case of a config file comparison it might include the
     *                  differenes found.")
     *              #struct_end()
     *          #prop_array_end()
     *      #struct_end()
     *  #array_end()
     */
    public List listSystemEvents(String sessionKey, Integer sid) {

        List retval = new LinkedList();
        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        
        List<ServerAction> sActions = ActionFactory.listServerActionsForServer(server);

        // In order to support bug 501224, this method is being updated to populate
        // the result vs having the serializer do so.  The reason is that in order to
        // support this bug, we want to be able to return some additional detail for the
        // various events in the system history; however, those details are stored in
        // different database tables depending upon the event type.  This includes
        // information like, the specific errata applied, pkgs installed/removed/
        // upgraded/verified, config files uploaded, deployed or compared...etc.

        List<Map> results = new ArrayList<Map>();
        for (ServerAction sAction : sActions) {

            Map result = new HashMap();

            Action action = sAction.getParentAction();

            if (action.getFailedCount() != null) {
                result.put("failed_count", action.getFailedCount());
            }
            if (action.getActionType().getName() != null) {
                result.put("action_type", action.getActionType().getName());
            }
            if (action.getSuccessfulCount() != null) {
                result.put("successful_count", action.getSuccessfulCount());
            }
            if (action.getEarliestAction() != null) {
                result.put("earliest_action", action.getEarliestAction().toString());
            }
            if (action.getArchived() != null) {
                result.put("archived", action.getArchived());
            }
            if (action.getSchedulerUser().getLogin() != null) {
                result.put("scheduler_user", action.getSchedulerUser().getLogin());
            }
            if (action.getPrerequisite() != null) {
                result.put("prerequisite", action.getPrerequisite());
            }
            if (action.getName() != null) {
                result.put("name", action.getName());
            }
            if (action.getId() != null) {
                result.put("id", action.getId());
            }
            if (action.getVersion() != null) {
                result.put("version", action.getVersion().toString());
            }

            if (sAction.getCompletionTime() != null) {
                result.put("completion_time", sAction.getCompletionTime().toString());
            }
            if (sAction.getPickupTime() != null) {
                result.put("pickup_time", sAction.getPickupTime().toString());
            }
            if (sAction.getModified() != null) {
                result.put("modified", sAction.getModified().toString());
                result.put("modified_date", sAction.getModified());
            }
            if (sAction.getCreated() != null) {
                result.put("created", sAction.getCreated().toString());
                result.put("created_date", sAction.getCreated());
            }
            if (sAction.getCompletionTime() != null) {
                result.put("completed_date", sAction.getCompletionTime());
            }
            if (sAction.getPickupTime() != null) {
                result.put("pickup_date", sAction.getPickupTime());
            }
            if (sAction.getResultMsg() != null) {
                result.put("result_msg", sAction.getResultMsg());
            }

            // depending on the event type, we need to retrieve additional information
            // and store that information in the result
            ActionType type = action.getActionType();
            List<Map<String, String>> additionalInfo = new ArrayList<Map<String, String>>();

            if (type.equals(ActionFactory.TYPE_PACKAGES_REMOVE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_UPDATE) ||
                type.equals(ActionFactory.TYPE_PACKAGES_VERIFY)) {

                // retrieve the list of package names associated with the action...

                DataResult pkgs = ActionManager.getPackageList(action.getId(), null);
                for (Iterator itr = pkgs.iterator(); itr.hasNext();) {
                    Map pkg = (Map) itr.next();
                    String detail = (String) pkg.get("nvre");

                    Map<String, String> info = new HashMap<String, String>();
                    info.put("detail", detail);
                    additionalInfo.add(info);
                }
            }
            else if (type.equals(ActionFactory.TYPE_ERRATA)) {

                // retrieve the errata that were associated with the action...
                DataResult errata = ActionManager.getErrataList(action.getId());
                for (Iterator itr = errata.iterator(); itr.hasNext();) {
                    Map erratum = (Map) itr.next();
                    String detail = (String) erratum.get("advisory");
                    detail += " (" + (String) erratum.get("synopsis") + ")";

                    Map<String, String> info = new HashMap<String, String>();
                    info.put("detail", detail);
                    additionalInfo.add(info);
                }
            }
            else if (type.equals(ActionFactory.TYPE_CONFIGFILES_UPLOAD) ||
                     type.equals(ActionFactory.TYPE_CONFIGFILES_MTIME_UPLOAD)) {

                // retrieve the details associated with the action...
                DataResult files = ActionManager.getConfigFileUploadList(action.getId());
                for (Iterator itr = files.iterator(); itr.hasNext();) {
                    Map file = (Map) itr.next();

                    Map<String, String> info = new HashMap<String, String>();
                    info.put("detail", (String) file.get("path"));
                    String error = (String) file.get("failure_reason");
                    if (error != null) {
                        info.put("result", error);
                    }
                    additionalInfo.add(info);
                }
            }
            else if (type.equals(ActionFactory.TYPE_CONFIGFILES_DEPLOY)) {

                // retrieve the details associated with the action...
                DataResult files = ActionManager.getConfigFileDeployList(action.getId());
                for (Iterator itr = files.iterator(); itr.hasNext();) {
                    Map file = (Map) itr.next();

                    Map<String, String> info = new HashMap<String, String>();
                    String path = (String) file.get("path");
                    path += " (rev. " + (Long) file.get("revision") + ")";
                    info.put("detail", path);
                    String error = (String) file.get("failure_reason");
                    if (error != null) {
                        info.put("result", error);
                    }
                    additionalInfo.add(info);
                }
            }
            else if (type.equals(ActionFactory.TYPE_CONFIGFILES_DIFF)) {

                // retrieve the details associated with the action...
                DataResult files = ActionManager.getConfigFileDiffList(action.getId());
                for (Iterator itr = files.iterator(); itr.hasNext();) {
                    Map file = (Map) itr.next();

                    Map<String, String> info = new HashMap<String, String>();
                    String path = (String) file.get("path");
                    path += " (rev. " + (Long) file.get("revision") + ")";
                    info.put("detail", path);

                    String error = (String) file.get("failure_reason");
                    if (error != null) {
                        info.put("result", error);
                    }
                    else {
                        // if there wasn't an error, check to see if there was a difference
                        // detected...
                        Blob blob = (Blob) file.get("diff");
                        if (blob != null) {
                            String diff = HibernateFactory.blobToString(blob);
                            info.put("result", diff);
                        }
                    }
                    additionalInfo.add(info);
                }
            }
            if (additionalInfo.size() > 0) {
                result.put("additional_info", additionalInfo);
            }
            results.add(result);
        }
        return results;
    }

    /**
     * 
     * Provision a guest on the server specified.  Defaults to: memory=256MB, vcpu=1, 
     * storage=2048MB.
     * 
     * @param sessionKey of user making call
     * @param sid of server to provision guest on
     * @param guestName to assign to guest
     * @param profileName of Kickstart Profile to use.
     * @return Returns 1 if successful, exception otherwise
     * 
     * @xmlrpc.doc Provision a guest on the host specified.  Defaults to: 
     * memory=256MB, vcpu=1, storage=2048MB.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of host to provision guest on.
     * @xmlrpc.param #param("string", "guestName") 
     * @xmlrpc.param #param_desc("string", "profileName", "Kickstart profile to use.")  
     * @xmlrpc.returntype #return_int_success()
     */
    public int provisionVirtualGuest(String sessionKey, Integer sid, String guestName, 
            String profileName) {
        return provisionVirtualGuest(sessionKey, sid, guestName, profileName, 
                new Integer(256), new Integer(1), new Integer(2048));
    }

    /**
     * Provision a system using the specified kickstart profile. 
     * 
     * @param sessionKey of user making call
     * @param serverId of the system to be provisioned
     * @param profileName of Kickstart Profile to be used.
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * id cannot be found or kickstart profile is not found.
     * 
     * @xmlrpc.doc Provision a system using the specified kickstart profile. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of the system to be provisioned.
     * @xmlrpc.param #param_desc("string", "profileName", "Kickstart profile to use.")  
     * @xmlrpc.returntype int - ID of the action scheduled, otherwise exception thrown 
     * on error
     */
    public int provisionSystem(String sessionKey, Integer serverId, String profileName) 
        throws FaultException {
        log.debug("provisionSystem called.");
        User loggedInUser = getLoggedInUser(sessionKey);

        // Lookup the server so we can validate it exists and throw error if not.
        Server server = lookupServer(loggedInUser, serverId);
        if (!(server.hasEntitlement(EntitlementManager.PROVISIONING))) {
            throw new FaultException(-2, "provisionError", 
                    "System does not have provisioning entitlement");
        }
        
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(profileName,
                                               loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                             "No Kickstart Profile found with label: " + profileName);
        }

        String host = RhnXmlRpcServer.getServerName();
        

        KickstartScheduleCommand cmd = new KickstartScheduleCommand(
                             Long.valueOf(serverId),
                             ksdata.getId(), loggedInUser, new Date(), host);
        ValidatorError ve = cmd.store();
        if (ve != null) {
            throw new FaultException(-2, "provisionError",
                             LocalizationService.getInstance().getMessage(ve.getKey()));
        }
        return cmd.getScheduledAction().getId().intValue();
    }

    /**
     * Provision a system using the specified kickstart profile at specified time. 
     * 
     * @param sessionKey of user making call
     * @param serverId of the system to be provisioned
     * @param profileName of Kickstart Profile to be used.
     * @param earliestDate when the kickstart needs to be scheduled
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * id cannot be found or kickstart profile is not found.
     * 
     * @xmlrpc.doc Provision a system using the specified kickstart profile. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of the system to be provisioned.
     * @xmlrpc.param #param_desc("string", "profileName", "Kickstart profile to use.")
     * @xmlrpc.param #param("dateTime.iso8601", "earliestDate") 
     * @xmlrpc.returntype int - ID of the action scheduled, otherwise exception thrown 
     * on error
     */
    public int provisionSystem(String sessionKey, Integer serverId, 
            String profileName, Date earliestDate) 
        throws FaultException {
        log.debug("provisionSystem called.");
        User loggedInUser = getLoggedInUser(sessionKey);

        // Lookup the server so we can validate it exists and throw error if not.
        Server server = lookupServer(loggedInUser, serverId);
        if (!(server.hasEntitlement(EntitlementManager.PROVISIONING))) {
            throw new FaultException(-2, "provisionError", 
                    "System does not have provisioning entitlement");
        }
        
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(profileName,
                                               loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                             "No Kickstart Profile found with label: " + profileName);
        }

        String host = RhnXmlRpcServer.getServerName();
                
        KickstartScheduleCommand cmd = new KickstartScheduleCommand(
                             Long.valueOf(serverId),
                             ksdata.getId(), loggedInUser, earliestDate, host);
        ValidatorError ve = cmd.store();
        if (ve != null) {
            throw new FaultException(-2, "provisionError",
                             LocalizationService.getInstance().getMessage(ve.getKey()));
        }
        return cmd.getScheduledAction().getId().intValue();
    }


        
    
    /**
     * Provision a guest on the server specified.
     * 
     * @param sessionKey of user making call
     * @param sid of server to provision guest on
     * @param guestName to assign to guest
     * @param profileName of Kickstart Profile to use.
     * @param memoryMb to allocate to the guest (maxMemory)
     * @param vcpus to assign
     * @param storageMb to assign to disk
     * @return Returns 1 if successful, exception otherwise 
     * 
     * @xmlrpc.doc Provision a guest on the host specified.  This schedules the guest
     * for creation and will begin the provisioning process when the host checks in 
     * or if OSAD is enabled will begin immediately.
     *   
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of host to provision guest on.
     * @xmlrpc.param #param("string", "guestName") 
     * @xmlrpc.param #param_desc("string", "profileName", "Kickstart Profile to use.")
     * @xmlrpc.param #param_desc("int", "memoryMb", "Memory to allocate to the guest")
     * @xmlrpc.param #param_desc("int", "vcpus", "Number of virtual CPUs to allocate to 
     *                                          the guest.")
     * @xmlrpc.param #param_desc("int", "storageMb", "Size of the guests disk image.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int provisionVirtualGuest(String sessionKey, Integer sid, String guestName, 
            String profileName, Integer memoryMb, Integer vcpus, Integer storageMb) {
        log.debug("provisionVirtualGuest called.");
        User loggedInUser = getLoggedInUser(sessionKey);
        // Lookup the server so we can validate it exists and throw error if not.
        lookupServer(loggedInUser, sid);
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(profileName, loggedInUser.getOrg().getId());
        
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound", 
                    "No Kickstart Profile found with label: " + profileName);
        }
        
        String url = ksdata.getCommand("url").getArguments();
        if (url == null) {
            throw new FaultException(-1, "kickstartUrlNoHost",
                "Kickstart profile requires a --url param.");
        }
        log.debug("url: " + url);
        String[] split = StringUtils.split(url);
        if (split.length < 2) {
            throw new FaultException(-1, "kickstartUrlNoHost",
                "Kickstart --url requires a host.  Needs to be of the format: " +
                "--url http://host.domain.com/rhn/kickstart/ks-rhel-i386-server-5");
        }
        try {
            URI uri = new URI(split[1]);
            // Convert to host
            url = uri.getHost();
            log.debug("host: " + url);
        }
        catch (URISyntaxException e) {
            throw new FaultException(-1, "kickstartUrlNoHost",
                    "Kickstart --url requires a host.  Needs to be of the format: " +
                    "--url http://host.domain.com/rhn/kickstart/ks-rhel-i386-server-5");
        }
        
        ProvisionVirtualInstanceCommand cmd = new ProvisionVirtualInstanceCommand(
                new Long(sid.longValue()), 
                ksdata.getId(), loggedInUser, new Date(), url); 
        
        cmd.setGuestName(guestName);
        cmd.setMemoryAllocation(new Long(memoryMb));
        cmd.setVirtualCpus(new Long(vcpus.toString()));
        cmd.setLocalStorageSize(new Long(storageMb));

        // Store the new KickstartSession to the DB.
        ValidatorError ve = cmd.store();
        if (ve != null) {
            throw new FaultException(-2, "provisionError", 
                    LocalizationService.getInstance().getMessage(ve.getKey()));
        }

        return 1;
    }
    
    
    /**
     * Private helper method to lookup a server from an sid, and throws a FaultException
     * if the server cannot be found.
     * @param user The user looking up the server
     * @param sid The id of the server we're looking for
     * @return Returns the server corresponding to sid
     * @throws NoSuchSystemException A NoSuchSystemException is thrown if the server 
     * corresponding to sid cannot be found.
     */
    private Server lookupServer(User user, Integer sid) throws NoSuchSystemException {
        return XmlRpcSystemHelper.getInstance().lookupServer(user, sid);
    }
    
    
    /**
     * Private helper method to determine if a server is inactive.
     * @param so SystemOverview object representing system to inspect.
     * @return Returns true if system is inactive, false if system is active.
     */
    private boolean isSystemInactive(SystemOverview so) {
        Long threshold = new Long(Config.get().getInt(
                ConfigDefaults.SYSTEM_CHECKIN_THRESHOLD, 1));
        if (so.getLastCheckinDaysAgo().compareTo(threshold) == 1) {
            return true;
        }
        return false;
    }
    
    /**
     * Get system IDs and last check in information for the given system name.
     * @param sessionKey of user making call
     * @param name of the server
     * @return Object[]  Integer Array containing system Ids with the given name
     * 
     * @xmlrpc.doc Get system IDs and last check in information for the given system name.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "systemName") 
     * @xmlrpc.returntype 
     *          #array()
     *              $SystemOverviewSerializer
     *          #array_end()
     */
    public List<SystemOverview> getId(String sessionKey, String name) {

        User loggedInUser = getLoggedInUser(sessionKey);
        List<SystemOverview> dr = UserManager.visibleSystemsAsDto(loggedInUser);
        List returnList = new ArrayList();
 
        for (SystemOverview system : dr) {
            if (system.getName().equals(name)) {
                returnList.add(system);
            }                                             
        }
        return returnList;
    }

    /**
     * Get system name and last check in information for the given system ID.
     * @param sessionKey of user making call
     * @param serverId of the server
     * @return Object[]  Integer Array containing system Ids with the given name
     * 
     * @xmlrpc.doc Get system name and last check in information for the given system ID.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "serverId") 
     * @xmlrpc.returntype 
     *     $SystemOverviewSerializer
     */
    public SystemOverview getName(String sessionKey, Integer serverId) {

        User loggedInUser = getLoggedInUser(sessionKey);
        List<SystemOverview> dr = UserManager.visibleSystemsAsDto(loggedInUser);
        SystemOverview result = new SystemOverview();
 
        for (SystemOverview system : dr) {
            if (system.getId().equals(new Long(serverId))) {
                result = system;
                // we can stop searching since server ids are unique
                break;
            }
        }
        return result;
    }

    /**
     * Provides the Date that the system was registered 
     * @param sessionKey of user making call
     * @param sid  the ServerId of the system
     * @return Date the date the system was registered
     * 
     * @xmlrpc.doc Returns the date the system was registered.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") 
     * @xmlrpc.returntype dateTime.iso8601 - The date the system was registered, 
     * in local time.
     */
    public Date getRegistrationDate(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);  
        Server server = lookupServer(loggedInUser, sid);   
        return server.getCreated();
    }
    

    /**
     * List the child channels that this system is subscribed to.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the channels this server is 
     * subscribed too.
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Returns a list of subscribed child channels. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype   
     *      #array()
     *          $ChannelSerializer
     *      #array_end()
     */
    public List<Channel> listSubscribedChildChannels(String sessionKey, Integer sid) { 
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        Set childChannels = server.getChildChannels();              
        
        if (childChannels == null) {
            return new ArrayList();
        }
                
        return new ArrayList(childChannels);
    }
    
    
    /**
     * Searching the system names using the regular expression
     *   passed in
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @param regexp regular expression to search with.  See the api for the
     *  Patter object for java specific regular expression details 
     * @return an array of Integers containing the system Ids
     * 
     * @xmlrpc.doc Returns a list of system IDs whose name matches
     *  the supplied regular expression.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "regexp",  "A regular expression. (as defined by 
     *   <a href=\"http://java.sun.com/j2se/1.4.2/docs/api/java/util/regex/Pattern.html\">
     *      http://java.sun.com/j2se/1.4.2/docs/api/java/util/regex/Pattern.html </a>) ")
     * @xmlrpc.returntype      
     *           #array()
     *              $SystemOverviewSerializer
     *          #array_end()
     * 
     */
    public List searchByName(String sessionKey, String regexp) {
        User loggedInUser = getLoggedInUser(sessionKey);
        List<SystemOverview>  systems =  getUserSystemsList(loggedInUser);
        List returnList = new ArrayList();

        Pattern pattern = Pattern.compile(regexp, Pattern.CASE_INSENSITIVE);
        
        for (SystemOverview system : systems) {
            Matcher match = pattern.matcher((String)system.getName());
            if (match.find()) {
                returnList.add(system);
            }
        }
        return returnList;
    }
    
    /**
     * Lists the administrators of a given system.  This includes Org Admins as well
     *      as system group users of groups that the system is in.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the users that can 
     *              administer the system
     * @throws FaultException A FaultException is thrown if the server corresponding to 
     * sid cannot be found.
     * 
     * @xmlrpc.doc Returns a list of users which can administer the system. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *              $UserSerializer
     *      #array_end()
     */
    public Object[] listAdministrators(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);      
        Server server = lookupServer(loggedInUser, sid); 
        return ServerFactory.listAdministrators(server).toArray(); 
    }
    
    /**
     * Returns the running kernel of the given system.
     * 
     * @param sessionKey The current user's session key
     * @param sid Server ID to lookup.
     * @return Running kernel string.
     * 
     * @xmlrpc.doc Returns the running kernel of the given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype string
     */
    public String getRunningKernel(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        try {
            Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                    loggedInUser);
            if (server.getRunningKernel() != null) {
                return server.getRunningKernel();
            }
            else {
                return LocalizationService.getInstance().getMessage(
                        "server.runningkernel.unknown");
            }
        }
        catch (LookupException e) {
            throw new NoSuchSystemException(e);
        }
    }

    /**
     * Lists the server history of a system.  Ordered from oldest to newest.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question 
     * @return Returns an array of maps representing the server history items
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     * 
     * @xmlrpc.doc Returns a list history items associated with the system, ordered
     *             from newest to oldest. Note that the details may be empty for
     *             events that were scheduled against the system (as compared to instant).
     *             For more information on such events, see the system.listSystemEvents
     *             operation.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *           $HistoryEventSerializer
     *      #array_end()
     */
    public Object[] getEventHistory(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        List history = ServerFactory.getServerHistory(server);
        return history.toArray();
    }
    
    /**
     * Returns a list of all errata that are relevant to the system.
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the errata that can be applied
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     * 
     * @xmlrpc.doc Returns a list of all errata that are relevant to the system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */
    public Object[] getRelevantErrata(String sessionKey, Integer sid) {

        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid); 
        DataResult dr = SystemManager.relevantErrata(loggedInUser, server.getId());
        return dr.toArray();
    }
    
    /**
     * Returns a list of all errata of the specified type that are relevant to the system. 
     * @param sessionKey key
     * @param serverId serverId
     * @param advisoryType The type of advisory (one of the following:
     * "Security Advisory", "Product Enhancement Advisory",
     * "Bug Fix Advisory")
     * @return Returns an array of maps representing errata relevant to the system.
     * 
     * @throws FaultException A FaultException is thrown if a valid user can not be found
     * from the passed in session key or if the server corresponding to the serverId
     * cannot be found.
     * 
     * @xmlrpc.doc Returns a list of all errata of the specified type that are
     * relevant to the system. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("string", "advisoryType", "type of advisory (one of
     * of the following: 'Security Advisory', 'Product Enhancement Advisory',
     * 'Bug Fix Advisory'")
     * @xmlrpc.returntype 
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */
    public Object[] getRelevantErrataByType(String sessionKey, Integer serverId, 
            String advisoryType) throws FaultException {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, serverId);

        DataResult<ErrataOverview> dr = SystemManager.relevantErrataByType(loggedInUser, 
                server.getId(), advisoryType);

        return dr.toArray();
    }

    /**
     * Lists all the relevant unscheduled errata for a system.
     * 
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the errata that can be applied
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     * 
     * @xmlrpc.doc Provides an array of errata that are applicable to a given system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      #array()
     *          $ErrataSerializer
     *      #array_end()       
     */
    public Errata[] getUnscheduledErrata(String sessionKey, Integer sid) {

        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid); 
        DataResult<Errata> dr = SystemManager.unscheduledErrata(loggedInUser,
                server.getId(), null);
        dr.elaborate();
        return (Errata [])dr.toArray(new Errata []{});
    }
    
    /**
     * Schedules an action to apply errata updates to a system.
     * @param sessionKey The user's session key.
     * @param sid ID of the server
     * @param errataIds List of errata IDs to apply (as Integers)
     * @return 1 if successful, exception thrown otherwise
     * @deprecated being replaced by system.scheduleApplyErrata(string sessionKey,
     * int serverId, array[int errataId])
     *
     * @xmlrpc.doc Schedules an action to apply errata updates to a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param  #array_single("int", "errataId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int applyErrata(String sessionKey, Integer sid, List errataIds) {
        scheduleApplyErrata(sessionKey, sid, errataIds);
        return 1;
    }

    /**
     * Schedules an action to apply errata updates to a system.
     * @param sessionKey The user's session key.
     * @param sid ID of the server
     * @param errataIds List of errata IDs to apply (as Integers)
     * @return 1 if successful, exception thrown otherwise
     * @since 10.6
     *
     * @xmlrpc.doc Schedules an action to apply errata updates to a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param  #array_single("int", "errataId")
     * @xmlrpc.returntype #return_int_success()
     */
    public int scheduleApplyErrata(String sessionKey, Integer sid, List errataIds) {
        applyErrataHelper(sessionKey, sid, errataIds, null);
        return 1;
    }
    
    /**
     * Schedules an action to apply errata updates to a system at a specified time.
     * @param sessionKey The user's session key.
     * @param sid ID of the server
     * @param errataIds List of errata IDs to apply (as Integers)
     * @param earliestOccurrence Earliest occurrence of the errata update
     * @return 1 if successful, exception thrown otherwise
     *
     * @xmlrpc.doc Schedules an action to apply errata updates to a system at a
     * given date/time.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "errataId")
     * @xmlrpc.param dateTime.iso8601 earliestOccurrence
     * @xmlrpc.returntype #return_int_success()
     */
    public int scheduleApplyErrata(String sessionKey, Integer sid, List errataIds, 
            Date earliestOccurrence) {
        applyErrataHelper(sessionKey, sid, errataIds, earliestOccurrence);
        return 1;
    }
    
    /**
     * Apply errata updates to a system at a specified time.
     * @param sessionKey The user's session key.
     * @param sid ID of the server
     * @param errataIds List of errata IDs to apply (as Integers)
     * @param earliestOccurrence Earliest occurrence of the errata update
     */
    private void applyErrataHelper(String sessionKey, Integer sid, List errataIds, 
            Date earliestOccurrence) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        
        // Check to make sure the given errata are applicable to and unscheduled for the 
        // system in question. This catches three scenarios, errata that don't apply to
        // this system, are already scheduled, or don't exist in the first place.
        // TODO: fail silently in some of these cases?
        Set unscheduledErrataIds = new HashSet();
        List unscheduledErrata = SystemManager.unscheduledErrata(loggedInUser, 
                server.getId(), null);
        for (Iterator it = unscheduledErrata.iterator(); it.hasNext();) {
            Errata e = (Errata)it.next();
            unscheduledErrataIds.add(new Integer(e.getId().intValue()));
        }
        for (Iterator it = errataIds.iterator(); it.hasNext();) {
            Integer currentId = (Integer)it.next();
            if (!unscheduledErrataIds.contains(currentId)) {
                throw new InvalidErrataException();
            }
        }
        
        for (Iterator it = errataIds.iterator(); it.hasNext();) {
            Integer currentId = (Integer)it.next();
            Errata errata = ErrataManager.lookupErrata(new Long(currentId.longValue()), 
                    loggedInUser);
            Action update = ActionManager.createErrataAction(loggedInUser, errata);
            if (earliestOccurrence != null) {
                update.setEarliestAction(earliestOccurrence);
            }
            ActionManager.addServerToAction(server.getId(), update);
            ActionManager.storeAction(update);
        }
    }
    
    /**
     * Compares the packages installed on two systems.
     * 
     * @param sessionKey User's session key
     * @param sid1 This system's ID
     * @param sid2 Other system's ID
     * @return Array of PackageMetadata
     * 
     * @xmlrpc.doc Compares the packages installed on two systems.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "thisServerId")
     * @xmlrpc.param #param("int", "otherServerId")
     * @xmlrpc.returntype 
     *          #array()
     *              $PackageMetadataSerializer
     *          #array_end()                  
     * 
     */
    public Object [] comparePackages(String sessionKey, Integer sid1, Integer sid2) {
        User loggedInUser = getLoggedInUser(sessionKey);

        Server target = null;
        Server source = null;
        try {
            target = SystemManager.lookupByIdAndUser(new Long(sid1.longValue()), 
                    loggedInUser);
            source = SystemManager.lookupByIdAndUser(new Long(sid2.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        // Check that the two systems are compatible for comparison:
        if (!isCompatible(loggedInUser, target, source)) {
            throw new InvalidSystemException();
        }
        
        DataResult result = null;
        try {
            result = ProfileManager.compareServerToServer(
                    new Long(sid1.longValue()), 
                    new Long(sid2.longValue()), loggedInUser.getOrg().getId(), null);
        }
        catch (MissingEntitlementException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException();
        }
        return result.toArray();
    }

    /**
     * Gets the hardware profile of a specific system
     * 
     * @param sessionKey User's session key
     * @param sid This system's ID
     * @return Map contianing the DMI information of the system
     * 
     * @xmlrpc.doc Gets the DMI information of a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *      $DmiSerializer
     */
    public Object getDmi(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);      
        Server server = lookupServer(loggedInUser, sid); 
        Dmi dmi = server.getDmi();
        return dmi;
    }
    
    /**
     * Gets the hardware profile of a specific system
     * 
     * @param sessionKey User's session key
     * @param sid This system's ID
     * @return Map contianing the CPU info of the system
     * 
     * @xmlrpc.doc Gets the CPU information of a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *      $CpuSerializer 
     */
    public Object getCpu(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);      
        Server server = lookupServer(loggedInUser, sid); 
        CPU cpu = server.getCpu();
        return cpu;
    }
    
    /**
     * Gets the memory information of a specific system
     * 
     * @param sessionKey User's session key
     * @param sid This system's ID
     * @return Map contianing the memory profile
     * 
     * @xmlrpc.doc Gets the memory information for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *  #struct("memory")
     *      #prop_desc("int", "ram", "The amount of physical memory in MB.")
     *      #prop_desc("int", "swap", "The amount of swap space in MB.")
     *  #struct_end()
     */
    public Map getMemory(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);      
        Server server = lookupServer(loggedInUser, sid); 
        Map memory = new HashMap();
        memory.put("swap", new Long(server.getSwap()));
        memory.put("ram", new Long(server.getRam()));
        return memory;
    }
    
    
    /**
     * Provides an array of devices for a system
     * 
     * @param sessionKey User's session key
     * @param sid This system's ID
     * @return array continaing device Maps
     * 
     * @xmlrpc.doc Gets a list of devices for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          #array()
     *              $DeviceSerializer
 *              #array_end()
     */
    public Object[] getDevices(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);      
        Server server = lookupServer(loggedInUser, sid); 
        Set devices = server.getDevices();
        return devices.toArray();
    }
    
    /**
     * Schedule package installation for a system.
     * 
     * @param sessionKey The user's session key
     * @param sid ID of the server
     * @param packageIds List of package IDs to install (as Integers)
     * @param earliestOccurrence Earliest occurrence of the package install
     * @return 1 if successful, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule package installation for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param dateTime.iso8601 earliestOccurrence
     * @xmlrpc.returntype #return_int_success()
     */
    public int schedulePackageInstall(String sessionKey, Integer sid, List packageIds, 
            Date earliestOccurrence) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);

        // Would be nice to do this check at the Manager layer but upset many tests,
        // some of which were not cooperative when being fixed. Placing here for now.
        if (!SystemManager.hasEntitlement(server.getId(), EntitlementManager.MANAGEMENT)) {
            throw new MissingEntitlementException(
                    EntitlementManager.MANAGEMENT.getHumanReadableLabel());
        }

        // Build a list of maps in the format the ActionManager wants:
        List packageMaps = new LinkedList();
        for (Iterator it = packageIds.iterator(); it.hasNext();) {
            Integer pkgId = (Integer)it.next();
            Map pkgMap = new HashMap();
            
            Package p = PackageManager.lookupByIdAndUser(new Long(pkgId.longValue()), 
                    loggedInUser);
            if (p == null) {
                throw new InvalidPackageException(pkgId.toString());
            }
            
            pkgMap.put("name_id", p.getPackageName().getId());
            pkgMap.put("evr_id", p.getPackageEvr().getId());
            pkgMap.put("arch_id", p.getPackageArch().getId());
            packageMaps.add(pkgMap);
        }
        
        try {
            ActionManager.schedulePackageInstall(loggedInUser, server, packageMaps, 
                    earliestOccurrence);
        }
        catch (MissingEntitlementException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException();
        }
        
        return 1;
    }
    
    /**
     * Schedule package removal for a system.
     * 
     * @param sessionKey The user's session key
     * @param sid ID of the server
     * @param packageIds List of package IDs to remove (as Integers)
     * @param earliestOccurrence Earliest occurrence of the package install
     * @return 1 if successful, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule package removal for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("int", "packageId")
     * @xmlrpc.param dateTime.iso8601 earliestOccurrence
     * @xmlrpc.returntype int - ID of the action scheduled, otherwise exception thrown 
     * on error
     */
    public int schedulePackageRemove(String sessionKey, Integer sid, List packageIds, 
            Date earliestOccurrence) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);

        // Would be nice to do this check at the Manager layer but upset many tests,
        // some of which were not cooperative when being fixed. Placing here for now.
        if (!SystemManager.hasEntitlement(server.getId(), EntitlementManager.MANAGEMENT)) {
            throw new MissingEntitlementException(
                    EntitlementManager.MANAGEMENT.getHumanReadableLabel());
        }

        // Build a list of maps in the format the ActionManager wants:
        List packageMaps = new LinkedList();
        for (Iterator it = packageIds.iterator(); it.hasNext();) {
            Integer pkgId = (Integer)it.next();
            Map pkgMap = new HashMap();
            
            Package p = PackageManager.lookupByIdAndUser(new Long(pkgId.longValue()), 
                    loggedInUser);
            if (p == null) {
                throw new InvalidPackageException(pkgId.toString());
            }
            
            pkgMap.put("name_id", p.getPackageName().getId());
            pkgMap.put("evr_id", p.getPackageEvr().getId());
            pkgMap.put("arch_id", p.getPackageArch().getId());
            packageMaps.add(pkgMap);
        }
        
        PackageAction action = null;
        try {
            action = ActionManager.schedulePackageRemoval(loggedInUser, server,
                    packageMaps, earliestOccurrence);
        }
        catch (MissingEntitlementException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException();
        }
        
        return action.getId().intValue();
    }

    /**
     * Lists all of the notes that are associated with a system.
     *   If no notes are found it should return an empty set.  
     * @param sessionKey the session key 
     * @param sid the system id 
     * @return Array of Note objects associated with the given system
     * 
     * @xmlrpc.doc Provides a list of notes associated with a system.      
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *  #array()
     *      $NoteSerializer
     *  #array_end()
     */
    public Set<Note> listNotes(String sessionKey , Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
            loggedInUser);
        return server.getNotes();
    }
    
    
    /**
     * Lists all of the packages that are installed on a system that also belong
     *  to a particular channel.  NOTE: when the arch for an installed package is 
     *  unavailable we do not take it into concern, meaning that it is arch unaware. 
     *  This is usually the case for RHEL 4 or older.  RHEL 5 started uploading 
     *  arch information, so that information is taken into account when matching 
     *  packages.
     * @param sessionKey the session key
     * @param sid the system Id
     * @param channelLabel the channel label 
     * @return Array of Package objects representing the intersection of the channel
     *          packages and the system's installed packages
     * 
     *     
     * @xmlrpc.doc Provides a list of packages installed on a system that are also
     *          contained in the given channel.  The installed package list did not 
     *          include arch information before RHEL 5, so it is arch unaware.  RHEL 5
     *          systems do upload the arch information, and thus are arch aware. 
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "channelLabel")
     * @xmlrpc.returntype 
     *  #array()
     *      $PackageSerializer
     *  #array_end()
     */
    public Object[] listPackagesFromChannel(String sessionKey, Integer sid, 
            String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        Channel channel = ChannelFactory.lookupByLabelAndUser(channelLabel, 
                loggedInUser);
        
        Set chanPacks = channel.getPackages();
        Set sysPacks = server.getPackages();
        Set intersection = new HashSet();

        for (Iterator it = sysPacks.iterator(); it.hasNext();) {
            InstalledPackage insPack = (InstalledPackage) it.next();
            
            for (Iterator chanIt = chanPacks.iterator(); chanIt.hasNext();) {
                Package chanPack = (Package) chanIt.next();
                
                if (insPack.equals(chanPack)) {
                    intersection.add(chanPack);
                    break;
                }
            }
        }
       
        return intersection.toArray();
    }

    /**
     * Schedule a hardware refresh for a system.
     * 
     * @param sessionKey User's session key.
     * @param sid ID of the server.
     * @param earliestOccurrence Earliest occurrence of the hardware refresh.
     * @return 1 if successful, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule a hardware refresh for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("dateTime.iso8601",  "earliestOccurrence")
     * @xmlrpc.returntype #return_int_success()
     */
    public int scheduleHardwareRefresh(String sessionKey, Integer sid, 
            Date earliestOccurrence) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        
        Action a = ActionManager.scheduleHardwareRefreshAction(loggedInUser, server, 
                earliestOccurrence);
        ActionFactory.save(a);
        
        return 1;
    }

    /**
     * Schedule a package list refresh for a system.
     * 
     * @param sessionKey User's session key.
     * @param sid ID of the server.
     * @param earliestOccurrence Earliest occurrence of the refresh.
     * @return the id of the action scheduled, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule a package list refresh for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("dateTime.iso8601",  "earliestOccurrence")
     * @xmlrpc.returntype int - ID of the action scheduled, otherwise exception thrown
     * on error
     */
    public int schedulePackageRefresh(String sessionKey, Integer sid, 
            Date earliestOccurrence) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        
        Action a = ActionManager.schedulePackageRefresh(loggedInUser, server, 
                earliestOccurrence);
        ActionFactory.save(a);
        
        return a.getId().intValue();
    }

    /**
     * Schedule a script to run.
     * 
     * @param sessionKey User's session key.
     * @param sid ID of the server to run the script on.
     * @param username User to run script as.
     * @param groupname Group to run script as.
     * @param timeout Seconds to allow the script to run before timing out.
     * @param script Contents of the script to run.
     * @param earliest Earliest the script can run.
     * @return ID of the new script action.
     * 
     * @xmlrpc.doc Schedule a script to run.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of the server to run the script on.
     * @xmlrpc.param #param_desc("string", "username", "User to run script as.")
     * @xmlrpc.param #param_desc("string", "groupname", "Group to run script as.")
     * @xmlrpc.param #param_desc("int", "timeout", "Seconds to allow the script to run 
     *                                      before timing out.")
     * @xmlrpc.param #param_desc("string", "script", "Contents of the script to run.")
     * @xmlrpc.param #param_desc("dateTime.iso8601", "earliestOccurrence", 
     *                  "Earliest the script can run.")
     * @xmlrpc.returntype int - ID of the script run action created. Can be used to fetch 
     * results with system.getScriptResults.
     */
    public Integer scheduleScriptRun(String sessionKey, Integer sid, String username, 
            String groupname, Integer timeout, String script, Date earliest) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        ScriptActionDetails scriptDetails = ActionManager.createScript(username, groupname, 
                new Long(timeout.longValue()), script);
        ScriptAction action = null;
        try {
            action = ActionManager.scheduleScriptRun(loggedInUser, server, 
                    null, scriptDetails, earliest);
        }
        catch (MissingCapabilityException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingCapabilityException();
        }
        catch (MissingEntitlementException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException();
        }
        
        return new Integer(action.getId().intValue());
    }
    
    /**
     * Fetch results from a script execution. Returns an empty array if no results are
     * yet available.
     * 
     * @param sessionKey User's session key.
     * @param actionId ID of the script run action.
     * @return Array of ScriptResult objects.
     * 
     * @xmlrpc.doc Fetch results from a script execution. Returns an empty array if no 
     * results are yet available.
     * @xmlrpc.param #param("string", "sessionKey") 
     * @xmlrpc.param #param_desc("int", "actionId", "ID of the script run action.")
     * @xmlrpc.returntype  
     *          #array()
     *              $ScriptResultSerializer
     *         #array_end()
     */
    public Object [] getScriptResults(String sessionKey, Integer actionId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        ScriptRunAction action = null;
        try {
            action = (ScriptRunAction)ActionManager.lookupAction(loggedInUser, 
                    new Long(actionId.longValue()));
        }
        catch (LookupException e) {
            throw new NoSuchActionException(actionId.toString(), e);
        }
        catch (ClassCastException e) {
            throw new InvalidActionTypeException(e);
        }
        
        ScriptActionDetails details = action.getScriptActionDetails();
        
        if (details.getResults() == null) {
            return new Object [] {};
        }
        
        List<ScriptResult> results = new LinkedList<ScriptResult>();
        for (Iterator it = details.getResults().iterator(); it.hasNext();) {
            ScriptResult r = (ScriptResult)it.next();
            results.add(r);
        }
        return results.toArray();
    }
    
    /**
     * Schedule a system reboot
     * 
     * @param sessionKey User's session key.
     * @param sid ID of the server.
     * @param earliestOccurrence Earliest occurrence of the reboot.
     * @return 1 if successful, exception thrown otherwise
     *
     * @xmlrpc.doc Schedule a reboot for a system.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("dateTime.iso860", "earliestOccurrence")
     * @xmlrpc.returntype #return_int_success()
     */
    public int scheduleReboot(String sessionKey, Integer sid, 
            Date earliestOccurrence) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        
        Action a = ActionManager.scheduleRebootAction(loggedInUser, server, 
                earliestOccurrence);
        ActionFactory.save(a);
        return 1;
    }
    
    /**
     * Get system details.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server to lookup details for.
     * @return Server object. (converted to XMLRPC struct by serializer)
     * 
     * @xmlrpc.doc Get system details.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype 
     *          $ServerSerializer
     */
    public Object getDetails(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }
        return server; // serializer will take care of the rest
    }

    
    /**
     * Set server details.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server to lookup details for.
     * @param details Map of (optional) system details to be set.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Set server details. All arguments are optional and will only be modified
     * if included in the struct.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") - ID of server to lookup details for.
     * @xmlrpc.param 
     *      #struct("server details")
     *          #prop_desc("string", "profile_name", "System's profile name")
     *          #prop_desc("string", "base_entitlement", "System's base entitlement label. 
     *                      (enterprise_entitled or sw_mgr_entitled)")
     *           #prop_desc("boolean", "auto_errata_update", "True if system has 
     *                          auto errata updates enabled")
     *           #prop_desc("string", "description", "System description")
     *           #prop_desc("string", "address1", "System's address line 1.")
     *           #prop_desc("string", "address2", "System's address line 2.")
     *           #prop("string", "city")
     *           #prop("string", "state")
     *           #prop("string", "country")
     *           #prop("string", "building")
     *           #prop("string", "room")
     *           #prop("string", "rack")
     *     #struct_end()
     *     
     *  @xmlrpc.returntype #return_int_success()
     */
    public Integer setDetails(String sessionKey, Integer serverId, Map details) {

        // confirm that the user only provided valid keys in the map
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("profile_name");
        validKeys.add("base_entitlement");
        validKeys.add("auto_errata_update");
        validKeys.add("address1");
        validKeys.add("address2");
        validKeys.add("city");
        validKeys.add("state");
        validKeys.add("country");
        validKeys.add("building");
        validKeys.add("room");
        validKeys.add("rack");
        validKeys.add("description");
        validateMap(validKeys, details);

        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }
        
        if (details.containsKey("profile_name")) {
            String name = (String)details.get("profile_name");
            name = StringUtils.trim(name);
            validateProfileName(name);
            server.setName(name);
        }
    
        if (details.containsKey("description")) {
            server.setDescription((String)details.get("description"));
        }
    
        if (details.containsKey("base_entitlement")) {
            // Raise exception if user attempts to set base entitlement but isn't an org
            // admin:
            if (!loggedInUser.hasRole(RoleFactory.ORG_ADMIN)) {
                throw new PermissionCheckFailureException();
            }
            
            String selectedEnt = (String)details.get("base_entitlement"); 
            Entitlement base = EntitlementManager.getByName(selectedEnt);
            if (base != null) {
                server.setBaseEntitlement(base);
            }
            else if (selectedEnt.equals("unentitle")) {
                SystemManager.removeAllServerEntitlements(server.getId());
            }
        }

        if (details.containsKey("auto_errata_update")) {
            Boolean autoUpdate = (Boolean)details.get("auto_errata_update");
            if (autoUpdate.booleanValue()) {
                server.setAutoUpdate("Y");
            }
            else {
                server.setAutoUpdate("N");
            }
        }
        
        if (server.getLocation() == null) {
            Location l = new Location();
            server.setLocation(l);
            l.setServer(server);
        }
        
        if (details.containsKey("address1")) {
            server.getLocation().setAddress1((String)details.get("address1"));
        }
        if (details.containsKey("address2")) {
            server.getLocation().setAddress2((String)details.get("address2"));
        }
        if (details.containsKey("city")) {
            server.getLocation().setCity((String)details.get("city"));
        }
        if (details.containsKey("state")) {
            server.getLocation().setState((String)details.get("state"));
        }
        if (details.containsKey("country")) {
            String country = (String)details.get("country");
            Map map = LocalizationService.getInstance().availableCountries();
            if (country.length() > 2 || 
                    !map.containsValue(country)) {
                throw new UnrecognizedCountryException(country);
            }    
            else {
                server.getLocation().setCountry(country);
            }
        }
        if (details.containsKey("building")) {
            server.getLocation().setBuilding((String)details.get("building"));
        }
        if (details.containsKey("room")) {
            server.getLocation().setRoom((String)details.get("room"));
        }
        if (details.containsKey("rack")) {
            server.getLocation().setRack((String)details.get("rack"));
        }
    
        return 1;
    }
    
    /**
     * Set server lock status.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server to lookup details for.
     * @param lockStatus to set. True to lock the system, False to unlock the system.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Set server lock status.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param_desc("boolean", "lockStatus", "true to lock the system, 
     * false to unlock the system.")
     *     
     *  @xmlrpc.returntype #return_int_success()
     */
    public Integer setLockStatus(String sessionKey, Integer serverId, boolean lockStatus) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        LocalizationService ls = LocalizationService.getInstance();

        if (lockStatus) {
            // lock the server, if it isn't already locked.
            if (server.getLock() == null) {
                SystemManager.lockServer(loggedInUser, server, ls.getMessage
                                         ("sdc.details.overview.lock.reason"));
            }
        }
        else {
            // unlock the server, if it isn't already locked.
            if (server.getLock() != null) {
                SystemManager.unlockServer(loggedInUser, server);
            }
        }
        
        return 1;
    }

    /**
     * Add addon entitlements to a server. Entitlements a server already has are simply 
     * ignored.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server.
     * @param entitlements List of addon entitlement labels to add.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Add addon entitlements to a server. Entitlements a server already has 
     * are quietly ignored.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("string", " entitlementLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addEntitlements(String sessionKey, Integer serverId, List entitlements) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }
        
        validateEntitlements(entitlements);
        
        // Check that we're not adding virt or virt platform to a system that already has
        // the other:
        if (server.hasEntitlement(EntitlementManager.VIRTUALIZATION) &&
                entitlements.contains(
                        EntitlementManager.VIRTUALIZATION_PLATFORM_ENTITLED)) {
            throw new InvalidEntitlementException();
        }
        if (server.hasEntitlement(EntitlementManager.VIRTUALIZATION_PLATFORM) &&
                entitlements.contains(
                        EntitlementManager.VIRTUALIZATION_ENTITLED)) {
            throw new InvalidEntitlementException();
        }

        List addOnEnts = new LinkedList(entitlements);
        // first process base entitlements
        for (Entitlement en : EntitlementManager.getBaseEntitlements()) {
            if (addOnEnts.contains(en.getLabel())) {
                addOnEnts.remove(en.getLabel());
                server.setBaseEntitlement(en);
            }
        }
        
        // put a more intelligible exception
        if ((server.getBaseEntitlement() == null) && (!addOnEnts.isEmpty())) {
            throw new InvalidEntitlementException("Base entitlement missing");
        }

        for (Iterator it = addOnEnts.iterator(); it.hasNext();) {
            
            Entitlement ent = EntitlementManager.getByName((String)it.next()); 

            // Ignore if the system already has this entitlement:
            if (server.hasEntitlement(ent)) {
                log.debug("System " + server.getName() + " already has entitlement: " +
                        ent.getLabel());
                continue;
            }
            
            if (SystemManager.canEntitleServer(server, ent)) {
                ValidatorResult vr = SystemManager.entitleServer(server, ent);
                if (vr.getErrors().size() > 0) {
                    throw new InvalidEntitlementException();
                }
            }
            else {
                throw new InvalidEntitlementException();
            }
        }
        
        return 1;
    }

    /**
     * Remove addon entitlements from a server.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server.
     * @param entitlements List of addon entitlement labels to remove.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Remove addon entitlements from a server. Entitlements a server does  
     * not have are quietly ignored.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") 
     * @xmlrpc.param #array_single("string", "entitlement_label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeEntitlements(String sessionKey, Integer serverId, List entitlements) {
            User loggedInUser = getLoggedInUser(sessionKey);
            Server server = null;
            try {
                server = SystemManager.lookupByIdAndUser(new Long(serverId.longValue()), 
                        loggedInUser);
            }
            catch (LookupException e) {
                throw new NoSuchSystemException();
            }
            
            validateEntitlements(entitlements);
            
            List<Entitlement> baseEnts = new LinkedList();

            for (Iterator it = entitlements.iterator(); it.hasNext();) {
                Entitlement ent = EntitlementManager.getByName((String)it.next());
                if (ent.isBase()) {
                    baseEnts.add(ent);
                    continue;
                }
                SystemManager.removeServerEntitlement(server.getId(), ent);
            }

            // process base entitlements at the end
            if (!baseEnts.isEmpty()) {
                // means unentile the whole system
                SystemManager.removeAllServerEntitlements(server.getId());
            }

            return 1;
    }
    
    
    /**
     * Creates a new stored Package Profile
     * 
     * @param sessionKey User's session key.
     * @param sid ID of server to lookup details for.
     * @param profileLabel the label of the profile to be created
     * @param desc the description of the profile to be created  
     * @return 1 on success 
     * 
     * @xmlrpc.doc Create a new stored Package Profile from a systems 
     *      installed package list.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "profileLabel") 
     * @xmlrpc.param #param("string", "description") 
     * @xmlrpc.returntype #return_int_success()
     */
    public int createPackageProfile(String sessionKey, Integer sid, 
            String profileLabel, String desc) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);
        
        try {
            Profile profile = ProfileManager.createProfile(loggedInUser, server,
                profileLabel, desc);
            ProfileManager.copyFrom(server, profile);
        }
        catch (DuplicateProfileNameException dbe) {
            throw new DuplicateProfileNameException("Package Profile already exists " +
                    "with name: " + profileLabel);
        }
        catch (NoBaseChannelFoundException nbcfe) {
            throw new ProfileNoBaseChannelException();
        }

        Profile newProfile = ProfileFactory.findByNameAndOrgId(profileLabel,
                loggedInUser.getOrg().getId());
        
        return 1;
    }
    
    /**
     * Compare a system's packages against a package profile.
     * 
     * @param sessionKey User's session key.
     * @param serverId ID of server
     * @param profileLabel the label of the package profile
     * @return 1 on success 
     * 
     * @xmlrpc.doc Compare a system's packages against a package profile.  In 
     * the result returned, 'this_system' represents the server provided as an input
     * and 'other_system' represents the profile provided as an input.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "profileLabel") 
     * @xmlrpc.returntype
     *          #array()
     *              $PackageMetadataSerializer
     *          #array_end()      
     */
    public Object[] comparePackageProfile(String sessionKey, Integer serverId,
            String profileLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        
        Long sid = new Long(serverId.longValue());
        Server server = SystemManager.lookupByIdAndUser(sid, loggedInUser);
        
        Profile profile = ProfileFactory.findByNameAndOrgId(profileLabel, 
                loggedInUser.getOrg().getId());
        
        if (profile == null) {
            throw new InvalidProfileLabelException(profileLabel);
        }

        DataResult dr = ProfileManager.compareServerToProfile(sid, profile.getId(),
                loggedInUser.getOrg().getId(), null);
        
        return dr.toArray();
    }
    
    /**
     * Returns list of systems which have packages needing updates
     * @param sessionKey WebSession containing User information.
     * @return Returns an array of SystemOverview objects (which are then 
     *          serialized using SystemOverviewSerializer)
     *
     * @xmlrpc.doc Returns list of systems needing package updates.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype 
     *          #array()
     *              $SystemOverviewSerializer
     *          #array_end()   
     * 
     */
    public Object[] listOutOfDateSystems(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        DataResult list = SystemManager.outOfDateList(loggedInUser, null);
        return list.toArray();
    }
    
    /**
     * Sync packages from a source system to a target.
     * 
     * @param sessionKey User's session key.
     * @param targetServerId Target system to apply package changes to.
     * @param sourceServerId Source system to retrieve package state from.
     * @param packageIds List of package IDs to be synced.
     * @param earliest Earliest occurrence of action.
     * @return 1 on success, exception thrown otherwise.
     * 
     * @xmlrpc.doc Sync packages from a source system to a target.
     * @xmlrpc.param #param("string", "sessionKey") 
     * @xmlrpc.param #param_desc("int", "targetServerId", "Target system to apply package 
     *                  changes to.")
     * @xmlrpc.param #param_desc("int", "sourceServerId", "Source system to retrieve 
     *                  package state from.")
     * @xmlrpc.param  #array_single("int", "packageId - Package IDs to be synced.")
     * @xmlrpc.param #param_desc("dateTime.iso8601", "date", "Date to schedule action for")
     * @xmlrpc.returntype #return_int_success()
     */
    public int scheduleSyncPackagesWithSystem(String sessionKey, Integer targetServerId,
            Integer sourceServerId, List packageIds, Date earliest) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        Server target = null;
        Server source = null;
        try {
            target = SystemManager.lookupByIdAndUser(new Long(targetServerId.longValue()), 
                    loggedInUser);
            source = SystemManager.lookupByIdAndUser(new Long(sourceServerId.longValue()), 
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }
        
        if (!isCompatible(loggedInUser, target, source)) {
            throw new InvalidSystemException();
        }

        // For each of the package ids provided, retrieve the pkg id combo
        // which includes name_id|evr_id|arch_id
        Set pkgIdCombos = new HashSet();
        for (Iterator it = packageIds.iterator(); it.hasNext();) {
            Integer i = (Integer)it.next();
            
            Package pkg = PackageManager.lookupByIdAndUser(i.longValue(), loggedInUser);

            if (pkg != null) {
                StringBuilder idCombo = new StringBuilder();
                idCombo.append(pkg.getPackageName().getId()).append("|");
                if (pkg.getPackageEvr() != null) {
                    idCombo.append(pkg.getPackageEvr().getId()).append("|");
                }
                if (pkg.getPackageArch() != null) {
                    idCombo.append(pkg.getPackageArch().getId());
                }
                pkgIdCombos.add(idCombo.toString());
            }
        }

        try {
            ProfileManager.syncToSystem(loggedInUser, new Long(targetServerId.longValue()), 
                    new Long(sourceServerId.longValue()), pkgIdCombos, null, 
                    earliest);
        }
        catch (MissingEntitlementException e) {
            throw new com.redhat.rhn.frontend.xmlrpc.MissingEntitlementException();
        }
        return 1;
    }

    /**
     * Returns true if the two systems are compatible for a package sync.
     * 
     * @param user User making the request.
     * @param target Target server.
     * @param source Source server.
     * @return True is systems are compatible, false otherwise.
     */
    private boolean isCompatible(User user, Server target, Server source) {
        List compatibleServers = SystemManager.compatibleWithServer(user, target);
        boolean found = false;
        for (Iterator it = compatibleServers.iterator(); it.hasNext();) {
            Map m = (Map)it.next();
            Long currentId = (Long)m.get("id");
            if (currentId.longValue() == source.getId().longValue()) {
                found = true;
                break;
            }
        }
        return found;
    }
    
    
    /**
     * list systems that are not in any system group
     * @param sessionKey of user making call
     * @return A list of Maps containing ID,name, and last checkin
     * 
     * @xmlrpc.doc List systems that are not associated with any system groups.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype 
     *      #array()
         *      #struct("system")
         *          #prop_desc("int", "id", "server id")
         *          #prop("string", "name")
         *          #prop("dateTime.iso8601", "last_checkin", "Last time server successfully
         *                      checked in.")
         *      #struct_end()
     *      #array_end()
     */
    public Object[] listUngroupedSystems(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        List <Server> servers = ServerFactory.listUngroupedSystems(loggedInUser);
        List <Map> serverMaps = new ArrayList<Map>();
        XmlRpcSystemHelper helper = XmlRpcSystemHelper.getInstance();
        for (Server server : servers) {
            serverMaps.add(helper.format(server));
        }
        return serverMaps.toArray();
    }
    
    
    /**
     * Gets the base channel for a particular system
     * @param sessionKey key of the logged in user
     * @param sid SystemID of the system in question
     * @return Channel that is the base channel
     * 
     * @xmlrpc.doc Provides the base channel of a given system
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId") 
     * @xmlrpc.returntype 
     *      $ChannelSerializer
     */
    public Channel getSubscribedBaseChannel(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        return server.getBaseChannel();
    }
    
    
    /**
     * Gets the list of inactive systems using the default inactive period
     * @param sessionKey the session of the user
     * @return list of inactive systems
     * 
     * @xmlrpc.doc Lists systems that have been inactive for the default period of 
     *          inactivity
     * @xmlrpc.param #param("string", "sessionKey") 
     * @xmlrpc.returntype array
     *              $SystemOverviewSerializer
     */
    public List listInactiveSystems(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        return SystemManager.inactiveList(loggedInUser, null);

    }
    

    /**
     * Gets the list of inactive systems using the provided  inactive period
     * @param sessionKey the session of the user
     * @param days the number of days for inactivity you want
     * @return list of inactive systems
     * 
     * @xmlrpc.doc Lists systems that have been inactive for the specified
     *      number of days..
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "days") 
     * @xmlrpc.returntype array
     *          $SystemOverviewSerializer
     */    
    public List listInactiveSystems(String sessionKey, Integer days) {
        User loggedInUser = getLoggedInUser(sessionKey);
        return SystemManager.inactiveList(loggedInUser, null, days);
    }
    
    /**
     * Retrieve the user who registered a particular system
     * @param sessionKey the session key
     * @param sid the id of the system in question
     * @return the User
     * 
     * @xmlrpc.doc Returns information about the user who registered the system
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "sid", "Id of the system in question")
     * @xmlrpc.returntype 
     *          $UserSerializer
     */
    public User whoRegistered(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);
        return server.getCreator();        
    }
    
    /**
     * returns a list of SystemOverview objects that contain the given package id
     * @param sessionKey the session of the user
     * @param pid the package id to search for
     * @return an array of systemOverview objects
     * 
     * @xmlrpc.doc Lists the systems that have the given installed package
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "pid", "the package id")
     * @xmlrpc.returntype 
     *           #array()
     *              $SystemOverviewSerializer
     *           #array_end()
     */
    public List listSystemsWithPackage(String sessionKey, Integer pid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Package pack = PackageFactory.lookupByIdAndOrg(
                pid.longValue(), loggedInUser.getOrg());
        if (pack == null) {
            throw new InvalidPackageException(pid.toString());
        }
        return SystemManager.listSystemsWithPackage(loggedInUser, 
                pack.getPackageName().getName() , pack.getPackageEvr().getVersion(),
                pack.getPackageEvr().getRelease());
    }
    
    /**
     * returns a list of SystemOverview objects that contain a package given it's NVR
     * @param sessionKey the session of the user
     * @param name package name
     * @param version package version
     * @param release package release
     * 
     * @return an array of systemOverview objects
     * 
     * @xmlrpc.doc Lists the systems that have the given installed package
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "name", "the package name")
     * @xmlrpc.param #param_desc("string", "version", "the package version")
     * @xmlrpc.param #param_desc("string", "release", "the package release")
     * @xmlrpc.returntype 
     *              #array()
     *                  $SystemOverviewSerializer
     *              #array_end()     
     */    
    public List listSystemsWithPackage(String sessionKey, String  name, String version, 
            String release) {
        User loggedInUser = getLoggedInUser(sessionKey);
        return SystemManager.listSystemsWithPackage(loggedInUser, 
                name, version, release);
    }
    
    /**
     * Gets a list of virtual hosts for the current user
     * @param sessionKey session
     * @return list of SystemOverview objects
     * 
     * @xmlrpc.doc Lists the virtual hosts visible to the user
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.returntype 
     *      #array()
     *       $SystemOverviewSerializer
     *      #array_end()
     */
    public List listVirtualHosts(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        return SystemManager.listVirtualHosts(loggedInUser);
    }
    
    /**
     * Gets a list of virtual guests for the given host
     * @param sessionKey session
     * @param sid the host system id
     * @return list of VirtualSystemOverview objects
     * 
     * @xmlrpc.doc Lists the virtual guests for agiven virtual host
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("int", "sid", "the virtual host's id")
     * @xmlrpc.returntype 
     *      #array()
     *          $VirtualSystemOverviewSerializer
     *     #array_end()             
     */
    public List listVirtualGuests(String sessionKey, Integer sid) {
        User loggedInUser = getLoggedInUser(sessionKey);
        DataResult result =  SystemManager.virtualGuestsForHostList(loggedInUser, 
                sid.longValue(), null);
        result.elaborate();
        return result;
    }
    
    /**
     * Schedules an action to set the guests memory usage
     * @param sessionKey the session key
     * @param sid the server ID of the guest
     * @param memory the amount of memory to set the guest to use
     * @return the action id of the scheduled action
     * 
     * @xmlrpc.doc Schedule an action of a guest's host, to set that guest's memory 
     *          allocation
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "sid", "The guest's system id")
     * @xmlrpc.param #param_desc("int", "memory", "The amount of memory to 
     *          allocate to the guest")
     *  @xmlrpc.returntype int actionID - the action Id for the schedule action 
     *              on the host system.  
     * 
     */
    public int setGuestMemory(String sessionKey, Integer sid, Integer memory) {
        User loggedInUser = getLoggedInUser(sessionKey);
        VirtualInstance vi = VirtualInstanceFactory.getInstance().lookupByGuestId(
                loggedInUser.getOrg(), sid.longValue());
        
        Map context = new HashMap();
        //convert from mega to kilo bytes
        context.put(VirtualizationSetMemoryAction.SET_MEMORY_STRING, 
                new Integer(memory * 1024).toString());
        
       
        VirtualizationActionCommand cmd = new VirtualizationActionCommand(loggedInUser,
                                          new Date(),
                                          ActionFactory.TYPE_VIRTUALIZATION_SET_MEMORY,
                                          vi.getHostSystem(),
                                          vi.getUuid(),
                                          context);
        cmd.store();
        return cmd.getAction().getId().intValue();
    }
    
    
    /**
     * Schedules an actino to set the guests CPU allocation
     * @param sessionKey the session key
     * @param sid the server ID of the guest
     * @param numOfCpus the num of cpus to set
     * @return the action id of the scheduled action
     * 
     * @xmlrpc.doc Schedule an action of a guest's host, to set that guest's CPU 
     *          allocation
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "sid", "The guest's system id")
     * @xmlrpc.param #param_desc("int", "numOfCpus", "The number of virtual cpus to 
     *          allocate to the guest")
     *  @xmlrpc.returntype int actionID - the action Id for the schedule action 
     *              on the host system.  
     * 
     */    
    public int setGuestCpus(String sessionKey, Integer sid, Integer numOfCpus) {
        User loggedInUser = getLoggedInUser(sessionKey);
        VirtualInstance vi = VirtualInstanceFactory.getInstance().lookupByGuestId(
                loggedInUser.getOrg(), sid.longValue());
        
        Map context = new HashMap();
        context.put(VirtualizationSetVcpusAction.SET_CPU_STRING, numOfCpus.toString());
        
        VirtualizationActionCommand cmd = new VirtualizationActionCommand(loggedInUser,
                                          new Date(),
                                          ActionFactory.TYPE_VIRTUALIZATION_SET_VCPUS,
                                          vi.getHostSystem(),
                                          vi.getUuid(),
                                          context);
        cmd.store();
        return cmd.getAction().getId().intValue();
    }
    
    /**
     *  schedules the specified action on the guest
     * @param sessionKey key
     * @param sid the id of the system
     * @param state one of the following: 'start', 'suspend', 'resume', 'restart', 
     *          'shutdown'
     * @param date the date to schedule it
     * @return action ID 
     * 
     * @xmlrpc.doc Schedules a guest action for the specified virtual guest for a given 
     *          date/time.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "sid", "the system Id of the guest")
     * @xmlrpc.param #param_desc("string", "state", "One of the following actions  'start', 
     *          'suspend', 'resume', 'restart', 'shutdown'.")
     * @xmlrpc.param  #param_desc($date, "date", "the time/date to schedule the action")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public int scheduleGuestAction(String sessionKey, Integer sid, String state, 
                Date date) {
        User loggedInUser = getLoggedInUser(sessionKey);
        VirtualInstance vi = VirtualInstanceFactory.getInstance().lookupByGuestId(
                loggedInUser.getOrg(), sid.longValue());
        
        ActionType action;
        if (state.equals("start")) {
             action = ActionFactory.TYPE_VIRTUALIZATION_START;
        }
        else if (state.equals("suspend")) {
            action = ActionFactory.TYPE_VIRTUALIZATION_SUSPEND;
        }
        else if (state.equals("resume")) {
            action = ActionFactory.TYPE_VIRTUALIZATION_RESUME;
        }
        else if (state.equals("restart")) {
            action = ActionFactory.TYPE_VIRTUALIZATION_REBOOT;
        }
        else if (state.equals("shutdown")) {
            action = ActionFactory.TYPE_VIRTUALIZATION_SHUTDOWN;
        }
        else {
            throw new InvalidActionTypeException();
        }
        
        VirtualizationActionCommand cmd = new VirtualizationActionCommand(loggedInUser,
                                          date == null ? new Date() : date,
                                          action,
                                          vi.getHostSystem(),
                                          vi.getUuid(),
                                          new HashMap());
        cmd.store();
        return cmd.getAction().getId().intValue();
    }
    
    /**
     *  schedules the specified action on the guest
     * @param sessionKey key
     * @param sid the id of the system
     * @param state one of the following: 'start', 'suspend', 'resume', 'restart', 
     *          'shutdown'
     * @return action ID 
     * 
     * @xmlrpc.doc Schedules a guest action for the specified virtual guest for the 
     *          current time.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "sid", "the system Id of the guest")
     * @xmlrpc.param #param_desc("string", "state", "One of the following actions  'start',
     *          'suspend', 'resume', 'restart', 'shutdown'.")
     * @xmlrpc.returntype int actionId - The action id of the scheduled action
     */
    public int scheduleGuestAction(String sessionKey, Integer sid, String state) {
        return scheduleGuestAction(sessionKey, sid, state, null);
    }
    
    /**
     * List the activation keys the system was registered with.
     * @param sessionKey session
     * @param serverId the host system id
     * @return list of keys
     *
     * @xmlrpc.doc List the activation keys the system was registered with.  An empty
     * list will be returned if an activation key was not used during registration.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype #array_single ("string", "key")
     */
    public List<String> listActivationKeys(String sessionKey, Integer serverId) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, serverId);

        DataResult<ActivationKeyDto> result = SystemManager.getActivationKeys(server);

        List<String> returnList = new ArrayList<String>();
        for (Iterator itr = result.iterator(); itr.hasNext();) {
            ActivationKeyDto key = (ActivationKeyDto) itr.next();

            returnList.add(key.getToken());
        }
        return returnList;
    }

    /**
     * Get the list of proxies that the given system connects
     * through in order to reach the server.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question
     * @return Returns an array of maps representing the proxies the system is connected
     * through
     * @throws FaultException A FaultException is thrown if the server corresponding to
     * sid cannot be found.
     *
     * @xmlrpc.doc Get the list of proxies that the given system connects
     * through in order to reach the server.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *      #array()
     *          $ServerPathSerializer
     *      #array_end()
     */
    public Object[] getConnectionPath(String sessionKey, Integer sid)
        throws FaultException {

        // Get the logged in user and server
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = lookupServer(loggedInUser, sid);

        DataResult<ServerPath> dr = SystemManager.getConnectionPath(server.getId());
        return dr.toArray();
    }

    private Channel lookupChannelByLabel(Org org, String label)
        throws NoSuchChannelException {

        Channel channel = ChannelManager.lookupByLabel(org, label);
        if (channel == null) {
            throw new NoSuchChannelException();
        }
        return channel;
    }

    /**
     * Method to setup the static network configuration for a given server
     * This is used by spacewalkkoan if the user selects static networking option
     * in the advanced configuration section during provisioning.
     * It basically adds $static_network variable to the cobbler system record
     * which gets rendered during the kickstart.
     * @param clientcert the client certificate or the system id file
     * @param data a map holding the network details like ip, gateway, 
     *              name servers, ip, netmask and hostname.
     * 
     * @return 1 on success exception otherwise.
     * 
     * @xmlrpc.ignore Since this API is for internal integration between services and
     * is not useful to external users of the API, the typical XMLRPC API documentation
     * is not being included.
     */
    public int setupStaticNetwork(String clientcert, Map<String, Object> data) {
        StringReader rdr = new StringReader(clientcert);
        Server server = null;

        ClientCertificate cert;
        try {
            cert = ClientCertificateDigester.buildCertificate(rdr);
            server = SystemManager.lookupByCert(cert);
            if (server == null) {
                throw new NoSuchSystemException();
            }
        }
        catch (IOException ioe) {
            log.error("IOException - Trying to access a system with an " +
                    "invalid certificate", ioe);
            throw new MethodInvalidParamException();
        }
        catch (SAXException se) {
            log.error("SAXException - Trying to access a " +
                    "system with an invalid certificate", se);
            throw new MethodInvalidParamException();
        }
        catch (InvalidCertificateException e) {
            log.error("InvalidCertificateException - Trying to access a " +
                    "system with an invalid certificate", e);
            throw new MethodInvalidParamException();
        }
        SystemRecord rec = server.getCobblerObject(null);
        if (rec == null) {
            throw new NoSuchSystemException();
        }
        
        String device = (String)data.get("device");
        String gateway = (String)data.get("gateway");
        List<String> nameservers = (List<String>)data.get("nameservers");
        String ip = (String)data.get("ip");
        String netmask = (String)data.get("netmask");
        String hostName = (String)data.get("hostname");
        String command = KickstartFormatter.makeStaticNetworkCommand(device, ip, gateway, 
                                                  nameservers.get(0), netmask, hostName);
        rec.setHostName(hostName);
        rec.setGateway(gateway);
        rec.setNameServers(nameservers);
        Map<String, Object> meta = rec.getKsMeta();
        meta.put(KickstartFormatter.STATIC_NETWORK_VAR, command);
        rec.setKsMeta(meta);
        rec.save();
        return 1;
    }

    private KickstartData lookupKsData(String label, Org org) {
        return XmlRpcKickstartHelper.getInstance().lookupKsData(label, org);
    }

    /**
     * Creates a cobbler system record
     * @param sessionKey session
     * @param serverId the host system id
     * @param ksLabel identifies the kickstart profile
     *
     * @return int - 1 on success, exception thrown otherwise.
     *
     * @xmlrpc.doc Creates a cobbler system record with the specified kickstart label
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.returntype int - #return_int_success()
     */
    public int createSystemRecord(String sessionKey, Integer serverId, String ksLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);

        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(serverId.longValue(),
                    loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        if (!(server.hasEntitlement(EntitlementManager.PROVISIONING))) {
            throw new FaultException(-2, "provisionError",
                    "System does not have provisioning entitlement");
        }

        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        CobblerSystemCreateCommand cmd = new CobblerSystemCreateCommand(
                loggedInUser, server, ksData.getCobblerObject(loggedInUser).getName());
        cmd.store();

        return 1;
    }

    /**
     * Returns a list of kickstart variables set for the specified server
     *
     * @param sessionKey      identifies the user making the call;
     * @param serverId        identifies the server
     * @return map of kickstart variables set for the specified server
     *
     * @xmlrpc.doc Lists kickstart variables set for the specified server
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *      #struct("System kickstart variables")
     *          #prop_desc("boolean" "netboot" "netboot enabled")
     *          #prop_desc("array" "kickstart variables")
     *              #array()
     *                  #prop("string", "key")
     *                  #prop("string or int", "value")
     *              #array_end()
     *      #struct_end()
     */
    public Map getVariables(String sessionKey, Integer serverId) {

        User loggedInUser = getLoggedInUser(sessionKey);

        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(serverId.longValue(), loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        if (!(server.hasEntitlement(EntitlementManager.PROVISIONING))) {
            throw new FaultException(-2, "provisionError",
                    "System does not have provisioning entitlement");
        }

        SystemRecord rec = SystemRecord.lookupById(
                CobblerXMLRPCHelper.getConnection(loggedInUser), server.getCobblerId());
        if (rec == null) {
            throw new NoSuchCobblerSystemRecordException();
        }

        Map vars = new HashMap();
        vars.put("netboot", rec.isNetbootEnabled());
        vars.put("variables", rec.getKsMeta());

        return vars;
    }

    /**
     * Sets a list of kickstart variables for the specified server
     *
     * @param sessionKey      identifies the user making the call
     * @param serverId        identifies the server
     * @param netboot         netboot enabled
     * @param variables       list of system kickstart variables to set
     * @return int - 1 on success, exception thrown otherwise
     *
     * @xmlrpc.doc Sets a list of kickstart variables for the specified server
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #param("boolean","netboot")
     * @xmlrpc.param #param("array",  "kickstart variables")
     *      #array()
     *          #prop("string", "key")
     *          #prop("string or int", "value")
     *      #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setVariables(String sessionKey, Integer serverId, Boolean netboot,
                                                        Map<String, Object> variables) {

        User loggedInUser = getLoggedInUser(sessionKey);

        Server server = null;
        try {
            server = SystemManager.lookupByIdAndUser(serverId.longValue(), loggedInUser);
        }
        catch (LookupException e) {
            throw new NoSuchSystemException();
        }

        if (!(server.hasEntitlement(EntitlementManager.PROVISIONING))) {
            throw new FaultException(-2, "provisionError",
                    "System does not have provisioning entitlement");
        }

        SystemRecord rec = SystemRecord.lookupById(
                CobblerXMLRPCHelper.getConnection(loggedInUser), server.getCobblerId());
        if (rec == null) {
            throw new NoSuchCobblerSystemRecordException();
        }

        rec.enableNetboot(netboot);
        rec.setKsMeta(variables);
        return 1;
    }
}
