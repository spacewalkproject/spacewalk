/**
 * Copyright (c) 2009--2014 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.kickstart.profile;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.HibernateFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartIpRange;
import com.redhat.rhn.domain.kickstart.KickstartPackage;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.kickstart.RepoInfo;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeFilter;
import com.redhat.rhn.frontend.action.kickstart.KickstartTreeUpdateType;
import com.redhat.rhn.frontend.dto.kickstart.KickstartOptionValue;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidKickstartScriptException;
import com.redhat.rhn.frontend.xmlrpc.InvalidScriptNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidScriptTypeException;
import com.redhat.rhn.frontend.xmlrpc.IpRangeConflictException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.ValidationException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidUpdateTypeAndKickstartTreeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidUpdateTypeAndNoBaseTreeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidUpdateTypeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.NoSuchKickstartTreeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.keys.KeysHandler;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartIpCommand;
import com.redhat.rhn.manager.kickstart.KickstartManager;
import com.redhat.rhn.manager.kickstart.KickstartOptionsCommand;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;

import org.apache.commons.lang.BooleanUtils;
import org.apache.commons.lang.StringUtils;
import org.cobbler.Profile;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

/**
 * ProfileHandler
 * @version $Rev$
 * @xmlrpc.namespace kickstart.profile
 * @xmlrpc.doc Provides methods to access and modify many aspects of
 * a kickstart profile.
 */
public class ProfileHandler extends BaseHandler {

    private static final String[] VALIDOPTIONNAMES = {"autostep", "interactive", "install",
            "upgrade", "text", "network", "cdrom", "harddrive", "nfs", "url",
            "lang", "langsupport", "keyboard", "mouse", "device", "deviceprobe",
            "zerombr", "clearpart", "bootloader", "timezone", "auth", "rootpw",
            "selinux", "reboot", "firewall", "xconfig", "skipx", "key",
            "ignoredisk", "autopart", "cmdline", "firstboot", "graphical", "iscsi",
            "iscsiname", "logging", "monitor", "multipath", "poweroff", "halt",
            "services", "shutdown", "user", "vnc", "zfcp", "driverdisk",
            "md5_crypt_rootpw"};

    /**
     * Get the kickstart tree for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be changed.
     * @return kickstart tree label
     *
     * @xmlrpc.doc Get the kickstart tree for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.returntype
     *     #param_desc("string", "kstreeLabel", "Label of the kickstart tree.")
     */
    public String getKickstartTree(User loggedInUser, String kslabel) {

        KickstartData ksdata = KickstartFactory
                .lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser
                        .getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }

        KickstartDefaults ksdefault = ksdata.getKickstartDefaults();
        return ksdefault.getKstree().getLabel();
    }

    /**
     * Get the update type for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be changed.
     * @return kickstart tree label
     *
     * @xmlrpc.doc Get the update type for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile.")
     * @xmlrpc.returntype
     *     #param_desc("string", "update_type", "Update type for this Kickstart Profile.")
     */
    public String getUpdateType(User loggedInUser, String kslabel) {

        KickstartData ksdata = KickstartFactory
                .lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser
                        .getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }

        return ksdata.getUpdateType();
    }

    /**
     * Get the option to perserve ks.cfg.
     * @param loggedInUser The current user
     * @param kslabel the kickstart label
     * @return Boolean value of the option
     *
     * @xmlrpc.doc Get ks.cfg preservation option for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.returntype boolean - The value of the option. True means that
     *     ks.cfg will be copied to /root, false means that it will not.
     */
    public Boolean getCfgPreservation(User loggedInUser, String kslabel) {
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(kslabel, loggedInUser.getOrg());
        if (data == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                "No Kickstart Profile found with label: " + kslabel);
        }
        return data.getKsCfg();
    }

    /**
     * Set the option to perserve ks.cfg.
     * @param loggedInUser The current user
     * @param kslabel the kickstart label
     * @param preserve whether to perserve ks.cfg or not
     * @return int 1 for success
     *
     * @xmlrpc.doc Set ks.cfg preservation option for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("boolean", "preserve", "whether or not
     *      ks.cfg and all %include fragments will be copied to /root.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setCfgPreservation(User loggedInUser, String kslabel, boolean preserve) {
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(kslabel, loggedInUser.getOrg());
        if (data == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                "No Kickstart Profile found with label: " + kslabel);
        }
        data.setKsCfg(preserve);
        KickstartFactory.saveKickstartData(data);
        return 1;
    }

    /**
     * Set the logging (Pre and post) for a kickstart file
     * @param loggedInUser The current user
     * @param kslabel the kickstart label
     * @param pre whether to log pre scripts or not
     * @param post whether to log post scripts or not
     * @return int 1 for success
     *
     * @xmlrpc.doc Set logging options for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("boolean", "pre", "whether or not to log
     *      the pre section of a kickstart to /root/ks-pre.log")
     * @xmlrpc.param #param_desc("boolean", "post", "whether or not to log
     *      the post section of a kickstart to /root/ks-post.log")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setLogging(User loggedInUser, String kslabel, boolean pre, boolean post) {
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(kslabel, loggedInUser.getOrg());
        data.setPreLog(pre);
        data.setPostLog(post);
        KickstartFactory.saveKickstartData(data);
        return 1;
    }


    /**
     * Set the kickstart tree for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be changed.
     * @param kstreeLabel label of the new kickstart tree.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Set the kickstart tree for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("string", "kstreeLabel", "Label of new
     * kickstart tree.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setKickstartTree(User loggedInUser, String kslabel,
            String kstreeLabel) {

        KickstartData ksdata = KickstartFactory
                .lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser
                        .getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }

        KickstartableTree tree = KickstartFactory.lookupKickstartTreeByLabel(
                kstreeLabel, loggedInUser.getOrg());
        if (tree == null) {
            throw new NoSuchKickstartTreeException(kstreeLabel);
        }

        KickstartDefaults ksdefault = ksdata.getKickstartDefaults();
        ksdefault.setKstree(tree);
        return 1;
    }

    /**
     * Set the update type for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be changed.
     * @param updateType the new update type.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Set the update typefor a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("string", "updateType", "The new update type
     * to set. Possible values are 'red_hat', 'all', and 'none'.")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setUpdateType(User loggedInUser, String kslabel,
            String updateType) {

        KickstartData ksdata = KickstartFactory
                .lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser
                        .getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + kslabel);
        }

        KickstartableTree tree = ksdata.getTree();
        KickstartTreeUpdateType realUT = null;
        if (updateType.equals(KickstartTreeUpdateType.ALL.getType())) {
            if (tree.getChannel() == null) {
                throw new InvalidUpdateTypeAndNoBaseTreeException(tree.getLabel());
            }
            realUT = KickstartTreeUpdateType.ALL;
        }
        else if (updateType.equals(KickstartTreeUpdateType.RED_HAT.getType())) {
            if (tree.getOrgId() != null) {
                throw new InvalidUpdateTypeAndKickstartTreeException(tree.getLabel());
            }
            if (tree.getChannel() == null) {
                throw new InvalidUpdateTypeAndNoBaseTreeException(tree.getLabel());
            }
            realUT = KickstartTreeUpdateType.RED_HAT;
        }
        else if (updateType.equals(KickstartTreeUpdateType.NONE.getType())) {
            realUT = KickstartTreeUpdateType.NONE;
        }
        else {
            throw new InvalidUpdateTypeException(updateType);
        }

        ksdata.setRealUpdateType(realUT);
        return 1;
    }

    /**
     * Get the child channels for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be updated.
     * @return list of child channels associated with the profile.
     *
     * @xmlrpc.doc Get the child channels for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile.")
     * @xmlrpc.returntype
     *     #array_single("string", "channelLabel")
     */
    public List<String> getChildChannels(User loggedInUser, String kslabel) {

        KickstartData ksdata = KickstartFactory.
              lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                "No Kickstart Profile found with label: " + kslabel);
        }

        List<String> childChannels = new ArrayList<String>();
        if (ksdata.getChildChannels() != null) {
            for (Iterator itr = ksdata.getChildChannels().iterator(); itr.hasNext();) {
                Channel channel = (Channel) itr.next();
                childChannels.add(channel.getLabel());
            }
        }
        return childChannels;
    }

    /**
     * Set the child channels for a kickstart profile.
     * @param loggedInUser The current user
     * @param kslabel label of the kickstart profile to be updated.
     * @param channelLabels labels of the child channels to be set in the
     * kickstart profile.
     * @return 1 if successful, exception otherwise.
     *
     * @xmlrpc.doc Set the child channels for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("string[]", "channelLabels",
     * "List of labels of child channels")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setChildChannels(User loggedInUser, String kslabel,
            List<String> channelLabels) {

        KickstartData ksdata = KickstartFactory.
              lookupKickstartDataByLabelAndOrgId(kslabel, loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                "No Kickstart Profile found with label: " + kslabel);
        }

        if (ksdata.getChildChannels() != null) {
            ksdata.getChildChannels().clear();
        }

        for (int i = 0; i < channelLabels.size(); i++) {
            Channel channel = ChannelManager.lookupByLabelAndUser(channelLabels.get(i),
                 loggedInUser);
            if (channel == null) {
                throw new InvalidChannelLabelException();
            }
            ksdata.addChildChannel(channel);
        }
        KickstartFactory.saveKickstartData(ksdata);
        return 1;
    }

    /**
     * List the pre and post scripts for a kickstart profile in the order
     * they will run during the kickstart.
     * @param loggedInUser The current user
     * @param label the kickstart label
     * @return list of kickstartScript objects
     *
     * @xmlrpc.doc List the pre and post scripts for a kickstart profile
     * in the order they will run during the kickstart.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart")
     * @xmlrpc.returntype #array() $KickstartScriptSerializer #array_end()
     */
    public List<KickstartScript> listScripts(User loggedInUser, String label) {
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(label, loggedInUser.getOrg());

        ArrayList<KickstartScript> scripts = new ArrayList<KickstartScript>(
                data.getScripts());
        Collections.sort(scripts);

        return scripts;

    }

    /**
     * Change the order that kickstart scripts will run for this kickstart
     * profile. Scripts will run in the order they appear in the array.
     * There are three arrays, one for all pre scripts, one for the post
     * scripts that run before registration and server actions happen,
     * and one for post scripts that run after registration and server
     * actinos. All scripts must be included in one of these lists, as
     * appropriate.
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @param preScripts the ordered list of pre scripts
     * @param postScriptsBeforeRegistration the ordered list of post
     * scripts that run before registration
     * @param postScriptsAfterRegistration the ordered list of post
     * scripts that run after registration
     * @return 1 on success
     *
     * @xmlrpc.doc Change the order that kickstart scripts will run for
     * this kickstart profile. Scripts will run in the order they appear
     * in the array. There are three arrays, one for all pre scripts, one
     * for the post scripts that run before registration and server
     * actions happen, and one for post scripts that run after registration
     * and server actions. All scripts must be included in one of these
     * lists, as appropriate.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart")
     * @xmlrpc.param #array_single("int",
     *              "IDs of the ordered pre scripts")
     * @xmlrpc.param #array_single("int",
     *              "IDs of the ordered post scripts that will run
     *              before registration")
     * @xmlrpc.param #array_single("int",
     *              "IDs of the ordered post scripts that will run
     *              after registration")
     * @xmlrpc.returntype #return_int_success()
     */
    public int orderScripts(User loggedInUser, String ksLabel, List<Integer> preScripts,
            List<Integer> postScriptsBeforeRegistration,
            List<Integer> postScriptsAfterRegistration) {
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(ksLabel, loggedInUser.getOrg());
        if (data == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + ksLabel);
        }
        Set<KickstartScript> scripts = data.getScripts();

        // validate the input
        List<KickstartScript> myPreScripts = new ArrayList<KickstartScript>();
        List<KickstartScript> myPostScripts = new ArrayList<KickstartScript>();
        Map<Integer, KickstartScript> idToScript = new HashMap<Integer, KickstartScript>();
        for (KickstartScript script : scripts) {
            idToScript.put(script.getId().intValue(), script);
            if (script.getScriptType().equals(KickstartScript.TYPE_PRE)) {
                myPreScripts.add(script);
                if (!preScripts.contains(script.getId().intValue())) {
                    throw new IllegalArgumentException("Kickstart Script ID missing: " +
                            script.getId());
                }
            }
            else {
                myPostScripts.add(script);
                if (!(postScriptsBeforeRegistration.contains(script.getId().intValue()) ||
                        postScriptsAfterRegistration.contains(
                        script.getId().intValue()))) {
                    throw new IllegalArgumentException("Kickstart Script ID missing: " +
                            script.getId());
                }
            }
        }
        if (preScripts.size() != myPreScripts.size()) {
            throw new IllegalArgumentException("Too many pre script IDs.");
        }
        if ((postScriptsBeforeRegistration.size() + postScriptsAfterRegistration.size() !=
                myPostScripts.size())) {
            throw new IllegalArgumentException("Too many post script IDs.");
        }

        // To avoid db constraint error about two scripts having same position,
        // make them something else
        Long fakePosition = 10000L;
        for (KickstartScript script : scripts) {
            script.setPosition(fakePosition);
            fakePosition += 1;
            HibernateFactory.getSession().save(script);
        }
        KickstartFactory.saveKickstartData(data);

        // create new position values
        Long nextPosition = 1L;
        Long nextNegativePosition = -1L;
        for (Integer id : preScripts) {
            KickstartScript script = idToScript.get(id);
            script.setPosition(nextPosition);
            nextPosition += 1;
            HibernateFactory.getSession().save(script);
        }
        for (Integer id : postScriptsBeforeRegistration) {
            KickstartScript script = idToScript.get(id);
            script.setPosition(nextNegativePosition);
            nextNegativePosition -= 1;
            HibernateFactory.getSession().save(script);
        }
        for (Integer id : postScriptsAfterRegistration) {
            KickstartScript script = idToScript.get(id);
            script.setPosition(nextPosition);
            nextPosition += 1;
            HibernateFactory.getSession().save(script);
        }
        KickstartFactory.saveKickstartData(data);

        return 1;
    }

    /**
     * Add a script to a kickstart profile
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @param name name of the script
     * @param contents the contents
     * @param interpreter the script interpreter to use
     * @param type "pre" or "post"
     * @param chroot true if you want it to be chrooted
     * @return the id of the created script
     *
     * @xmlrpc.doc Add a pre/post script to a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label to
     * add the script to.")
     * @xmlrpc.param #param_desc("string", "name", "The kickstart script name.")
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
    public int addScript(User loggedInUser, String ksLabel, String name, String contents,
            String interpreter, String type, boolean chroot) {
        return addScript(loggedInUser, ksLabel, name, contents, interpreter, type,
                chroot, false);
    }

    /**
     * Add a script to a kickstart profile
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @param name name of the script
     * @param contents the contents
     * @param interpreter the script interpreter to use
     * @param type "pre" or "post"
     * @param chroot true if you want it to be chrooted
     * @param template enable templating using cobbler
     * @return the id of the created script
     *
     * @xmlrpc.doc Add a pre/post script to a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label to
     * add the script to.")
     * @xmlrpc.param #param_desc("string", "name", "The kickstart script name.")
     * @xmlrpc.param #param_desc("string", "contents", "The full script to
     * add.")
     * @xmlrpc.param #param_desc("string", "interpreter", "The path to the
     * interpreter to use (i.e. /bin/bash). An empty string will use the
     * kickstart default interpreter.")
     * @xmlrpc.param #param_desc("string", "type", "The type of script (either
     * 'pre' or 'post').")
     * @xmlrpc.param #param_desc("boolean", "chroot", "Whether to run the script
     * in the chrooted install location (recommended) or not.")
     * @xmlrpc.param #param_desc("boolean", "template", "Enable templating using cobbler.")
     * @xmlrpc.returntype int id - the id of the added script
     *
     */
    public int addScript(User loggedInUser, String ksLabel, String name, String contents,
            String interpreter, String type, boolean chroot, boolean template) {
        return addScript(loggedInUser, ksLabel, name, contents, interpreter, type, chroot,
                template, false);
    }

    /**
     * Add a script to a kickstart profile
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @param name name of the script
     * @param contents the contents
     * @param interpreter the script interpreter to use
     * @param type "pre" or "post"
     * @param chroot true if you want it to be chrooted
     * @param template enable templating using cobbler
     * @param erroronfail Whether to throw an error if the script fails or not
     * @return the id of the created script
     *
     * @xmlrpc.doc Add a pre/post script to a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label to
     * add the script to.")
     * @xmlrpc.param #param_desc("string", "name", "The kickstart script name.")
     * @xmlrpc.param #param_desc("string", "contents", "The full script to
     * add.")
     * @xmlrpc.param #param_desc("string", "interpreter", "The path to the
     * interpreter to use (i.e. /bin/bash). An empty string will use the
     * kickstart default interpreter.")
     * @xmlrpc.param #param_desc("string", "type", "The type of script (either
     * 'pre' or 'post').")
     * @xmlrpc.param #param_desc("boolean", "chroot", "Whether to run the script
     * in the chrooted install location (recommended) or not.")
     * @xmlrpc.param #param_desc("boolean", "template", "Enable templating using cobbler.")
     * @xmlrpc.param #param_desc("boolean", "erroronfail", "Whether to throw an
     * error if the script fails or not")
     * @xmlrpc.returntype int id - the id of the added script
     *
     */
    public int addScript(User loggedInUser, String ksLabel, String name, String contents,
            String interpreter, String type, boolean chroot, boolean template,
            boolean erroronfail) {
        checkKickstartPerms(loggedInUser);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        if (!type.equals("pre") && !type.equals("post")) {
            throw new InvalidScriptTypeException();
        }

        if (StringUtils.isBlank(name) || name.length() > 40) {
            throw new InvalidScriptNameException();
        }

        KickstartScript script = new KickstartScript();
        script.setScriptName(name);
        script.setData(contents.getBytes());
        script.setInterpreter(interpreter.equals("") ? null : interpreter);
        script.setScriptType(type);
        script.setChroot(chroot ? "Y" : "N");
        script.setRaw(!template);
        script.setErrorOnFail(erroronfail);
        script.setKsdata(ksData);
        ksData.addScript(script);
        HibernateFactory.getSession().save(script);
        KickstartFactory.saveKickstartData(ksData);
        return script.getId().intValue();
    }

    /**
     * Remove a script from a kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel the kickstart to remove a script from
     * @param id the id of the kickstart
     * @return 1 on success
     *
     * @xmlrpc.doc Remove a script from a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart from which
     * to remove the script from.")
     * @xmlrpc.param #param_desc("int", "scriptId", "The id of the script to
     * remove.")
     * @xmlrpc.returntype #return_int_success()
     *
     */
    public int removeScript(User loggedInUser, String ksLabel, Integer id) {
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
        KickstartFactory.saveKickstartData(ksData);

        return 1;
    }

    /**
     * returns the fully formatted kickstart file
     * @param loggedInUser The current user
     * @param ksLabel the label to download
     * @param host The host/ip to use when referring to the server itself
     * @return the kickstart file
     *
     * @xmlrpc.doc Download the full contents of a kickstart file.
     * @xmlrpc.param #session_key()
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
    public String downloadKickstart(User loggedInUser, String ksLabel,
            String host) {
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartFormatter form = new KickstartFormatter(host, ksData);
        return form.getFileData();
    }

    /**
     * returns the Cobbler-rendered kickstart file
     * @param loggedInUser The current user
     * @param ksLabel the label to download
     * @return the kickstart file
     *
     * @xmlrpc.doc Downloads the Cobbler-rendered Kickstart file.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart to download.")
     * @xmlrpc.returntype string - The contents of the kickstart file.
     */
    public String downloadRenderedKickstart(User loggedInUser, String ksLabel) {
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartManager manager = KickstartManager.getInstance();
        return manager.renderKickstart(ksData);
    }

    /**
     * Get advanced options for existing kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel label of the kickstart profile to be updated.
     * @return An array of advanced options
     * @throws FaultException A FaultException is thrown if
     *         the profile associated with ksLabel cannot be found
     *
     * @xmlrpc.doc Get advanced options for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.returntype
     * #array()
     * $KickstartAdvancedOptionsSerializer
     * #array_end()
     */

    public Object[] getAdvancedOptions(User loggedInUser, String ksLabel)
    throws FaultException {
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(ksLabel, loggedInUser.
                    getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
                    "No Kickstart Profile found with label: " + ksLabel);
        }

        Set<KickstartCommand> options = ksdata.getOptions();
        return options.toArray();
    }

    /**
     * Set advanced options in a kickstart profile
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @param options the advanced options to set
     * @return 1 if success, exception otherwise
     * @throws FaultException A FaultException is thrown if
     *         the profile associated with ksLabel cannot be found
     *         or invalid advanced option is provided
     *
     * @xmlrpc.doc Set advanced options for a kickstart profile.
     * If 'md5_crypt_rootpw' is set to 'True', 'root_pw' is taken as plaintext and
     * will md5 encrypted on server side, otherwise a hash encoded password
     * (according to the auth option) is expected
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string","ksLabel")
     * @xmlrpc.param
     *   #array()
     *      #struct("advanced options")
     *          #prop_desc("string", "name", "Name of the advanced option.
     *              Valid Option names: autostep, interactive, install, upgrade, text,
     *              network, cdrom, harddrive, nfs, url, lang, langsupport keyboard,
     *              mouse, device, deviceprobe, zerombr, clearpart, bootloader,
     *              timezone, auth, rootpw, selinux, reboot, firewall, xconfig, skipx,
     *              key, ignoredisk, autopart, cmdline, firstboot, graphical, iscsi,
     *              iscsiname, logging, monitor, multipath, poweroff, halt, services,
     *              shutdown, user, vnc, zfcp, driverdisk, md5_crypt_rootpw")
     *          #prop_desc("string", "arguments", "Arguments of the option")
     *      #struct_end()
     *   #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setAdvancedOptions(User loggedInUser, String ksLabel, List<Map> options)
    throws FaultException {
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(ksLabel, loggedInUser.
                    getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
            "No Kickstart Profile found with label: " + ksLabel);
        }

        List<String> validOptions = Arrays.asList(VALIDOPTIONNAMES);

        Set<String> givenOptions = new HashSet<String>();
        for (Map option : options) {
            givenOptions.add((String) option.get("name"));
        }


        if (!validOptions.containsAll(givenOptions)) {
            throw new FaultException(-5, "invalidKickstartCommandName",
              "Invalid kickstart option present. List of valid options is: " +
              validOptions);
          }

        Long ksid = ksdata.getId();
        KickstartOptionsCommand cmd = new KickstartOptionsCommand(ksid, loggedInUser);

        //check if all the required options are present
        List<KickstartCommandName> requiredOptions = KickstartFactory.
            lookupKickstartRequiredOptions();

        List<String> requiredOptionNames = new ArrayList<String>();
        for (KickstartCommandName kcn : requiredOptions) {
            requiredOptionNames.add(kcn.getName());
          }

        if (!givenOptions.containsAll(requiredOptionNames)) {
            throw new FaultException(-6, "requiredOptionMissing",
                    "Required option missing. List of required options: " +
                    requiredOptionNames);
          }

        Set<KickstartCommand> customSet = new HashSet<KickstartCommand>();

        for (Iterator itr = cmd.getAvailableOptions().iterator(); itr.hasNext();) {
            Map option = null;
            KickstartCommandName cn = (KickstartCommandName) itr.next();
            if (givenOptions.contains(cn.getName())) {
              for (Map o : options) {
                if (cn.getName().equals(o.get("name"))) {
                  option = o;
                  break;
                }
              }

              KickstartCommand kc = new KickstartCommand();
              kc.setCommandName(cn);
              kc.setKickstartData(cmd.getKickstartData());
              kc.setCreated(new Date());
              kc.setModified(new Date());
              if (cn.getArgs().booleanValue()) {
                  // handle password encryption
                  if (cn.getName().equals("rootpw")) {
                      String pwarg = (String) option.get("arguments");
                        // password already encrypted
                      if (!md5cryptRootPw(options)) {
                          kc.setArguments(pwarg);
                      }
                        // password changed, encrypt it
                      else {
                          kc.setArguments(MD5Crypt.crypt(pwarg));
                      }
                  }
                  else {
                      kc.setArguments((String) option.get("arguments"));
                  }
                }
                customSet.add(kc);
            }
        }
        cmd.getKickstartData().setOptions(customSet);
        KickstartFactory.saveKickstartData(ksdata);

        return 1;
    }

    private boolean md5cryptRootPw(List<Map> options) {
        for (Map m : options) {
            if ("md5_crypt_rootpw".equals(m.get("name"))) {
                return BooleanUtils.toBoolean((String)m.get("arguments"));
            }
        }
        return false;
    }

    /**
     * Get custom options for a kickstart profile.
     * @param loggedInUser The current user
     * @param ksLabel the kickstart label
     * @return a list of hashes holding this info.
     * @throws FaultException A FaultException is thrown if
     *         the profile associated with ksLabel cannot be found
     *
     * @xmlrpc.doc Get custom options for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param("string","ksLabel")
     *
     * @xmlrpc.returntype
     * #array()
     * $KickstartCommandSerializer
     * #array_end()
     */
    public Object[] getCustomOptions(User loggedInUser, String ksLabel)
    throws FaultException {
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabel, loggedInUser.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
            "No Kickstart Profile found with label: " + ksLabel);
        }
        SortedSet options = ksdata.getCustomOptions();
        return options.toArray();
    }

   /**
    * Set custom options for a kickstart profile.
    * @param loggedInUser The current user
    * @param ksLabel the kickstart label
    * @param options the custom options to set
    * @return a int being the number of options set
    * @throws FaultException A FaultException is thrown if
    *         the profile associated with ksLabel cannot be found
    *
    * @xmlrpc.doc Set custom options for a kickstart profile.
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param("string","ksLabel")
    * @xmlrpc.param #param("string[]","options")
    * @xmlrpc.returntype #return_int_success()
    */
   public int setCustomOptions(User loggedInUser, String ksLabel, List<String> options)
   throws FaultException {
       KickstartData ksdata =
               XmlRpcKickstartHelper.getInstance().lookupKsData(ksLabel,
                       loggedInUser.getOrg());
       if (ksdata == null) {
           throw new FaultException(-3, "kickstartProfileNotFound",
               "No Kickstart Profile found with label: " + ksLabel);
       }
       Long ksid = ksdata.getId();
       KickstartOptionsCommand cmd = new KickstartOptionsCommand(ksid, loggedInUser);
       SortedSet<KickstartCommand> customSet = new TreeSet<KickstartCommand>();
       if (options != null) {
           for (int i = 0; i < options.size(); i++) {
               String option = options.get(i);
               KickstartCommand custom = new KickstartCommand();
               custom.setCommandName(
                    KickstartFactory.lookupKickstartCommandName("custom"));

               // the following is a workaround to ensure that the options are rendered
               // on the UI on separate lines.
               if (i < (options.size() - 1)) {
                   option += "\r";
               }

               custom.setArguments(option);
               custom.setKickstartData(cmd.getKickstartData());
               custom.setCustomPosition(customSet.size());
               custom.setCreated(new Date());
               custom.setModified(new Date());
               customSet.add(custom);
           }
           if (cmd.getKickstartData().getCustomOptions() == null) {
               cmd.getKickstartData().setCustomOptions(customSet);
           }
           else {
               cmd.getKickstartData().setCustomOptions(customSet);
           }
           cmd.store();
       }
       return 1;
   }

   /**
    * Lists all ip ranges for a kickstart profile.
    * @param loggedInUser The current user
    * @param ksLabel the label of the kickstart
    * @return List of KickstartIpRange objects
    *
    * @xmlrpc.doc List all ip ranges for a kickstart profile.
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "label", "The label of the
    * kickstart")
    * @xmlrpc.returntype #array() $KickstartIpRangeSerializer #array_end()
    *
    */
   public Set listIpRanges(User loggedInUser, String ksLabel) {
       if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
           throw new PermissionCheckFailureException();
       }
       KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
       return ksdata.getIps();
   }

   /**
    * Add an ip range to a kickstart.
    * @param loggedInUser The current user
    * @param ksLabel the kickstart label
    * @param min the min ip address of the range
    * @param max the max ip address of the range
    * @return 1 on success
    *
    * @xmlrpc.doc Add an ip range to a kickstart profile.
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
   public int addIpRange(User loggedInUser, String ksLabel, String min,
           String max) {
       KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
       KickstartIpCommand com = new KickstartIpCommand(ksdata.getId(), loggedInUser);

       IpAddress minIp = new IpAddress(min);
       IpAddress maxIp = new IpAddress(max);

       if (!com.validateIpRange(minIp.getOctets(), maxIp.getOctets())) {
           ValidatorError error = new ValidatorError("kickstart.iprange_validate.failure");
           throw new ValidationException(error.getMessage());
       }

       if (!com.addIpRange(minIp.getOctets(), maxIp.getOctets())) {
           throw new IpRangeConflictException(min + " - " + max);
       }
       com.store();
       return 1;
   }

   /**
    * Remove an ip range from a kickstart profile.
    * @param loggedInUser The current user
    * @param ksLabel the kickstart to remove an ip range from
    * @param ipAddress an ip address in the range that you want to remove
    * @return 1 on removal, 0 if not found, exception otherwise
    *
    * @xmlrpc.doc Remove an ip range from a kickstart profile.
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "ksLabel", "The kickstart label of
    * the ip range you want to remove")
    * @xmlrpc.param #param_desc("string", "ip_address", "An Ip Address that
    * falls within the range that you are wanting to remove. The min or max of
    * the range will work.")
    * @xmlrpc.returntype int - 1 on successful removal, 0 if range wasn't found
    * for the specified kickstart, exception otherwise.
    */
   public int removeIpRange(User loggedInUser, String ksLabel, String ipAddress) {
       if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
           throw new PermissionCheckFailureException();
       }
       KickstartData ksdata = lookupKsData(ksLabel, loggedInUser.getOrg());
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

    /**
     * Returns a list for each kickstart profile of activation keys that are present
     * in that profile but not the other.
     *
     * @param loggedInUser The current user
     * @param kickstartLabel1 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     * @param kickstartLabel2 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     *
     * @return map of kickstart label to a list of keys in that profile but not in
     *         the other; if no keys match the criteria the list will be empty
     *
     * @xmlrpc.doc Returns a list for each kickstart profile; each list will contain
     *             activation keys not present on the other profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel1")
     * @xmlrpc.param #param("string", "kickstartLabel2")
     * @xmlrpc.returntype
     *  #struct("Comparison Info")
     *      #prop_desc("array", "kickstartLabel1", "Actual label of the first kickstart
     *                 profile is the key into the struct")
     *          #array()
     *              $ActivationKeySerializer
     *          #array_end()
     *      #prop_desc("array", "kickstartLabel2", "Actual label of the second kickstart
     *                 profile is the key into the struct")
     *          #array()
     *              $ActivationKeySerializer
     *          #array_end()
     *  #struct_end()
     */
    public Map<String, List<ActivationKey>> compareActivationKeys(User loggedInUser,
                                                                  String kickstartLabel1,
                                                                  String kickstartLabel2) {

        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Leverage exisitng handler for key loading
        KeysHandler keysHandler = new KeysHandler();

        List<ActivationKey> keyList1 =
            keysHandler.getActivationKeys(loggedInUser, kickstartLabel1);
        List<ActivationKey> keyList2 =
            keysHandler.getActivationKeys(loggedInUser, kickstartLabel2);

        // Set operations to determine deltas
        List<ActivationKey> onlyInKickstart1 = new ArrayList<ActivationKey>(keyList1);
        onlyInKickstart1.removeAll(keyList2);

        List<ActivationKey> onlyInKickstart2 = new ArrayList<ActivationKey>(keyList2);
        onlyInKickstart2.removeAll(keyList1);

        // Package up for return
        Map<String, List<ActivationKey>> results =
            new HashMap<String, List<ActivationKey>>(2);

        results.put(kickstartLabel1, onlyInKickstart1);
        results.put(kickstartLabel2, onlyInKickstart2);

        return results;
    }

    /**
     * Returns a list for each kickstart profile of package names that are present
     * in that profile but not the other.
     *
     * @param loggedInUser The current user
     *                        cannot be <code>null</code>
     * @param kickstartLabel1 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     * @param kickstartLabel2 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     *
     * @return map of kickstart label to a list of package names in that profile but not in
     *         the other; if no keys match the criteria the list will be empty
     *
     * @xmlrpc.doc Returns a list for each kickstart profile; each list will contain
     *             package names not present on the other profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel1")
     * @xmlrpc.param #param("string", "kickstartLabel2")
     * @xmlrpc.returntype
     *  #struct("Comparison Info")
     *      #prop_desc("array", "kickstartLabel1", "Actual label of the first kickstart
     *                 profile is the key into the struct")
     *          #array_single("string", "package name")
     *      #prop_desc("array", "kickstartLabel2", "Actual label of the second kickstart
     *                 profile is the key into the struct")
     *          #array_single("string", "package name")
     *  #struct_end()
     */
    public Map<String, Set<String>> comparePackages(User loggedInUser,
                                       String kickstartLabel1, String kickstartLabel2) {
        // Validate parameters
        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Load the profiles and their package lists
        KickstartData profile1 =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel1,
                loggedInUser.getOrg().getId());

        KickstartData profile2 =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel2,
                loggedInUser.getOrg().getId());

        // Set operations to determine deltas


        Set<String> onlyInProfile1 = getPackageNamesForKS(profile1);
        onlyInProfile1.removeAll(getPackageNamesForKS(profile2));

        Set<String> onlyInProfile2 = getPackageNamesForKS(profile2);
        onlyInProfile2.removeAll(getPackageNamesForKS(profile1));


        // Package for return
        Map<String, Set<String>> results = new HashMap<String, Set<String>>(2);

        results.put(kickstartLabel1, onlyInProfile1);
        results.put(kickstartLabel2, onlyInProfile2);

        return results;
    }

    private Set<String> getPackageNamesForKS(KickstartData ksdata) {
        Set<String> toRet = new HashSet<String>();
        for (KickstartPackage ksPack : ksdata.getKsPackages()) {
            toRet.add(ksPack.getPackageName().getName());
        }
        return toRet;
    }


    /**
     * Returns a list for each kickstart profile of properties that are different between
     * the profiles. Each property that is not equal between the two profiles will be
     * present in both lists with the current values for its respective profile.
     *
     * @param loggedInUser The current user
     *                        cannot be <code>null</code>
     * @param kickstartLabel1 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     * @param kickstartLabel2 identifies a profile to be compared;
     *                        cannot be <code>null</code>
     *
     * @return map of kickstart label to a list of properties and their values whose
     *         values are different for each profile
     *
     * @xmlrpc.doc Returns a list for each kickstart profile; each list will contain the
     *             properties that differ between the profiles and their values for that
     *             specific profile .
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel1")
     * @xmlrpc.param #param("string", "kickstartLabel2")
     * @xmlrpc.returntype
     *  #struct("Comparison Info")
     *      #prop_desc("array", "kickstartLabel1", "Actual label of the first kickstart
     *                 profile is the key into the struct")
     *          #array()
     *              $KickstartOptionValueSerializer
     *          #array_end()
     *      #prop_desc("array", "kickstartLabel2", "Actual label of the second kickstart
     *                 profile is the key into the struct")
     *          #array()
     *              $KickstartOptionValueSerializer
     *          #array_end()
     *  #struct_end()
     */
    public Map<String, List<KickstartOptionValue>> compareAdvancedOptions(User loggedInUser,
                                        String kickstartLabel1, String kickstartLabel2) {
        // Validate parameters
        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Load the profiles
        KickstartData profile1 =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel1,
                loggedInUser.getOrg().getId());

        KickstartData profile2 =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel2,
                loggedInUser.getOrg().getId());

        // Load the options
        KickstartOptionsCommand profile1OptionsCommand =
            new KickstartOptionsCommand(profile1.getId(), loggedInUser);

        KickstartOptionsCommand profile2OptionsCommand =
            new KickstartOptionsCommand(profile2.getId(), loggedInUser);

        // Set operations to determine which values are different. The equals method
        // of KickstartOptionValue will take the name and value into account, so
        // only cases where this tuple is present in both will be removed.
        List<KickstartOptionValue> onlyInProfile1 =
            profile1OptionsCommand.getDisplayOptions();
        onlyInProfile1.removeAll(profile2OptionsCommand.getDisplayOptions());

        List<KickstartOptionValue> onlyInProfile2 =
            profile2OptionsCommand.getDisplayOptions();
        onlyInProfile2.removeAll(profile1OptionsCommand.getDisplayOptions());

        // Package for transport
        Map<String, List<KickstartOptionValue>> results =
            new HashMap<String, List<KickstartOptionValue>>(2);
        results.put(kickstartLabel1, onlyInProfile1);
        results.put(kickstartLabel2, onlyInProfile2);

        return results;
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
     * Returns a list of kickstart variables associated with the specified kickstart profile
     *
     * @param loggedInUser The current user
     *                        cannot be <code>null</code>
     * @param ksLabel identifies the kickstart profile
     *                        cannot be <code>null</code>
     *
     * @return map of kickstart variables associated with the specified kickstart
     *
     * @xmlrpc.doc Returns a list of variables
     *                      associated with the specified kickstart profile
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.returntype
     *     #struct("kickstart variable")
     *         #prop("string", "key")
     *         #prop("string or int", "value")
     *     #struct_end()
     */
    public Map<String, Object> getVariables(User loggedInUser, String ksLabel) {

        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        return ksData.getCobblerObject(loggedInUser).getKsMeta();
    }

    /**
     * Associates list of kickstart variables with the specified kickstart profile
     *
     * @param loggedInUser The current user
     *                        cannot be <code>null</code>
     * @param ksLabel identifies the kickstart profile
     *                        cannot be <code>null</code>
     * @param variables          list of variables to set
     *
     * @return int - 1 on success, exception thrown otherwise
     *
     * @xmlrpc.doc Associates list of kickstart variables
     *                              with the specified kickstart profile
     *
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.param
     *     #struct("kickstart variable")
     *         #prop("string", "key")
     *         #prop("string or int", "value")
     *     #struct_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setVariables
                (User loggedInUser, String ksLabel, Map<String, Object> variables) {

        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        Profile profile = ksData.getCobblerObject(loggedInUser);
        profile.setKsMeta(variables);
        profile.save();

        return 1;
    }

    /**
     * @param loggedInUser The current user
     * @param ksLabel identifies the kickstart profile
     * @return Array of available OS repositories for provided kickstart profile
     * @xmlrpc.doc Lists available OS repositories to associate with the provided
     * kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.returntype #array_single("string", "repositoryLabel")
     */
    public String[] getAvailableRepositories(User loggedInUser, String ksLabel) {
        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(LocalizationService.getInstance()
                    .getMessage("permission.configadmin.needed"));
        }
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartableTree ksTree = ksData.getKickstartDefaults().getKstree();

        List<String> repos = new ArrayList<String>();
        for (RepoInfo repo : RepoInfo.getStandardRepos(ksTree)) {
            if (repo.isAvailable()) {
                repos.add(repo.getName());
            }
        }
        return (String[]) repos.toArray(new String[]{});
    }

    /**
     * @param loggedInUser The current user
     * @param ksLabel identifies the kickstart profile
     * @return Array of available OS repositories
     * @xmlrpc.doc Lists all OS repositories associated with provided kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.returntype #array_single("string", "repositoryLabel")
     */
    public String[] getRepositories(User loggedInUser, String ksLabel) {
        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(LocalizationService.getInstance()
                    .getMessage("permission.configadmin.needed"));
        }
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartableTree ksTree = ksData.getKickstartDefaults().getKstree();

        List<String> items = new ArrayList<String>();
        if (ksTree != null && !ksTree.getInstallType().isRhel2() &&
                !ksTree.getInstallType().isRhel3() &&
                !ksTree.getInstallType().isRhel4()) {
            Set<RepoInfo> selected = ksData.getRepoInfos();
            for (RepoInfo repo : selected) {
                items.add(repo.getName());
            }
        }
        return (String[]) items.toArray(new String[]{});
    }

    /**
     * @param loggedInUser The current user
     * @param ksLabel ksLabel identifies the kickstart profile
     * @param reposIn OS repositories to set
     * @return int - 1 on success, exception thrown otherwise
     * @xmrpc.doc Associates OS repository to a kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.param #array_single("string", "repositoryLabel")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setRepositories(User loggedInUser, String ksLabel, List<String> reposIn) {
        if (!loggedInUser.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException(LocalizationService.getInstance()
                    .getMessage("permission.configadmin.needed"));
        }
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        if (ksData.isRhel5OrGreater()) {
            List<RepoInfo> repoList = RepoInfo.getStandardRepos(
                    ksData.getKickstartDefaults().getKstree());
            Map<String, RepoInfo> repoSet = new HashMap<String, RepoInfo>();
            for (Iterator<RepoInfo> ri = repoList.iterator(); ri.hasNext();) {
                RepoInfo rInfo = ri.next();
                repoSet.put(rInfo.getName(), rInfo);
            }
            Set<RepoInfo> selected = new HashSet <RepoInfo>();
            for (int i = 0; i < reposIn.size(); i++) {
                RepoInfo repoInfo = repoSet.get(reposIn.get(i));
                if (repoInfo != null) {
                    selected.add(repoInfo);
                }
            }
            ksData.setRepoInfos(selected);
            KickstartWizardHelper ksHelper = new KickstartWizardHelper(loggedInUser);
            ksHelper.processSkipKey(ksData);
        }
        return 1;
    }

    /**
     * @param loggedInUser The Current user
     * @param ksLabel Kickstart profile label
     * @return Label of virtualization type for given profile
     * @xmlrpc.doc For given kickstart profile label returns label of
     * virtualization type it's using
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.returntype #param_desc("string", "virtLabel",
     * "Label of virtualization type.")
     */
    public String getVirtualizationType(User loggedInUser, String ksLabel) {
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartEditCommand cmd = new KickstartEditCommand(ksData.getId(), loggedInUser);

        return cmd.getVirtualizationType().getLabel();
    }

    /**
     * @param loggedInUser The Current user
     * @param ksLabel Kickstart profile label
     * @param typeLabel virtualization type label
     * @return int - 1 on success, exception thrown otherwise
     * @xmlrpc.doc For given kickstart profile label sets its virtualization type.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "ksLabel")
     * @xmlrpc.param #param_desc("string", "typeLabel", "One of the following: 'none',
     * 'qemu', 'para_host', 'xenpv', 'xenfv'")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setVirtualizationType(User loggedInUser, String ksLabel, String typeLabel) {
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartEditCommand cmd = new KickstartEditCommand(ksData.getId(), loggedInUser);

        cmd.setVirtualizationType(KickstartFactory.
                lookupKickstartVirtualizationTypeByLabel(typeLabel));
        cmd.store();
        return 1;
    }
}
