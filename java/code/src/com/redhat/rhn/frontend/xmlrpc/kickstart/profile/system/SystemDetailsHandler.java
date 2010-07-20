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

package com.redhat.rhn.frontend.xmlrpc.kickstart.profile.system;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.SELinuxMode;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.frontend.xmlrpc.FileListNotFoundException;
import com.redhat.rhn.frontend.xmlrpc.InvalidLocaleCodeException;
import com.redhat.rhn.frontend.xmlrpc.kickstart.XmlRpcKickstartHelper;
import com.redhat.rhn.manager.kickstart.KickstartCryptoKeyCommand;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartLocaleCommand;
import com.redhat.rhn.manager.kickstart.KickstartPartitionCommand;
import com.redhat.rhn.manager.kickstart.SystemDetailsCommand;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
* SystemDetailsHandler
* @version $Rev$
* @xmlrpc.namespace kickstart.profile.system
* @xmlrpc.doc Provides methods to set various properties of a kickstart profile.
*/
public class SystemDetailsHandler extends BaseHandler {

    /**
      * Check the configuration management status for a kickstart profile
      * so that a system created using this profile will be configuration capable.
      * @param sessionKey the session key
      * @param ksLabel the ks profile label
      * @return returns true if configuration management is enabled; otherwise, false
      *
      * @xmlrpc.doc Check the configuration management status for a kickstart profile.
      * @xmlrpc.param #session_key()
      * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
      * @xmlrpc.returntype #prop_desc("boolean", "enabled", "true if configuration
      * management is enabled; otherwise, false")
      */
    public boolean checkConfigManagement(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        return command.getKickstartData().getKickstartDefaults().getCfgManagementFlag().
            booleanValue();
    }

    /**
     * Enables the configuration management flag in a kickstart profile
     * so that a system created using this profile will be configuration capable.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     *
     *
     * @xmlrpc.doc Enables the configuration management flag in a kickstart profile
     * so that a system created using this profile will be configuration capable.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int enableConfigManagement(String sessionKey, String ksLabel) {
        return setConfigFlag(sessionKey, ksLabel, true);
    }

    /**
     * Disables the configuration management flag in a kickstart profile
     * so that a system created using this profile will be NOT be configuration capable.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     *
     * @xmlrpc.doc Disables the configuration management flag in a kickstart profile
     * so that a system created using this profile will be NOT be configuration capable.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()

     */
    public int disableConfigManagement(String sessionKey, String ksLabel) {
        return setConfigFlag(sessionKey, ksLabel, false);
    }

