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
package com.redhat.rhn.frontend.xmlrpc.channel.software;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.time.StopWatch;
import org.apache.log4j.Logger;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.client.InvalidCertificateException;
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
import com.redhat.rhn.domain.channel.ContentSourceFilter;
import com.redhat.rhn.domain.channel.InvalidChannelRoleException;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.errata.ErrataFactory;
import com.redhat.rhn.domain.errata.impl.PublishedClonedErrata;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.rhnpackage.Package;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ErrataOverview;
import com.redhat.rhn.frontend.dto.PackageDto;
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
import com.redhat.rhn.manager.channel.CloneChannelCommand;
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
import com.redhat.rhn.taskomatic.task.errata.ErrataCacheWorker;

/**
 * ChannelSoftwareHandler
 * @version $Rev$
 * @xmlrpc.namespace channel.software
 * @xmlrpc.doc Provides methods to access and modify many aspects of a channel.
 */
public class ChannelSoftwareHandler extends BaseHandler {

    private static Logger log = Logger.getLogger(ChannelSoftwareHandler.class);

    /**
     * If you have satellite-synced a new channel then Red Hat Errata
     * will have been updated with the packages that are in the newly synced
     * channel. A cloned erratum will not have been automatically updated
     * however. If you cloned a channel that includes those cloned errata and
     * should include the new packages, they will not be included when they
     * should. This method lists the errata that will be updated if you run the
     * syncErrata method.
     * @param loggedInUser The current user
     * @param channelLabel Label of cloned channel to check
     * @return List of errata that are missing packages
     *
     * @xmlrpc.doc If you have satellite-synced a new channel then Red Hat
     * Errata will have been updated with the packages that are in the newly
     * synced channel. A cloned erratum will not have been automatically updated
     * however. If you cloned a channel that includes those cloned errata and
     * should include the new packages, they will not be included when they
     * should. This method lists the errata that will be updated if you run the
     * syncErrata method.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to update")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */
    public List<ErrataOverview> listErrataNeedingSync(User loggedInUser,
                String channelLabel) {
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        return ChannelManager.listErrataNeedingResync(channel, loggedInUser);
    }

    /**
     * If you have satellite-synced a new channel then Red Hat Errata
     * will have been updated with the packages that are in the newly synced
     * channel. A cloned erratum will not have been automatically updated
     * however. If you cloned a channel that includes those cloned errata and
     * should include the new packages, they will not be included when they
     * should. This method updates all the errata in the given cloned channel
     * with packages that have recently been added, and ensures that all the
     * packages you expect are in the channel.
     * @param loggedInUser The current user
     * @param channelLabel Label of cloned channel to update
     * @return Returns 1 if successfull, FaultException otherwise
     * @throws NoSuchChannelException thrown if no channel is found.
     *
     * @xmlrpc.doc If you have satellite-synced a new channel then Red Hat
     * Errata will have been updated with the packages that are in the newly
     * synced channel. A cloned erratum will not have been automatically updated
     * however. If you cloned a channel that includes those cloned errata and
     * should include the new packages, they will not be included when they
     * should. This method updates all the errata in the given cloned channel
     * with packages that have recently been added, and ensures that all the
     * packages you expect are in the channel.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to update")
     * @xmlrpc.returntype  #return_int_success()
     */
    public Integer syncErrata(User loggedInUser, String channelLabel) {
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        //Verify permissions
        if (!(UserManager.verifyChannelAdmin(loggedInUser, channel) ||
                loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN))) {
            throw new PermissionCheckFailureException();
        }

        List<Long> eids = ChannelManager.listErrataIdsNeedingResync(channel,
                loggedInUser);

        List<Long> pids = ChannelManager
                .listErrataPackageIdsForResync(channel, loggedInUser);

        ChannelEditor.getInstance().addPackages(loggedInUser, channel, pids);

