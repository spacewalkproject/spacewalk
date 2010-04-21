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
package com.redhat.rhn.frontend.xmlrpc.channel.software;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.db.datasource.SelectMode;
import com.redhat.rhn.common.db.datasource.WriteMode;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.channel.NewChannelHelper;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.events.UpdateErrataCacheEvent;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.DuplicateChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelArchException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.frontend.xmlrpc.MultipleBaseChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchPackageException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.system.SystemHandler;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;
import com.redhat.rhn.frontend.xmlrpc.user.XmlRpcUserHelper;
import com.redhat.rhn.manager.channel.ChannelEditor;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.CreateChannelCommand;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.system.IncompatibleArchException;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ChannelSoftwareHandler
 * @version $Rev$
 * @xmlrpc.namespace channel.software
 * @xmlrpc.doc Provides methods to access and modify many aspects of a channel.
 */
public class ChannelSoftwareHandler extends BaseHandler {
    
    private static Logger log = Logger.getLogger(ChannelSoftwareHandler.class);
    
    /**
     * Lists the packages with the latest version (including release and epoch)
     * for the unique package names
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @return Lists the packages with the largest version (including release
     * and epoch) for the unique package names
     * @throws NoSuchChannelException thrown if no channel is found.
     * 
     * @xmlrpc.doc Lists the packages with the latest version (including release and
     * epoch) for the given channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *              #prop("int", "id")
     *              #prop("string", "arch_label")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listLatestPackages(String sessionKey, String channelLabel)
        throws NoSuchChannelException {
        
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        
        List pkgs = ChannelManager.latestPackagesInChannel(channel);
        return pkgs.toArray();
    }

    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @param endDate last modified end date (as a string)
     * @return all packages in the channel, regardless of version between the
     * given dates.
     * @throws NoSuchChannelException thrown if no channel is found.
     * 
     * @xmlrpc.doc Lists all packages in the channel, regardless of package version, 
     * between the given dates.  
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param($date, "startDate")
     * @xmlrpc.param #param($date, "endDate")
     * @xmlrpc.returntype
     *      #array()
     *              $PackageDtoSerializer
     *      #array_end()
     */
    public Object[] listAllPackages(String sessionKey, String channelLabel,
            Date startDate, Date endDate) throws NoSuchChannelException {
        
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        List pkgs = ChannelManager.listAllPackages(channel, startDate, endDate);
        return pkgs.toArray();
    }
    
    /**
     * Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @return all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @throws NoSuchChannelException thrown if no channel is found.
     *
     * @xmlrpc.doc Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param($date, "startDate")
     * @xmlrpc.returntype
     *      #array()
     *              $PackageDtoSerializer
     *      #array_end()
     */
    public Object[] listAllPackages(String sessionKey, String channelLabel,
            Date startDate) throws NoSuchChannelException {
        return listAllPackages(sessionKey, channelLabel, startDate, null);
    }
    
