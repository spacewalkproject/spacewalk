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
package com.redhat.rhn.frontend.xmlrpc.kickstart;

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.KickstartRawData;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.kickstart.builder.KickstartParser;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeFilter;
import com.redhat.rhn.frontend.action.kickstart.KickstartTreeUpdateType;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.RhnXmlRpcServer;
import com.redhat.rhn.frontend.xmlrpc.kickstart.tree.KickstartTreeHandler;
import com.redhat.rhn.manager.kickstart.KickstartCloneCommand;
import com.redhat.rhn.manager.kickstart.KickstartDeleteCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;

import java.util.List;


/**
 * KickstartHandler
 * @xmlrpc.namespace kickstart
 * @xmlrpc.doc Provides methods to create kickstart files
 * @version $Rev$
 */
public class KickstartHandler extends BaseHandler {

    /**
     * List the available kickstartable trees for the given channel.
     * @param loggedInUser The current user
     * @param channelLabel Label of channel to search.
     * @return Array of KickstartableTreeObjects
     * @deprecated being replaced by kickstart.tree.list(string sessionKey,
     * string channelLabel)
     *
     * @xmlrpc.doc List the available kickstartable trees for the given channel.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "channelLabel", "Label of channel to
     * search.")
     * @xmlrpc.returntype #array() $KickstartTreeSerializer #array_end()
     */
    @Deprecated
    public List listKickstartableTrees(User loggedInUser,
            String channelLabel) {
        return new KickstartTreeHandler().
                list(loggedInUser, channelLabel);
    }

    /**
     * List kickstartable channels for the logged in user.
     * @param loggedInUser The current user
     * @return Array of Channel objects.
     *
     * @xmlrpc.doc List kickstartable channels for the logged in user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $ChannelSerializer #array_end()
     */
    public List<Channel> listKickstartableChannels(User loggedInUser) {
        ensureConfigAdmin(loggedInUser);
        return  ChannelFactory
                .getKickstartableChannels(loggedInUser.getOrg());

    }

    /**
     * List kickstartable tree channels for the logged in user.
     * @param loggedInUser The current user
     * @return Array of Channel objects.
     *
     * @xmlrpc.doc List kickstartable tree channels for the logged in user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $ChannelSerializer #array_end()
     */
    public List<Channel> listKickstartableTreeChannels(User loggedInUser) {
        ensureConfigAdmin(loggedInUser);
        return ChannelFactory.getKickstartableTreeChannels(loggedInUser.getOrg());
    }

