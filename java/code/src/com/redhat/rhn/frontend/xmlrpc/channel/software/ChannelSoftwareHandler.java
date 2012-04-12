/**
 * Copyright (c) 2009--2012 Red Hat, Inc.
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
import com.redhat.rhn.common.messaging.MessageQueue;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.channel.ContentSource;
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
import com.redhat.rhn.frontend.xmlrpc.InvalidParameterException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.frontend.xmlrpc.MultipleBaseChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchChannelException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchContentSourceException;
import com.redhat.rhn.frontend.xmlrpc.NoSuchPackageException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoLabelException;
import com.redhat.rhn.frontend.xmlrpc.channel.repo.InvalidRepoUrlException;
import com.redhat.rhn.frontend.xmlrpc.system.SystemHandler;
import com.redhat.rhn.frontend.xmlrpc.system.XmlRpcSystemHelper;
import com.redhat.rhn.frontend.xmlrpc.user.XmlRpcUserHelper;
import com.redhat.rhn.manager.channel.ChannelEditor;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.CreateChannelCommand;
import com.redhat.rhn.manager.channel.UpdateChannelCommand;
import com.redhat.rhn.manager.channel.repo.BaseRepoCommand;
import com.redhat.rhn.manager.channel.repo.CreateRepoCommand;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.errata.cache.ErrataCacheManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.taskomatic.TaskomaticApi;
import com.redhat.rhn.taskomatic.task.TaskConstants;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
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
    @Deprecated
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
    @Deprecated
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
    @Deprecated
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
    @Deprecated
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
    @Deprecated
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
        return lookupChannelById(user, id.longValue());
    }

    /**
     * Allows to modify channel attributes
     * @param sessionKey WebSession containing User information.
     * @param channelId id of channel to be modified
     * @param details map of channel attributes to be changed
     * @return 1 if edit was successful, exception thrown otherwise
     *
     * @xmlrpc.doc Allows to modify channel attributes
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "channelDd", "channel id")
     * @xmlrpc.param
     *  #struct("channel_map")
     *      #prop_desc("string", "checksum_label", "new channel repository checksum label
     *          (optional)")
     *      #prop_desc("string", "name", "new channel name (optional)")
     *      #prop_desc("string", "summary", "new channel summary (optional)")
     *      #prop_desc("string", "description", "new channel description (optional)")
     *      #prop_desc("string", "maintainer_name", "new channel maintainer name
     *          (optional)")
     *      #prop_desc("string", "maintainer_email", "new channel email address
     *          (optional)")
     *      #prop_desc("string", "maintainer_phone", "new channel phone number (optional)")
     *      #prop_desc("string", "gpg_key_url", "new channel gpg key url (optional)")
     *      #prop_desc("string", "gpg_key_id", "new channel gpg key id (optional)")
     *      #prop_desc("string", "gpg_key_fp", "new channel gpg key fingerprint
     *          (optional)")
     *  #struct_end()

     *@xmlrpc.returntype #return_int_success()
     */
    public int setDetails(String sessionKey, Integer channelId, Map details) {
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelById(user, channelId.longValue());

        Set<String> validKeys = new HashSet<String>();
        validKeys.add("checksum_label");
        validKeys.add("name");
        validKeys.add("summary");
        validKeys.add("description");
        validKeys.add("maintainer_name");
        validKeys.add("maintainer_email");
        validKeys.add("maintainer_phone");
        validKeys.add("gpg_key_url");
        validKeys.add("gpg_key_id");
        validKeys.add("gpg_key_fp");
        validateMap(validKeys, details);

        UpdateChannelCommand ucc = new UpdateChannelCommand(user, channel);

        if (details.containsKey("checksum_label")) {
            ucc.setChecksumLabel((String) details.get("checksum_label"));
        }

        if (details.containsKey("name")) {
            ucc.setName((String) details.get("name"));
        }

        if (details.containsKey("summary")) {
            ucc.setSummary((String)details.get("summary"));
        }

        if (details.containsKey("description")) {
            ucc.setDescription((String)details.get("description"));
        }

        if (details.containsKey("maintainer_name")) {
            ucc.setMaintainerName((String)details.get("maintainer_name"));
        }

        if (details.containsKey("maintainer_email")) {
            ucc.setMaintainerEmail((String)details.get("maintainer_email"));
        }

        if (details.containsKey("maintainer_phone")) {
            ucc.setMaintainerPhone((String)details.get("maintainer_phone"));
        }

        if (details.containsKey("gpg_key_url")) {
            ucc.setGpgKeyUrl((String)details.get("gpg_key_url"));
        }

        if (details.containsKey("gpg_key_id")) {
            ucc.setGpgKeyId((String)details.get("gpg_key_id"));
        }

        if (details.containsKey("gpg_key_fp")) {
            ucc.setGpgKeyFp((String)details.get("gpg_key_fp"));
        }

       ucc.update(channelId.longValue());
        return 1;
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
        return cnt.intValue();
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
     * @xmlrpc.returntype int - 1 if the creation operation succeeded, 0 otherwise
     */
    public int create(String sessionKey, String label, String name,
            String summary, String archLabel, String parentLabel, String checksumType,
            Map gpgKey)
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
        ccc.setChecksumLabel(checksumType);
        ccc.setGpgKeyUrl((String)gpgKey.get("url"));
        ccc.setGpgKeyId((String)gpgKey.get("id"));
        ccc.setGpgKeyFp((String)gpgKey.get("fingerprint"));

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
                new HashMap());
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
     * @xmlrpc.returntype #return_int_success()
     */
    @Deprecated
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
     * Set the manageable flag for a given channel and user. If value is set to 'true',
     * this method will give the user manage permissions to the channel. Otherwise, this
     * method revokes that privilege.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel in question
     * @param login The login for the user in question
     * @param value The boolean value telling us whether to grant manage permission or
     * revoke it.
     * @return Returns 1 on success, FaultException otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The loggedInUser doesn't have permission to perform this action
     *   - The login, sessionKey, or channelLabel is invalid
     *
     * @xmlrpc.doc Set the manageable flag for a given channel and user.
     * If value is set to 'true', this method will give the user
     * manage permissions to the channel. Otherwise, that privilege is revoked.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("string", "login", "login of the target user")
     * @xmlrpc.param #param_desc("boolean", "value", "value of the flag to set")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setUserManageable(String sessionKey, String channelLabel,
                   String login, Boolean value) throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(loggedInUser, login);

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        if (!channel.isCustom()) {
            throw new InvalidChannelException(
                    "Manageable flag is relevant for custom channels only.");
        }
        //Verify permissions
        if (!(UserManager.verifyChannelAdmin(loggedInUser, channel) ||
              loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN))) {
            throw new PermissionCheckFailureException();
        }

        if (value) {
            // Add the 'manage' role for the target user to the channel
            ChannelManager.addManageRole(target, channel);
        }
        else {
            // Remove the 'manage' role for the target user to the channel
            ChannelManager.removeManageRole(target, channel);
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
     * Returns whether the channel may be managed by the given user.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel in question
     * @param login The login for the user in question
     * @return whether the channel may be managed by the given user.
     * @throws FaultException thrown if
     *   - The loggedInUser doesn't have permission to perform this action
     *   - The login, sessionKey, or channelLabel is invalid
     *
     * @xmlrpc.doc Returns whether the channel may be managed by the given user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "label of the channel")
     * @xmlrpc.param #param_desc("string", "login", "login of the target user")
     * @xmlrpc.returntype int - 1 if manageable, 0 if not
     */
    public int isUserManageable(String sessionKey, String channelLabel,
            String login) throws FaultException {
        // Get Logged in user
        User loggedInUser = getLoggedInUser(sessionKey);
        User target = XmlRpcUserHelper.getInstance().lookupTargetUser(
                loggedInUser, login);

        Channel channel = lookupChannelByLabel(loggedInUser.getOrg(), channelLabel);
        if (!channel.isCustom()) {
            throw new InvalidChannelException(
                    "Manageable flag is relevant for custom channels only.");
        }
        //Verify permissions
        if (!(UserManager.verifyChannelAdmin(loggedInUser, channel) ||
              loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN))) {
            throw new PermissionCheckFailureException();
        }

        boolean flag = ChannelManager.verifyChannelManage(target, channel.getId());
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

        // Try to add the list of packages to the channel. Catch any exceptions and
        // convert to FaultExceptions
        try {
            ChannelEditor.getInstance().addPackages(loggedInUser, channel, packageIds);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e.getMessage());
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
     * Removes a given list of errata from the given channel.
     * @param sessionKey The sessionKey containing the logged in user
     * @param channelLabel The label for the channel
     * @param errataNames A list containing the advisory names of errata to remove
     * @param removePackages Boolean to remove packages from the channel also
     * @return Returns 1 if successfull, Exception otherwise
     *   - The user is not a channel admin for the channel
     *   - The channel is invalid
     *   - The user doesn't have access to one of the channels in the list
     *
     * @xmlrpc.doc Removes a given list of errata from the given channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "target channel.")
     * @xmlrpc.param #array_single("string", "advisoryName - name of an erratum to remove")
     * @xmlrpc.param #param_desc("boolean", "removePackages",
     *                          "True to remove packages from the channel")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int removeErrata(String sessionKey, String channelLabel,
            List errataNames, boolean removePackages) {

        User user = getLoggedInUser(sessionKey);
        channelAdminPermCheck(user);

        Channel channel = lookupChannelByLabel(user, channelLabel);

        if (!UserManager.verifyChannelAdmin(user, channel)) {
            throw new PermissionCheckFailureException();
        }

        HashSet<Errata> errataToRemove = new HashSet();

        for (Iterator itr = errataNames.iterator(); itr.hasNext();) {
            Errata erratum = ErrataManager.lookupByAdvisory((String)itr.next());

            if (erratum != null) {
                errataToRemove.add(erratum);
                ErrataManager.removeErratumFromChannel(erratum, channel, user);
            }
        }

        // remove packages from the channel if requested
        if (removePackages) {
            List<Long> packagesToRemove = new ArrayList();

            List<Long> channelPkgs = ChannelFactory.getPackageIds(channel.getId());

            for (Errata erratum : errataToRemove) {
                Set<Package> erratumPackageList = erratum.getPackages();

                for (Package pkg : erratumPackageList) {
                    // if the package is in the channel, remove it
                    if (channelPkgs.contains(pkg.getId())) {
                        packagesToRemove.add(pkg.getId());
                    }
                }
            }

            // remove the packages from the channel
            ChannelManager.removePackages(channel, packagesToRemove, user);

            // refresh the channel
            ChannelManager.refreshWithNewestPackages(channel, "api");

            // Mark the affected channel to have it's metadata evaluated, where necessary
            // (RHEL5+, mostly)
            ChannelManager.queueChannelChange(channel.getLabel(), "java::removeErrata",
                                              user.getLogin());

            List<Long> cids = new ArrayList();
            cids.add(channel.getId());
            ErrataCacheManager.insertCacheForChannelPackagesAsync(cids, packagesToRemove);
        }

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
        List<Map> list = listErrata(sessionKey, channelLabel, "", "");
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
    @Deprecated
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

    @Deprecated
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
            throw new NoSuchChannelException(label);
        }

        return channel;
    }


    private Channel lookupChannelByLabel(Org org, String label)
        throws NoSuchChannelException {

        Channel channel = ChannelManager.lookupByLabel(
                org, label);
        if (channel == null) {
            throw new NoSuchChannelException(label);
        }

        return channel;
    }

    private Channel lookupChannelById(User user, Long id)
        throws NoSuchChannelException {

        Channel channel = ChannelManager.lookupByIdAndUser(new Long(id), user);
        if (channel == null) {
            throw new NoSuchChannelException(id);
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
    @Deprecated
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
     *      string name
     *      string label
     *      string summary
     *      string parent_label (optional)
     *      string arch_label (optional)
     *      string gpg_key_url (optional), gpg_url left for historical reasons
     *      string gpg_key_id (optional), gpg_id left for historical reasons
     *      string gpg_key_fp (optional), gpg_fingerprint left for historical reasons
     *      string description (optional)
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
     *          #prop_desc("string", "gpg_key_url", "(optional),
     *              gpg_url might be used as well")
     *          #prop_desc("string", "gpg_key_id", "(optional),
     *              gpg_id might be used as well")
     *          #prop_desc("string", "gpg_key_fp", "(optional),
     *              gpg_fingerprint might be used as well")
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
        validKeys.add("gpg_url");           // deprecated, left for compatibility reasons
        validKeys.add("gpg_id");            // deprecated, left for compatibility reasons
        validKeys.add("gpg_fingerprint");   // deprecated, left for compatibility reasons
        validKeys.add("gpg_key_url");
        validKeys.add("gpg_key_id");
        validKeys.add("gpg_key_fp");
        validKeys.add("description");
        validateMap(validKeys, channelDetails);

        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);

        String name = (String) channelDetails.get("name");
        String label = (String) channelDetails.get("label");
        String parentLabel = (String) channelDetails.get("parent_label");
        String archLabel = (String) channelDetails.get("arch_label");
        String summary = (String) channelDetails.get("summary");
        String description =  (String) channelDetails.get("description");
        String gpgUrl;
        if (channelDetails.get("gpg_key_url") == null) {
            gpgUrl = (String) channelDetails.get("gpg_url");
        }
        else {
            gpgUrl = (String) channelDetails.get("gpg_key_url");
        }
        String gpgId;
        if ((String) channelDetails.get("gpg_key_id") == null) {
            gpgId = (String) channelDetails.get("gpg_id");
        }
        else {
            gpgId = (String) channelDetails.get("gpg_key_id");
        }
        String gpgFingerprint;
        if (channelDetails.get("gpg_key_fp") == null) {
            gpgFingerprint = (String) channelDetails.get("gpg_fingerprint");
        }
        else {
            gpgFingerprint = (String) channelDetails.get("gpg_key_fp");
        }


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

        Channel clone = helper.clone(originalState.booleanValue(), originalChan);
        ChannelManager.cloneNewestPackages(originalChan.getId(), clone, "api");
        return clone.getId().intValue();
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

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        Set<Errata> mergedErrata =
            mergeErrataToChannel(loggedInUser, new HashSet(mergeFrom.getErratas()),
                    mergeTo, mergeFrom);

        return mergedErrata.toArray();
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

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        List<Errata> fromErrata = ErrataFactory.lookupByChannelBetweenDates(
                loggedInUser.getOrg(), mergeFrom, startDate, endDate);

        Set<Errata> mergedErrata =
            mergeErrataToChannel(loggedInUser, new HashSet(fromErrata), mergeTo, mergeFrom);

        return mergedErrata.toArray();
    }

    /**
     * Merge a list of errata from one channel into another channel
     * @param sessionKey session of the user
     * @param mergeFromLabel the label of the channel to pull the errata from
     * @param mergeToLabel the label of the channel to push errata into
     * @param errataNames the list of errata to merge
     * @return A list of errata that were merged.
     *
     * @xmlrpc.doc Merges a list of errata from one channel into another
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "mergeFromLabel", "the label of the
     * channel to pull errata from")
     * @xmlrpc.param #param_desc("string", "mergeToLabel", "the label to push the
     * errata into")
     * @xmlrpc.param
     *      #array_single("string", " advisory - The advisory name of the errata to merge")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataSerializer
     *      #array_end()
     */
    public Object[] mergeErrata(String sessionKey, String mergeFromLabel,
            String mergeToLabel, List errataNames) {

        User loggedInUser = getLoggedInUser(sessionKey);
        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        HashSet<Errata> sourceErrata = new HashSet(mergeFrom.getErratas());
        HashSet<Errata> errataToMerge = new HashSet();

        // make sure our errata exist in the "from" channel
        for (Iterator itr = errataNames.iterator(); itr.hasNext();) {
            Errata toMerge = ErrataManager.lookupByAdvisory((String)itr.next());

            for (Errata erratum : sourceErrata) {
                if (erratum.getAdvisoryName() == toMerge.getAdvisoryName()) {
                    errataToMerge.add(toMerge);
                    break;
                }
            }
        }

        Set<Errata> mergedErrata =
            mergeErrataToChannel(loggedInUser, errataToMerge, mergeTo, mergeFrom);

        return mergedErrata.toArray();
    }

    private Set<Errata> mergeErrataToChannel(User user, Set<Errata> errataToMerge,
            Channel toChannel, Channel fromChannel) {

        // find errata that we do not need to merge
        List<Errata> same = ErrataManager.listSamePublishedInChannels(
                user, fromChannel, toChannel);
        List<Errata> brothers = ErrataManager.listPublishedBrothersInChannels(
                user, fromChannel, toChannel);
        List<Errata> clones = ErrataManager.listPublishedClonesInChannels(
                user, fromChannel, toChannel);
        // and remove them
        errataToMerge.removeAll(same);
        errataToMerge.removeAll(brothers);
        errataToMerge.removeAll(clones);

        ErrataManager.publishErrataToChannelAsync(toChannel,
                getErrataIds(errataToMerge), user);

        // no need to regenerate errata cache, because we didn't touch any packages

        return errataToMerge;
    }

    private Set<Long> getErrataIds(Set<Errata> errata) {
        Set<Long> ids = new HashSet();
        for (Errata erratum : errata) {
            ids.add(erratum.getId());
        }
        return ids;
    }

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

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        List<Package> differentPackages = new ArrayList<Package>();

        Set<Package> toPacks = mergeTo.getPackages();
        Set<Package> fromPacks = mergeFrom.getPackages();
        List<Long> pids = new ArrayList<Long>();
        for (Package pack : fromPacks) {
            if (!toPacks.contains(pack)) {
                pids.add(pack.getId());
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


        List<Long> cids = new ArrayList<Long>();
        cids.add(mergeTo.getId());
        ErrataCacheManager.insertCacheForChannelPackagesAsync(cids, pids);
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
                ChannelManager.getRepoLastBuild(lookupChannelById(user, id.longValue()));
        if (repoLastBuild == null) {
            return "";
        }
        return repoLastBuild;
    }

   /** Returns a list of ContentSource (repos) that the user can see
     * @param sessionKey WebSession containing User information.
     * @return Lists the repos visible to the user
     * @xmlrpc.doc Returns a list of ContentSource (repos) that the user can see
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype
     *      #array()
     *          #struct("map")
     *              #prop_desc("long","id", "ID of the repo")
     *              #prop_desc("string","label", "label of the repo")
     *              #prop_desc("string","sourceUrl", "URL of the repo")
     *          #struct_end()
     *      #array_end()
     **/
    public List listUserRepos(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        List<ContentSource> result = ChannelFactory.lookupContentSources(user.getOrg());

        List list = new ArrayList();
        for (Iterator itr = result.iterator(); itr.hasNext();) {
            ContentSource cs = (ContentSource) itr.next();
            Map map = new HashMap();
            map.put("id", cs.getId());
            map.put("label", cs.getLabel());
            map.put("sourceUrl", cs.getSourceUrl());
            list.add(map);
        }
        return list;
    }

   /**
    * Creates a repository
    * @param sessionKey Session containing user information.
    * @param label of the repo to be created
    * @param type of the repo (YUM only for now)
    * @param url of the repo
    * @return new ContentSource
    *
    * @xmlrpc.doc Creates a repository
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "repository label")
    * @xmlrpc.param #param_desc("string", "type", "repository type (only YUM is supported)")
    * @xmlrpc.param #param_desc("string", "url", "repository url")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource createRepo(String sessionKey, String label, String type,
            String url) {
        User user = getLoggedInUser(sessionKey);

        BaseRepoCommand repoCmd = null;
        repoCmd = new CreateRepoCommand(user.getOrg());

        repoCmd.setLabel(label);
        repoCmd.setUrl(url);

        repoCmd.store();

        ContentSource repo = ChannelFactory.lookupContentSourceByOrgAndLabel(
                user.getOrg(), label);
        return repo;
    }

   /**
    * Removes a repository
    * @param sessionKey Session containing user information.
    * @param id of the repo to be removed
    * @return Integer 1 on success
    *
    * @xmlrpc.doc Removes a repository
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("long", "id", "ID of repo to be removed")
    * @xmlrpc.returntype #return_int_success()
   **/
    public Integer removeRepo(String sessionKey, Integer id) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceById(id.longValue(), user.getOrg());

        ChannelFactory.remove(repo);
        return 1;
    }

   /**
    * Removes a repository
    * @param sessionKey Session containing user information.
    * @param label of the repo to be removed
    * @return Integer 1 on success
    *
    * @xmlrpc.doc Removes a repository
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "label of repo to be removed")
    * @xmlrpc.returntype #return_int_success()
   **/
    public Integer removeRepo(String sessionKey, String label) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceByLabel(label, user.getOrg());

        ChannelFactory.remove(repo);
        return 1;
    }

   /**
    * Associates a repository with a channel
    * @param sessionKey Session containing user information.
    * @param chanLabel of the channel to use
    * @param repoLabel of the repo to associate
    * @return the channel with the newly associated repo
    *
    * @xmlrpc.doc Associates a repository with a channel
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
    * @xmlrpc.param #param_desc("string", "repoLabel", "repository label")
    * @xmlrpc.returntype $ChannelSerializer
   **/
    public Channel associateRepo(String sessionKey, String chanLabel, String repoLabel) {
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, chanLabel);
        ContentSource repo = lookupContentSourceByLabel(repoLabel, user.getOrg());

        Set<ContentSource> set = channel.getSources();
        set.add(repo);
        ChannelFactory.save(channel);

        return channel;
    }

   /**
    * Disassociates a repository from a channel
    * @param sessionKey Session containing user information.
    * @param chanLabel of the channel to use
    * @param repoLabel of the repo to disassociate
    * @return the channel minus the disassociated repo
    *
    * @xmlrpc.doc Disassociates a repository from a channel
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
    * @xmlrpc.param #param_desc("string", "repoLabel", "repository label")
    * @xmlrpc.returntype $ChannelSerializer
   **/
    public Channel disassociateRepo(String sessionKey, String chanLabel, String repoLabel) {
        User user = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(user, chanLabel);
        ContentSource repo = lookupContentSourceByLabel(repoLabel, user.getOrg());

        Set<ContentSource> set = channel.getSources();
        set.remove(repo);
        channel.setSources(set);

        ChannelFactory.save(channel);

        return channel;
    }

   /**
    * Updates repository source URL
    * @param sessionKey Session containing user information.
    * @param id ID of the repo
    * @param url new URL to use
    * @return the updated repo
    *
    * @xmlrpc.doc Updates repository source URL
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("int", "id", "repository id")
    * @xmlrpc.param #param_desc("string", "url", "repository url")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepoUrl(String sessionKey, Integer id, String url) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceById(id.longValue(), user.getOrg());
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

   /**
    * Updates repository source URL
    * @param sessionKey Session containing user information.
    * @param label of the repo to use
    * @param url new URL to use
    * @return the updated repo
    *
    * @xmlrpc.doc Updates repository source URL
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "repository label")
    * @xmlrpc.param #param_desc("string", "url", "repository url")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepoUrl(String sessionKey, String label, String url) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceByLabel(label, user.getOrg());
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

   /**
    * Updates repository label
    * @param sessionKey Session containing user information.
    * @param id ID of the repo
    * @param label new label
    * @return the updated repo
    *
    * @xmlrpc.doc Updates repository label
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("int", "id", "repository id")
    * @xmlrpc.param #param_desc("string", "label", "new repository label")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepoLabel(String sessionKey, Integer id, String label) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceById(id.longValue(), user.getOrg());
        setRepoLabel(repo, label);
        ChannelFactory.save(repo);
        return repo;
    }

   /**
    * Updates a repository
    * @param sessionKey Session containing user information.
    * @param id ID of the repo
    * @param label new label
    * @param url new URL
    * @return the updated repo
    *
    * @xmlrpc.doc Updates a ContentSource (repo)
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("int", "id", "repository id")
    * @xmlrpc.param #param_desc("string", "label", "new repository label")
    * @xmlrpc.param #param_desc("string", "url", "new repository URL")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepo(String sessionKey, Integer id, String label,
            String url) {
        User user = getLoggedInUser(sessionKey);
        ContentSource repo = lookupContentSourceById(id.longValue(), user.getOrg());
        setRepoLabel(repo, label);
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

    /**
     * Returns the details of the given repo
     * @param sessionKey Session containing user information.
     * @param repoLabel Label of repo whose details are sought.
     * @return the repo requested.
     *
     * @xmlrpc.doc Returns details of the given repository
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "repoLabel", "repo to query")
     * @xmlrpc.returntype
     *     $ContentSourceSerializer
     */
    public ContentSource getRepoDetails(String sessionKey, String repoLabel) {
        User user = getLoggedInUser(sessionKey);
        return lookupContentSourceByLabel(repoLabel, user.getOrg());
    }

    /**
     * Returns the details of the given repo
     * @param sessionKey Session containing user information.
     * @param id ID of repo whose details are sought.
     * @return the repo requested.
     *
     * @xmlrpc.doc Returns details of the given repo
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "repoLabel", "repo to query")
     * @xmlrpc.returntype
     *     $ContentSourceSerializer
     */
    public ContentSource getRepoDetails(String sessionKey, Integer id) {
        User user = getLoggedInUser(sessionKey);
        return lookupContentSourceById(id.longValue(), user.getOrg());
    }

    /**
     * Lists associated repos with the given channel
     * @param sessionKey session key
     * @param channelLabel channel label
     * @return list of associates repos
     *
     * @xmlrpc.doc Lists associated repos with the given channel
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.returntype
     *      #array()
     *          $ContentSourceSerializer
     *      #array_end()
     */
    public List<ContentSource> listChannelRepos(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        return ChannelFactory.lookupContentSources(loggedInUser.getOrg(), channel);
    }

    /**
     * Trigger immediate repo synchronization
     * @param sessionKey session key
     * @param channelLabel channel label
     * @return 1 on success
     *
     * @xmlrpc.doc Trigger immediate repo synchronization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int syncRepo(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        new TaskomaticApi().scheduleSingleRepoSync(chan, loggedInUser);
        return 1;
    }
    /**
     * Schedule periodic repo synchronization
     * @param sessionKey session key
     * @param channelLabel channel label
     * @param cronExpr cron expression, if empty all periodic schedules will be disabled
     * @return 1 on success
     *
     * @xmlrpc.doc Schedule periodic repo synchronization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.param #param_desc("string", "cron expression",
     *      "if empty all periodic schedules will be disabled")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int syncRepo(String sessionKey, String channelLabel, String cronExpr) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        if (StringUtils.isEmpty(cronExpr)) {
            new TaskomaticApi().unscheduleRepoSync(chan, loggedInUser);
        }
        else {
            new TaskomaticApi().scheduleRepoSync(chan, loggedInUser, cronExpr);
        }
        return 1;
    }

    /**
     * Returns repo synchronization quartz expression
     * @param sessionKey session key
     * @param channelLabel channel label
     * @return quartz expression
     *
     * @xmlrpc.doc Returns repo synchronization cron expression
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.returntype string quartz expression
     */
    public String getRepoSyncCronExpression(String sessionKey, String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
            String cronExpr = new TaskomaticApi().getRepoSyncSchedule(chan, loggedInUser);
            if (StringUtils.isEmpty(cronExpr)) {
                return new String("");
            }
            return cronExpr;
    }

    private ContentSource lookupContentSourceById(Long repoId, Org org) {
        ContentSource cs = ChannelFactory.lookupContentSource(repoId, org);
        if (cs == null) {
            throw new NoSuchContentSourceException(repoId);
        }
        return cs;
    }

    private ContentSource lookupContentSourceByLabel(String repoLabel, Org org) {
        ContentSource cs = ChannelFactory.lookupContentSourceByOrgAndLabel(org, repoLabel);
        if (cs == null) {
            throw new NoSuchContentSourceException(repoLabel);
        }
        return cs;
    }

    private void setRepoLabel(ContentSource cs, String repoLabel) {
        if (StringUtils.isEmpty(repoLabel)) {
            throw new InvalidParameterException("label might not be empty");
        }
        if (ChannelFactory.lookupContentSourceByOrgAndLabel(cs.getOrg(), repoLabel) !=
                null) {
            throw new InvalidRepoLabelException(repoLabel);
        }
        cs.setLabel(repoLabel);
    }

    private void setRepoUrl(ContentSource cs, String repoUrl) {
        if (StringUtils.isEmpty(repoUrl)) {
            throw new InvalidParameterException("url might not be empty");
        }
        if (!ChannelFactory.lookupContentSourceByOrgAndRepo(cs.getOrg(),
                ChannelFactory.CONTENT_SOURCE_TYPE_YUM, repoUrl).isEmpty()) {
            throw new InvalidRepoUrlException(repoUrl);
        }
        cs.setSourceUrl(repoUrl);
    }
}
