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
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.token.ActivationKey;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartIpRangeFilter;
import com.redhat.rhn.frontend.dto.kickstart.KickstartOptionValue;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidKickstartScriptException;
import com.redhat.rhn.frontend.xmlrpc.InvalidScriptTypeException;
import com.redhat.rhn.frontend.xmlrpc.IpRangeConflictException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.frontend.xmlrpc.ValidationException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.NoSuchKickstartTreeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;
import com.redhat.rhn.frontend.xmlrpc.kickstart.profile.keys.KeysHandler;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.kickstart.IpAddress;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.KickstartIpCommand;
import com.redhat.rhn.manager.kickstart.KickstartOptionsCommand;

import org.cobbler.Profile;

import java.util.ArrayList;
import java.util.Arrays;
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

    /**
     * Get the kickstart tree for a kickstart profile.
     * @param sessionKey User's session key.
     * @param kslabel label of the kickstart profile to be changed.
     * @return kickstart tree label
     *
     * @xmlrpc.doc Get the kickstart tree for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.returntype
     *     #prop_desc("string", "kstreeLabel", "Label of the kickstart tree.")
     */
    public String getKickstartTree(String sessionKey, String kslabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
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
     * Set the logging (Pre and post) for a kickstart file
     * @param sessionKey the session key
     * @param kslabel the kickstart label
     * @param pre whether to log pre scripts or not
     * @param post whether to log post scripts or not
     * @return int 1 for success
     *
     * @xmlrpc.doc Get the kickstart tree for a kickstart profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "kslabel", "Label of kickstart
     * profile to be changed.")
     * @xmlrpc.param #param_desc("boolean", "pre", "whether or not to log
     *      the pre section of a kickstart to /root/ks-pre.log")
     * @xmlrpc.param #param_desc("boolean", "post", "whether or not to log
     *      the pre section of a kickstart to /root/ks-post.log")
     * @xmlrpc.returntype #return_int_success()
     */
    public int setLogging(String sessionKey, String kslabel, boolean pre, boolean post) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(kslabel, loggedInUser.getOrg());
        data.setPreLog(pre);
        data.setPostLog(post);
        KickstartFactory.saveKickstartData(data);
        return 1;
    }


    /**
     * Set the kickstart tree for a kickstart profile.
     * @param sessionKey User's session key.
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
     * Get the child channels for a kickstart profile.
     * @param sessionKey User's session key.
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
    public List<String> getChildChannels(String sessionKey, String kslabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
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
     * @param sessionKey User's session key.
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
    public int setChildChannels(String sessionKey, String kslabel,
            List<String> channelLabels) {

        User loggedInUser = getLoggedInUser(sessionKey);
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

        return 1;
    }

    /**
     * List the pre and post scripts for a kickstart profile.
     * @param sessionKey key
     * @param label the kickstart label
     * @return list of kickstartScript objects
     *
     * @xmlrpc.doc List the pre and post scripts for a kickstart profile.
     * profile
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel", "The label of the
     * kickstart")
     * @xmlrpc.returntype #array() $KickstartScriptSerializer #array_end()
     */
    public List<KickstartScript> listScripts(String sessionKey, String label) {
        User loggedInUser = getLoggedInUser(sessionKey);
        checkKickstartPerms(loggedInUser);
        KickstartData data = lookupKsData(label, loggedInUser.getOrg());

        return new ArrayList<KickstartScript>(data.getScripts());

    }

    /**
     * Add a script to a kickstart profile
     * @param sessionKey key
     * @param ksLabel the kickstart label
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
     * Remove a script from a kickstart profile.
     * @param sessionKey key
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
    public String downloadKickstart(String sessionKey, String ksLabel,
            String host) {
        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());
        KickstartFormatter form = new KickstartFormatter(host, ksData);
        return form.getFileData();
    }


    /**
     * Get advanced options for existing kickstart profile.
     * @param sessionKey User's session key.
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

    public Object[] getAdvancedOptions(String sessionKey, String ksLabel)
    throws FaultException {
        User loggedInUser = getLoggedInUser(sessionKey);
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
     * @param sessionKey the session key
     * @param ksLabel the kickstart label
     * @param options the advanced options to set
     * @return 1 if success, exception otherwise
     * @throws FaultException A FaultException is thrown if
     *         the profile associated with ksLabel cannot be found
     *         or invalid advanced option is provided
     *
     * @xmlrpc.doc Set advanced options for a kickstart profile.
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
     *              iscsiname, logging, monitor, multipath, poweroff, halt, service,
     *              shutdown, user, vnc, zfcp")
     *          #prop_desc("string", "arguments", "Arguments of the option")
     *      #struct_end()
     *   #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setAdvancedOptions(String sessionKey, String ksLabel, List<Map> options)
    throws FaultException {
        User user = getLoggedInUser(sessionKey);
        KickstartData ksdata = KickstartFactory.
            lookupKickstartDataByLabelAndOrgId(ksLabel, user.
                    getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
            "No Kickstart Profile found with label: " + ksLabel);
        }

        String[] validOptionNames = new String[] {"autostep", "interactive", "install",
                "upgrade", "text", "network", "cdrom", "harddrive", "nfs", "url",
                "lang", "langsupport", "keyboard", "mouse", "device", "deviceprobe",
                "zerombr", "clearpart", "bootloader", "timezone", "auth", "rootpw",
                "selinux", "reboot", "firewall", "xconfig", "skipx", "key",
                "ignoredisk", "autopart", "cmdline", "firstboot", "graphical", "iscsi",
                "iscsiname", "logging", "monitor", "multipath", "poweroff", "halt",
                "service", "shutdown", "user", "vnc", "zfcp"};

        List<String> validOptions = Arrays.asList(validOptionNames);

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
        KickstartOptionsCommand cmd = new KickstartOptionsCommand(ksid, user);

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
                      if (pwarg.startsWith("$1$")) {
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

        return 1;
    }

    /**
     * Get custom options for a kickstart profile.
     * @param sessionKey the session key
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
    public Object[] getCustomOptions(String sessionKey, String ksLabel)
    throws FaultException {
        User user = getLoggedInUser(sessionKey);
        KickstartData ksdata = KickstartFactory.lookupKickstartDataByLabelAndOrgId(
                ksLabel, user.getOrg().getId());
        if (ksdata == null) {
            throw new FaultException(-3, "kickstartProfileNotFound",
            "No Kickstart Profile found with label: " + ksLabel);
        }
        SortedSet options = ksdata.getCustomOptions();
        return options.toArray();
    }

   /**
    * Set custom options for a kickstart profile.
    * @param sessionKey the session key
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
   public int setCustomOptions(String sessionKey, String ksLabel, List<String> options)
   throws FaultException {
       User user = getLoggedInUser(sessionKey);
       KickstartData ksdata =
               XmlRpcKickstartHelper.getInstance().lookupKsData(ksLabel, user.getOrg());
       if (ksdata == null) {
           throw new FaultException(-3, "kickstartProfileNotFound",
               "No Kickstart Profile found with label: " + ksLabel);
       }
       Long ksid = ksdata.getId();
       KickstartOptionsCommand cmd = new KickstartOptionsCommand(ksid, user);
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
    * @param sessionKey An active session key
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
   public Set listIpRanges(String sessionKey, String ksLabel) {
       User user = getLoggedInUser(sessionKey);
       if (!user.hasRole(RoleFactory.CONFIG_ADMIN)) {
           throw new PermissionCheckFailureException();
       }
       KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
       return ksdata.getIps();
   }

   /**
    * Add an ip range to a kickstart.
    * @param sessionKey the session key
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
   public int addIpRange(String sessionKey, String ksLabel, String min,
           String max) {
       User user = getLoggedInUser(sessionKey);
       KickstartData ksdata = lookupKsData(ksLabel, user.getOrg());
       KickstartIpCommand com = new KickstartIpCommand(ksdata.getId(), user);

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
    * @param sessionKey the session key
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

    /**
     * Returns a list for each kickstart profile of activation keys that are present
     * in that profile but not the other.
     *
     * @param sessionKey      identifies the user making the call;
     *                        cannot be <code>null</code>
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
    public Map<String, List<ActivationKey>> compareActivationKeys(String sessionKey,
                                                                  String kickstartLabel1,
                                                                  String kickstartLabel2) {
        // Validate parameters
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Leverage exisitng handler for key loading
        KeysHandler keysHandler = new KeysHandler();

        List<ActivationKey> keyList1 =
            keysHandler.getActivationKeys(sessionKey, kickstartLabel1);
        List<ActivationKey> keyList2 =
            keysHandler.getActivationKeys(sessionKey, kickstartLabel2);

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
     * @param sessionKey      identifies the user making the call;
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
     *          #array()
     *              #prop("string", "package name")
     *          #array_end()
     *      #prop_desc("array", "kickstartLabel2", "Actual label of the second kickstart
     *                 profile is the key into the struct")
     *          #array()
     *              #prop("string", "package name")
     *          #array_end()
     *  #struct_end()
     */
    public Map<String, Set<String>> comparePackages(String sessionKey,
                                       String kickstartLabel1, String kickstartLabel2) {
        // Validate parameters
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Load the profiles and their package lists
        User loggedInUser = getLoggedInUser(sessionKey);
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
     * @param sessionKey      identifies the user making the call;
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
    public Map<String, List<KickstartOptionValue>> compareAdvancedOptions(String sessionKey,
                                        String kickstartLabel1, String kickstartLabel2) {
        // Validate parameters
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel1 == null) {
            throw new IllegalArgumentException("kickstartLabel1 cannot be null");
        }

        if (kickstartLabel2 == null) {
            throw new IllegalArgumentException("kickstartLabel2 cannot be null");
        }

        // Load the profiles
        User loggedInUser = getLoggedInUser(sessionKey);
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
     * @param sessionKey      identifies the user making the call
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
     *          #array()
     *              #struct("kickstart variable")
     *                  #prop("string", "key")
     *                  #prop("string or int", "value")
     *              #struct_end()
     *          #array_end()
     */
    public Map<String, Object> getVariables(String sessionKey, String ksLabel) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        return ksData.getCobblerObject(loggedInUser).getKsMeta();
    }

    /**
     * Associates list of kickstart variables with the specified kickstart profile
     *
     * @param sessionKey      identifies the user making the call
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
     *      #array()
     *          #struct("kickstart variable")
     *              #prop("string", "key")
     *              #prop("string or int", "value")
     *          #struct_end()
     *      #array_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setVariables
                (String sessionKey, String ksLabel, Map<String, Object> variables) {

        User loggedInUser = getLoggedInUser(sessionKey);
        KickstartData ksData = lookupKsData(ksLabel, loggedInUser.getOrg());

        Profile profile = ksData.getCobblerObject(loggedInUser);
        profile.setKsMeta(variables);
        profile.save();

        return 1;
    }
}