    private int setConfigFlag(String sessionKey, String ksLabel, boolean flag) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.enableConfigManagement(flag);
        command.store();
        return 1;
    }

    /**
    * Check the remote commands status flag for a kickstart profile
    * so that a system created using this profile
    * will be capable of running remote commands
    * @param sessionKey the session key
    * @param ksLabel the ks profile label
    * @return returns true if remote command support is enabled; otherwise, false
    *
    * @xmlrpc.doc Check the remote commands status flag for a kickstart profile.
    * @xmlrpc.param #session_key()
    * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
    * @xmlrpc.returntype #prop_desc("boolean", "enabled", "true if remote
    * commands support is enabled; otherwise, false")
    */
    public boolean checkRemoteCommands(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        return command.getKickstartData().getKickstartDefaults().getRemoteCommandFlag().
            booleanValue();
    }

    /**
     * Enables the remote command flag in a kickstart profile
     * so that a system created using this profile
     * will be capable of running remote commands
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     *
     * @xmlrpc.doc Enables the remote command flag in a kickstart profile
     * so that a system created using this profile
     *  will be capable of running remote commands
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()
     */
    public int enableRemoteCommands(String sessionKey, String ksLabel) {
        return setRemoteCommandsFlag(sessionKey, ksLabel, true);
    }

    /**
     * Disables the remote command flag in a kickstart profile
     * so that a system created using this profile
     * will be capable of running remote commands
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return 1 on success
     *
     * @xmlrpc.doc Disables the remote command flag in a kickstart profile
     * so that a system created using this profile
     * will be capable of running remote commands
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype #return_int_success()

     */
    public int disableRemoteCommands(String sessionKey, String ksLabel) {
        return setRemoteCommandsFlag(sessionKey, ksLabel, false);
    }

    private int setRemoteCommandsFlag(String sessionKey, String ksLabel, boolean flag) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.enableRemoteCommands(flag);
        command.store();
        return 1;
    }

    /**
     * Retrieves the SELinux enforcing mode property of a kickstart
     * profile.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @return the enforcing mode
     *
     * @xmlrpc.doc Retrieves the SELinux enforcing mode property of a kickstart
     * profile.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.returntype
     * #param("string", "enforcingMode")
     *      #options()
     *          #item ("enforcing")
     *          #item ("permissive")
     *          #item ("disabled")
     *      #options_end()
     */
    public String getSELinux(String sessionKey, String ksLabel) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        return command.getKickstartData().getSELinuxMode().getValue();
    }

    /**
     * Sets the SELinux enforcing mode property of a kickstart profile
     * so that a system created using this profile will be have
     * the appropriate SELinux enforcing mode.
     * @param sessionKey the session key
     * @param ksLabel the ks profile label
     * @param enforcingMode the SELinux enforcing mode.
     * @return 1 on success
     *
     * @xmlrpc.doc Sets the SELinux enforcing mode property of a kickstart profile
     * so that a system created using this profile will be have
     * the appropriate SELinux enforcing mode.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #param_desc("string", "ksLabel","the kickstart profile label")
     * @xmlrpc.param #param_desc("string", "enforcingMode","the selinux enforcing mode")
     *      #options()
     *          #item ("enforcing")
     *          #item ("permissive")
     *          #item ("disabled")
     *      #options_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setSELinux(String sessionKey, String ksLabel, String enforcingMode) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command  = getSystemDetailsCommand(ksLabel, user);
        command.setMode(SELinuxMode.lookup(enforcingMode));
        return setRemoteCommandsFlag(sessionKey, ksLabel, true);
    }

    /**
     * Retrieves the locale for a kickstart profile.
     * @param sessionKey The current user's session key
     * @param ksLabel The kickstart profile label
     * @return Returns a map containing the local and useUtc.
     * @throws FaultException A FaultException is thrown if:
     *   - The profile associated with ksLabel cannot be found
     *
     * @xmlrpc.doc Retrieves the locale for a kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "ksLabel", "the kickstart profile label")
     * @xmlrpc.returntype
     *          #struct("locale info")
     *              #prop("string", "locale")
     *              #prop("boolean", "useUtc")
     *                  #options()
     *                      #item_desc ("true", "the hardware clock uses UTC")
     *                      #item_desc ("false", "the hardware clock does not use UTC")
     *                  #options_end()
     *          #struct_end()
     */
    public Map getLocale(String sessionKey, String ksLabel) throws FaultException {

        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);

        KickstartLocaleCommand command  = getLocaleCommand(ksLabel, user);

        Map locale = new HashMap();
        locale.put("locale", command.getTimezone());
        locale.put("useUtc", command.isUsingUtc());

        return locale;
    }

    /**
     * Sets the locale for a kickstart profile.
     * @param sessionKey The current user's session key
     * @param ksLabel The kickstart profile label
     * @param locale The locale
     * @param useUtc true if the hardware clock uses UTC
     * @return 1 on success, exception thrown otherwise
     * @throws FaultException A FaultException is thrown if:
     *   - The profile associated with ksLabel cannot be found
     *   - The locale provided is invalid
     *
     * @xmlrpc.doc Sets the locale for a kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param_desc("string", "ksLabel", "the kickstart profile label")
     * @xmlrpc.param #param_desc("string", "locale", "the locale")
     * @xmlrpc.param #param("boolean", "useUtc")
     *      #options()
     *          #item_desc ("true",
     *          "the hardware clock uses UTC")
     *          #item_desc ("false",
     *          "the hardware clock does not use UTC")
     *      #options_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setLocale(String sessionKey, String ksLabel, String locale,
            boolean useUtc) throws FaultException {

        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);

        KickstartLocaleCommand command  = getLocaleCommand(ksLabel, user);

        if (command.isValidTimezone(locale) == Boolean.FALSE) {
            throw new InvalidLocaleCodeException(locale);
        }

        command.setTimezone(locale);
        if (useUtc) {
            command.useUtc();
        }
        else {
            command.doNotUseUtc();
        }
        command.store();
        return 1;
    }

    /**
     * Set the partitioning scheme for a kickstart profile.
     * @param sessionKey An active session key.
     * @param ksLabel A kickstart profile label.
     * @param scheme The partitioning scheme.
     * @return 1 on success
     * @throws FaultException
     * @xmlrpc.doc Set the partitioning scheme for a kickstart profile.
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
     * Get the partitioning scheme for a kickstart profile.
     * @param sessionKey An active session key
     * @param ksLabel A kickstart profile label
     * @return The profile's partitioning scheme. This is a list of commands
     * used to setup the partitions, logical volumes and volume groups.
     * @throws FaultException
     * @xmlrpc.doc Get the partitioning scheme for a kickstart profile.
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
        Long ksid = ksdata.getId();
        KickstartPartitionCommand command = new KickstartPartitionCommand(ksid,
                                                                          user);
        String[] partitions = command.populatePartitions().split("\\r?\\n");

        return new ArrayList<String>(Arrays.asList(partitions));
    }


    private KickstartData lookupKsData(String label, Org org) {
        return XmlRpcKickstartHelper.getInstance().lookupKsData(label, org);
    }


    private KickstartLocaleCommand getLocaleCommand(String label, User user) {
        XmlRpcKickstartHelper helper = XmlRpcKickstartHelper.getInstance();
        return new KickstartLocaleCommand(helper.lookupKsData(label, user), user);
    }

    private SystemDetailsCommand getSystemDetailsCommand(String label, User user) {
        XmlRpcKickstartHelper helper = XmlRpcKickstartHelper.getInstance();
        return new SystemDetailsCommand(helper.lookupKsData(label, user), user);
    }

    /**
     * Returns the set of all keys associated with the indicated kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @return set of all keys associated with the given profile
     *
     * @xmlrpc.doc Returns the set of all keys associated with the given kickstart
     *             profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.returntype
     *      #array()
     *          #struct("key")
     *              #prop("string", "description")
     *              #prop("string", "type")
     *              #prop("string", "content")
     *          #struct_end()
     *      #array_end()
     */
    public Set listKeys(String sessionKey, String kickstartLabel) {

        // TODO: Determine if null or empty set is returned when no keys associated

        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        // Set will contain crypto key
        Set keys = data.getCryptoKeys();
        return keys;
    }

    /**
     * Adds the given list of keys to the specified kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @param descriptions   list identifiying the keys to add
     * @return 1 if the associations were performed correctly
     *
     * @xmlrpc.doc Adds the given list of keys to the specified kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.param #array_single("string", "keyDescription")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addKeys(String sessionKey, String kickstartLabel,
                             List descriptions) {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        if (descriptions == null) {
            throw new IllegalArgumentException("descriptions cannot be null");
        }

        // Load the kickstart profile
        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        // Associate the keys
        KickstartCryptoKeyCommand command =
            new KickstartCryptoKeyCommand(data.getId(), user);

        command.addKeysByDescriptionAndOrg(descriptions, org);
        command.store();

        return 1;
    }

    /**
     * Removes the given list of keys from the specified kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @param descriptions   list identifiying the keys to remove
     * @return 1 if the associations were performed correctly
     *
     * @xmlrpc.doc Removes the given list of keys from the specified kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.param #array_single("string", "keyDescription")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeKeys(String sessionKey, String kickstartLabel,
                             List descriptions) {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        if (descriptions == null) {
            throw new IllegalArgumentException("descriptions cannot be null");
        }

        // Load the kickstart profile
        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        KickstartCryptoKeyCommand command =
            new KickstartCryptoKeyCommand(data.getId(), user);

        command.removeKeysByDescriptionAndOrg(descriptions, org);
        command.store();

        return 1;
    }

    /**
     * Returns the set of all file preservations associated with the given kickstart
     * profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The kickstartLabel is invalid
     * @return set of all file preservations associated with the given profile
     *
     * @xmlrpc.doc Returns the set of all file preservations associated with the given
     * kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.returntype
     *     #array()
     *         $FileListSerializer
     *     #array_end()
     */
    public Set listFilePreservations(String sessionKey, String kickstartLabel)
        throws FaultException {

        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        return data.getPreserveFileLists();
    }

    /**
     * Adds the given list of file preservations to the specified kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @param filePreservations   list identifying the file preservations to add
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The kickstartLabel is invalid
     *   - One of the filePreservations is invalid
     * @return 1 if the associations were performed correctly
     *
     * @xmlrpc.doc Adds the given list of file preservations to the specified kickstart
     * profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.param #array_single("string", "filePreservations")
     * @xmlrpc.returntype #return_int_success()
     */
    public int addFilePreservations(String sessionKey, String kickstartLabel,
                             List<String> filePreservations) throws FaultException {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        if (filePreservations == null) {
            throw new IllegalArgumentException("filePreservations cannot be null");
        }

        // Load the kickstart profile
        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        // Add the file preservations
        KickstartEditCommand command =
            new KickstartEditCommand(data.getId(), user);

        Set<FileList> fileLists = new HashSet<FileList>();
        for (String name : filePreservations) {
            FileList fileList = CommonFactory.lookupFileList(name, user.getOrg());
            if (fileList == null) {
                throw new FileListNotFoundException(name);
            }
            else {
                fileLists.add(fileList);
            }
        }
        // Cycle through the list of file list objects retrieved and add
        // them to the profile.  We do this on a second pass because, we
        // don't want to remove anything if there was an error that would have
        // resulted in an exception being thrown.
        for (FileList fileList : fileLists) {
            command.getKickstartData().addPreserveFileList(fileList);
        }
        command.store();
        return 1;
    }

    /**
     * Removes the given list of file preservations from the specified kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @param filePreservations   list identifying the file preservations to remove
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The kickstartLabel is invalid
     *   - One of the filePreservations is invalid
     * @return 1 if the associations were performed correctly
     *
     * @xmlrpc.doc Removes the given list of file preservations from the specified
     * kickstart profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.param #array_single("string", "filePreservations")
     * @xmlrpc.returntype #return_int_success()
     */
    public int removeFilePreservations(String sessionKey, String kickstartLabel,
                             List<String> filePreservations) throws FaultException {
        if (sessionKey == null) {
            throw new IllegalArgumentException("sessionKey cannot be null");
        }

        if (kickstartLabel == null) {
            throw new IllegalArgumentException("kickstartLabel cannot be null");
        }

        if (filePreservations == null) {
            throw new IllegalArgumentException("filePreservations cannot be null");
        }

        // Load the kickstart profile
        User user = getLoggedInUser(sessionKey);
        Org org = user.getOrg();

        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                org.getId());

        // Associate the file preservations
        KickstartEditCommand command =
            new KickstartEditCommand(data.getId(), user);

        Set<FileList> fileLists = new HashSet<FileList>();
        for (String name : filePreservations) {
            FileList fileList = CommonFactory.lookupFileList(name, user.getOrg());
            if (fileList == null) {
                throw new FileListNotFoundException(name);
            }
            else {
                fileLists.add(fileList);
            }
        }
        // Cycle through the list of file list objects retrieved and remove
        // them from the profile.  We do this on a second pass because, we
        // don't want to remove anything if there was an error that would have
        // resulted in an exception being thrown.
        for (FileList fileList : fileLists) {
            command.getKickstartData().removePreserveFileList(fileList);
        }
        command.store();
        return 1;
    }


    /**
     * Sets the registration type of a given kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @param registrationType   registration type
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The kickstartLabel is invalid
     *   - registration type is not reactivation/deletion/none
     * @return 1 if the associations were performed correctly
     *
     * @xmlrpc.doc Sets the registration type of a given kickstart profile.
     * Registration Type can be one of reactivation/deletion/none
     * These types determine the behaviour of the re registration when using
     * this profile.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.param #param("string","registrationType")
     *      #options()
     *         #item_desc ("reactivation", "to try and generate a reactivation key
     *              and use that to register the system when reprovisioning a system.")
     *         #item_desc ("deletion", "to try and delete the existing system profile
     *              and reregister the system being reprovisioned as new")
     *         #item_desc ("none", "to preserve the status quo and leave the current system
     *              as a duplicate on a reprovision.")
     *      #options_end()
     * @xmlrpc.returntype #return_int_success()
     */
    public int setRegistrationType(String sessionKey, String kickstartLabel,
                                                        String registrationType) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        SystemDetailsCommand command = getSystemDetailsCommand(kickstartLabel, user);
        command.setRegistrationType(registrationType);
        command.store();
        return 1;
    }


    /**
     * Returns the registration type of a given kickstart profile.
     *
     * @param sessionKey     identifies the user's session; cannot be <code>null</code>
     * @param kickstartLabel identifies the profile; cannot be <code>null</code>
     * @throws FaultException A FaultException is thrown if:
     *   - The sessionKey is invalid
     *   - The kickstartLabel is invalid
     * @return the registration type -> one of reactivation/deletion/none
     *
     * @xmlrpc.doc returns the registration type of a given kickstart profile.
     * Registration Type can be one of reactivation/deletion/none
     * These types determine the behaviour of the registration when using
     * this profile for reprovisioning.
     * @xmlrpc.param #param("string", "sessionKey")
     * @xmlrpc.param #param("string", "kickstartLabel")
     * @xmlrpc.returntype
     * #param("string", "registrationType")
     *      #options()
     *         #item ("reactivation")
     *         #item ("deletion")
     *         #item ("none")
     *      #options_end()
     */
    public String  getRegistrationType(String sessionKey, String kickstartLabel) {
        User user = getLoggedInUser(sessionKey);
        ensureConfigAdmin(user);
        KickstartData data =
            KickstartFactory.lookupKickstartDataByLabelAndOrgId(kickstartLabel,
                    user.getOrg().getId());
        return data.getRegistrationType(user).getType();
    }
}