    /**
     * Import a kickstart profile. This method will maintain the
     * url/nfs/harddrive/cdrom command in the kickstart file rather than replace
     * it with the kickstartable tree's default URL.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartFileContents Contents of a kickstart file.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Import a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartFileContents", "Contents of
     * the kickstart file to import.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int importFile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartFileContents) {

        return importFile(loggedInUser, profileLabel, virtualizationType,
                kickstartableTreeLabel,
                RhnXmlRpcServer.getServerName(), kickstartFileContents);
    }

    /**
     * Import a kickstart profile, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartHost Kickstart hostname (of a satellite or proxy) used to
     * construct the default download URL for the new kickstart profile. Using
     * this option signifies that this default URL will be used instead of any
     * url/nfs/cdrom/harddrive commands in the kickstart file itself.
     * @param kickstartFileContents Contents of a kickstart file.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Import a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartHost", "Kickstart hostname
     * (of a satellite or proxy) used to construct the default download URL for
     * the new kickstart profile. Using this option signifies that this default
     * URL will be used instead of any url/nfs/cdrom/harddrive commands in the
     * kickstart file itself.")
     * @xmlrpc.param #param_desc("string", "kickstartFileContents", "Contents of
     * the kickstart file to import.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int importFile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String kickstartFileContents) {
        return importFile(loggedInUser, profileLabel, virtualizationType,
                kickstartableTreeLabel, kickstartHost, kickstartFileContents,
                getDefaultUpdateType());
    }

    /**
     * Import a kickstart profile, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartHost Kickstart hostname (of a satellite or proxy) used to
     * construct the default download URL for the new kickstart profile. Using
     * this option signifies that this default URL will be used instead of any
     * url/nfs/cdrom/harddrive commands in the kickstart file itself.
     * @param kickstartFileContents Contents of a kickstart file.
     * @param updateType Set the automatic ks tree update strategy
     * for the profile. Valid choices are "red_hat", "none", "all".
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Import a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartHost", "Kickstart hostname
     * (of a satellite or proxy) used to construct the default download URL for
     * the new kickstart profile. Using this option signifies that this default
     * URL will be used instead of any url/nfs/cdrom/harddrive commands in the
     * kickstart file itself.")
     * @xmlrpc.param #param_desc("string", "kickstartFileContents", "Contents of
     * the kickstart file to import.")
     * @xmlrpc.param #param_desc("string", "updateType", "Should the profile update
     * itself to use the newest tree available? Possible values are: none (default),
     * red_hat (only use Kickstart Trees synced from Red Hat), or all (includes
     * custom Kickstart Trees).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int importFile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String kickstartFileContents,
            String updateType) {

        KickstartParser parser = new KickstartParser(kickstartFileContents);
        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        KickstartTreeUpdateType updateTree = getUpdateType(updateType, tree);

        try {
            builder.createFromParser(parser, profileLabel, virtualizationType,
                    tree, updateTree);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (com.redhat.rhn.domain.kickstart.builder.InvalidKickstartLabelException e) {
            throw new InvalidKickstartLabelException(profileLabel);
        }

        return 1;
    }

    /**
     * Create a new kickstart profile using the default download URL for the
     * kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartHost Kickstart hostname (of a satellite or proxy) used to
     * construct the default download URL for the new kickstart profile.
     * @param rootPassword Root password.
     * @param updateType Set the automatic ks tree update strategy
     * for the profile. Valid choices are "red_hat", "none", "all".
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Create a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel" "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartHost", "Kickstart hostname
     * (of a satellite or proxy) used to construct the default download URL for
     * the new kickstart profile.")
     * @xmlrpc.param #param_desc("string", "rootPassword", "Root password.")
     * @xmlrpc.param #param_desc("string", "updateType", "Should the profile update
     * itself to use the newest tree available? Possible values are: none (default),
     * red_hat (only use Kickstart Trees synced from Red Hat), or all (includes
     * custom Kickstart Trees).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createProfile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String rootPassword, String updateType) {

        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        builder.validateTreeVirt(tree, virtualizationType);

        KickstartTreeUpdateType updateTree = getUpdateType(updateType, tree);

        String downloadUrl = tree.getDefaultDownloadLocation();
        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword, updateTree);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (com.redhat.rhn.domain.kickstart.builder.InvalidKickstartLabelException e) {
            throw new InvalidKickstartLabelException(profileLabel);
        }

        return 1;
    }

    /**
     * Create a new kickstart profile using the default download URL for the
     * kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartHost Kickstart hostname (of a satellite or proxy) used to
     * construct the default download URL for the new kickstart profile.
     * @param rootPassword Root password.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Create a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel" "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartHost", "Kickstart hostname
     * (of a satellite or proxy) used to construct the default download URL for
     * the new kickstart profile.")
     * @xmlrpc.param #param_desc("string", "rootPassword", "Root password.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createProfile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String rootPassword) {
        return createProfile(loggedInUser, profileLabel, virtualizationType,
                kickstartableTreeLabel, kickstartHost, rootPassword,
                getDefaultUpdateType());
    }

    /**
     * Create a new kickstart profile with a custom download URL.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param downloadUrl Download URL, or 'default' to use the kickstart tree's
     * default URL.
     * @param rootPassword Root password.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Create a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("boolean", "downloadUrl", "Download URL, or
     * 'default' to use the kickstart tree's default URL.")
     * @xmlrpc.param #param_desc("string", "rootPassword", "Root password.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createProfileWithCustomUrl(User loggedInUser,
            String profileLabel, String virtualizationType,
            String kickstartableTreeLabel, String downloadUrl,
            String rootPassword) {
        return createProfileWithCustomUrl(loggedInUser, profileLabel,
                virtualizationType, kickstartableTreeLabel, downloadUrl,
                rootPassword, getDefaultUpdateType());
    }

    /**
     * Create a new kickstart profile with a custom download URL.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param downloadUrl Download URL, or 'default' to use the kickstart tree's
     * default URL.
     * @param rootPassword Root password.
     * @param updateType Set the automatic ks tree update strategy
     * for the profile. Valid choices are "red_hat", "none", "all".
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Create a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("boolean", "downloadUrl", "Download URL, or
     * 'default' to use the kickstart tree's default URL.")
     * @xmlrpc.param #param_desc("string", "rootPassword", "Root password.")
     * @xmlrpc.param #param_desc("string", "updateType", "Should the profile update
     * itself to use the newest tree available? Possible values are: none (default),
     * red_hat (only use Kickstart Trees synced from Red Hat), or all (includes
     * custom Kickstart Trees).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int createProfileWithCustomUrl(User loggedInUser,
            String profileLabel, String virtualizationType,
            String kickstartableTreeLabel, String downloadUrl,
            String rootPassword, String updateType) {

        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        KickstartTreeUpdateType updateTree = getUpdateType(updateType, tree);
        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword, updateTree);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (com.redhat.rhn.domain.kickstart.builder.InvalidKickstartLabelException e) {
            throw new InvalidKickstartLabelException(profileLabel);
        }

        return 1;
    }

    private void checkKickstartPerms(User user) {
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(LocalizationService.getInstance()
                    .getMessage("permission.configadmin.needed"));
        }
    }

    private KickstartData lookupKsData(String label, Org org) {
        return XmlRpcKickstartHelper.getInstance().lookupKsData(label, org);
    }

    /**
     * List kickstarts for a user
     * @param loggedInUser The current user
     * @return list of KickstartDto objects
     *
     * @xmlrpc.doc Provides a list of kickstart profiles visible to the user's
     * org
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $KickstartDtoSerializer #array_end()
     */
    public List listKickstarts(User loggedInUser) {
        checkKickstartPerms(loggedInUser);
        return KickstartLister.getInstance().kickstartsInOrg(loggedInUser.getOrg(), null);
    }

