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
package com.redhat.rhn.domain.kickstart.builder;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorException;
import com.redhat.rhn.domain.kickstart.KickstartCommand;
import com.redhat.rhn.domain.kickstart.KickstartCommandName;
import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.domain.kickstart.KickstartDefaults;
import com.redhat.rhn.domain.kickstart.KickstartFactory;
import com.redhat.rhn.domain.kickstart.KickstartPackage;
import com.redhat.rhn.domain.kickstart.KickstartRawData;
import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.domain.kickstart.KickstartVirtualizationType;
import com.redhat.rhn.domain.kickstart.KickstartableTree;
import com.redhat.rhn.domain.rhnpackage.PackageFactory;
import com.redhat.rhn.domain.rhnpackage.PackageName;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.kickstart.KickstartTreeUpdateType;
import com.redhat.rhn.frontend.dto.StringDto;
import com.redhat.rhn.frontend.xmlrpc.kickstart.InvalidVirtualizationTypeException;
import com.redhat.rhn.manager.kickstart.KickstartEditCommand;
import com.redhat.rhn.manager.kickstart.KickstartLister;
import com.redhat.rhn.manager.kickstart.KickstartScriptCreateCommand;
import com.redhat.rhn.manager.kickstart.KickstartWizardHelper;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerProfileCommand;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.Distro;

import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * KickstartBuilder: Creates KickstartData objects.
 * @version $Rev$
 */
public class KickstartBuilder {

    private static Logger log = Logger.getLogger(KickstartBuilder.class);

    private static final String IA64 = "IA-64";
    private static final String PPC = "PPC";
    private static final int MIN_KS_LABEL_LENGTH = 6;

    // Kickstart options frequently have multiple aliases, but we only support one version
    // in our database. This map will be used to convert to the supported version.
    private static Map<String, String> optionAliases;
    private static Set<String> installationTypes;
    private static Set<String> partitionCommands = new HashSet<String>();
    static {
        optionAliases = new HashMap<String, String>();
        optionAliases.put("authconfig", "auth");

        partitionCommands.add("logvol");
        partitionCommands.add("partition");
        partitionCommands.add("part");
        partitionCommands.add("raid");
        partitionCommands.add("volgroup");
        partitionCommands.add("%include");

        installationTypes = new HashSet<String>();
        installationTypes.add("nfs");
        installationTypes.add("url");
        installationTypes.add("cdrom");
        installationTypes.add("harddrive");
    }

    private final User user;


    /**
     * Constructor
     * @param userIn User creating the kickstart profile.
     */
    public KickstartBuilder(User userIn) {
        user = userIn;
    }