        for (Long eid : eids) {
            Errata e = ErrataManager.lookupErrata(eid, loggedInUser);
            if (e.isPublished() && e.isCloned()) {
                ErrataFactory.syncErrataDetails((PublishedClonedErrata) e);
            }
            else {
                log.fatal("Tried to sync errata with id " + eid +
                        " But it was not published or was not cloned");
            }
        }
        return 1;
    }

    /**
     * Lists the packages with the latest version (including release and epoch)
     * for the unique package names
     * @param loggedInUser The current user
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
    public Object[] listLatestPackages(User loggedInUser, String channelLabel)
        throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        List<Map<String, Object>> pkgs = ChannelManager.latestPackagesInChannel(channel);
        return pkgs.toArray();
    }

    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param loggedInUser The current user
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
    public List<PackageDto> listAllPackages(User loggedInUser, String channelLabel,
            Date startDate, Date endDate) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        return ChannelManager.listAllPackages(channel, startDate, endDate);
    }

    /**
     * Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @param loggedInUser The current user
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
    public List<PackageDto> listAllPackages(User loggedInUser, String channelLabel,
            Date startDate) throws NoSuchChannelException {
        return listAllPackages(loggedInUser, channelLabel, startDate, null);
    }

    /**
     * Lists all packages in the channel, regardless of version
     * @param loggedInUser The current user
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
    public List<PackageDto> listAllPackages(User loggedInUser, String channelLabel)
        throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        return ChannelManager.listAllPackages(channel);
    }

    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param loggedInUser The current user
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
    public List<PackageDto> listAllPackages(User loggedInUser, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        return ChannelManager.listAllPackages(channel, startDate, endDate);
    }

    /**
     * Lists all packages in the channel, regardless of version whose last
     * modified date is greater than given date.
     * @param loggedInUser The current user
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
    public List<PackageDto> listAllPackages(User loggedInUser, String channelLabel,
            String startDate) throws NoSuchChannelException {
        return listAllPackages(loggedInUser, channelLabel, startDate, null);
    }

    /**
     * Lists all packages in the channel, regardless of version, between the
     * given dates.
     * @param loggedInUser The current user
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
    public Object[] listAllPackagesByDate(User loggedInUser, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        List<Map<String, Object>> pkgs =
                ChannelManager.listAllPackagesByDate(channel, startDate, endDate);
        return pkgs.toArray();
    }

    /**
     * Lists all packages in the channel, regardless of version, whose last
     * modified date is greater than given date.
     * @param loggedInUser The current user
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
    public Object[] listAllPackagesByDate(User loggedInUser, String channelLabel,
            String startDate) throws NoSuchChannelException {

        return listAllPackagesByDate(loggedInUser, channelLabel, startDate, null);
    }

    /**
     * Lists all packages in the channel, regardless of version
     * @param loggedInUser The current user
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
    public Object[] listAllPackagesByDate(User loggedInUser, String channelLabel)
        throws NoSuchChannelException {

        return listAllPackagesByDate(loggedInUser, channelLabel, null, null);
    }

    /**
     * Return Lists potential software channel arches that can be created
     * @param loggedInUser The current user
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
    public List<ChannelArch> listArches(User loggedInUser)
            throws PermissionCheckFailureException {
        if (!loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        return ChannelManager.getChannelArchitectures();
    }

    /**
     * Deletes a software channel
     * @param loggedInUser The current user
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
    public int delete(User loggedInUser, String channelLabel)
        throws PermissionCheckFailureException, NoSuchChannelException {

        try {
            ChannelManager.deleteChannel(loggedInUser, channelLabel);
        }
        catch (InvalidChannelRoleException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (PermissionException e) {
            throw new FaultException(1234, "permissions", e.getMessage(), new String[] {});
        }

        return 1;
    }

    /**
     * Returns whether the channel is subscribable by any user in the
     * organization.
     * @param loggedInUser The current user
     * @param channelLabel Label of channel to be deleted.
     * @return 1 if the Channel is globally subscribable, 0 otherwise.
     *
     * @xmlrpc.doc Returns whether the channel is subscribable by any user
     * in the organization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.returntype int - 1 if true, 0 otherwise
     */
    public int isGloballySubscribable(User loggedInUser, String channelLabel) {
        // TODO: this should return a boolean NOT an int

        // Make sure the channel exists:
        lookupChannelByLabel(loggedInUser, channelLabel);

        return ChannelManager.isGloballySubscribable(loggedInUser, channelLabel) ? 1 : 0;
    }

    /**
     * Returns the details of the given channel as a map with the following
     * keys:
     * @param loggedInUser The current user
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
    public Channel getDetails(User loggedInUser, String channelLabel)
        throws NoSuchChannelException {
        return lookupChannelByLabel(loggedInUser, channelLabel);
    }

    /**
     * Returns the requested channel
     * @param loggedInUser The current user
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
    public Channel getDetails(User loggedInUser, Integer id)
        throws NoSuchChannelException {
        return lookupChannelById(loggedInUser, id.longValue());
    }

    /**
     * Allows to modify channel attributes
     * @param loggedInUser The current user
     * @param channelId id of channel to be modified
     * @param details map of channel attributes to be changed
     * @return 1 if edit was successful, exception thrown otherwise
     *
     * @xmlrpc.doc Allows to modify channel attributes
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("int", "channelId", "channel id")
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
    public int setDetails(User loggedInUser, Integer channelId, Map<String,
            String> details) {
        Channel channel = lookupChannelById(loggedInUser, channelId.longValue());

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

        UpdateChannelCommand ucc = new UpdateChannelCommand(loggedInUser, channel);

        if (details.containsKey("checksum_label")) {
            ucc.setChecksumLabel(details.get("checksum_label"));
        }

        if (details.containsKey("name")) {
            ucc.setName(details.get("name"));
        }

        if (details.containsKey("summary")) {
            ucc.setSummary(details.get("summary"));
        }

        if (details.containsKey("description")) {
            ucc.setDescription(details.get("description"));
        }

        if (details.containsKey("maintainer_name")) {
            ucc.setMaintainerName(details.get("maintainer_name"));
        }

        if (details.containsKey("maintainer_email")) {
            ucc.setMaintainerEmail(details.get("maintainer_email"));
        }

        if (details.containsKey("maintainer_phone")) {
            ucc.setMaintainerPhone(details.get("maintainer_phone"));
        }

        if (details.containsKey("gpg_key_url")) {
            ucc.setGpgKeyUrl(details.get("gpg_key_url"));
        }

        if (details.containsKey("gpg_key_id")) {
            ucc.setGpgKeyId(details.get("gpg_key_id"));
        }

        if (details.containsKey("gpg_key_fp")) {
            ucc.setGpgKeyFp(details.get("gpg_key_fp"));
        }

       ucc.update(channelId.longValue());
        return 1;
    }


    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param loggedInUser The current user
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
     *              "the label of the architecture the channel corresponds to,
     *              see channel.software.listArches API for complete listing")
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
    public int create(User loggedInUser, String label, String name,
            String summary, String archLabel, String parentLabel, String checksumType,
            Map<String, String> gpgKey)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        if (!loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        CreateChannelCommand ccc = new CreateChannelCommand();
        ccc.setArchLabel(archLabel);
        ccc.setLabel(label);
        ccc.setName(name);
        ccc.setSummary(summary);
        ccc.setParentLabel(parentLabel);
        ccc.setUser(loggedInUser);
        ccc.setChecksumLabel(checksumType);
        ccc.setGpgKeyUrl(gpgKey.get("url"));
        ccc.setGpgKeyId(gpgKey.get("id"));
        ccc.setGpgKeyFp(gpgKey.get("fingerprint"));

        return (ccc.create() != null) ? 1 : 0;
    }

    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param loggedInUser The current user
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
     *              "the label of the architecture the channel corresponds to,
     *              see channel.software.listArches API for complete listing")
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

    public int create(User loggedInUser, String label, String name,
            String summary, String archLabel, String parentLabel, String checksumType)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        return create(loggedInUser, label, name,
                summary, archLabel, parentLabel, checksumType,
                new HashMap<String, String>());
    }

    /**
     * Creates a software channel, parent_channel_label can be empty string
     * @param loggedInUser The current user
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
     *              "the label of the architecture the channel corresponds to,
     *              see channel.software.listArches API for complete listing")
     * @xmlrpc.param #param_desc("string", "parentLabel", "label of the parent of this
     *              channel, an empty string if it does not have one")
     * @xmlrpc.returntype int - 1 if the creation operation succeeded, 0 otherwise
     */
    public int create(User loggedInUser, String label, String name,
            String summary, String archLabel, String parentLabel)
        throws PermissionCheckFailureException, InvalidChannelLabelException,
               InvalidChannelNameException, InvalidParentChannelException {

        return create(loggedInUser, label, name, summary, archLabel, parentLabel, "sha1");
    }

    /**
     * Set the contact/support information for given channel.
     * @param loggedInUser The current user
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
    public int setContactDetails(User loggedInUser, String channelLabel,
            String maintainerName, String maintainerEmail, String maintainerPhone,
            String supportPolicy)
        throws FaultException {

        if (!loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        channel.setMaintainerName(maintainerName);
        channel.setMaintainerEmail(maintainerEmail);
        channel.setMaintainerPhone(maintainerPhone);
        channel.setSupportPolicy(supportPolicy);

        ChannelFactory.save(channel);

        return 1;
    }

    /**
     * Returns list of subscribed systems for the given channel label.
     * @param loggedInUser The current user
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
    public Object[] listSubscribedSystems(User loggedInUser, String label)
        throws FaultException {

        // Make sure user has access to the orgs channels
        if (!loggedInUser.hasRole(RoleFactory.CHANNEL_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        // Get the channel.
        Channel channel = lookupChannelByLabel(loggedInUser, label);

        DataResult<Map<String, Object>> dr =
                SystemManager.systemsSubscribedToChannel(channel, loggedInUser);
        for (Map<String, Object> sys : dr) {
            sys.remove("selectable");
        }
        return dr.toArray();
    }

    /**
     * Retrieve the channels for a given system id.
     * @param loggedInUser The current user
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
     *                  #prop("string", "id")
     *                  #prop("string", "label")
     *                  #prop("string", "name")
     *              #struct_end()
     *           #array_end()
     */
    public Object[] listSystemChannels(User loggedInUser, Integer sid)
        throws FaultException {
        Server server = XmlRpcSystemHelper.getInstance().lookupServer(loggedInUser, sid);

        DataResult<Map<String, Object>> dr = SystemManager.channelsForServer(server);
        return dr.toArray();
    }

    /**
     * Change a systems subscribed channels to the list of channels passed in.
     * @param loggedInUser The current user
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
    public int setSystemChannels(User loggedInUser, Integer sid,
            List<String> channelLabels) throws FaultException {
        Server server = XmlRpcSystemHelper.getInstance().lookupServer(loggedInUser, sid);
        List<Channel> channels = new ArrayList<Channel>();
        log.debug("setSystemChannels()");

        // Verify that each channel label we were passed corresponds to a valid channel
        // and store in a list.
        Channel baseChannel = null;
        log.debug("Incoming channels:");
        for (String label : channelLabels) {
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
     * @param loggedInUser The current user
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
    public int setUserSubscribable(User loggedInUser, String channelLabel,
                   String login, Boolean value) throws FaultException {
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
     * @param loggedInUser The current user
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
    public int setUserManageable(User loggedInUser, String channelLabel,
                   String login, Boolean value) throws FaultException {
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
     * @param loggedInUser The current user
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
    public int isUserSubscribable(User loggedInUser, String channelLabel,
            String login) throws FaultException {
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
     * @param loggedInUser The current user
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
    public int isUserManageable(User loggedInUser, String channelLabel,
            String login) throws FaultException {
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
     * @param loggedInUser The current user
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
    public int setGloballySubscribable(User loggedInUser, String channelLabel,
                   boolean value) throws FaultException {
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
     * @param loggedInUser The current user
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
    public int addPackages(User loggedInUser, String channelLabel, List<Long> packageIds)
        throws FaultException {
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
     * @param loggedInUser The current user
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
    public int removeErrata(User loggedInUser, String channelLabel,
            List<String> errataNames, boolean removePackages) {

        channelAdminPermCheck(loggedInUser);

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        if (!UserManager.verifyChannelAdmin(loggedInUser, channel)) {
            throw new PermissionCheckFailureException();
        }

        HashSet<Errata> errataToRemove = new HashSet<Errata>();

        for (String erratumName : errataNames) {
            Errata erratum = ErrataManager.lookupByAdvisory(erratumName);

            if (erratum != null) {
                errataToRemove.add(erratum);
                ErrataManager.removeErratumFromChannel(erratum, channel, loggedInUser);
            }
        }

        // remove packages from the channel if requested
        if (removePackages) {
            List<Long> packagesToRemove = new ArrayList<Long>();

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
            ChannelManager.removePackages(channel, packagesToRemove, loggedInUser);

            // refresh the channel
            ChannelManager.refreshWithNewestPackages(channel, "api");

            // Mark the affected channel to have it's metadata evaluated, where necessary
            // (RHEL5+, mostly)
            ChannelManager.queueChannelChange(channel.getLabel(), "java::removeErrata",
                    loggedInUser.getLogin());

            List<Long> cids = new ArrayList<Long>();
            cids.add(channel.getId());
            ErrataCacheManager.insertCacheForChannelPackagesAsync(cids, packagesToRemove);

        }

        return 1;
    }

    /**
     * Removes a given list of packages from the given channel.
     * @param loggedInUser The current user
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
    public int removePackages(User loggedInUser, String channelLabel,
            List<Long> packageIds) throws FaultException {
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
     * @param loggedInUser The current user
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
    public List<ErrataOverview> listErrata(User loggedInUser, String channelLabel,
            Date startDate) throws NoSuchChannelException {
        return listErrata(loggedInUser, channelLabel, startDate, null);
    }

    /**
     * List the errata applicable to a channel between startDate and endDate.
     * @param loggedInUser The current user
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

    public List<ErrataOverview> listErrata(User loggedInUser, String channelLabel,
            Date startDate, Date endDate) throws NoSuchChannelException {
        return listErrata(loggedInUser, channelLabel, startDate, endDate, false);
    }

    /**
     * List the errata applicable to a channel between startDate and endDate.
     * Allow to select errata by last modified date.
     * Support behaviour available in old versions. (needed for Dumper)
     * @param loggedInUser The current user
     * @param channelLabel The label for the channel
     * @param startDate begin date
     * @param endDate end date
     * @param lastModified select by last modified timestamp or not
     * @return the errata applicable to a channel
     * @throws NoSuchChannelException thrown if there is no channel matching
     * channelLabel.
     *
     * @xmlrpc.doc List the errata applicable to a channel between startDate and endDate.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel to query")
     * @xmlrpc.param #param($date, "startDate")
     * @xmlrpc.param #param($date, "endDate")
     * @xmlrpc.param #param_desc("boolean", "lastModified",
     *     "select by last modified or not")
     * @xmlrpc.returntype
     *      #array()
     *          $ErrataOverviewSerializer
     *      #array_end()
     */

    public List<ErrataOverview> listErrata(User loggedInUser,
            String channelLabel, Date startDate, Date endDate,
            boolean lastModified) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        DataResult<ErrataOverview> errata = ChannelManager.listErrata(channel, startDate,
                endDate, lastModified, loggedInUser);
        errata.elaborate();
        return errata;
    }

    /**
     * List the errata applicable to a channel
     * @param loggedInUser The current user
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
    public List<Map<String, Object>> listErrata(User loggedInUser, String channelLabel)
        throws NoSuchChannelException {
        List<Map<String, Object>> list = listErrata(loggedInUser, channelLabel, "", "");
        return list;
    }

    /**
     * List the errata applicable to a channel after given startDate
     * @param loggedInUser The current user
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
    public List<Map<String, Object>> listErrata(User loggedInUser, String channelLabel,
            String startDate) throws NoSuchChannelException {

        return listErrata(loggedInUser, channelLabel, startDate, null);
    }

    /**
     * List the errata applicable to a channel between startDate and endDate.
     * @param loggedInUser The current user
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
     * @xmlrpc.param #param("string", "endDate")
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
    public List<Map<String, Object>> listErrata(User loggedInUser, String channelLabel,
            String startDate, String endDate) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        List<Map<String, Object>> errata =
                ChannelManager.listErrataForDates(channel, startDate, endDate);
        return errata;
    }

    /**
     * List the errata of a specific type that are applicable to a channel
     * @param loggedInUser The current user
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
    public Object[] listErrataByType(User loggedInUser, String channelLabel,
            String advisoryType) throws NoSuchChannelException {

        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);

        List<Map<String, Object>> errata =
                ChannelManager.listErrataByType(channel, advisoryType);
        return errata.toArray();
    }

    private void scheduleErrataCacheUpdate(Org org, Channel channel, long delay) {
        SelectMode m = ModeFactory.getMode(TaskConstants.MODE_NAME,
                                           "find_channel_in_task_queue");
        Map<String, Object> inParams = new HashMap<String, Object>();

        inParams.put("cid", channel.getId());
        DataResult dr = m.execute(inParams);

        delay /= (24 * 60 * 60);

        if (dr.isEmpty()) {
            WriteMode w = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                                                         "insert_into_task_queue");

            inParams = new HashMap<String, Object>();
            inParams.put("org_id", org.getId());
            inParams.put("task_name", ErrataCacheWorker.BY_CHANNEL);
            inParams.put("task_data", channel.getId());
            inParams.put("earliest", new Timestamp(System.currentTimeMillis() + delay));

            w.executeUpdate(inParams);
        }
        else {
            WriteMode w = ModeFactory.getWriteMode(TaskConstants.MODE_NAME,
                                                         "update_task_queue");
            inParams = new HashMap<String, Object>();
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
     * @param loggedInUser The current user
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
    public Object[] listPackagesWithoutChannel(User loggedInUser) {
        ensureUserRole(loggedInUser, RoleFactory.CHANNEL_ADMIN);
        return PackageFactory.lookupOrphanPackages(loggedInUser.getOrg()).toArray();
    }

    /**
     * Subscribe a system to a list of channels
     * @param loggedInUser The current user
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
    public int subscribeSystem(User loggedInUser, Integer sid, List<String> labels) {
        Server server = SystemManager.lookupByIdAndUser(new Long(sid.longValue()),
                loggedInUser);


        if (labels.size() == 0) {
            ServerFactory.unsubscribeFromAllChannels(loggedInUser, server);
            return 1;
        }

        Channel base = null;
        List<Integer> childChannelIds = new ArrayList<Integer>();

        for (String label : labels) {
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

            sysHandler.setBaseChannel(loggedInUser, sid,
                    new Integer(base.getId().intValue()));
        }
        sysHandler.setChildChannels(loggedInUser, sid, childChannelIds);

        return 1;
    }


    /**
     * Clone a channel
     * @param loggedInUser The current user
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
     *          #prop_desc("string", "checksum", "either sha1 or sha256")
     *      #struct_end()
     * @xmlrpc.param #param("boolean", "original_state")
     * @xmlrpc.returntype int the cloned channel ID
     */
    public int clone(User loggedInUser, String originalLabel,
            Map<String, String> channelDetails, Boolean originalState) {

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
        validKeys.add("checksum");
        validateMap(validKeys, channelDetails);

        channelAdminPermCheck(loggedInUser);

        String name = channelDetails.get("name");
        String label = channelDetails.get("label");
        String parentLabel = channelDetails.get("parent_label");
        String archLabel = channelDetails.get("arch_label");
        String summary = channelDetails.get("summary");
        String description = channelDetails.get("description");
        String checksum = channelDetails.get("checksum");

        if (ChannelFactory.lookupByLabel(loggedInUser.getOrg(), label) != null) {
            throw new DuplicateChannelLabelException(label);
        }

        Channel originalChan = lookupChannelByLabel(loggedInUser.getOrg(), originalLabel);

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

        if (checksum == null) {
            checksum = originalChan.getChecksumTypeLabel();
        }

        String gpgUrl, gpgId, gpgFingerprint;
        if (channelDetails.containsKey("gpg_key_url") ||
                channelDetails.containsKey("gpg_url") ||
                channelDetails.containsKey("gpg_key_id") ||
                channelDetails.containsKey("gpg_id") ||
                channelDetails.containsKey("gpg_key_fp") ||
                channelDetails.containsKey("gpg_fingerprint")) {
            // if one of the GPG information was set, use it
            if (channelDetails.get("gpg_key_url") == null) {
                gpgUrl = channelDetails.get("gpg_url");
            }
            else {
                gpgUrl = channelDetails.get("gpg_key_url");
            }
            if (channelDetails.get("gpg_key_id") == null) {
                gpgId = channelDetails.get("gpg_id");
            }
            else {
                gpgId = channelDetails.get("gpg_key_id");
            }
            if (channelDetails.get("gpg_key_fp") == null) {
                gpgFingerprint = channelDetails.get("gpg_fingerprint");
            }
            else {
                gpgFingerprint = channelDetails.get("gpg_key_fp");
            }
        }
        else {
            // copy GPG info from the original channel
            gpgUrl = originalChan.getGPGKeyUrl();
            gpgId = originalChan.getGPGKeyId();
            gpgFingerprint = originalChan.getGPGKeyFp();
        }

        CloneChannelCommand helper = new CloneChannelCommand(originalState.booleanValue(),
                originalChan);
        helper.setName(name);
        helper.setArchLabel(arch.getLabel());
        helper.setDescription(description);
        helper.setGpgKeyFp(gpgFingerprint);
        helper.setGpgKeyId(gpgId);
        helper.setGpgKeyUrl(gpgUrl);
        helper.setLabel(label);
        if (parentLabel != null) {
            helper.setParentLabel(parentLabel);
        }
        helper.setUser(loggedInUser);
        helper.setSummary(summary);
        helper.setChecksumLabel(checksum);

        Channel clone = helper.create();
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
     * @param loggedInUser The current user
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
    public Object[] mergeErrata(User loggedInUser, String mergeFromLabel,
            String mergeToLabel) {
        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        Set<Errata> mergedErrata = mergeErrataToChannel(loggedInUser, mergeFrom
                .getErratas(), mergeTo, mergeFrom);

        return mergedErrata.toArray();
    }

    /**
     * Merge a channel's errata into another channel based upon a given start/end date.
     * @param loggedInUser The current user
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
    public Object[] mergeErrata(User loggedInUser, String mergeFromLabel,
            String mergeToLabel, String startDate, String endDate) {
        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        List<Errata> fromErrata = ErrataFactory.lookupByChannelBetweenDates(
                loggedInUser.getOrg(), mergeFrom, startDate, endDate);

        Set<Errata> mergedErrata = mergeErrataToChannel(loggedInUser,
                new HashSet<Errata>(fromErrata), mergeTo, mergeFrom);

        return mergedErrata.toArray();
    }

    /**
     * Merge a list of errata from one channel into another channel
     * @param loggedInUser The current user
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
    public Object[] mergeErrata(User loggedInUser, String mergeFromLabel,
            String mergeToLabel, List<String> errataNames) {

        channelAdminPermCheck(loggedInUser);

        Channel mergeFrom = lookupChannelByLabel(loggedInUser, mergeFromLabel);
        Channel mergeTo = lookupChannelByLabel(loggedInUser, mergeToLabel);

        if (!UserManager.verifyChannelAdmin(loggedInUser, mergeTo)) {
            throw new PermissionCheckFailureException();
        }

        Set<Errata> sourceErrata = mergeFrom.getErratas();
        Set<Errata> errataToMerge = new HashSet<Errata>();

        // make sure our errata exist in the "from" channel
        for (String erratumName : errataNames) {
            Errata toMerge = ErrataManager.lookupByAdvisory(erratumName);

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
        Set<Long> ids = new HashSet<Long>();
        for (Errata erratum : errata) {
            ids.add(erratum.getId());
        }
        return ids;
    }

    /**
     * Merge a channel's packages into another channel.
     * @param loggedInUser The current user
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
    public Object[] mergePackages(User loggedInUser, String mergeFromLabel,
            String mergeToLabel) {

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
     * @param loggedInUser The current user
     * @param channelLabel the channel label
     * @return int - 1 on success!
     *
     * @xmlrpc.doc Completely clear and regenerate the needed Errata and Package
     *      cache for all systems subscribed to the specified channel.  This should
     *      be used only if you believe your cache is incorrect for all the systems
     *      in a given channel. This will schedule an asynchronous action to actually
     *      do the processing.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "the label of the
     *          channel")
     * @xmlrpc.returntype  #return_int_success()
     *
     */
    public int regenerateNeededCache(User loggedInUser, String channelLabel) {
        channelAdminPermCheck(loggedInUser);
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        List<Long> chanList = new ArrayList<Long>();
        chanList.add(chan.getId());
        ErrataCacheManager.updateCacheForChannelsAsync(chanList);
        return 1;
    }

    /**
     * Regenerate the errata cache for all the systems subscribed to the satellite
     * @param loggedInUser The current user
     * @return int - 1 on success!
     *
     * @xmlrpc.doc Completely clear and regenerate the needed Errata and Package
     *      cache for all systems subscribed.  You must be a Satellite Admin to
     *      perform this action. This will schedule an asynchronous action to
     *      actually do the processing.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype  #return_int_success()
     *
     */
    public int regenerateNeededCache(User loggedInUser) {
        if (loggedInUser.hasRole(RoleFactory.SAT_ADMIN)) {
            Set<Channel> set = new HashSet<Channel>();
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
     * @param loggedInUser The current user
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
    public int regenerateYumCache(User loggedInUser, String channelLabel) {
        channelAdminPermCheck(loggedInUser);
        lookupChannelByLabel(loggedInUser, channelLabel);
        ChannelManager.queueChannelChange(channelLabel,
                "api: regenerateYumCache", "api called");
        return 1;
    }

    /**
     * List the children of a channel
     * @param loggedInUser The current user
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

    public Object[] listChildren(User loggedInUser, String channelLabel) {
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);

        return ChannelFactory.getAccessibleChildChannels(chan, loggedInUser).toArray();
    }

    /**
    * Returns the last build date on the repodata for a channel
    * @param loggedInUser The current user
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

    public String getChannelLastBuildById(User loggedInUser, Integer id)
                                            throws NoSuchChannelException {
        String repoLastBuild =
                ChannelManager.getRepoLastBuild(lookupChannelById(loggedInUser,
                        id.longValue()));
        if (repoLastBuild == null) {
            return "";
        }
        return repoLastBuild;
    }

   /** Returns a list of ContentSource (repos) that the user can see
     * @param loggedInUser The current user
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
    public List<Map<String, Object>> listUserRepos(User loggedInUser) {
        List<ContentSource> result = ChannelFactory
                .lookupContentSources(loggedInUser.getOrg());

        List<Map<String, Object>> list = new ArrayList<Map<String, Object>>();
        for (ContentSource cs : result) {
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("id", cs.getId());
            map.put("label", cs.getLabel());
            map.put("sourceUrl", cs.getSourceUrl());
            list.add(map);
        }
        return list;
    }

   /**
    * Creates a repository
    * @param loggedInUser The current user
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
    public ContentSource createRepo(User loggedInUser, String label, String type,
            String url) {

        BaseRepoCommand repoCmd = null;
        repoCmd = new CreateRepoCommand(loggedInUser.getOrg());

        repoCmd.setLabel(label);
        repoCmd.setUrl(url);

        try {
            repoCmd.store();
        }
        catch (InvalidCertificateException e) {
            // this kind of exception gets thrown only for SSL content sources
        }

        ContentSource repo = ChannelFactory.lookupContentSourceByOrgAndLabel(
                loggedInUser.getOrg(), label);
        return repo;
    }

   /**
    * Removes a repository
    * @param loggedInUser The current user
    * @param id of the repo to be removed
    * @return Integer 1 on success
    *
    * @xmlrpc.doc Removes a repository
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("long", "id", "ID of repo to be removed")
    * @xmlrpc.returntype #return_int_success()
   **/
    public Integer removeRepo(User loggedInUser, Integer id) {
        ContentSource repo = lookupContentSourceById(id.longValue(), loggedInUser.getOrg());

        ChannelFactory.remove(repo);
        return 1;
    }

   /**
    * Removes a repository
    * @param loggedInUser The current user
    * @param label of the repo to be removed
    * @return Integer 1 on success
    *
    * @xmlrpc.doc Removes a repository
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "label of repo to be removed")
    * @xmlrpc.returntype #return_int_success()
   **/
    public Integer removeRepo(User loggedInUser, String label) {
        ContentSource repo = lookupContentSourceByLabel(label, loggedInUser.getOrg());
        ChannelFactory.clearContentSourceFilters(repo.getId());

        ChannelFactory.remove(repo);
        return 1;
    }

   /**
    * Associates a repository with a channel
    * @param loggedInUser The current user
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
    public Channel associateRepo(User loggedInUser, String chanLabel, String repoLabel) {
        Channel channel = lookupChannelByLabel(loggedInUser, chanLabel);
        ContentSource repo = lookupContentSourceByLabel(repoLabel, loggedInUser.getOrg());

        Set<ContentSource> set = channel.getSources();
        set.add(repo);
        ChannelFactory.save(channel);

        return channel;
    }

   /**
    * Disassociates a repository from a channel
    * @param loggedInUser The current user
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
    public Channel disassociateRepo(User loggedInUser, String chanLabel, String repoLabel) {
        Channel channel = lookupChannelByLabel(loggedInUser, chanLabel);
        ContentSource repo = lookupContentSourceByLabel(repoLabel, loggedInUser.getOrg());

        Set<ContentSource> set = channel.getSources();
        set.remove(repo);
        channel.setSources(set);

        ChannelFactory.save(channel);

        return channel;
    }

   /**
    * Updates repository source URL
    * @param loggedInUser The current user
    * @param id ID of the repo
    * @param url new URL to use
    * @return the updated repo
    *
    * @xmlrpc.doc Updates repository source URL
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("int", "id", "repository id")
    * @xmlrpc.param #param_desc("string", "url", "new repository url")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepoUrl(User loggedInUser, Integer id, String url) {
        ContentSource repo = lookupContentSourceById(id.longValue(), loggedInUser.getOrg());
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

   /**
    * Updates repository source URL
    * @param loggedInUser The current user
    * @param label of the repo to use
    * @param url new URL to use
    * @return the updated repo
    *
    * @xmlrpc.doc Updates repository source URL
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "repository label")
    * @xmlrpc.param #param_desc("string", "url", "new repository url")
    * @xmlrpc.returntype $ContentSourceSerializer
   **/
    public ContentSource updateRepoUrl(User loggedInUser, String label, String url) {
        ContentSource repo = lookupContentSourceByLabel(label, loggedInUser.getOrg());
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

   /**
    * Updates repository label
    * @param loggedInUser The current user
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
    public ContentSource updateRepoLabel(User loggedInUser, Integer id, String label) {
        ContentSource repo = lookupContentSourceById(id.longValue(), loggedInUser.getOrg());
        setRepoLabel(repo, label);
        ChannelFactory.save(repo);
        return repo;
    }

    /**
     * Updates repository label
     * @param loggedInUser The current user
     * @param label of the repo
     * @param newLabel new label
     * @return the updated repo
     *
     * @xmlrpc.doc Updates repository label
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "repository label")
     * @xmlrpc.param #param_desc("string", "newLabel", "new repository label")
     * @xmlrpc.returntype $ContentSourceSerializer
    **/
     public ContentSource updateRepoLabel(User loggedInUser, String label,
                     String newLabel) {
         ContentSource repo = lookupContentSourceByLabel(label, loggedInUser.getOrg());
         setRepoLabel(repo, newLabel);
         ChannelFactory.save(repo);
         return repo;
     }

   /**
    * Updates a repository
    * @param loggedInUser The current user
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
    public ContentSource updateRepo(User loggedInUser, Integer id, String label,
            String url) {
        ContentSource repo = lookupContentSourceById(id.longValue(), loggedInUser.getOrg());
        setRepoLabel(repo, label);
        setRepoUrl(repo, url);
        ChannelFactory.save(repo);
        return repo;
    }

    /**
     * Returns the details of the given repo
     * @param loggedInUser The current user
     * @param repoLabel Label of repo whose details are sought.
     * @return the repo requested.
     *
     * @xmlrpc.doc Returns details of the given repository
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "repoLabel", "repo to query")
     * @xmlrpc.returntype
     *     $ContentSourceSerializer
     */
    public ContentSource getRepoDetails(User loggedInUser, String repoLabel) {
        return lookupContentSourceByLabel(repoLabel, loggedInUser.getOrg());
    }

    /**
     * Returns the details of the given repo
     * @param loggedInUser The current user
     * @param id ID of repo whose details are sought.
     * @return the repo requested.
     *
     * @xmlrpc.doc Returns details of the given repo
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "repoLabel", "repo to query")
     * @xmlrpc.returntype
     *     $ContentSourceSerializer
     */
    public ContentSource getRepoDetails(User loggedInUser, Integer id) {
        return lookupContentSourceById(id.longValue(), loggedInUser.getOrg());
    }

    /**
     * Lists associated repos with the given channel
     * @param loggedInUser The current user
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
    public List<ContentSource> listChannelRepos(User loggedInUser, String channelLabel) {
        Channel channel = lookupChannelByLabel(loggedInUser, channelLabel);
        return ChannelFactory.lookupContentSources(loggedInUser.getOrg(), channel);
    }

    /**
     * Trigger immediate repo synchronization
     * @param loggedInUser The current user
     * @param channelLabel channel label
     * @return 1 on success
     *
     * @xmlrpc.doc Trigger immediate repo synchronization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.returntype  #return_int_success()
     */
    public int syncRepo(User loggedInUser, String channelLabel) {
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        new TaskomaticApi().scheduleSingleRepoSync(chan, loggedInUser);
        return 1;
    }

    /**
     * Trigger immediate repo synchronization
     * @param loggedInUser The current user
     * @param channelLabel channel label
     * @param params parameters
     * @return 1 on success
     *
     * @xmlrpc.doc Trigger immediate repo synchronization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.param
     *  #struct("params_map")
     *    #prop_desc("Boolean", "sync-kickstart", "Create kickstartable tree - Optional")
     *    #prop_desc("Boolean", "no-errata", "Do not sync errata - Optional")
     *    #prop_desc("Boolean", "fail", "Terminate upon any error - Optional")
     *  #struct_end()
     * @xmlrpc.returntype  #return_int_success()
     */
    public int syncRepo(User loggedInUser, String channelLabel,
                                               Map <String, String> params) {
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        new TaskomaticApi().scheduleSingleRepoSync(chan, loggedInUser, params);
        return 1;
    }

    /**
     * Schedule periodic repo synchronization
     * @param loggedInUser The current user
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
    public int syncRepo(User loggedInUser, String channelLabel, String cronExpr) {
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
     * Schedule periodic repo synchronization
     * @param loggedInUser The current user
     * @param channelLabel channel label
     * @param cronExpr cron expression, if empty all periodic schedules will be disabled
     * @param params parameters
     * @return 1 on success
     *
     * @xmlrpc.doc Schedule periodic repo synchronization
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.param #param_desc("string", "cron expression",
     *      "if empty all periodic schedules will be disabled")
     * @xmlrpc.param
     *  #struct("params_map")
     *    #prop_desc("Boolean", "sync-kickstart", "Create kickstartable tree - Optional")
     *    #prop_desc("Boolean", "no-errata", "Do not sync errata - Optional")
     *    #prop_desc("Boolean", "fail", "Terminate upon any error - Optional")
     *  #struct_end()
     * @xmlrpc.returntype  #return_int_success()
     */
    public int syncRepo(User loggedInUser,
            String channelLabel, String cronExpr, Map <String, String> params) {
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
        if (StringUtils.isEmpty(cronExpr)) {
            new TaskomaticApi().unscheduleRepoSync(chan, loggedInUser);
        }
        else {
            new TaskomaticApi().scheduleRepoSync(chan, loggedInUser, cronExpr, params);
        }
        return 1;
    }

    /**
     * Returns repo synchronization quartz expression
     * @param loggedInUser The current user
     * @param channelLabel channel label
     * @return quartz expression
     *
     * @xmlrpc.doc Returns repo synchronization cron expression
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "channelLabel", "channel label")
     * @xmlrpc.returntype string quartz expression
     */
    public String getRepoSyncCronExpression(User loggedInUser, String channelLabel) {
        Channel chan = lookupChannelByLabel(loggedInUser, channelLabel);
            String cronExpr = new TaskomaticApi().getRepoSyncSchedule(chan, loggedInUser);
            if (StringUtils.isEmpty(cronExpr)) {
                return new String("");
            }
            return cronExpr;
    }

   /**
    * Lists the filters for a repo
    * @param loggedInUser The current user
    * @param label of the repo to use
    * @return list of filters
    *
    * @xmlrpc.doc Lists the filters for a repo
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "repository label")
    * @xmlrpc.returntype
    *      #array()
    *          $ContentSourceFilterSerializer
    *      #array_end()
    *
   **/
    public List<ContentSourceFilter> listRepoFilters(User loggedInUser, String label) {

        ContentSource cs = lookupContentSourceByLabel(label, loggedInUser.getOrg());

        List<ContentSourceFilter> result =
            ChannelFactory.lookupContentSourceFiltersById(cs.getId());

        return result;
    }

    /**
     * adds a filter for a given repo.
     * @param loggedInUser The current user
     * @param label of the repo to use
     * @param filterIn list of filters
     * @return sort order for the new filter
     *
     * @xmlrpc.doc Adds a filter for a given repo.
     * @xmlrpc.param #param("string", "sessionKey ")
     * @xmlrpc.param #param_desc("string", "label", "repository label")
     * @xmlrpc.param
     *  #struct("filter_map")
     *          #prop_desc("string", "filter", "string to filter on")
     *          #prop_desc("string", "flag", "+ for include, - for exclude")
     *  #struct_end()
     * @xmlrpc.returntype int sort order for new filter
     */
    public int addRepoFilter(User loggedInUser, String label,
            Map<String, String> filterIn) {
        Role orgAdminRole = RoleFactory.lookupByLabel("org_admin");

        if (!loggedInUser.hasRole(orgAdminRole)) {
            throw new PermissionException("Only Org Admins can add repo filters.");
        }

        ContentSource cs = lookupContentSourceByLabel(label, loggedInUser.getOrg());

        String flag = filterIn.get("flag");
        String filter = filterIn.get("filter");

        if (!(flag.equals("+") || flag.equals("-"))) {
            throw new InvalidParameterException("flag must be + or -");
        }

        // determine the highest sort order of existing filters
        int sortOrder = 0;
        for (ContentSourceFilter f : listRepoFilters(loggedInUser, label)) {
            sortOrder = Math.max(sortOrder, f.getSortOrder());
        }

        ContentSourceFilter newFilter = new ContentSourceFilter();
        newFilter.setSourceId(cs.getId());
        newFilter.setFlag(flag);
        newFilter.setFilter(filter);
        newFilter.setSortOrder(sortOrder + 1);

        ChannelFactory.save(newFilter);

        return sortOrder;
    }

    /**
     * Removes a filter for a given repo.
     * @param loggedInUser The current user
     * @param label of the repo to use
     * @param filterIn list of filters
     * @return 1 on success
     *
     * @xmlrpc.doc Removes a filter for a given repo.
     * @xmlrpc.param #param("string", "sessionKey ")
     * @xmlrpc.param #param_desc("string", "label", "repository label")
     * @xmlrpc.param
     *  #struct("filter_map")
     *          #prop_desc("string", "filter", "string to filter on")
     *          #prop_desc("string", "flag", "+ for include, - for exclude")
     *  #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeRepoFilter(User loggedInUser, String label,
            Map<String, String> filterIn) {
        Role orgAdminRole = RoleFactory.lookupByLabel("org_admin");

        if (!loggedInUser.hasRole(orgAdminRole)) {
            throw new PermissionException("Only Org Admins can remove repo filters.");
        }

        //TODO is this necessary?
        lookupContentSourceByLabel(label, loggedInUser.getOrg());

        String flag = filterIn.get("flag");
        String filter = filterIn.get("filter");

        if (!(flag.equals("+") || flag.equals("-"))) {
            throw new InvalidParameterException("flag must be + or -");
        }

        // find the existing filter
        ContentSourceFilter oldFilter = null;
        for (ContentSourceFilter f : listRepoFilters(loggedInUser, label)) {
            if (flag.equals(f.getFlag()) && filter.equals(f.getFilter())) {
                oldFilter = f;
                break;
            }
        }

        if (oldFilter == null) {
            throw new InvalidParameterException("filter does not exist");
        }

        ChannelFactory.remove(oldFilter);

        return 1;
    }

    /**
     * replaces the existing set of filters for a given repo.
     * filters are ranked by their order in the array.
     * @param loggedInUser The current user
     * @param label of the repo to use
     * @param filtersIn list of filters
     * @return 1 on success
     *
     * @xmlrpc.doc Replaces the existing set of filters for a given repo.
     * Filters are ranked by their order in the array.
     * @xmlrpc.param #param("string", "sessionKey ")
     * @xmlrpc.param #param_desc("string", "label", "repository label")
     * @xmlrpc.param
     *  #array()
     *      #struct("filter_map")
     *          #prop_desc("string", "filter", "string to filter on")
     *          #prop_desc("string", "flag", "+ for include, - for exclude")
     *      #struct_end()
     *  #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setRepoFilters(User loggedInUser, String label,
            List<Map<String, String>> filtersIn) {
        Role orgAdminRole = RoleFactory.lookupByLabel("org_admin");

        if (!loggedInUser.hasRole(orgAdminRole)) {
            throw new PermissionException("Only Org Admins can set repo filters.");
        }

        ContentSource cs = lookupContentSourceByLabel(label, loggedInUser.getOrg());

        List<ContentSourceFilter> filters = new ArrayList<ContentSourceFilter>();

        int i = 1;
        for (Map<String, String> filterIn : filtersIn) {
            String flag = filterIn.get("flag");
            String filter = filterIn.get("filter");

            if (!(flag.equals("+") || flag.equals("-"))) {
                throw new InvalidParameterException("flag must be + or -");
            }

            ContentSourceFilter f = new ContentSourceFilter();
            f.setSourceId(cs.getId());
            f.setFlag(flag);
            f.setFilter(filter);
            f.setSortOrder(i);

            filters.add(f);

            i++;
        }

        ChannelFactory.clearContentSourceFilters(cs.getId());

        for (ContentSourceFilter filter : filters) {
            ChannelFactory.save(filter);
        }

        return 1;
    }

   /**
    * Clears the filters for a repo
    * @param loggedInUser The current user
    * @param label of the repo to use
    * @return 1 on success
    *
    * @xmlrpc.doc Removes the filters for a repo
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "repository label")
    * @xmlrpc.returntype #return_int_success()
   **/
    public int clearRepoFilters(User loggedInUser, String label) {
        Role orgAdminRole = RoleFactory.lookupByLabel("org_admin");

        if (!loggedInUser.hasRole(orgAdminRole)) {
            throw new PermissionException("Only Org Admins can remove repo filters.");
        }

        ContentSource cs = lookupContentSourceByLabel(label, loggedInUser.getOrg());

        ChannelFactory.clearContentSourceFilters(cs.getId());

        return 1;
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
