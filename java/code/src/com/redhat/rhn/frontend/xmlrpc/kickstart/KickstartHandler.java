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
package com.redhat.rhn.frontend.xmlrpc.kickstart;


import com.redhat.rhn.common.db.datasource.DataResult;
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
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.RhnXmlRpcServer;
import com.redhat.rhn.frontend.xmlrpc.kickstart.tree.KickstartTreeHandler;
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
     * @param sessionKey User's session key.
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
    public List listKickstartableTrees(String sessionKey,
            String channelLabel) {
        return new KickstartTreeHandler().
            list(sessionKey, channelLabel);
    }

    /**
     * List kickstartable channels for the logged in user.
     * @param sessionKey User's session key.
     * @return Array of Channel objects.
     * 
     * @xmlrpc.doc List kickstartable channels for the logged in user.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $ChannelSerializer #array_end()
     */
    public List<Channel> listKickstartableChannels(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        ensureConfigAdmin(loggedInUser);
        return  ChannelFactory
                .getKickstartableChannels(loggedInUser.getOrg());
        
    }

    

    /**
     * Import a kickstart profile into RHN. This method will maintain the
     * url/nfs/harddrive/cdrom command in the kickstart file rather than replace
     * it with the kickstartable tree's default URL.
     * 
     * @param sessionKey User's session key.
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartFileContents Contents of a kickstart file.
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Import a kickstart profile into RHN.
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
    public int importFile(String sessionKey, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartFileContents) {

        return importFile(sessionKey, profileLabel, virtualizationType,
                kickstartableTreeLabel, 
                RhnXmlRpcServer.getServerName(), kickstartFileContents);
    }

    /**
     * Import a kickstart profile into RHN, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     * 
     * @param sessionKey User's session key.
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
     * @xmlrpc.doc Import a kickstart profile into RHN.
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
    public int importFile(String sessionKey, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String kickstartFileContents) {

        User loggedInUser = getLoggedInUser(sessionKey);

        KickstartParser parser = new KickstartParser(kickstartFileContents);
        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        try {
            builder.createFromParser(parser, profileLabel, virtualizationType,
                    tree, kickstartHost);
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
     * @param sessionKey User's session key.
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param kickstartHost Kickstart hostname (of a satellite or proxy) used to
     * construct the default download URL for the new kickstart profile.
     * @param rootPassword Root password.
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Import a kickstart profile into RHN.
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
    public int createProfile(String sessionKey, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartHost, String rootPassword) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        String downloadUrl = tree.getDefaultDownloadLocation(kickstartHost);
        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword,  RhnXmlRpcServer.getServerName());
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
     * Create a new kickstart profile with a custom download URL.
     * 
     * @param sessionKey User's session key.
     * @param profileLabel Label for the new kickstart profile.
     * @param virtualizationType Virtualization type, or none.
     * @param kickstartableTreeLabel Label of a kickstartable tree.
     * @param downloadUrl Download URL, or 'default' to use the kickstart tree's
     * default URL.
     * @param rootPassword Root password.
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Import a kickstart profile into RHN.
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
    public int createProfileWithCustomUrl(String sessionKey,
            String profileLabel, String virtualizationType,
            String kickstartableTreeLabel, String downloadUrl,
            String rootPassword) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword, RhnXmlRpcServer.getServerName());
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
     * @param sessionKey key
     * @return list of KickstartDto objects
     * 
     * @xmlrpc.doc Provides a list of kickstart profiles visible to the user's
     * org
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $KickstartDtoSerializer #array_end()
     */
    public List listKickstarts(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        DataResult<KickstartDto> result = KickstartLister.getInstance()
                .kickstartsInOrg(loggedInUser.getOrg(), null);
        return result;
    }

    /**
     * Lists all ip ranges for an org
     * @param sessionKey An active session key
     * @return List of KickstartIpRange objects
     * 
     * @xmlrpc.doc List all Ip Ranges and their associated kickstarts available
     * in the user's org.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype #array() $KickstartIpRangeSerializer #array_end()
     * 
     */
    public List listAllIpRanges(String sessionKey) {
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException();
        }

        return KickstartFactory.lookupRangeByOrg(user.getOrg());
    }

    /**
     * find a kickstart profile by an ip
     * @param sessionKey the session
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
    public String findKickstartForIp(String sessionKey, String ipAddress) {
        User user = getLoggedInUser(sessionKey);
        List<KickstartIpRange> ranges = KickstartFactory.lookupRangeByOrg(user
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
     * @param sessionKey the session key
     * @param ksLabel the kickstart to remove an ip range from
     * @return 1 on removal, 0 if not found, exception otherwise
     * 
     * @xmlrpc.doc Delete a kickstart profile
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of
     * the kickstart profile you want to remove")
     * @xmlrpc.returntype int - 1 on successful deletion, 0 if kickstart wasn't found
     *  or couldn't be deleted.
     */    
    public int deleteProfile(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(RoleFactory.CONFIG_ADMIN);
        }
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        KickstartDeleteCommand com = new KickstartDeleteCommand(ksdata.getId(), user);
        ValidatorError error = com.store();
        if (error == null) {
            return 1;
        }
        else {
            return 0;
        }
    }
    
    /**
     * Rename a kickstart profile.
     * 
     * @param sessionKey User's session key.
     * @param originalLabel Label for tree we want to edit
     * @param newLabel to assign to tree.
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Rename a Kickstart Tree (Distribution) in Satellite
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "originalLabel" "Label for the
     * kickstart tree you want to rename")
     * @xmlrpc.param #param_desc("string", "newLabel" "new label to change too")
     * @xmlrpc.returntype #return_int_success()
     */
    public int renameProfile(String sessionKey, String originalLabel, String newLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
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
        
        /*if (op.getTree() == null) {
            throw new InvalidKickstartTreeException("api.kickstart.tree.notfound");
        }
        op.setLabel(newLabel);
        ValidatorError ve = op.store();
        if (ve != null) {
            throw new InvalidKickstartTreeException(ve.getKey());
        }*/
        return 1;
    }

    /**
     * Import a kickstart profile into RHN, overriding the
     * url/nfs/harddrive/cdrom command in the file and replacing it with the
     * default URL for the kickstartable tree and kickstart host specified.
     * 
     * @param sessionKey User's session key.
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
    public int importRawFile(String sessionKey, String profileLabel,
            String virtualizationType, String kickstartableTreeLabel,
            String kickstartFileContents) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartBuilder builder = new KickstartBuilder(loggedInUser);

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        try {
            KickstartRawData data = builder.createRawData(profileLabel,
                                                     tree, kickstartFileContents,
                                                     virtualizationType);
        }
        catch (PermissionException e) {
            throw new PermissionCheckFailureException(e);
        }
        catch (com.redhat.rhn.domain.kickstart.builder.InvalidKickstartLabelException e) {
            throw new InvalidKickstartLabelException(profileLabel);
        }

        return 1;
    }    
}