    /**
     * Lists all ip ranges for an org
     * @param loggedInUser The current user
     * @return List of KickstartIpRange objects
     *
     * @xmlrpc.doc List all Ip Ranges and their associated kickstarts available
     * in the user's org.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $KickstartIpRangeSerializer #array_end()
     *
     */
    public List listAllIpRanges(User loggedInUser) {
        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        return KickstartFactory.lookupRangeByOrg(loggedInUser.getOrg());
    }

    /**
     * find a kickstart profile by an ip
     * @param loggedInUser The current user
     * @param ipAddress the ipaddress to search on
     * @return label of the associated kickstart
     *
     * @xmlrpc.doc Find an associated kickstart for a given ip address.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ipAddress", "The ip address to
     * search for (i.e. 192.168.0.1)")
     * @xmlrpc.returntype string - label of the kickstart. Empty string ("") if
     * not found.
     */
    public String findKickstartForIp(User loggedInUser, String ipAddress) {
        List<KickstartIpRange> ranges = KickstartFactory.lookupRangeByOrg(loggedInUser
                .getOrg());
        KickstartIpRangeFilter filter = new KickstartIpRangeFilter();
        for (KickstartIpRange range : ranges) {
            if (filter.filterOnRange(ipAddress, range.getMinString(), range
                    .getMaxString())) {
                return range.getKsdata().getLabel();
            }
        }
        return "";
    }

    /**
     * delete a kickstart profile
     * @param loggedInUser The current user
     * @param ksLabel the kickstart to remove an ip range from
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Delete a kickstart profile
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of
     * the kickstart profile you want to remove")
     * @xmlrpc.returntype #return_int_success()
     */
    public int deleteProfile(User loggedInUser, String ksLabel) {
        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartDeleteCommand com = new KickstartDeleteCommand(ksdata.getId(),
                loggedInUser);
        ValidatorError error = com.store();

        return 1;
    }

    /**
     * En/Disable kickstart profile
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for tree we want to en/disable
     * @param disabled True to disable the profile
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Enable/Disable a Kickstart Profile
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel" "Label for the
     * kickstart tree you want to en/disable")
     * @xmlrpc.param #param_desc("string", "disabled" "true to disable the profile")
     * @xmlrpc.returntype #return_int_success()
     */
    public int disableProfile(User loggedInUser, String profileLabel, Boolean disabled) {

        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        KickstartData ksData = lookupKsData(profileLabel, loggedInUser.getOrg());

        KickstartEditCommand cmd = new KickstartEditCommand(
                ksData.getId(), loggedInUser);

        cmd.setActive(!disabled);
        cmd.store();

        return 1;
    }

    /**
     * Returns whether a kickstart profile is disabled
     *
     * @param loggedInUser The current user
     * @param profileLabel kickstart profile label
     * @return true if profile is disabled
     *
     * @xmlrpc.doc Returns whether a kickstart profile is disabled
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel" "kickstart profile label")
     * @xmlrpc.returntype true if profile is disabled
     */
    public boolean isProfileDisabled(User loggedInUser, String profileLabel) {

        KickstartData ksData = lookupKsData(profileLabel, loggedInUser.getOrg());

        return !ksData.isActive();
    }

    /**
     * Rename a kickstart profile.
     *
     * @param loggedInUser The current user
     * @param originalLabel Label for profile we want to edit
     * @param newLabel to assign to profile
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Rename a Kickstart Profile in Satellite
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "originalLabel" "Label for the
     * kickstart profile you want to rename")
     * @xmlrpc.param #param_desc("string", "newLabel" "new label to change to")
     * @xmlrpc.returntype #return_int_success()
     */
    public int renameProfile(User loggedInUser, String originalLabel, String newLabel) {

        KickstartData ksData = lookupKsData(originalLabel, loggedInUser.getOrg());

        KickstartData existing = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                newLabel, loggedInUser.getOrg().getId());

