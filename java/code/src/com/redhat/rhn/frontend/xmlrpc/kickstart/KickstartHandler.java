/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.builder.KickstartBuilder;
import com.redhat.rhn.domain.kickstart.builder.KickstartParser;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeFilter;
import com.redhat.rhn.frontend.dto.kickstart.KickstartDto;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidKickstartScriptException;
import com.redhat.rhn.frontend.xmlrpc.InvalidScriptTypeException;
import com.redhat.rhn.frontend.xmlrpc.IpRangeConflictException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartIpCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.kickstart.KickstartPartitionCommand;

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
     * 
     * @xmlrpc.doc List the available kickstartable trees for the given channel.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "channelLabel", "Label of channel to
     * search.")
     * @xmlrpc.returntype #array() $KickstartTreeSerializer #array_end()
     */
    public Object[] listKickstartableTrees(String sessionKey,
            String channelLabel) {
        User loggedInUser = getLoggedInUser(sessionKey);
        Channel channel = ChannelManager.lookupByLabelAndUser(channelLabel,
                loggedInUser);
        if (channel == null) {
            throw new InvalidChannelLabelException();
        }
        List<KickstartableTree> ksTrees = KickstartFactory
                .lookupKickstartableTrees(channel.getId(), loggedInUser
                        .getOrg());
        return ksTrees.toArray();
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
    public Object[] listKickstartableChannels(String sessionKey) {
        User loggedInUser = getLoggedInUser(sessionKey);
        List<Channel> ksChannels = ChannelFactory
                .getKickstartableChannels(loggedInUser.getOrg());
        return ksChannels.toArray();
    }

    /**
     * Change kickstart tree (and base channel if required) of an existing
     * kickstart profile.
     * @param sessionKey User's session key.
     * @param kslabel label of the kickstart profile to be changed.
     * @param kstreeLabel label of the new kickstart tree.
     * @return 1 if successful, exception otherwise.
     * 
     * @xmlrpc.doc Change kickstart tree of an existing kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("string", "kstreeLabel", "Label of new
     * kickstart tree.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setKickstartTree(String sessionKey, String kslabel,
            String kstreeLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksdata = KickstartFactory
                .lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser
                        .getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }

        KickstartableTree tree = KickstartFactory.lookupTreeByLabel(
                kstreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kstreeLabel);
        }

        KickstartDefaults ksdefault = ksdata.getKsdefault();
        ksdefault.setKstree(tree);
        return 1;
    }

    
    /** 
     * Set child channels for an existing kickstart profile.   
     * @param sessionKey User's session key. 
     * @param kslabel label of the kickstart profile to be updated.
     * @param channelLabels labels of the child channels to be set in the 
     * kickstart profile. 
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Update child channels for an existing kickstart profile. 
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")     
     * @xmlrpc.param #param_desc("string[]", "channelLabels", 
     * "List of labels of child channels")
     * @xmlrpc.returntype #return_int_success()
     */    
    public int setChildChannels(String sessionKey, String kslabel, 
            List<String> channelLabels) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksdata = KickstartFactory.
              lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                "No Kickstart Profile found with label: " + kslabel);
        }
               
        Long ksid = ksdata.getId();
        KickstartEditCommand ksEditCmd = new KickstartEditCommand(ksid, loggedInUser);
        List<String> channelIds = new ArrayList<String>(); 
        
        for (int i = 0; i < channelIds.size(); i++) {
            Channel channel = ChannelManager.lookupByLabelAndUser(channelLabels.get(i), 
                 loggedInUser);
            if (channel == null) {
                throw new InvalidChannelLabelException();
            }
            String channelId = channel.getId().toString();
            channelIds.add(channelId);
        }

        String[] childChannels = new String [channelIds.size()];
        childChannels = (String[]) channelIds.toArray(new String[0]);
        ksEditCmd.updateChildChannels(childChannels);        
        
        return 1;
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
     * @xmlrpc.param #param_desc("string", "virtualizationType", "para_host,
     * para_guest, or none.")
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
                kickstartableTreeLabel, null, kickstartFileContents);
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
     * @xmlrpc.param #param_desc("string", "virtualizationType", "para_host,
     * para_guest, or none.")
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

        KickstartableTree tree = KickstartFactory.lookupTreeByLabel(
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
     * @xmlrpc.param #param_desc("string", "virtualizationType", "para_host,
     * para_guest, or none.")
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

        KickstartableTree tree = KickstartFactory.lookupTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        String downloadUrl = tree.getDefaultDownloadLocation(kickstartHost);
        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword);
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
     * @xmlrpc.param #param_desc("string", "virtualizationType", "para_host,
     * para_guest, or none.")
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

        KickstartableTree tree = KickstartFactory.lookupTreeByLabel(
                kickstartableTreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kickstartableTreeLabel);
        }

        try {
            builder.create(profileLabel, tree, virtualizationType, downloadUrl,
                    rootPassword);
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
     * Lists all the scripts associated with a kickstart profile
     * @param sessionKey key
     * @param label the kickstart label
     * @return list of kickstartScript objects
     * 
     * @xmlrpc.doc lists the pre and post script associated with a kickstart
     * profile
     * @xmlprc.param
     * @xmlrpc.param
     * @xmlrpc.returntype #array() $KickstartScriptSerializer #array_end()
     */
    public List<KickstartScript> listScripts(String sessionKey, String label) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(label, loggedInUser.getOrg());

        return new ArrayList<KickstartScript>(data.getScripts());

    }

    /**
     * Adds a script to a kickstart profile
     * @param sessionKey key
     * @param ksLabel the kickstart label
     * @param contents the contents
     * @param interpreter the script interpreter to use
     * @param type "pre" or "post"
     * @param chroot true if you want it to be chrooted
     * @return the id of the created script
     * 
     * @xmlrpc.doc Adds a pre/post script to the given kickstart profile.
     * @xmlprc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label to
     * add the script to.")
     * @xmlrpc.param #param_desc("string", "contents", "The full script to
     * add.")
     * @xmlrpc.param #param_desc("string", "interpreter", "The path to the
     * interpreter to use (i.e. /bin/bash). An empty string will use the
     * kickstart default interpreter.")
     * @xmlrpc.param #param_desc("string", "type", "The type of script (either
     * 'pre' or 'post').")
     * @xmlrpc.param #param_desc("boolean", "chroot", "Whether to run the script
     * in the chrooted install location (recommended) or not.")
     * @xmlrpc.returntype int id - the id of the added script
     * 
     */
    public int addScript(String sessionKey, String ksLabel, String contents,
            String interpreter, String type, boolean chroot) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        if (!type.equals("pre") && !type.equals("post")) {
            throw new InvalidScriptTypeException();
        }

        KickstartScript script = new KickstartScript();
        script.setData(contents.getBytes());
        script.setInterpreter(interpreter.equals("") ? null : interpreter);
        script.setScriptType(type);
        script.setChroot(chroot ? "Y" : "N");
        script.setKsdata(ksData);
        ksData.addScript(script);
        HibernateFactory.getSession().save(script);
        return script.getId().intValue();
    }

    /**
     * Removes a kickstart script from the associated kickstart
     * @param sessionKey key
     * @param ksLabel the kickstart to remove a script from
     * @param id the id of the kickstart
     * @return 1 on success
     * 
     * @xmlrpc.doc Removes the specified script from the specified kickstart
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #prop_desc("string", "ksLabel", "The kickstart from which
     * to remove the script from.")
     * @xmlrpc.param #prop_desc("int", "scriptId", "The id of the script to
     * remove.")
     * @xmlrpc.returntype #return_int_success()
     * 
     */
    public int removeScript(String sessionKey, String ksLabel, Integer id) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        KickstartScript script = KickstartFactory.lookupKickstartScript(
                loggedInUser.getOrg(), id);
        if (script == null || 
                !script.getKsdata().getLabel().equals(ksData.getLabel())) {
            throw new InvalidKickstartScriptException();
        }

        script.setKsdata(null);
        ksData.getScripts().remove(script);
        KickstartFactory.removeKickstartScript(script);

        return 1;
    }

    /**
     * returns the fully formatted kickstart file
     * @param sessionKey key
     * @param ksLabel the label to download
     * @param host The host/ip to use when referring to the server itself
     * @return the kickstart file
     * 
     * @xmlrpc.doc Download the full contents of a kickstart file.
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart to download.")
     * @xmlrpc.param #param_desc("string", "host", "The host to use when
     * referring to the satellite itself (Usually this should be the FQDN of the
     * satellite, but could be the ip address or shortname of it as well.")
     * @xmlrpc.returntype string - The contents of the kickstart file. Note: if
     * an activation key is not associated with the kickstart file, registration
     * will not occur in the satellite generated %post section. If one is
     * associated, it will be used for registration.
     * 
     * 
     */
    public String downloadKickstart(String sessionKey, String ksLabel,
            String host) {
        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartFormatter form = new KickstartFormatter(host, ksData);
        return form.getFileData();
    }

    /**
     * Set a kickstart profile's partitioning scheme.
     * @param sessionKey An active session key.
     * @param ksLabel A kickstart profile label.
     * @param scheme The partitioning scheme.
     * @return 1 on success
     * @throws FaultException
     * @xmlrpc.doc Set a kickstart profile's partitioning scheme.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart profile to update.")
     * @xmlrpc.param #param_desc("string[]", "scheme", "The partitioning scheme
     * is a list of partitioning command strings used to setup the partitions,
     * volume groups and logical volumes.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setPartitioningScheme(String sessionKey, String ksLabel,
            List<String> scheme) {
        User user = getLoggedInUser(sessionKey);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        Long ksid = ksdata.getId();
        KickstartPartitionCommand command = new KickstartPartitionCommand(ksid,
                user);
        StringBuilder sb = new StringBuilder();
        for (String s : scheme) {
            sb.append(s);
            sb.append('\n');
        }
        ValidatorError err = command.parsePartitions(sb.toString());
        if (err != null) {
            throw new FaultException(-4, "PartitioningSchemeInvalid", err
                    .toString());
        }
        command.store();
        return 1;
    }

    /**
     * Get a kickstart profile's partitioning scheme.
     * @param sessionKey An active session key
     * @param ksLabel A kickstart profile label
     * @return The profile's partitioning scheme. This is a list of commands
     * used to setup the partitions, logical volumes and volume groups.
     * @throws FaultException
     * @xmlrpc.doc Get a kickstart profile's partitioning scheme.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of a kickstart
     * profile.")
     * @xmlrpc.returntype string[] - A list of partitioning commands used to
     * setup the partitions, logical volumes and volume groups."
     */
    @SuppressWarnings("unchecked")
    public List<String> getPartitioningScheme(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        List<String> list = new ArrayList<String>();
        for (KickstartCommand cmd : (List<KickstartCommand>) ksdata
                .getPartitions()) {
            String s = "partition " + cmd.getArguments();
            list.add(s);
        }
        for (KickstartCommand cmd : (Set<KickstartCommand>) ksdata
                .getVolgroups()) {
            String s = "volgroup " + cmd.getArguments();
            list.add(s);
        }
        for (KickstartCommand cmd : (Set<KickstartCommand>) ksdata.getLogvols()) {
            String s = "logvol " + cmd.getArguments();
            list.add(s);
        }
        return list;
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
     * Lists all ip ranges for a kickstart
     * @param sessionKey An active session key
     * @param ksLabel the label of the kickstart
     * @return List of KickstartIpRange objects
     * 
     * @xmlrpc.doc List all Ip Ranges for an associated kickstart
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "The label of the
     * kickstart")
     * @xmlrpc.returntype #array() $KickstartIpRangeSerialzier #array_end()
     * 
     */
    public Set listIpRanges(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        return ksdata.getIps();
    }

    /**
     * Add an ip range to a kickstart
     * @param sessionKey the session key
     * @param ksLabel the kickstart label
     * @param min the min ip address of the range
     * @param max the max ip address of the range
     * @return 1 on success
     * 
     * 
     * @xmlrpc.doc List all Ip Ranges for an associated kickstart
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "label", "The label of the
     * kickstart")
     * @xmlrpc.param #param_desc("string", "min", "The ip address making up the
     * minimum of the range (i.e. 192.168.0.1)")
     * @xmlrpc.param #param_desc("string", "max", "The ip address making up the
     * maximum of the range (i.e. 192.168.0.254)")
     * @xmlrpc.returntype #return_int_success()
     * 
     */
    public int addIpRange(String sessionKey, String ksLabel, String min,
            String max) {
        User user = getLoggedInUser(sessionKey);
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        KickstartIpCommand com = new KickstartIpCommand(ksdata.getId(), user);

        IpAddress minIp = new IpAddress(min);
        IpAddress maxIp = new IpAddress(max);

        if (!com.addIpRange(minIp.getOctets(), maxIp.getOctets())) {
            throw new IpRangeConflictException(min + " - " + max);
        }
        com.store();
        return 1;
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
     * 
     * 
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
     * remove an ip range from a kickstart
     * @param sessionKey the session key
     * @param ksLabel the kickstart to remove an ip range from
     * @param ipAddress an ip address in the range that you want to remove
     * @return 1 on removal, 0 if not found, exception otherwise
     * 
     * @xmlrpc.doc Remove an ip range from a specified kickstart
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label of
     * the ip range you want to remove")
     * @xmlrpc.param #param_desc("string", "ip_address", "An Ip Address that
     * falls within the range that you are wanting to remove. The min or max of
     * the range will work.")
     * @xmlrpc.returntype int - 1 on successful removal, 0 if range wasn't found
     * for the specified kickstart, exception otherwise.
     */
    public int removeIpRange(String sessionKey, String ksLabel, String ipAddress) {
        User user = getLoggedInUser(sessionKey);
        if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionCheckFailureException();
        }
        KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
        KickstartIpRangeFilter filter = new KickstartIpRangeFilter();
        for (KickstartIpRange range : ksdata.getIps()) {
            if (filter.filterOnRange(ipAddress, range.getMinString(), range
                    .getMaxString())) {
                ksdata.getIps().remove(range);
                return 1;
            }
        }
        return 0;
    }
}