    /**
     * Create KickstartCommands and associate with their KickstartData.
     * @param ksData KickstartData to associate commands with.
     * @param lines Kickstart option lines.
     * @param tree KickstartableTree for the new kickstart profile.
     */
    public void buildCommands(KickstartData ksData, List<String> lines,
            KickstartableTree tree) {
        StringBuilder partitionBuf = new StringBuilder();
        // Grab a list of all the available command names:
        List<KickstartCommandName> availableOptions = KickstartFactory
                .lookupAllKickstartCommandNames(ksData);
        Map<String, KickstartCommandName> commandNames =
                new HashMap<String, KickstartCommandName>();
        for (KickstartCommandName cmdName : availableOptions) {
            commandNames.put(cmdName.getName(), cmdName);
        }

        Set<KickstartCommand> commandOptions = new HashSet<KickstartCommand>();

        for (String currentLine : lines) {
            if (currentLine.startsWith("#") || currentLine.equals("")) {
                continue;
            }

            // Split the first word from the rest of the line:
            int firstSpaceIndex = currentLine.indexOf(' ');
            String firstWord = currentLine;
            String restOfLine = "";
            if (firstSpaceIndex != -1) {
                restOfLine = currentLine.substring(firstSpaceIndex).trim();
                firstWord = currentLine.substring(0, firstSpaceIndex).trim();
            }
            if (partitionCommands.contains(firstWord)) {
                partitionBuf.append(currentLine).append("\n");
                continue;
            }

            if (optionAliases.containsKey(firstWord)) {
                firstWord = optionAliases.get(firstWord);
            }

            // authconfig is an alias to the auth command
            if (firstWord.equals("authconfig")) {
                firstWord = "auth";
            }

            // Some possible values do not seem to be valid command names, (authconfig has
            // surfaced so far) what should be done with these?
            // Note: this may in fact never happen. See above, authconfig
            // is an alias to auth.
            if (!commandNames.containsKey(firstWord)) {
                // TODO
                log.warn("Unable to parse kickstart command: " + firstWord);
                continue;
            }

            // If we're to use the default URL for the new profile's kickstart tree,
            // ignore any url/nfs/cdrom/harddrive commands and instead add the default url:
            if (installationTypes.contains(firstWord)) {
                firstWord = "url";
                restOfLine = tree.getDefaultDownloadLocation();
                log.warn("Using default kickstartable tree URL:");
                log.warn("   Replaced: " + currentLine);
                log.warn("   With: " + firstWord + " " + restOfLine);
            }

            KickstartCommand kc = new KickstartCommand();
            KickstartCommandName cn = commandNames
                    .get(firstWord);
            kc.setCommandName(cn);
            kc.setKickstartData(ksData);
            kc.setCreated(new Date());
            kc.setModified(new Date());
            if (cn.getArgs().booleanValue()) {
                if (cn.getName().equals("rootpw")) {

                    // RHN only stores encrypted passwords and assumes it should add the
                    // --iscrypted option to rootpw when generating the final kickstart
                    // file. When importing we need to check for this option, remove it
                    // if it's there, and encrypt the password if it isn't.
                    // The way this works is that the system can determine from the crypted
                    // password what algorithm it was crypted with. It does not have to
                    // match with the algo specified on the auth command. So it's safe
                    // to encrypt using whatever algorithm we want without fear of being
                    // incompatible with the rest of the kickstart file.
                    String [] tokens = restOfLine.split(" ");
                    if (tokens.length > 2 || tokens.length == 0) {
                        throw new KickstartParsingException("Error parsing rootpw");
                    }
                    else if (tokens.length == 2) {
                        // Looks like the --iscrypted option is present:
                        if (!tokens[0].equals("--iscrypted")) {
                            throw new KickstartParsingException("Error parsing rootpw");
                        }
                        restOfLine = tokens[1];
                    }
                    else {
                        // No --iscrypted present, encrypt the password:
                        restOfLine = "--iscrypted " + ksData.encryptPassword(tokens[0]);
                    }
                }

                kc.setArguments(restOfLine);
            }
            commandOptions.add(kc);

        }
        ksData.setPartitionData(partitionBuf.toString());
        ksData.getCommands().addAll(commandOptions);
        KickstartFactory.saveKickstartData(ksData);
    }

    /**
     * Add packages to the given KickstartData.
     * @param ksData KickstartData to associate commands with.
     * @param lines %package section of the kickstart file.
     */
    public void buildPackages(KickstartData ksData, List<String> lines) {
        if (lines.size() == 0) {
            // Could conceivably be no packages?
            return;
        }

        // Make sure the first line starts with %packages for sanity:
        if (!(lines.get(0)).startsWith("%packages")) {
            throw new KickstartParsingException("Packages section didn't start with " +
                    "%packages tag.");
        }

        Set<KickstartPackage> ksPackagesSet = new TreeSet<KickstartPackage>();
        Long pos = new Long(0);
        for (Iterator<String> it = lines.iterator(); it.hasNext();) {
            String currentLine = it.next();
            if (currentLine.startsWith("#") || currentLine.startsWith("%packages") ||
                    currentLine.equals("")) {
                continue;
            }
            pos++;
            PackageName pn = PackageFactory.lookupOrCreatePackageByName(currentLine);
            ksPackagesSet.add(new KickstartPackage(ksData, pn, pos));
        }

        ksData.getKsPackages().addAll(ksPackagesSet);
    }