    /**
     * Lists all packages in the channel, regardless of version
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @return all packages in the channel, regardless of version
     * @throws NoSuchChannelException thrown if no channel is found.
     *
     * @xmlrpc.doc Lists all packages in the channel, regardless of the package version
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *      #array()
     *              $PackageDtoSerializer
     *      #array_end()
     */
    public Object[] listAllPackages(String sessionKey, String channelLabel)
        throws NoSuchChannelException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        List pkgs = ChannelManager.listAllPackages(channel);
        return pkgs.toArray();
    }
  
    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @param endDate last modified end date (as a string)
     * @return all packages in the channel, regardless of version between the
     * given dates.
     * @throws NoSuchChannelException thrown if no channel is found.
     * @deprecated being replaced by listAllPackages(string sessionKey, 
     * string channelLabel, dateTime.iso8601 startDate, dateTime.iso8601 endDate)
     * 
     * @xmlrpc.doc Lists all packages in the channel, regardless of package version, 
     * between the given dates.  
     * Example Date:  '2008-08-20 08:00:00'
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.param #param("string", "endDate")
     * @xmlrpc.returntype
     *      #array()
     *              $PackageDtoSerializer
     *      #array_end()
     */
    public Object[] listAllPackages(String sessionKey, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        List pkgs = ChannelManager.listAllPackages(channel, startDate, endDate);
        return pkgs.toArray();
    }
    
    /**
     * Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @return all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @throws NoSuchChannelException thrown if no channel is found.
     * @deprecated being replaced by listAllPackages(string sessionKey, 
     * string channelLabel, dateTime.iso8601 startDate)
     *
     * @xmlrpc.doc Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date. Example Date: '2008-08-20 08:00:00'
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.returntype
     *      #array()
     *              $PackageDtoSerializer
     *      #array_end()
     */
    public Object[] listAllPackages(String sessionKey, String channelLabel,
            String startDate) throws NoSuchChannelException {
        return listAllPackages(sessionKey, channelLabel, startDate, null);
    }
    
    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @param endDate last modified end date (as a string)
     * @return all packages in the channel, regardless of version between the
     * given dates.
     * @throws NoSuchChannelException thrown if there is the channel is not
     * found.
     * @deprecated being replaced by listAllPackages(string sessionKey, 
     * string channelLabel, dateTime.iso8601 startDate, dateTime.iso8601 endDate)
     * 
     * @xmlrpc.doc Lists all packages in the channel, regardless of the package version, 
     * between the given dates. Example Date: '2008-08-20 08:00:00'
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.param #param("string", "endDate")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *              #prop("string", "id")
     *              #prop("string", "arch_label")
     *              #prop("string", "last_modified")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listAllPackagesByDate(String sessionKey, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {
        
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, channelLabel);
        List pkgs = ChannelManager.listAllPackagesByDate(channel, startDate, endDate);
        return pkgs.toArray();
    }
    
    /**
     * Lists all packages in the channel, regardless of version, whose last
     * modified date is greater than given date.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @param startDate last modified begin date (as a string)
     * @return all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @throws NoSuchChannelException thrown if no channel is found.
     * @deprecated being replaced by listAllPackages(string sessionKey, 
     * string channelLabel, dateTime.iso8601 startDate)
     *
     * @xmlrpc.doc Lists all packages in the channel, regardless of the package version, 
     * whose last modified date is greater than given date.
     * Example Date:  '2008-08-20 08:00:00'
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *              #prop("string", "id")
     *              #prop("string", "arch_label")
     *              #prop("string", "last_modified")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listAllPackagesByDate(String sessionKey, String channelLabel,
            String startDate) throws NoSuchChannelException {
        
        return listAllPackagesByDate(sessionKey, channelLabel, startDate, null);
    }
    
    /**
     * Lists all packages in the channel, regardless of version
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose package are sought.
     * @return all packages in the channel, regardless of version between the
     * given dates.
     * @throws NoSuchChannelException thrown if no channel is found.
     * @deprecated being replaced by listAllPackages(string sessionKey, 
     * string channelLabel)
     *
     * @xmlrpc.doc Lists all packages in the channel, regardless of the package version
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("package")
     *              #prop("string", "name")
     *              #prop("string", "version")
     *              #prop("string", "release")
     *              #prop("string", "epoch")
     *              #prop("string", "id")
     *              #prop("string", "arch_label")
     *              #prop("string", "last_modified")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listAllPackagesByDate(String sessionKey, String channelLabel)
        throws NoSuchChannelException {
        
        return listAllPackagesByDate(sessionKey, channelLabel, null, null);
    }
    
    /**
     * Return Lists potential software channel arches that can be created
     * @param sessionKey WebSession containing User information.
     * @return Lists potential software channel arches that can be created
     * @throws PermissionCheckFailureException thrown if the user is not a
     * channel admin
     *
     * @xmlrpc.doc Lists the potential software channel architectures that can be created
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *          #array()
     *              $ChannelArchSerializer
     *          #array_end()
     */
    public Object[] listArches(String sessionKey) throws PermissionCheckFailureException {
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        
        List arches = ChannelManager.getChannelArchitectures();
        
        return arches.toArray();
    }
    
    /**
     * Deletes a software channel
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel to be deleted.
     * @return 1 if Channel was successfully deleted.
     * @throws PermissionCheckFailureException thrown if User has no access to
     * delete channel.
     * @throws NoSuchChannelException thrown if label is invalid.
     *
     * @xmlrpc.doc Deletes a custom software channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to delete")
     * @xmlrpc.returntype #return_int_success()
     */
    public int delete(String sessionKey, String channelLabel)
        throws PermissionCheckFailureException, NoSuchChannelException {
        
        User user = getLoggedInUser(sessionKey);
        try {
            ChannelManager.deleteChannel(user, channelLabel);
        }
        catch (InvalidChannelRoleException e) {
            throw new PermissionCheckFailureException(e);
        }

        return 1;
    }
    
    /**
     * Returns whether the channel is subscribable by any user in the
     * organization.
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel to be deleted.
     * @return 1 if the Channel is globally subscribable, 0 otherwise.
     *
     * @xmlrpc.doc Returns whether the channel is subscribable by any user
     * in the organization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype int - 1 if true, 0 otherwise
     */
    public int isGloballySubscribable(String sessionKey, String channelLabel) {
        // TODO: this should return a boolean NOT an int
        User user = getLoggedInUser(sessionKey);
        
        // Make sure the channel exists:
        lookupChannelByLabel(user, channelLabel);
        
        return ChannelManager.isGloballySubscribable(user, channelLabel) ? 1 : 0;
    }

    /**
     * Returns the details of the given channel as a map with the following
     * keys:
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose details are sought.
     * @throws NoSuchChannelException thrown if no channel is found.
     * @return the channel requested.
     *
     * @xmlrpc.doc Returns details of the given channel as a map
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *     $ChannelSerializer
     */
    public Channel getDetails(String sessionKey, String channelLabel)
        throws NoSuchChannelException {
        User user = getLoggedInUser(sessionKey);
        return lookupChannelByLabel(user, channelLabel);
    }
    
    /**
     * Returns the requested channel
     * @param sessionKey WebSession containing User information.
     * @param id - id of channel wanted
     * @throws NoSuchChannelException thrown if no channel is found.
     * @return the channel requested.
     *
     * @xmlrpc.doc Returns details of the given channel as a map
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "id", "channel to query")
     * @xmlrpc.returntype
     *     $ChannelSerializer
     */
    public Channel getDetails(String sessionKey, Integer id)
        throws NoSuchChannelException {
        User user = getLoggedInUser(sessionKey);
        return lookupChannelById(user, id);        
    }
    
    
    /**
     * Returns the number of available subscriptions for the given channel
     * @param sessionKey WebSession containing User information.
     * @param channelLabel Label of channel whose details are sought.
     * @return the number of available subscriptions for the given channel
     * @throws NoSuchChannelException thrown if no channel is found.
     *
     * @xmlrpc.doc Returns the number of available subscriptions for the given channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype int number of available subscriptions for the given channel
     */
    public int availableEntitlements(String sessionKey, String channelLabel)
        throws NoSuchChannelException {
        
        User user = getLoggedInUser(sessionKey);
        Channel c = lookupChannelByLabel(user, channelLabel);
        Long cnt = ChannelManager.getAvailableEntitlements(user.getOrg(), c);
        if (cnt == null) {
            return 0;
        }
        else {
            return cnt.intValue();
        }
    }
    
    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param sessionKey WebSession containing User information.
     * @param label Channel label to be created
     * @param name Name of Channel
     * @param summary Channel Summary
     * @param archLabel Architecture label
     * @param parentLabel Parent Channel label (may be null)
     * @param checksumType checksum type for this channel
     * @param gpgKey a map consisting of
     *      <li>string url</li>
     *      <li>string id</li>
     *      <li>string fingerprint</li>
     * @param yumRepo a map consisting of
     *      <li>string url</li>
     *      <li>string label</li>
     *      <li>boolean sync</li>
     * @return 1 if creation of channel succeeds.
     * @since 10.9
     * @throws PermissionCheckFailureException  thrown if user does not have
     * permission to create the channel.
     * @throws InvalidChannelNameException thrown if given name is in use or
     * otherwise, invalid.
     * @throws InvalidChannelLabelException throw if given label is in use or
     * otherwise, invalid. 
     * @throws InvalidParentChannelException thrown if parent label is for a
     * channel that is not a base channel.
     * 
     * @xmlrpc.doc Creates a software channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "label of the new channel")
     * @xmlrpc.param #param_desc("string", "name", "name of the new channel")
     * @xmlrpc.param #param_desc("string", "summary" "summary of the channel")
     * @xmlrpc.param #param_desc("string", "archLabel", 
     *              "the label of the architecture the channel corresponds to")
     *      #options()
     *          #item_desc ("channel-ia32", "For 32 bit channel architecture")
     *          #item_desc ("channel-ia64", "For 64 bit channel architecture")
     *          #item_desc ("channel-sparc", "For Sparc channel architecture")
     *          #item_desc ("channel-alpha", "For Alpha channel architecture")
     *          #item_desc ("channel-s390", "For s390 channel architecture")
     *          #item_desc ("channel-s390x", "For s390x  channel architecture")
     *          #item_desc ("channel-iSeries", "For i-Series channel architecture")
     *          #item_desc ("channel-pSeries", "For p-Series channel architecture")
     *          #item_desc ("channel-x86_64", "For x86_64 channel architecture")
     *          #item_desc ("channel-ppc", "For PPC channel architecture")
     *          #item_desc ("channel-sparc-sun-solaris", 
     *                                  "For Sparc Solaris channel architecture")
     *          #item_desc ("channel-i386-sun-solaris", 
     *                                  "For i386 Solaris channel architecture")
     *      #options_end()
     * @xmlrpc.param #param_desc("string", "parentLabel", "label of the parent of this 
     *              channel, an empty string if it does not have one")
     * @xmlrpc.param #param_desc("string", "checksumType", "checksum type for this channel,
     *              used for yum repository metadata generation")
     *      #options()
     *          #item_desc ("sha1", "Offers widest compatibility  with clients")
     *          #item_desc ("sha256", "Offers highest security, but is compatible
     *                        only with newer clients: Fedora 11 and newer,
     *                        or Enterprise Linux 6 and newer.")
     *      #options_end()
     * @xmlrpc.param
     *      #struct("gpgKey")
     *          #prop_desc("string", "url", "GPG key URL")
     *          #prop_desc("string", "id", "GPG key ID")
     *          #prop_desc("string", "fingerprint", "GPG key Fingerprint")
     *      #struct_end()
     * @xmlrpc.param
     *      #struct("yumRepo")
     *          #prop_desc("string", "url", "Associated Yum Repository URL")
     *          #prop_desc("string", "label", "Associated Yum Repository Label")
     *          #prop_desc("boolean", "sync", "Sync Yum Repository")
     *      #struct_end()
     * @xmlrpc.returntype int - 1 if the creation operation succeeded, 0 otherwise
     */
    public int create(String sessionKey, String label, String name,
            String summary, String archLabel, String parentLabel, String checksumType,
            Map gpgKey, Map yumRepo)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        CreateChannelCommand ccc = new CreateChannelCommand();
        ccc.setArchLabel(archLabel);
        ccc.setLabel(label);
        ccc.setName(name);
        ccc.setSummary(summary);
        ccc.setParentLabel(parentLabel);
        ccc.setUser(user);
        ccc.setChecksum(checksumType);
        ccc.setGpgKeyUrl((String)gpgKey.get("url"));
        ccc.setGpgKeyId((String)gpgKey.get("id"));
        ccc.setGpgKeyFp((String)gpgKey.get("fingerprint"));
        ccc.setYumUrl((String)yumRepo.get("url"));
        ccc.setRepoLabel((String)yumRepo.get("label"));
        ccc.setSyncRepo(BooleanUtils.toBoolean((Boolean) yumRepo.get("sync")));

        return (ccc.create() != null) ? 1 : 0;
    }

    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param sessionKey WebSession containing User information.
     * @param label Channel label to be created
     * @param name Name of Channel
     * @param summary Channel Summary
     * @param archLabel Architecture label
     * @param parentLabel Parent Channel label (may be null)
     * @param checksumType checksum type for this channel
     * @return 1 if creation of channel succeeds.
     * @since 10.9
     * @throws PermissionCheckFailureException  thrown if user does not have
     * permission to create the channel.
     * @throws InvalidChannelNameException thrown if given name is in use or
     * otherwise, invalid.
     * @throws InvalidChannelLabelException throw if given label is in use or
     * otherwise, invalid.
     * @throws InvalidParentChannelException thrown if parent label is for a
     * channel that is not a base channel.
     *
     * @xmlrpc.doc Creates a software channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "label of the new channel")
     * @xmlrpc.param #param_desc("string", "name", "name of the new channel")
     * @xmlrpc.param #param_desc("string", "summary" "summary of the channel")
     * @xmlrpc.param #param_desc("string", "archLabel",
     *              "the label of the architecture the channel corresponds to")
     *      #options()
     *          #item_desc ("channel-ia32", "For 32 bit channel architecture")
     *          #item_desc ("channel-ia64", "For 64 bit channel architecture")
     *          #item_desc ("channel-sparc", "For Sparc channel architecture")
     *          #item_desc ("channel-alpha", "For Alpha channel architecture")
     *          #item_desc ("channel-s390", "For s390 channel architecture")
     *          #item_desc ("channel-s390x", "For s390x  channel architecture")
     *          #item_desc ("channel-iSeries", "For i-Series channel architecture")
     *          #item_desc ("channel-pSeries", "For p-Series channel architecture")
     *          #item_desc ("channel-x86_64", "For x86_64 channel architecture")
     *          #item_desc ("channel-ppc", "For PPC channel architecture")
     *          #item_desc ("channel-sparc-sun-solaris",
     *                                  "For Sparc Solaris channel architecture")
     *          #item_desc ("channel-i386-sun-solaris",
     *                                  "For i386 Solaris channel architecture")
     *      #options_end()
     * @xmlrpc.param #param_desc("string", "parentLabel", "label of the parent of this
     *              channel, an empty string if it does not have one")
     * @xmlrpc.param #param_desc("string", "checksumType", "checksum type for this channel,
     *              used for yum repository metadata generation")
     *      #options()
     *          #item_desc ("sha1", "Offers widest compatibility  with clients")
     *          #item_desc ("sha256", "Offers highest security, but is compatible
     *                        only with newer clients: Fedora 11 and newer,
     *                        or Enterprise Linux 6 and newer.")
     *      #options_end()
     * @xmlrpc.returntype int - 1 if the creation operation succeeded, 0 otherwise
     */

    public int create(String sessionKey, String label, String name,
            String summary, String archLabel, String parentLabel, String checksumType)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        return create(sessionKey, label, name,
                summary, archLabel, parentLabel, checksumType,
                new HashMap(), new HashMap());
    }
    
    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param sessionKey WebSession containing User information.
     * @param label Channel label to be created
     * @param name Name of Channel
     * @param summary Channel Summary
     * @param archLabel Architecture label
     * @param parentLabel Parent Channel label (may be null)
     * @return 1 if creation of channel succeeds.
     * @throws PermissionCheckFailureException  thrown if user does not have
     * permission to create the channel.
     * @throws InvalidChannelNameException thrown if given name is in use or
     * otherwise, invalid.
     * @throws InvalidChannelLabelException throw if given label is in use or
     * otherwise, invalid.
     * @throws InvalidParentChannelException thrown if parent label is for a
     * channel that is not a base channel.
     *
     * @xmlrpc.doc Creates a software channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "label of the new channel")
     * @xmlrpc.param #param_desc("string", "name", "name of the new channel")
     * @xmlrpc.param #param_desc("string", "summary" "summary of the channel")
     * @xmlrpc.param #param_desc("string", "archLabel",
     *              "the label of the architecture the channel corresponds to")
     *      #options()
     *          #item_desc ("channel-ia32", "For 32 bit channel architecture")
     *          #item_desc ("channel-ia64", "For 64 bit channel architecture")
     *          #item_desc ("channel-sparc", "For Sparc channel architecture")
     *          #item_desc ("channel-alpha", "For Alpha channel architecture")
     *          #item_desc ("channel-s390", "For s390 channel architecture")
     *          #item_desc ("channel-s390x", "For s390x  channel architecture")
     *          #item_desc ("channel-iSeries", "For i-Series channel architecture")
     *          #item_desc ("channel-pSeries", "For p-Series channel architecture")
     *          #item_desc ("channel-x86_64", "For x86_64 channel architecture")
     *          #item_desc ("channel-ppc", "For PPC channel architecture")
     *          #item_desc ("channel-sparc-sun-solaris",
     *                                  "For Sparc Solaris channel architecture")
     *          #item_desc ("channel-i386-sun-solaris",
     *                                  "For i386 Solaris channel architecture")
     *      #options_end()
     * @xmlrpc.param #param_desc("string", "parentLabel", "label of the parent of this
     *              channel, an empty string if it does not have one")
     * @xmlrpc.returntype int - 1 if the creation operation succeeded, 0 otherwise
     */
    public int create(String sessionKey, String label, String name,
            String summary, String archLabel, String parentLabel)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        return create(sessionKey, label, name, summary, archLabel, parentLabel, "sha1");
    }

    /**
     * Set the contact/support information for given channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @param maintainerName The name of the channel maintainer
     * @param maintainerEmail The email address of the channel maintainer
     * @param maintainerPhone The phone number of the channel maintainer
     * @param supportPolicy The channel support polity
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The channelLabel is invalid
     *   - The user doesn't have channel admin permissions
     *
     * @xmlrpc.doc Set contact/support information for given channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("string", "maintainerName", "name of the channel 
     * maintainer")
     * @xmlrpc.param #param_desc("string", "maintainerEmail", "email of the channel 
     * maintainer")
     * @xmlrpc.param #param_desc("string", "maintainerPhone", "phone number of the channel
     * maintainer")
     * @xmlrpc.param #param_desc("string", "supportPolicy", "channel support policy")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int setContactDetails(String sessionKey, String channelLabel, 
            String maintainerName, String maintainerEmail, String maintainerPhone, 
            String supportPolicy) 
        throws FaultException {
        
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        
        Channel channel = lookupChannelByLabel(user, channelLabel);

        channel.setMaintainerName(maintainerName);
        channel.setMaintainerEmail(maintainerEmail);
        channel.setMaintainerPhone(maintainerPhone);
        channel.setSupportPolicy(supportPolicy);
        
        ChannelFactory.save(channel);
        
        return 1;
    }

    /**
     * Returns list of subscribed systems for the given channel label.
     * @param sessionKey WebSession containing User information.
     * @param label Label of the channel in question.
     * @return Returns an array of maps representing a system. Contains system id and 
     * system name for each system subscribed to this channel.
     * @throws FaultException A FaultException is thrown if:
     *   - Logged in user is not a channel admin.
     *   - Channel does not exist.
     *
     * @xmlrpc.doc Returns list of subscribed systems for the given channel label
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *          #array()
     *              #struct("system")
     *                  #prop("int", "id")
     *                  #prop("string", "name")
     *              #struct_end()
     *           #array_end()
     */
    public Object[] listSubscribedSystems(String sessionKey, String label) 
        throws FaultException {
        
        User user = getLoggedInUser(sessionKey);
        
        // Make sure user has access to the orgs channels
        if (!user.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        // Get the channel. 
        Channel channel = lookupChannelByLabel(user.getOrg(), label);
        
        DataResult<Map> dr = SystemManager.systemsSubscribedToChannel(channel, user);
        for (Map sys : dr) {
            sys.remove("selectable");
        }
        return dr.toArray();
    }
    
    /**
     * Retrieve the channels for a given system id.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id of the system in question.
     * @return Returns an array of maps representing the channels this system is
     * subscribed to. 
     * @throws FaultException A FaultException is thrown if:
     *   - sessionKey is invalid
     *   - Server does not exist
     *   - User does not have access to system 
     *
     * @xmlrpc.doc Returns a list of channels that a system is subscribed to for the 
     * given system id
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.returntype
     *          #array()
     *              #struct("channel")
     *                  #prop("string", "label")
     *                  #prop("string", "name")
     *              #struct_end()
     *           #array_end()
     */
    public Object[] listSystemChannels(String sessionKey, Integer sid) 
        throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = XmlRpcSystemHelper.getInstance().lookupServer(loggedInUser, sid);
        
        DataResult dr = SystemManager.channelsForServer(server);
        return dr.toArray();
    }
    
    /**
     * Change a systems subscribed channels to the list of channels passed in.
     * @param sessionKey The sessionKey containing the logged in user
     * @param sid The id for the system in question
     * @param channelLabels The list of labels to subscribe the system to
     * @return Returns 1 on success, Exception otherwise.
     * @throws FaultException A FaultException is thrown if:
     *   - sessionKey is invalid
     *   - server doesn't exist
     *   - channel doesn't exist
     *   - user can't subscribe server to channel
     *   - a base channel is not specified
     *   - multiple base channels are specified
     * @deprecated being replaced by system.setBaseChannel(string sessionKey,
     * int serverId, string channelLabel) and system.setChildChannels(string sessionKey,
     * int serverId, array[string channelLabel])
     *
     * @xmlrpc.doc Change a systems subscribed channels to the list of channels passed in.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("string", "channelLabel - labels of the channels to 
     *              subscribe the system to.")
     * @xmlrpc.returntype int - 1 on success, 0 otherwise
     */
    public int setSystemChannels(String sessionKey, Integer sid, List channelLabels) 
        throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Server server = XmlRpcSystemHelper.getInstance().lookupServer(loggedInUser, sid);
        List<Channel> channels = new ArrayList<Channel>();
        log.debug("setSystemChannels()");

        // Verify that each channel label we were passed corresponds to a valid channel 
        // and store in a list.
        Channel baseChannel = null;
        log.debug("Incoming channels:");
        for (Iterator itr = channelLabels.iterator(); itr.hasNext();) {
            String label = (String) itr.next();
            Channel channel = lookupChannelByLabel(loggedInUser, label);
            log.debug("   " + channel.getLabel());
            if (!ChannelManager.verifyChannelSubscribe(loggedInUser, channel.getId())) {
                throw new PermissionCheckFailureException();
            }
            
            // let's save ourselves some time and check the arches here
            if (!channel.getChannelArch().isCompatible(server.getServerArch())) {
                throw new InvalidChannelException();
            }
            
            if (baseChannel == null && channel.isBaseChannel()) {

                baseChannel = channel;

                // need to make sure the base channel is the first
                // item in the list because subscribeToServer can't subscribe
                // to a child channel unless the server is subscribed to a base
                // channel.  
                channels.add(0, channel);
            }
            else if (baseChannel != null && channel.isBaseChannel()) {
                throw new MultipleBaseChannelException(baseChannel.getLabel(), label);
            }
            else {
                channels.add(channel);
            }
        }
        
        // if we can't find a base channel in the list, we need to leave
        // the system alone and punt.
        if (baseChannel == null) {
            throw new InvalidChannelException("No base channel specified");
        }

        // Unsubscribe the server from it's current channels (if any)
        Set<Channel> currentlySubscribed = server.getChannels();
        Channel oldBase = server.getBaseChannel();
        log.debug("Unsubscribing from:");
        for (Channel channel : currentlySubscribed) {
            if (channel.isBaseChannel()) {
                continue; // must leave base for now
            }
            server = SystemManager.unsubscribeServerFromChannel(server, channel);
            log.debug("   " + channel.getLabel());
        }
        
        // We must unsubscribe from the old Base channel last, so no child channels
        // are still subscribed
        if (!channels.contains(oldBase)) {
            server = SystemManager.unsubscribeServerFromChannel(server, oldBase);
        }
        else {
            // Base is the same, no need to resubscribe:
            channels.remove(oldBase);
        }

        
        // Subscribe the server to channels in channels list
        log.debug("Subscribing to:");
        for (Channel channel : channels) {
            server = SystemManager.subscribeServerToChannel(loggedInUser, server, 
                    channel, true);
            log.debug("   " + channel.getName());
        }
        
        //Update errata cache
        publishUpdateErrataCacheEvent(loggedInUser.getOrg());
        return 1;
    }

    /**
     * Set the subscribable flag for a given channel and user. If value is set to 'true', 
     * this method will give the user subscribe permissions to the channel. Otherwise, this
     * method revokes that privilege.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel in question
     * @param login The login for the user in question
     * @param value The boolean value telling us whether to grant subscribe permission or
     * revoke it.
     * @return Returns 1 on success, FaultException otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The loggedInUser doesn't have permission to perform this action
     *   - The login, sessionKey, or channelLabel is invalid
     *
     * @xmlrpc.doc Set the subscribable flag for a given channel and user. 
     * If value is set to 'true', this method will give the user 
     * subscribe permissions to the channel. Otherwise, that privilege is revoked.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("string", "login", "login of the target user")
     * @xmlrpc.param #param_desc("boolean", "value", "value of the flag to set")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setUserSubscribable(String sessionKey, String channelLabel, 
                   String login, Boolean value) throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);
        
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        //Verify permissions
        if (!(UserManager.verifyChannelAdmin(loggedInUser, channel) ||
              loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN))) {
            throw new PermissionCheckFailureException();
        }
        
        if (value) {
            // Add the 'subscribe' role for the target user to the channel
            ChannelManager.addSubscribeRole(target, channel);
        }
        else {
            // Remove the 'subscribe' role for the target user to the channel
            ChannelManager.removeSubscribeRole(target, channel);
        }
        
        return 1;
    }
    
    /**
     * Returns whether the channel may be subscribed to by the given user.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel in question
     * @param login The login for the user in question
     * @return whether the channel may be subscribed to by the given user.
     * @throws FaultException thrown if
     *   - The loggedInUser doesn't have permission to perform this action
     *   - The login, sessionKey, or channelLabel is invalid
     *
     * @xmlrpc.doc Returns whether the channel may be subscribed to by the given user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("string", "login", "login of the target user")
     * @xmlrpc.returntype int - 1 if subscribable, 0 if not
     */
    public int isUserSubscribable(String sessionKey, String channelLabel,
            String login) throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);
        
        Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), channelLabel);
        //Verify permissions
        if (!(UserManager.verifyChannelAdmin(loggedInUser, channel) ||
              loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN))) {
            throw new PermissionCheckFailureException();
        }
        
        boolean flag = ChannelManager.verifyChannelSubscribe(target, channel.getId());
        return BooleanUtils.toInteger(flag);
    }
    
    /**
     * Set globally subscribable attribute for given channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel to change
     * @param value The boolean value to set globally subscribable to.
     * @return Returns 1 if successful, exception otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionkey is invalid
     *   - The channel is invalid
     *   - The logged in user isn't a channel admin
     *
     * @xmlrpc.doc Set globally subscribable attribute for given channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("boolean", "subscribable", "true if the channel is to be   
     *          globally subscribable.  False otherwise.")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int setGloballySubscribable(String sessionKey, String channelLabel, 
                   boolean value) throws FaultException {
        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), channelLabel);
        
        try {
            if (!ChannelManager.verifyChannelAdmin(loggedInUser, channel.getId())) {
                throw new PermissionCheckFailureException();
            }
        }
        catch (InvalidChannelRoleException e) {
            throw new PermissionCheckFailureException();
        }
        
        if (value) {
            channel.setGloballySubscribable(true, loggedInUser.getOrg());
        }
        else {
            channel.setGloballySubscribable(false, loggedInUser.getOrg());
        }
        
        return 1;
    }
    
    /**
     * Adds a given list of packages to the given channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param packageIds A list containing the ids of the packages to be added
     * @return Returns 1 if successfull, FaultException otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The user is not a channel admin for the channel
     *   - The channel is invalid
     *   - A package id is invalid
     *   - The user doesn't have access to one of the channels in the list
     *
     * @xmlrpc.doc Adds a given list of packages to the given channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "target channel.")
     * @xmlrpc.param #array_single("int", "packageId -  id of a package to
     *                                   add to the channel.")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int addPackages(String sessionKey, String channelLabel, List packageIds)
        throws FaultException {
        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), channelLabel);

        //Make sure the user is a channel admin for the given channel.
        if (!UserManager.verifyChannelAdmin(loggedInUser, channel)) {
            throw new PermissionCheckFailureException();
        }
        
        // Try to add the list of packages to the channel. Catch any exceptions and 
        // convert to FaultExceptions
        try {
            ChannelEditor.getInstance().addPackages(loggedInUser, channel, packageIds);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException();
        }
        catch (LookupException le) {
            //This shouldn't happen, but if it does, it is because one of the packages
            //doesn't exist.
            throw new NoSuchPackageException(le);
        }
        catch (IncompatibleArchException iae) {
            throw new FaultException(1202, "incompatiblePackageArch",
                    "package architecture is incompatible with channel", iae);
        }

        //refresh channel with newest packages
        ChannelManager.refreshWithNewestPackages(channel, "api");
        
        /* Bugzilla # 177673 */
        scheduleErrataCacheUpdate(loggedInUser.getOrg(), channel, 3600000);
        
        //if we made it this far, the operation was a success!
        return 1;
    }
    
    /**
     * Removes a given list of packages from the given channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param packageIds A list containing the ids of the packages to be removed
     * @return Returns 1 if successfull, FaultException otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The user is not a channel admin for the channel
     *   - The channel is invalid
     *   - A package id is invalid
     *   - The user doesn't have access to one of the channels in the list
     *
     * @xmlrpc.doc Removes a given list of packages from the given channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "target channel.")
     * @xmlrpc.param #array_single("int", "packageId -  id of a package to
     *                                   remove from the channel.")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int removePackages(String sessionKey, String channelLabel, List packageIds) 
        throws FaultException {
        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), channelLabel);

        //Make sure the user is a channel admin for the given channel.
        if (!UserManager.verifyChannelAdmin(loggedInUser, channel)) {
            throw new PermissionCheckFailureException();
        }
        
        // Try to remove the list of packages from the channel. Catch any exceptions and 
        // convert to FaultExceptions
        try {
            ChannelEditor.getInstance().removePackages(loggedInUser, channel, packageIds);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException();
        }
        catch (LookupException le) {
            //This shouldn't happen, but if it does, it is because one of the packages
            //doesn't exist.
            throw new NoSuchPackageException(le);
        }

        //refresh channel with newest packages
        ChannelManager.refreshWithNewestPackages(channel, "api");
        
        /* Bugzilla # 177673 */
        scheduleErrataCacheUpdate(loggedInUser.getOrg(), channel, 3600000);
        
        //if we made it this far, the operation was a success!
        return 1;
    }
    
    /**
     * Private helper method to create a new UpdateErrataCacheEvent and publish it to the
     * MessageQueue.
     * @param orgIn The org we're updating.
     */
    private void publishUpdateErrataCacheEvent(Org orgIn) {
        StopWatch sw = new StopWatch();
        if (log.isDebugEnabled()) {
            log.debug("Updating errata cache");
            sw.start();
        }
        
        UpdateErrataCacheEvent uece = 
            new UpdateErrataCacheEvent(UpdateErrataCacheEvent.TYPE_ORG);
        uece.setOrgId(orgIn.getId());
        MessageQueue.publish(uece);
        
        if (log.isDebugEnabled()) {
            sw.stop();
            log.debug("Finished Updating errata cache. Took [" +
                    sw.getTime() + "]");
        }
    }


    /**
     * List the errata applicable to a channel after given startDate
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param startDate begin date
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     *
     * @xmlrpc.doc List the errata applicable to a channel after given startDate
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param($date, "startDate")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */
    public List listErrata(String sessionKey, String channelLabel,
            Date startDate) throws NoSuchChannelException {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        DataResult dr = ChannelManager.listErrata(channel, startDate, null, loggedInUser);
        dr.elaborate();
        return dr;
    }

    /**
     * List the errata applicable to a channel between startDate and endDate.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param startDate begin date
     * @param endDate end date
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     *
     * @xmlrpc.doc List the errata applicable to a channel between startDate and endDate.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param($date, "startDate")
     * @xmlrpc.param #param($date, "endDate")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */

    public List<ErrataOverview> listErrata(String sessionKey, String channelLabel,
            Date startDate, Date endDate) throws NoSuchChannelException {

        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        DataResult errata = ChannelManager.listErrata(channel, startDate, endDate,
                loggedInUser);
        errata.elaborate();
        return errata;
    }




    /**
     * List the errata applicable to a channel
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     *
     * When removing deprecation, swtich this method over to using
     *     listErrata(sessionKey, null, null) after deleting
     *     listErrata(String, String, String, String), then update docs
     *     to use  $ErrataOverviewSerializer
     *
     *
     * @xmlrpc.doc List the errata applicable to a channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype
     *    #array()
     *      #struct("errata")
     *        #prop_desc("int", "id", "Errata Id")
     *        #prop_desc("string", "date", "Date erratum was created.")
     *        #prop_desc("string", "advisory_synopsis", "Summary of the erratum.")
     *        #prop_desc("string", "advisory_type", "Type label such as Security, Bug Fix")
     *        #prop_desc("string", "advisory_name", "Name such as RHSA, etc")
     *        #prop_desc("string","advisory", "name of the advisory (Deprecated)")
     *        #prop_desc("string","issue_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS (Deprecated)")
     *        #prop_desc("string","update_date",
     *                        "date format follows YYYY-MM-DD HH24:MI:SS (Deprecated)")
     *        #prop("string","synopsis (Deprecated)")
     *        #prop_desc("string","last_modified_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS (Deprecated)")
     *      #struct_end()
     *    #array_end()
     */
    public List listErrata(String sessionKey, String channelLabel)
        throws NoSuchChannelException {
        List<Map> list = (List<Map>) listErrata(sessionKey, channelLabel, "", "");
        return list;
    }
    
    /**
     * List the errata applicable to a channel after given startDate
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param startDate begin date
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     * @deprecated being replaced by listErrata(string sessionKey,
     * string channelLabel, dateTime.iso8601 startDate)
     *
     * @xmlrpc.doc List the errata applicable to a channel after given startDate
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("errata")
     *              #prop_desc("string","advisory", "name of the advisory")
     *              #prop_desc("string","issue_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop_desc("string","update_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop("string","synopsis")
     *              #prop("string","advisory_type")
     *              #prop_desc("string","last_modified_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *          #struct_end()
     *      #array_end()
     */
    public List listErrata(String sessionKey, String channelLabel,
            String startDate) throws NoSuchChannelException {
        
        return listErrata(sessionKey, channelLabel, startDate, null);
    }
    
    /**
     * List the errata applicable to a channel between startDate and endDate.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param startDate begin date
     * @param endDate end date
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     * @deprecated being replaced by listErrata(string sessionKey,
     * string channelLabel, dateTime.iso8601 startDate, dateTime.iso8601)
     *
     * @xmlrpc.doc List the errata applicable to a channel between startDate and endDate.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("errata")
     *              #prop_desc("string","advisory", "name of the advisory")
     *              #prop_desc("string","issue_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop_desc("string","update_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop("string","synopsis")
     *              #prop("string","advisory_type")
     *              #prop_desc("string","last_modified_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *          #struct_end()
     *      #array_end()
     */

    public List listErrata(String sessionKey, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        
        List errata = ChannelManager.listErrataForDates(channel, startDate, endDate);
        return errata;
    }
    
    /**
     * List the errata of a specific type that are applicable to a channel
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param advisoryType The type of advisory (one of the following:
     * "Security Advisory", "Product Enhancement Advisory",
     * "Bug Fix Advisory")
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     *
     * @xmlrpc.doc List the errata of a specific type that are applicable to a channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param_desc("string", "advisoryType", "type of advisory (one of
     * of the following: 'Security Advisory', 'Product Enhancement Advisory',
     * 'Bug Fix Advisory'")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("errata")
     *              #prop_desc("string","advisory", "name of the advisory")
     *              #prop_desc("string","issue_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop_desc("string","update_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *              #prop("string","synopsis")
     *              #prop("string","advisory_type")
     *              #prop_desc("string","last_modified_date",
     *                         "date format follows YYYY-MM-DD HH24:MI:SS")
     *          #struct_end()
     *      #array_end()
     */
    public Object[] listErrataByType(String sessionKey, String channelLabel,
            String advisoryType) throws NoSuchChannelException {

        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        List errata = ChannelManager.listErrataByType(channel, advisoryType);
        return errata.toArray();
    }

    private void scheduleErrataCacheUpdate(Org org, Channel channel, long delay) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME, 
                                           "find_channel_in_task_queue");
        Map inParams = new HashMap();
        
        inParams.put("cid", channel.getId());
        DataResult dr = m.execute(inParams);
        
        delay /= (24 * 60 * 60);
        
        if (dr.isEmpty()) {
            WriteMode w = ModeFactory.getWriteMode(TaskConstants.MODE_NAME, 
                                                         "insert_into_task_queue");
            
            inParams = new HashMap();
            inParams.put("org_id", org.getId());
            inParams.put("cid", channel.getId());
            inParams.put("task_data", "update_errata_cache_by_channel");
            inParams.put("earliest", new Timestamp(System.currentTimeMillis() + delay));
            
            w.executeUpdate(inParams);
        }
        else {
            WriteMode w = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                                                         "update_task_queue");
            inParams = new HashMap();
            inParams.put("earliest", new Timestamp(System.currentTimeMillis() + delay));
            inParams.put("cid", channel.getId());
            
            w.executeUpdate(inParams);
        }
    }
    
    private Channel lookupChannelByLabel(User user, String label)
        throws NoSuchChannelException {

        Channel channel = ChannelFactory.lookupByLabelAndUser(label, user);
        if (channel == null) {
            throw new NoSuchChannelException();
        }

        return channel;
    }
    
    
    private Channel lookupChannelByLabel(Org org, String label)
        throws NoSuchChannelException {

        Channel channel = ChannelManager.lookupByLabel(
                org, label);
        if (channel == null) {
            throw new NoSuchChannelException();
        }
        
        return channel;
    }
    
    private Channel lookupChannelById(User user, int id)
        throws NoSuchChannelException {
    
        Channel channel = ChannelManager.lookupByIdAndUser(new Long(id), user);
        if (channel == null) {
            throw new NoSuchChannelException();
        }
        
        return channel;
    }
    
    
    /**
     * Lists all packages for an Org that are not contained within any channel
     * @param sessionKey WebSession containing User information.
     * @return list of Package objects not associated with a channel
     * @throws NoSuchChannelException thrown if no channel is found.
     *
     * @xmlrpc.doc Lists all packages that are not associated with a channel.  Typically 
     *          these are custom packages.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *  #array()
     *      $PackageSerializer
     *   #array_end()
     */
    public Object[] listPackagesWithoutChannel(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureUserRole(loggedInUser, RoleFactory.CHANNEL_ADMIN);
        return PackageFactory.lookupOrphanPackages(loggedInUser.getOrg()).toArray();
    }
    
    /**
     * Subscribe a system to a list of channels
     * @param sessionKey The key of the logged in user
     * @param labels a list of channel labels to subscribe the system to
     * @param sid the serverId of the system in question
     * @return 1 for success
     * @deprecated being replaced by system.setBaseChannel(string sessionKey,
     * int serverId, string channelLabel) and system.setChildChannels(string sessionKey,
     * int serverId, array[string channelLabel])
     * 
     * @xmlrpc.doc Subscribes a system to a list of channels.  If a base channel is  
     *      included, that is set before setting child channels.  When setting child 
     *      channels the current child channel subscriptions are cleared.  To fully 
     *      unsubscribe the system from all channels, simply provide an empty list of 
     *      channel labels.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("int", "serverId")
     * @xmlrpc.param #array_single("string", "label - channel label to subscribe 
     *                  the system to.") 
     * @xmlrpc.returntype #return_int_success()
     */
    public int subscribeSystem(String sessionKey, Integer sid, List labels) {
        User loggedInUser = getLoggedInUser(sessionKey);
        
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()), 
                loggedInUser);

        
        if (labels.size() == 0) {
            ServerFactory.unsubscribeFromAllChannels(loggedInUser, server);
            return 1;
        }
        
        Channel base = null;
        List<Integer> childChannelIds = new ArrayList();
        
        for (Iterator itr = labels.iterator(); itr.hasNext();) {
            String label = (String) itr.next();
           
            Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), label);

            if (base == null && channel.isBaseChannel()) {
                base = channel;
            }
            else if (base != null && channel.isBaseChannel()) {
                throw new MultipleBaseChannelException(base.getLabel(), label);
            }
            else {
                childChannelIds.add(new Integer(channel.getId().intValue()));
            }
        }     
        SystemHandler sysHandler = new SystemHandler();
        if (base != null) {
            
            sysHandler.setBaseChannel(sessionKey, sid, 
                    new Integer(base.getId().intValue()));
        }
        sysHandler.setChildChannels(sessionKey, sid, childChannelIds);

        return 1;
    }
    
    
    /**
     * Clone a channel
     * @param sessionKey session of the user
     * @param originalLabel the label of the channel to clone
     * @param channelDetails a map consisting of 
     *      <li>string name</li>
     *      <li>string label</li>
     *      <li>string summary</li>
     *      <li>string parent_label (optional)</li>
     *      <li>string arch_label (optional)<li>
     *      <li>string gpg_url (optional)</li>
     *      <li>string gpg_id (optional)</li>
     *      <li>string gpg_fingerprint (optional)</li>
     *      <li>string description (optional)</li>   
     * @param originalState if true, only the original packages of the channel to clone 
     *          will be cloned.  Any updates will not be. 
     * @return int id of clone channel
     * 
     * @xmlrpc.doc Clone a channel.  If arch_label is omitted, the arch label of the 
     *      original channel will be used. If parent_label is omitted, the clone will be
     *      a base channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string", "original_label")
     * @xmlrpc.param 
     *      #struct("channel details")
     *          #prop("string", "name")
     *          #prop("string", "label")
     *          #prop("string", "summary")
     *          #prop_desc("string", "parent_label", "(optional)")
     *          #prop_desc("string", "arch_label", "(optional)")
     *          #prop_desc("string", "gpg_url", "(optional)")
     *          #prop_desc("string", "gpg_id", "(optional)")
     *          #prop_desc("string", "gpg_fingerprint", "(optional)")
     *          #prop_desc("string", "description", "(optional)")
     *      #struct_end()
     * @xmlrpc.param #param("boolean", "original_state")
     * @xmlrpc.returntype int the cloned channel ID
     */
    public int clone(String sessionKey, String originalLabel, Map channelDetails, 
            Boolean originalState) {

        // confirm that the user only provided valid keys in the map
        Set<String> validKeys = new HashSet<String>();
        validKeys.add("name");
        validKeys.add("label");
        validKeys.add("summary");
        validKeys.add("parent_label");
        validKeys.add("arch_label");
        validKeys.add("gpg_url");
        validKeys.add("gpg_id");
        validKeys.add("gpg_fingerprint");
        validKeys.add("description");
        validateMap(validKeys, channelDetails);

        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);
        
        String name = (String) channelDetails.get("name");
        String label = (String) channelDetails.get("label");
        String parentLabel = (String) channelDetails.get("parent_label");
        String archLabel = (String) channelDetails.get("arch_label");
        String summary = (String) channelDetails.get("summary");
        String gpgUrl =  (String) channelDetails.get("gpg_url");
        String gpgId =  (String) channelDetails.get("gpg_id");
        String gpgFingerprint =  (String) channelDetails.get("gpg_fingerprint");
        String description =  (String) channelDetails.get("description");
        
        if (ChannelFactory.lookupByLabel(loggedInUser.getOrg(), label) != null) {
            throw new DuplicateChannelLabelException(label);
        }
        
        Channel originalChan = lookupChannelByLabel(loggedInUser.getOrg(), originalLabel);
        
        Channel parent = null;
        if (parentLabel != null) {
            parent = lookupChannelByLabel(loggedInUser.getOrg(), parentLabel);
        }
        
        ChannelArch arch = null;
        if (archLabel != null && archLabel.length() > 0) {
        
            arch = ChannelFactory.lookupArchByName(archLabel);
            if (arch == null) {
                throw new InvalidChannelArchException(archLabel);
            }
        }
        else {
            arch = originalChan.getChannelArch(); 
        }
        
        NewChannelHelper helper = new NewChannelHelper();
        helper.setName(name);
        helper.setArch(arch);
        helper.setDescription(description);
        helper.setGpgFingerprint(gpgFingerprint);
        helper.setGpgId(gpgId);
        helper.setGpgUrl(gpgUrl);
        helper.setLabel(label);
        helper.setParent(parent);
        helper.setUser(loggedInUser);
        helper.setSummary(summary);
        
        return helper.clone(originalState.booleanValue(), originalChan).getId().intValue();
    }

    /**
     * Checks whether a user is an org admin or channnel admin (and thus can admin 
     *          a channel)
     * @param loggedInUser the user to check
     */
    private void channelAdminPermCheck(User loggedInUser) {
        Role channelRole = RoleFactory.lookupByLabel("channel_admin");
        Role orgAdminRole = RoleFactory.lookupByLabel("org_admin");
        if (!loggedInUser.hasRole(channelRole) && !loggedInUser.hasRole(orgAdminRole)) {
            throw new PermissionException("Only Org Admins and Channel Admins can clone " +
                    "channels.");
        }
    }
    
    /**
     * Merge a channel's errata into another channel.
     * @param sessionKey session of the user
     * @param mergeFromLabel the label of the channel to pull the errata from
     * @param mergeToLabel the label of the channel to push errata into
     * @return A list of errata that were merged.
     *
     * @xmlrpc.doc Merges all errata from one channel into another
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "mergeFromLabel", "the label of the
     * channel to pull errata from")
     * @xmlrpc.param #param_desc("string", "mergeToLabel", "the label to push the
     * errata into")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataSerializer
     *      #array_end()
     */
    public Object[] mergeErrata(String sessionKey, String mergeFromLabel,
            String mergeToLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        try {
               ChannelManager.verifyChannelAdmin(loggedInUser, mergeTo.getId());
        }
        catch (InvalidChannelRoleException e) {
            LocalizationService ls = LocalizationService.getInstance();
            throw new PermissionException(ls.getMessage(
                    "frontend.xmlrpc.channels.software.merge.permsfailure",
                    mergeTo.getLabel()));
        }

        List<Errata> differentErrata = new ArrayList<Errata>();

        Set<Errata> toErrata = mergeTo.getErratas();
        Set<Errata> fromErrata = mergeFrom.getErratas();
       
        for (Errata errata : fromErrata) {
            if (!toErrata.contains(errata)) {
                differentErrata.add(errata);
            }
        }
        mergeTo.getErratas().addAll(differentErrata);
        ChannelFactory.save(mergeTo);
        return differentErrata.toArray();
    }
    
    /**
     * Merge a channel's errata into another channel based upon a given start/end date. 
     * @param sessionKey session of the user
     * @param mergeFromLabel the label of the channel to pull the errata from
     * @param mergeToLabel the label of the channel to push errata into
     * @param startDate begin date
     * @param endDate end date
     * @return A list of errata that were merged.
     *
     * @xmlrpc.doc Merges all errata from one channel into another based upon a 
     * given start/end date.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "mergeFromLabel", "the label of the
     * channel to pull errata from")
     * @xmlrpc.param #param_desc("string", "mergeToLabel", "the label to push the
     * errata into")
     * @xmlrpc.param #param("string", "startDate")
     * @xmlrpc.param #param("string", "endDate")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataSerializer
     *      #array_end()
     */
    public Object[] mergeErrata(String sessionKey, String mergeFromLabel,
            String mergeToLabel, String startDate, String endDate) {

        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        try {
               ChannelManager.verifyChannelAdmin(loggedInUser, mergeTo.getId());
        }
        catch (InvalidChannelRoleException e) {
            LocalizationService ls = LocalizationService.getInstance();
            throw new PermissionException(ls.getMessage(
                    "frontend.xmlrpc.channels.software.merge.permsfailure",
                    mergeTo.getLabel()));
        }

        List<Errata> differentErrata = new ArrayList<Errata>();

        Set<Errata> toErrata = mergeTo.getErratas();
        List<Errata> fromErrata = ErrataFactory.lookupByChannelBetweenDates(
                loggedInUser.getOrg(), mergeFrom, startDate, endDate);

        for (Errata errata : fromErrata) {
            if (!toErrata.contains(errata)) {
                differentErrata.add(errata);
            }
        }
        mergeTo.getErratas().addAll(differentErrata);
        ChannelFactory.save(mergeTo);
        return differentErrata.toArray();
    }

    /*
     public Object[] listErrata(String sessionKey, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        //Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        List errata = ChannelManager.listErrata(channel, startDate, endDate);
        return errata.toArray();
     */
    
    /**
     * Merge a channel's packages into another channel.
     * @param sessionKey session of the user 
     * @param mergeFromLabel the label of the channel to pull the packages from
     * @param mergeToLabel the label of the channel to push packages into
     * @return A list of packages that were merged.
     * 
     * @xmlrpc.doc Merges all packages from one channel into another
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "mergeFromLabel", "the label of the 
     *          channel to pull packages from")
     * @xmlrpc.param #param_desc("string", "mergeToLabel", "the label to push the 
     *              packages into")
     * @xmlrpc.returntype  
     *      #array()
     *          $PackageSerializer
     *      #array_end()
     */
    public Object[] mergePackages(String sessionKey, String mergeFromLabel, 
            String mergeToLabel) {
        
        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);
        
        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);
        
        try {
               ChannelManager.verifyChannelAdmin(loggedInUser, mergeTo.getId());
        }
        catch (InvalidChannelRoleException e) {
            LocalizationService ls = LocalizationService.getInstance();
            throw new PermissionException(ls.getMessage(
                    "frontend.xmlrpc.channels.software.merge.permsfailure", 
                    mergeTo.getLabel()));
        }
        
        List<Package> differentPackages = new ArrayList<Package>();
        
        Set<Package> toPacks = mergeTo.getPackages();
        Set<Package> fromPacks = mergeFrom.getPackages();

        for (Package pack : fromPacks) {
            if (!toPacks.contains(pack)) {
                differentPackages.add(pack);
            }
        }
        mergeTo.getPackages().addAll(differentPackages);
        ChannelFactory.save(mergeTo);
        ChannelManager.refreshWithNewestPackages(mergeTo, "api");

        // Mark the affected channel to have it's metadata evaluated, where necessary
        // (RHEL5+, mostly)
        ChannelManager.queueChannelChange(mergeTo.getLabel(), "java::mergePackages",
            loggedInUser.getLogin());

        return differentPackages.toArray();
    }

    /**
     * Regenerate the errata cache for all the systems subscribed to a particular channel
     * @param sessionKey the session key
     * @param channelLabel the channel label
     * @return int - 1 on success!
     * 
     * @xmlrpc.doc Completely clear and regenerate the needed Errata and Package 
     *      cache for all systems subscribed to the specified channel.  This should 
     *      be used only if you believe your cache is incorrect for all the systems 
     *      in a given channel. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "the label of the 
     *          channel")
     * @xmlrpc.returntype  #return_int_success()  
     *          
     */
    public int regenerateNeededCache(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        List chanList = new ArrayList<Long>();
        chanList.add(chan.getId());
        ErrataCacheManager.updateCacheForChannelsAsync(chanList);
        return 1;
    }
    
    /**
     * Regenerate the errata cache for all the systems subscribed to the satellite
     * @param sessionKey the session key
     * @return int - 1 on success!
     * 
     * @xmlrpc.doc Completely clear and regenerate the needed Errata and Package 
     *      cache for all systems subscribed.  You must be a Satellite Admin to 
     *      perform this action. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype  #return_int_success()  
     *          
     */
    public int regenerateNeededCache(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        if (loggedInUser.hasRole(RoleFactory.SAT_ADMIN)) {
            Set set = new HashSet();
            set.addAll(ChannelFactory.listAllBaseChannels());
            ErrataCacheManager.updateCacheForChannelsAsync(set);
        }
        else {
            throw new PermissionException(RoleFactory.SAT_ADMIN);
        }
        return 1;
    }
    
    /**
     * Regenerate the yum cache for a specific channel.
     * @param sessionKey the session key
     * @param channelLabel the channel label
     * @return int - 1 on success!
     *
     * @xmlrpc.doc Regenerate yum cache for the specified channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "the label of the
     *          channel")
     * @xmlrpc.returntype  #return_int_success()
     *
     */
    public int regenerateYumCache(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        ChannelManager.queueChannelChange(channelLabel,
                "api: regenerateYumCache", "api called");
        return 1;

    }

    /**
     * List the children of a channel
     * @param sessionKey the session key
     * @param channelLabel the channel label
     * @return list of channel id's and labels
     *
     * @xmlrpc.doc List the children of a channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "the label of the channel")
     * @xmlrpc.returntype
     *      #array()
     *              $ChannelSerializer
     *      #array_end()
     */

    public Object[] listChildren(String sessionKey, String channelLabel) {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);

        return ChannelFactory.getAccessibleChildChannels(chan, loggedInUser).toArray();
    }

    /**
    * Returns the last build date on the repodata for a channel
    * @param sessionKey WebSession containing User information.
    * @param id - id of channel wanted
    * @throws NoSuchChannelException thrown if no channel is found.
    * @return the build date on the repodata of the channel requested
    *
    * @xmlrpc.doc Returns the last build date of the repomd.xml file
    * for the given channel as a localised string.
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("int", "id", "id of channel wanted")
    * @xmlrpc.returntype the last build date of the repomd.xml file
    * as a localised string
    */

    public String getChannelLastBuildById(String sessionKey, Integer id)
                                            throws NoSuchChannelException {
        User user = getLoggedInUser(sessionKey);
        String repoLastBuild =
                ChannelManager.getRepoLastBuild(lookupChannelById(user, id));
        if (repoLastBuild == null) {
            return "";
        }
        return repoLastBuild;
    }
}