        if (existing != null) {
            throw new InvalidKickstartLabelException(newLabel);
        }
        KickstartEditCommand cmd = new KickstartEditCommand(
                ksData.getId(), loggedInUser);

        cmd.setLabel(newLabel);
        cmd.store();

        return 1;
    }

    /**
     * Clones a kickstart profile.
     *
     * @param loggedInUser The current user
     * @param ksLabelToClone label of the kickstart profile to clone
     * @param newKsLabel label of the cloned profile
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Clone a Kickstart Profile
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabelToClone" "Label of the
     * kickstart profile to clone")
     * @xmlrpc.param #param_desc("string", "newKsLabel" "label of the cloned profile")
     * @xmlrpc.returntype #return_int_success()
     */
    public int cloneProfile(User loggedInUser, String ksLabelToClone, String newKsLabel) {

        KickstartData toClone = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabelToClone, loggedInUser.getOrg().getId());
        if (toClone == null) {
            throw new InvalidKickstartLabelException(ksLabelToClone);
        }

        KickstartCloneCommand cmd =
                new KickstartCloneCommand(toClone.getId(), loggedInUser, newKsLabel);

        KickstartBuilder builder = new KickstartBuilder(loggedInUser);
        builder.validateNewLabel(newKsLabel);
        cmd.store();

        return 1;
    }

    /**
     * Import a kickstart profile, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartFileContents Contents of a kickstart file.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Import a raw kickstart file into satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartFileContents", "Contents of
     * the kickstart file to import.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int importRawFile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartFileContents) {
        return importRawFile(loggedInUser, profileLabel, virtualizationType,
                kickstartableTreeLabel, kickstartFileContents,
                getDefaultUpdateType());
    }

    /**
     * Import a kickstart profile, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     *
     * @param loggedInUser The current user
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartFileContents Contents of a kickstart file.
     * @param updateType Set the automatic ks tree update strategy
     * for the profile. Valid choices are "red_hat", "none", "all".
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Import a raw kickstart file into satellite.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "profileLabel", "Label for the new
     * kickstart profile.")
     * @xmlrpc.param #param_desc("string", "virtualizationType", "none, para_host,
     * qemu, xenfv or xenpv.")
     * @xmlrpc.param #param_desc("string", "kickstartableTreeLabel", "Label of a
     * kickstartable tree to associate the new profile with.")
     * @xmlrpc.param #param_desc("string", "kickstartFileContents", "Contents of
     * the kickstart file to import.")
     * @xmlrpc.param #param_desc("string", "updateType", "Should the profile update
     * itself to use the newest tree available? Possible values are: none (default),
     * red_hat (only use Kickstart Trees synced from Red Hat), or all (includes
     * custom Kickstart Trees).")
     * @xmlrpc.returntype #return_int_success()
     */
    public int importRawFile(User loggedInUser, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartFileContents, String updateType) {

        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        KickstartTreeUpdateType updateTree = getUpdateType(updateType, tree);

        try {
            KickstartRawData data = builder.createRawData(profileLabel, tree,
                    kickstartFileContents, virtualizationType, updateTree);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (com.redhat.rhn.domain.kickstart.builder.InvalidKickstartLabelException e) {
            throw new InvalidKickstartLabelException(profileLabel);
        }

        return 1;
    }

    /**
     * Conver string updatetype to a real KickstartTreeUpdateType
     * @param typeIn the string to try
     * @return the KickstartTreeUpdateType
     */
    private KickstartTreeUpdateType getUpdateType(String typeIn,
                KickstartableTree tree) {
        if (typeIn.equals(KickstartTreeUpdateType.ALL.getType())) {
            if (tree.getChannel() == null) {
                throw new InvalidUpdateTypeAndNoBaseTreeException(tree.getLabel());
            }
            return KickstartTreeUpdateType.ALL;
        }
        else if (typeIn.equals(KickstartTreeUpdateType.RED_HAT.getType())) {
            if (tree.getOrgId() != null) {
                throw new InvalidUpdateTypeAndKickstartTreeException(tree.getLabel());
            }
            if (tree.getChannel() == null) {
                throw new InvalidUpdateTypeAndNoBaseTreeException(tree.getLabel());
            }
            return KickstartTreeUpdateType.RED_HAT;
        }
        else if (typeIn.equals(KickstartTreeUpdateType.NONE.getType())) {
            return KickstartTreeUpdateType.NONE;
        }
        else {
            throw new InvalidUpdateTypeException(typeIn);
        }
    }

    /**
     * Return the default KickstartTreeUpdateType
     * @return string for the default KickstartTreeUpdateType
     */
    private String getDefaultUpdateType() {
        return KickstartTreeUpdateType.NONE.getType();
    }
}