    /**
     * Builds the pre-scripts and associates them with the given KickstartData. Lines can
     * include multiple %pre sections.
     * @param ksData KicksartData to add scripts to.
     * @param lines %pre sections of the kickstart file.
     */
    public void buildPreScripts(KickstartData ksData, List<String> lines) {
        parseScript(ksData, lines, "%pre");
    }

    /**
     * Builds the post-scripts and associates them with the given KickstartData. Lines can
     * include multiple %post sections.
     * @param ksData KicksartData to add scripts to.
     * @param lines %post sections of the kickstart file.
     */
    public void buildPostScripts(KickstartData ksData, List<String> lines) {
        parseScript(ksData, lines, "%post");
    }

    private void parseScript(KickstartData ksData, List<String> lines, String prefix) {

        if (lines.size() == 0) {
            return;
        }

        if (!(lines.get(0)).startsWith(prefix)) {
            throw new KickstartParsingException("Pre section didn't start with " +
                    "%pre tag.");
        }

        StringBuffer buf = new StringBuffer();
        String interpreter = "";
        String chroot = "Y";
        boolean errorOnFail = false;
        for (String currentLine : lines) {
            if (currentLine.startsWith(prefix)) {
                if (buf.toString().length() > 0) {
                    storeScript(prefix, ksData, buf, interpreter, chroot, errorOnFail);
                }
                buf = new StringBuffer();

                interpreter = getInterpreter(currentLine);
                chroot = getChroot(prefix, currentLine);
                errorOnFail = getErrorOnFail(currentLine);

                continue;
            }
            if (buf.length() > 0) {
                buf.append("\n");
            }
            buf.append(currentLine);
        }
        storeScript(prefix, ksData, buf, interpreter, chroot, errorOnFail);
    }

    private String getInterpreter(String prefixLine) {
        String [] tokens = prefixLine.split(" ");
        for (int i = 1; i < tokens.length; i++) {
            if (tokens[i].equals("--interpreter")) {
                if (i == tokens.length - 1) {
                    throw new KickstartParsingException("Missing argument to " +
                            "--interpreter");
                }
                return tokens[i + 1];
            }
        }
        return null;
    }

    private String getChroot(String prefix, String prefixLine) {
        String [] tokens = prefixLine.split(" ");
        for (int i = 1; i < tokens.length; i++) {
            // nochroot is only valid for post scripts:
            if (tokens[i].equals("--nochroot")) {
                if (prefix.equals("%pre")) {
                    throw new KickstartParsingException("Invalid %pre argument: " +
                            "--nochroot");
                }
                return "N";
            }
        }
        return "Y";
    }

    private boolean getErrorOnFail(String prefixLine) {
        String[] tokens = prefixLine.split(" ");
        for (String token : tokens) {
            if (token.equals("--erroronfail")) {
                return true;
            }
        }
        return false;
    }

    private void storeScript(String prefix, KickstartData ksData, StringBuffer buf,
            String interpreter, String chroot, boolean errorOnFail) {
        KickstartScriptCreateCommand scriptCommand =
                new KickstartScriptCreateCommand(ksData.getId(), user);

        String type = KickstartScript.TYPE_PRE;
        if (prefix.equals("%post")) {
            type = KickstartScript.TYPE_POST;
        }

        scriptCommand.setScript(interpreter, buf.toString(), type, chroot, false, null,
                errorOnFail);
        scriptCommand.store();

    }

    private void checkRoles() {
        if (!user.hasRole(RoleFactory.ORG_ADMIN) &&
                !user.hasRole(RoleFactory.CONFIG_ADMIN)) {
            throw new PermissionException("Only Org Admins or Configuration Admins can " +
                    "modify kickstarts.");
        }
    }

    /**
     * Construct a KickstartData.
     * @param parser KickstartParser to build from.
     * @param label Label for the new kickstart data. (caller is responsible for ensuring
     * the label is valid and not already used within the users organization)
     * @param virtualizationType Virtualization type, or none.
     * @param tree KickstartableTree to associate with the new KickstartData.
     * @param updateType way that the profile should automaticall update the ks tree
     * @return KickstartData
     */
    public KickstartData createFromParser(KickstartParser parser, String label,
            String virtualizationType, KickstartableTree tree,
            KickstartTreeUpdateType updateType) {
        KickstartData ksdata = new KickstartData();
        setupBasicInfo(label, ksdata, tree, virtualizationType, updateType);

        if (ksdata.getKsPackages() == null) {
            ksdata.setKsPackages(new TreeSet<KickstartPackage>());
        }
        buildCommands(ksdata, parser.getOptionLines(), tree);
        buildPackages(ksdata, parser.getPackageLines());
        buildPreScripts(ksdata, parser.getPreScriptLines());
        buildPostScripts(ksdata, parser.getPostScriptLines());

        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        cmd.store(ksdata);
        return ksdata;
    }

    /**
     * Tests to see if a kickstart label is valid or not
     * @param ksLabel The label to test
     * @return true if it is valid, false otherwise
     */
    private boolean isLabelValid(String ksLabel) {
        if (ksLabel.length() < MIN_KS_LABEL_LENGTH) {
            return false;
        }
        Pattern pattern = Pattern.compile("[A-Za-z0-9_-]+", Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(ksLabel);
        return match.matches();
    }

    /**
     * Checks to see if the given label aready exists
     * @param label  the Ks label
     * @return checks for duplicate labels
     */
    private KickstartData labelAlreadyExists(String label) {
        return KickstartFactory.
                lookupKickstartDataByCILabelAndOrgId(label, user.getOrg().getId());
    }

    /**
     * Checks to see if the new label meets the proper
     * criterira.
     * @param label the ks label..
     */
    public void validateNewLabel(String label) {
        if (StringUtils.isBlank(label)) {
            ValidatorException.raiseException("kickstart.details.nolabel",
                    MIN_KS_LABEL_LENGTH);
        }
        KickstartData existing = labelAlreadyExists(label);
        if (existing != null) {
            ValidatorException.raiseException("kickstart.error.labelexists",
                    existing.getLabel());
        }
        if (!isLabelValid(label)) {
            ValidatorException.raiseException("kickstart.error.invalidlabel",
                    MIN_KS_LABEL_LENGTH);
        }
    }

    /**
     * Create a new KickstartRawData object
     * basically useful for KS raw mode.
     * @param label the kickstart label
     * @param tree the Ks tree
     * @param virtType and KS virt type.
     * @param fileContents to actually write out to disk.
     * @param updateType to set for KS profile
     * @return new Kickstart Raw Data object
     */
    public KickstartRawData createRawData(String label,
            KickstartableTree tree,
            String fileContents,
            String virtType,
            KickstartTreeUpdateType updateType) {
        checkRoles();
        KickstartRawData ksdata = new KickstartRawData();
        ksdata.setData(fileContents);
        setupBasicInfo(label, ksdata, tree, virtType, updateType);
        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        cmd.store(ksdata);
        return ksdata;
    }


    private void setupBasicInfo(String ksLabel,
            KickstartData ksdata,
            KickstartableTree ksTree,
            String virtType,
            KickstartTreeUpdateType updateType) {
        checkRoles();
        validateNewLabel(ksLabel);
        ksdata.setLabel(ksLabel);
        ksdata.setOrg(user.getOrg());
        ksdata.setActive(Boolean.TRUE);
        ksdata.setOrgDefault(false);
        ksdata.setRealUpdateType(updateType);
        KickstartDefaults defaults = new KickstartDefaults();
        defaults.setKstree(ksTree);
        ksdata.setKickstartDefaults(defaults);
        defaults.setKsdata(ksdata);
        defaults.setCfgManagementFlag(Boolean.FALSE);
        defaults.setRemoteCommandFlag(Boolean.FALSE);
        setupVirtType(virtType, ksdata);
    }
    /**
     * Updates the label, tree and virty tpe infor
     * for the passed in data
     * @param data ks data
     * @param label ks label
     * @param ksTree the ks tree
     * @param virtType the virt type
     */
    public void update(KickstartData data, String label,
            KickstartableTree ksTree,
            String virtType) {
        checkRoles();
        if (!data.getLabel().equals(label)) {
            validateNewLabel(label);
            data.setLabel(label);
        }
        data.getKickstartDefaults().setKstree(ksTree);
        setupVirtType(virtType, data);
        KickstartEditCommand cmd = new KickstartEditCommand(data, user);
        cmd.store();
    }

    /**
     * sets up the virt info for a ksdata
     * @param virtType vurt type
     * @param data ksdata
     */
    private void setupVirtType(String virtType, KickstartData data) {
        if (StringUtils.isBlank(virtType)) {
            virtType = KickstartVirtualizationType.XEN_PARAVIRT;
        }
        KickstartVirtualizationType ksVirtType = KickstartFactory.
                lookupKickstartVirtualizationTypeByLabel(virtType);
        if (ksVirtType == null) {
            throw new InvalidVirtualizationTypeException(virtType);
        }
        data.getKickstartDefaults().setVirtualizationType(ksVirtType);
    }

    /**
     * Create a new KickstartData.
     *
     * @param ksLabel Label for the new kickstart profile.
     * @param tree KickstartableTree the new profile is associated with.
     * @param virtType fully_virtualized, para_virtualized, or none.
     * @param downloadUrl Download location.
     * @param rootPassword Root password.
     * @param updateType how this profile will update the kickstart tree when new ones
     * become available.
     * @return Newly created KickstartData.
     */
    public KickstartData create(String ksLabel, KickstartableTree tree,
            String virtType, String downloadUrl, String rootPassword,
            KickstartTreeUpdateType updateType) {

        checkRoles();
        KickstartData ksdata = new KickstartData();
        setupBasicInfo(ksLabel, ksdata, tree, virtType, updateType);
        KickstartCommandName kcn = null;
        KickstartCommand kscmd = null;
        ksdata.setCommands(new LinkedHashSet<KickstartCommand>());
        kcn = KickstartFactory.lookupKickstartCommandName("url");
        kscmd = new KickstartCommand();
        kscmd.setCommandName(kcn);
        kscmd.setArguments("--url " + downloadUrl);
        ksdata.getCommands().add(kscmd);
        kscmd.setKickstartData(ksdata);
        kscmd.setCreated(new Date());

        KickstartWizardHelper cmd = new KickstartWizardHelper(user);
        setNetwork(cmd, ksdata);

        setRootPassword(cmd, ksdata, rootPassword);

        // Set defaults
        setLanguage(cmd, ksdata);
        setKeyboardMouse(cmd, ksdata);
        setBootloader(cmd, ksdata);
        setTimezone(cmd, ksdata);
        setAuth(cmd, ksdata);
        setMiscDefaults(cmd, ksdata);
        setPartitionScheme(cmd, ksdata);
        cmd.processSkipKey(ksdata);
        cmd.processRepos(ksdata);
        if (ksdata.getKsPackages() == null) {
            ksdata.setKsPackages(new TreeSet<KickstartPackage>());
        }
        cmd.store(ksdata);
        PackageName pn = cmd.findPackageName("@ Base");
        ksdata.addKsPackage(new KickstartPackage(ksdata, pn));
        return ksdata;

    }

    private void setRootPassword(KickstartWizardHelper cmd,
            KickstartData ksdata, String rootPassword) {
        cmd.createCommand("rootpw", ksdata.encryptPassword(rootPassword), ksdata);
    }

    private void setLanguage(KickstartWizardHelper cmd,
            KickstartData ksdata) {
        cmd.createCommand("lang", "en_US", ksdata);
        if (!ksdata.isRhel5OrGreater()) {
            cmd.createCommand("langsupport", "--default en_US en_US", ksdata);
        }
    }

    private void setKeyboardMouse(KickstartWizardHelper cmd,
            KickstartData ksdata) {
        cmd.createCommand("keyboard", "us", ksdata);
        if (!ksdata.isRhel5OrGreater()) {
            cmd.createCommand("mouse", "none", ksdata);
        }
    }

    private void setTimezone(KickstartWizardHelper cmd, KickstartData ksdata) {
        if (user != null && user.getTimeZone() != null) {
            StringDto userTzOlson = new StringDto(user.getTimeZone().getOlsonName());
            DataResult<StringDto> tzs =
                    KickstartLister.getInstance().getValidTimezonesFotInstallType(
                            ksdata.getTree().getInstallType());
            if (tzs.contains(userTzOlson)) {
                cmd.createCommand("timezone", userTzOlson.getValue(), ksdata);
                return;
            }
        }
        cmd.createCommand("timezone", "America/New_York", ksdata);
    }

    private void setAuth(KickstartWizardHelper cmd, KickstartData ksdata) {
        cmd.createCommand("auth", ksdata.defaultAuthArgs(), ksdata);
    }

    private void setNetwork(KickstartWizardHelper cmd, KickstartData ksdata) {
        cmd.createCommand("network", "--bootproto dhcp", ksdata);
    }

    private void setMiscDefaults(KickstartWizardHelper cmd, KickstartData ksdata) {
        if (!ksdata.isRhel5OrGreater()) {
            cmd.createCommand("zerombr", "yes", ksdata);
        }
        else {
            cmd.createCommand("zerombr", null, ksdata);
        }
        cmd.createCommand("reboot", null, ksdata);
        cmd.createCommand("skipx", null, ksdata);
        cmd.createCommand("firewall", "--disabled", ksdata);
        cmd.createCommand("clearpart", "--all", ksdata);
        if (!ksdata.isLegacyKickstart()) {
            cmd.createCommand("selinux", "--permissive", ksdata);
        }
        cmd.createCommand("text", null, ksdata);
        cmd.createCommand("install", null, ksdata);
    }

    /**
     * Setup the bootloader command for this profile's current settings.
     * @param cmd Helper
     * @param ksdata Kickstart data
     */
    public static void setBootloader(KickstartWizardHelper cmd, KickstartData ksdata) {
        if (ksdata.getKickstartDefaults().getVirtualizationType().getLabel().equals(
                KickstartVirtualizationType.XEN_PARAVIRT)) {
            cmd.createCommand("bootloader", "--location mbr --driveorder=xvda --append=",
                    ksdata);
        }
        else {
            cmd.createCommand("bootloader", "--location mbr", ksdata);
        }
    }

    /**
     * Setup the default partition scheme for this kickstart profile's current settings.
     *
     * @param cmd Helper
     * @param ksdata Kickstart data.
     */
    public static void setPartitionScheme(KickstartWizardHelper cmd, KickstartData ksdata) {

        String configData = Config.get().getString(ConfigDefaults.KS_PARTITION_DEFAULT);
        if (!StringUtils.isBlank(configData)) {
            ksdata.setPartitionData(configData);
        }
        else if (ksdata.isRhel7OrGreater()) {
            ksdata.setPartitionData("autopart --type=lvm");
        }
        else if (ksdata.getChannel().getChannelArch().getName().equals(IA64)) {
            setItaniumParitionScheme(cmd, ksdata);
        }
        else if (ksdata.getChannel().getChannelArch().getName().equals(PPC)) {
            setPpcPartitionScheme(cmd, ksdata);
        }
        else {
            String virtType = ksdata.getKickstartDefaults().
                    getVirtualizationType().getLabel();
            if (virtType.equals(KickstartVirtualizationType.XEN_PARAVIRT)) {
                String data = "part /boot --fstype ext3 --size=100 --ondisk=xvda\n" +
                        "part pv.00 --size=0 --grow --ondisk=xvda \n" +
                        "volgroup VolGroup00 --pesize=32768 pv.00\n" +
                        "logvol / --fstype ext3 --name=LogVol00 " +
                        "--vgname=VolGroup00 --size=1024 --grow\n" +
                        "logvol swap --fstype swap --name=LogVol01 " +
                        "--vgname=VolGroup00 --size=272 --grow --maxsize=544";
                ksdata.setPartitionData(data);

            }
            else if (!ksdata.isLegacyKickstart()) {
                String data = "part /boot --fstype=ext3 --size=200 \n" +
                        "part pv.01 --size=1000 --grow \n" +
                        "part swap --size=1000   --maxsize=2000 \n" +
                        "volgroup myvg pv.01 \n" +
                        "logvol / --vgname=myvg --name=rootvol --size=1000 --grow";
                ksdata.setPartitionData(data);
            }
            else {
                String data = "part /boot --fstype=ext3 --size=200 \n" +
                        "part pv.01 --size=1000 --grow \n" +
                        "part swap --size=1000   --maxsize=2000";
                ksdata.setPartitionData(data);
            }
        }
    }

    private static void setItaniumParitionScheme(KickstartWizardHelper cmd,
            KickstartData ksdata) {
        if (!ksdata.isLegacyKickstart()) {
            String data = "part /boot/efi --fstype=vfat --size=100 \n" +
                    "part swap --size=1000 --grow --maxsize=2000\n" +
                    "part pv.01 --fstype=ext3 --size=700 --grow\n" +
                    "volgroup myvg pv.01\n" +
                    "logvol --vgname=myvg --name=rootvol --size=1000 --grow";
            ksdata.setPartitionData(data);
        }
        else {
            String data = "part /boot/efi --fstype=vfat --size=100 \n" +
                    "part swap --size=1000 --grow --maxsize=2000\n" +
                    "part pv.01 --fstype=ext3 --size=700 --grow";
            ksdata.setPartitionData(data);
        }
    }

    private static void setPpcPartitionScheme(KickstartWizardHelper cmd,
            KickstartData ksdata) {
        log.debug("Adding PPC specific partition info:");
        if (!ksdata.isLegacyKickstart()) {
            String data = "part /boot --fstype=ext3 --size=200\n" +
                    "part prepboot --fstype \"PPC PReP Boot\" --size=4\n" +
                    "part swap --size=1000   --maxsize=2000 \n" +
                    "part pv.01 --size=1000 --grow \n" +
                    "volgroup myvg pv.01 \n" +
                    "logvol / --vgname=myvg --name=rootvol --size=1000 --grow";
            ksdata.setPartitionData(data);
        }
        else {
            String data = "part /boot --fstype=ext3 --size=200\n" +
                    "part prepboot --fstype \"PPC PReP Boot\" --size=4\n" +
                    "part swap --size=1000   --maxsize=2000 \n" +
                    "part / --fstype=ext3 --size=700 --grow";
            ksdata.setPartitionData(data);
        }

    }

    /**
     * Check if there is a suitable distro for tree + virt. type combination.
     * @param tree suitable kickstartable tree
     * @param virtualizationType string with virtualization type
     */
    public void validateTreeVirt(KickstartableTree tree, String virtualizationType) {
        KickstartVirtualizationType vType =
                KickstartFactory.lookupKickstartVirtualizationTypeByLabel(
                        virtualizationType);
        Distro distro = CobblerProfileCommand.getCobblerDistroForVirtType(tree,
                vType, user);
        if (distro == null) {
            ValidatorException.raiseException(
                    "kickstart.cobbler.profile.nodistribution");
        }
    }

}
