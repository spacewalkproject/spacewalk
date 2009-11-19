/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.kickstart.crypto.CryptoKey;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.token.Token;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.kickstart.KickstartFormatter;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerCommand;
import com.redhat.rhn.manager.kickstart.cobbler.CobblerXMLRPCHelper;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.cobbler.CobblerConnection;
import org.cobbler.Profile;

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * KickstartData - Class representation of the table RhnKSData.
 * @version $Rev: 1 $
 */
public class KickstartData {

    private Long id;
    protected String kickstartType;
    private Org org;
    private String label;
    private String comments;
    private Boolean active;
    private Boolean postLog; 
    private Boolean preLog;
    private Boolean ksCfg;
    private Date created;
    private Date modified;
    private boolean isOrgDefault;
    private String kernelParams;    
    private Boolean nonChrootPost;
    private Boolean verboseUp2date;
    private String cobblerId;

    private Set cryptoKeys;
    private Set childChannels;
    private Set defaultRegTokens;
    private Set preserveFileLists;
    private Set<KickstartPackage> ksPackages;
    private Collection<KickstartCommand> commands = new HashSet<KickstartCommand>();
    private Set ips;          // rhnKickstartIpRange
    private Set<KickstartScript> scripts;      // rhnKickstartScript
    private KickstartDefaults kickstartDefaults;
    
    private static final Pattern URL_REGEX =
        Pattern.compile("--url\\s*(\\S+)", Pattern.CASE_INSENSITIVE);
    public static final String LEGACY_KICKSTART_PACKAGE_NAME = "auto-kickstart-";
    
    public static final String WIZARD_DIR = "wizard";
    public static final String RAW_DIR = "upload";

    public static final String SELINUX_MODE_COMMAND = "selinux";
    
    public static final String TYPE_WIZARD = "wizard";
    public static final String TYPE_RAW = "raw";

    private static String[] advancedOptions = 
        {"partitions", "raids", "logvols", "volgroups", "include", 
            "repo", "custom", "custom_partition"};
    
    private static final List ADANCED_OPTIONS = Arrays.asList(advancedOptions); 
    
    /**
     * Initializes properties.
     */
    public KickstartData() {
        cryptoKeys = new HashSet();
        defaultRegTokens = new HashSet();
        preserveFileLists = new HashSet();
        ksPackages = new TreeSet<KickstartPackage>();
        commands = new HashSet<KickstartCommand>();
        ips = new HashSet();
        scripts = new HashSet<KickstartScript>();
        postLog = new Boolean(false);
        preLog = new Boolean(false);
        ksCfg = new Boolean(false);
        verboseUp2date = new Boolean(false);
        nonChrootPost = new Boolean(false);
        childChannels = new HashSet();
        kickstartType = TYPE_WIZARD;
    }
    
    /**
     * Logger for this class
     */
    private static Logger logger = Logger
            .getLogger(KickstartData.class);

    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Associates the KS with an Org.
     * @param orgIn Org to be associated to this KS.
     */
    public void setOrg(Org orgIn) {
        org = orgIn;
    }

    /** 
     * Getter for org 
     * @return org to get
    */
    public Org getOrg() {
        return org;
    }

    /** 
     * Getter for label 
     * @return String to get
    */
    public String getLabel() {
        return this.label;
    }

    /** 
     * Setter for label 
     * @param labelIn to set
    */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /** 
     * Getter for comments 
     * @return String to get
    */
    public String getComments() {
        return this.comments;
    }

    /** 
     * Setter for comments 
     * @param commentsIn to set
    */
    public void setComments(String commentsIn) {
        this.comments = commentsIn;
    }

    /** 
     * Getter for active 
     * @return String to get
    */
    public Boolean isActive() {
        return this.active;
    }


    /** 
     * Getter for active 
     * @return String to get
    */
    public boolean getActive() {
        return isActive();
    }    
    /** 
     * Setter for active 
     * @param activeIn to set
    */
    public void setActive(Boolean activeIn) {
        this.active = activeIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /** 
     * Getter for isOrgDefault 
     * @return String to get
    */
    public Boolean isOrgDefault() {
        return getIsOrgDefault();
    }

    /** 
     * Getter for isOrgDefault 
     * @return String to get
    */
    protected boolean getIsOrgDefault() {
        return this.isOrgDefault;
    }    
    /** 
     * Setter for isOrgDefault 
     * @param isDefault to set
    */
    protected void setIsOrgDefault(boolean isDefault) {
        this.isOrgDefault = isDefault;
    }
    
    /** 
     * Setter for isOrgDefault 
     * @param isDefault to set
    */
    public void setOrgDefault(boolean isDefault) {
        // We actually want to set the orgdefault
        if (!isOrgDefault() &&
                isDefault) {
            KickstartData existingDefault = KickstartFactory.
                lookupOrgDefault(getOrg());
            if (existingDefault != null) {
                existingDefault.setIsOrgDefault(Boolean.FALSE);
                KickstartFactory.saveKickstartData(existingDefault);
            }
        }
        setIsOrgDefault(isDefault);
    }

    /** 
     * Getter for kernelParams 
     * @return String to get
    */
    public String getKernelParams() {
        return this.kernelParams;
    }

    /** 
     * Setter for kernelParams 
     * @param kernelParamsIn to set
    */
    public void setKernelParams(String kernelParamsIn) {
        this.kernelParams = kernelParamsIn;
    }
    
    /**
     * @return the cryptoKeys
     */
    public Set getCryptoKeys() {
        return cryptoKeys;
    }

    
    /**
     * @param cryptoKeysIn The cryptoKeys to set.
     */
    public void setCryptoKeys(Set cryptoKeysIn) {
        this.cryptoKeys = cryptoKeysIn;
    }

    /**
     * Add a CryptoKey to this kickstart
     * @param key to add
     */
    public void addCryptoKey(CryptoKey key) {
        this.cryptoKeys.add(key);
    }
    
    /**
     * Remove a crypto key from the set.
     * @param key to remove.
    */
    public void removeCryptoKey(CryptoKey key) {
        this.cryptoKeys.remove(key);
    }

    /**
     * @return the childChannels
     */
    public Set<Channel> getChildChannels() {
        return childChannels;
    }

    /**
     * @param childChannelsIn childChannels to set.
     */
    public void setChildChannels(Set childChannelsIn) {
        this.childChannels = childChannelsIn;
    }

    /**
     * Add a ChildChannel to this kickstart
     * @param childChnl to add
     */
    public void addChildChannel(Channel childChnl) {
        if (this.childChannels == null) {
            this.childChannels = new HashSet();
        }
        this.childChannels.add(childChnl);
    }

    /**
     * Remove a child Channel from the set.
     * @param childChnl to remove.
     */
    public void removeChildChannel(Channel childChnl) {
        this.childChannels.remove(childChnl);
    }

    /**
     * Adds an Token object to default.
     * Note that an ActivationKey is almost the same as a Token.  Sorry.
     * @param key Token to add
     */
    public void addDefaultRegToken(Token key) {
        defaultRegTokens.add(key);
    }

    /**
     * Getter for defaultRegTokens
     * @return Returns the packageLists.
     */
    public Set<Token> getDefaultRegTokens() {
        return defaultRegTokens;
    }

    /**
     * Setter for defaultRegTokens
     * @param p The packageLists to set.
     */
    public void setDefaultRegTokens(Set p) {
        this.defaultRegTokens = p;
    }

    /**
     * Gets the value of preserveFileLists
     *
     * @return the value of preserveFileLists
     */
    public Set getPreserveFileLists() {
        return this.preserveFileLists;
    }

    /**
     * Sets the value of preserveFileLists
     *
     * @param preserveFileListsIn set of FileList objects to assign to
     * this.preserveFileLists
     */
    public void setPreserveFileLists(Set preserveFileListsIn) {
        this.preserveFileLists = preserveFileListsIn;
    }

    /**
     * Adds a PreserveFileList object to preserveFileLists
     * @param fileList preserveFileList to add
     */
    public void addPreserveFileList(FileList fileList) {
        preserveFileLists.add(fileList);
    }

    /**
     * Remove a file list from the set.
     * @param fileList to remove.
    */
    public void removePreserveFileList(FileList fileList) {
        this.preserveFileLists.remove(fileList);
    }
    
    /**
     * Adds a KickstartPackage object to ksPackages.
     * @param kp KickstartPackage to add
     */

    public void addKsPackage(KickstartPackage kp) {
        kp.setPosition((long)ksPackages.size());
        if (this.ksPackages.add(kp)) {              // save to collection
            KickstartFactory.savePackage(kp);       // save to DB
        }
    }

    /**
     * Removes a KickstartPackage object from ksPackages.
     * @param kp KickstartPackage to remove
     */

    public void removeKsPackage(KickstartPackage kp) {
        this.ksPackages.remove(kp);
    }

    /**
     * Getter for ksPackages
     * @return Returns the ksPackages.
     */
    public Set<KickstartPackage> getKsPackages() {
        return ksPackages;
    }

    /**
     * Setter for ksPackages
     * @param p The KickstartPackage set to set.
     */
    public void setKsPackages(Set<KickstartPackage> p) {
        this.ksPackages = p;
    }
 
    /**
     * Clear all ksPackages
     */
    public void clearKsPackages() {
        for (Iterator iter = ksPackages.iterator(); iter.hasNext();) {
            // remove from DB
            KickstartFactory.removePackage((KickstartPackage)iter.next());
            // remove from collection
            iter.remove();
        }
    }

    /**
     * Get the KickstartScript of type "pre"
     * @return KickstartScript used by the Pre section.  Null if not used
     */
    public KickstartScript getPreKickstartScript() {
        return lookupScriptByType(KickstartScript.TYPE_PRE); 
    }
    
    /**
     * Get the KickstartScript of type "post" 
     * @return KickstartScript used by the post section.  Null if not used
     */
    public KickstartScript getPostKickstartScript() {
        return lookupScriptByType(KickstartScript.TYPE_POST); 
    }
    
    
    private KickstartScript lookupScriptByType(String typeIn) {
        if (this.getScripts() != null && 
            this.getScripts().size() > 0) {
            Iterator i = this.getScripts().iterator();
            while (i.hasNext()) {
                KickstartScript kss = (KickstartScript) i.next();
                if (kss.getScriptType().equals(typeIn)) {
                    return kss;
                }
            }
        } 
        return null;
    }
    
    /**
     * Getter for commands
     * @return Returns commands 
     */
    public Collection<KickstartCommand> getCommands() {
        return this.commands;
    }

    /**
     * Convenience method to detect if command is set
     * @param commandName Command name
     * @return true if found, otherwise false
     */
    public boolean hasCommand(String commandName) {
        boolean retval = false;
        if (this.commands != null && this.commands.size() > 0) {
            for (Iterator iter = this.commands.iterator(); iter.hasNext();) {
                KickstartCommand cmd = (KickstartCommand) iter.next();
                if (cmd.getCommandName().getName().equals(label)) {
                    retval = true;
                    break;
                }
            }
        }
        return retval;
    }
    
    /**
     * Convenience method to remove commands by name
     * @param commandName Command name
     * @param removeFirst if true only stop at first instance, otherwise remove all
     */
    public void removeCommand(String commandName, boolean removeFirst) {
        if (this.commands != null && this.commands.size() > 0) {
            for (Iterator iter = this.commands.iterator(); iter.hasNext();) {
                KickstartCommand cmd = (KickstartCommand) iter.next();
                if (cmd.getCommandName().getName().equals(commandName)) {
                    iter.remove();
                    if (removeFirst) {
                        break;
                    }
                }
            }
        }
    }
    
    /**
     * Convenience method to find a command by name stopping at the first match
     * @param commandName Command name
     * @return command if found, otherwise null
     */
    public KickstartCommand getCommand(String commandName) {
        KickstartCommand retval = null;
        if (this.commands != null && this.commands.size() > 0) {
            for (Iterator iter = this.commands.iterator(); iter.hasNext();) {
                KickstartCommand cmd = (KickstartCommand) iter.next();
                if (cmd.getCommandName().getName().equals(commandName)) {
                    retval = cmd;
                    break;
                }
            }
        }
        return retval;
    }

    /**
     * Setter for commands
     * @param c The Command List to set.
     */
    public void setCommands(Collection<KickstartCommand> c) {
        this.commands = c;
    }
    
    private Set <KickstartCommand> getCommandSubset(String name) {
        Set retval = new HashSet();
        if (this.commands != null && this.commands.size() > 0) {
            for (Iterator iter = this.commands.iterator(); iter.hasNext();) {
                KickstartCommand cmd = (KickstartCommand) iter.next();
                logger.debug("getCommandSubset : working with: " + 
                        cmd.getCommandName().getName());
                if (cmd.getCommandName().getName().equals(name)) {
                    logger.debug("getCommandSubset : name equals, returning");
                    retval.add(cmd);
                }
            }
        }
        logger.debug("getCommandSubset : returning: " + retval);
        return Collections.unmodifiableSet(retval);
    }
    
    
    
    /**
     * Getter for commandPartion
     * @return Returns commandPartions 
     */
    public Set getPartitions() {
        return getCommandSubset("partitions");
    }

    /**
     * Adds a Partition Command object to partitions.
     * @param p partition to add
     */
    public void addPartition(KickstartCommand p) {
        this.commands.add(p);
    }
    
    /**
     * Getter for commandIncludes
     * @return Returns commandIncludes 
     */
    public Set getIncludes() {
        return getCommandSubset("include");
    }
    
    /**
     * Getter for commandVolGroups
     * @return Returns commandVolGroups 
     */
    public Set getVolgroups() {
        return getCommandSubset("volgroups");
    }

    /**
     * Adds a include KickstartCommand volgroup object to volgroups.
     * @param v Include to add
     */
    public void addVolGroup(KickstartCommand v) {
        this.commands.add(v);
    }
     
    /**
     * Getter for commandLogVols
     * @return Returns commandLogVols 
     */
    public Set getLogvols() {
        return getCommandSubset("logvols");
    }
    
    /**
     * Adds a logvol KickstartCommand object to logvols.
     * @param l logvol to add
     */
    public void addLogVol(KickstartCommand l) {
        this.commands.add(l);
    }
    
    /**
     * Getter for command raids
     * @return Returns Kickstartcommand raids 
     */
    public Set getRaids() {
        return getCommandSubset("raids");
    }
 
    /**
     * Adds a raid KickstartCommand object to raids.
     * @param r raid to add
     */
    public void addRaid(KickstartCommand r) {
        this.commands.add(r);
    }
    
    /**
     * @return Returns the repos.
     */    
    public Set <KickstartCommand> getRepos() {
        return getCommandSubset("repo");
    }

    /**
     * Updates the repos commands associated to this ks data.  
     * @param repoCommands the repos to update
     */
    public void setRepos(Collection<KickstartCommand> repoCommands) {
        replaceSet(getRepos(), repoCommands);
    }
    
    /**
     * @return Returns the repos.
     */
    public Set<RepoInfo> getRepoInfos() {
        Set <KickstartCommand> repoCommands =  getRepos();
        Set <RepoInfo> info = new HashSet<RepoInfo>();
        for (KickstartCommand cmd : repoCommands) {
            info.add(RepoInfo.parse(cmd));
        }
        return info;
    }

    /**
     * Updates the repos commands associated to this ks data.  
     * @param repos the repos to update
     **/
    public void setRepoInfos(Collection<RepoInfo> repos) { 
        Set <KickstartCommand> repoCommands = new HashSet<KickstartCommand>();
        for (RepoInfo repo : repos) {
            KickstartCommand cmd = KickstartFactory.createKickstartCommand(this, "repo");
            repo.setArgumentsIn(cmd);
            repoCommands.add(cmd);
        }
        setRepos(repoCommands);
    }
    
    
    /**
     * @return Returns the customOptions.
     */
    public SortedSet getCustomOptions() {
        return new TreeSet(getCommandSubset("custom"));
    }
    
    /**
     * @return Returns the customOptions.
     */
    public SortedSet getCustomPartitionOptions() {
        return new TreeSet(getCommandSubset("custom_partition"));
    }


    /**
     * remove old custom options and replace with new
     * @param customIn to replace old with.
     */
    public void setCustomOptions(Collection<KickstartCommand> customIn) {
        replaceSet(this.getCustomOptions(), customIn);
    }
    
    /**
     * remove old custom partition options and replace with new
     * @param customIn to replace old with.
     */
    public void setCustomPartitionOptions(Collection<KickstartCommand> customIn) {
        replaceSet(this.getCustomPartitionOptions(), customIn);
    }

    /**
     * remove old partitions and replace with new
     * @param partitionsIn to replace old with.
     */
    public void setPartitions(Collection<KickstartCommand> partitionsIn) {
        replaceSet(this.getPartitions(), partitionsIn);
    }

    
    /**
     * remove old options and replace with new
     * @param optionsIn to replace old with.
     */
    public void setOptions(Collection<KickstartCommand> optionsIn) {
        replaceSet(this.getOptions(), optionsIn);
    }

    /**
     * remove old includes and replace with new
     * @param includesIn to replace old with.
     */
    public void setIncludes(Collection<KickstartCommand> includesIn) {
        replaceSet(this.getIncludes(), includesIn);
    }

    /**
     * remove old raids and replace with new
     * @param raidsIn to replace old with.
     */
    public void setRaids(Collection<KickstartCommand> raidsIn) {
        replaceSet(this.getRaids(), raidsIn);
    }

    /**
     * remove logvols and replace
     * @param logvolsIn to replace old with.
     */
    public void setLogvols(Collection<KickstartCommand> logvolsIn) {
        replaceSet(this.getLogvols(), logvolsIn);
    }

    /**
     * remove old options and replace with new
     * @param volgroupsIn to replace old with.
     */
    public void setVolgroups(Collection<KickstartCommand> volgroupsIn) {
        replaceSet(this.getVolgroups(), volgroupsIn);
    }

    private void replaceSet(Collection<KickstartCommand> oldSet,
            Collection<KickstartCommand> newSet) {
        logger.debug("replaceSet co.pre: " + this.getCustomOptions());
        this.commands.removeAll(oldSet);
        logger.debug("replaceSet co.post: " + this.getCustomOptions());
        this.commands.addAll(newSet);
        logger.debug("replaceSet co.done: " + this.getCustomOptions());
    }
    
    /**
     * Getter for command options
     * @return Returns Kickstartcommand options 
     */
    public Set<KickstartCommand> getOptions() {
        // 'partitions', 'raids', 'logvols', 'volgroups', 'include', 'repo', 'custom'
        logger.debug("returning all commands except: " + ADANCED_OPTIONS);
        Set retval = new HashSet();
        if (this.commands != null && this.commands.size() > 0) {
            for (Iterator iter = this.commands.iterator(); iter.hasNext();) {
                KickstartCommand cmd = (KickstartCommand) iter.next();
                logger.debug("working with: " + cmd.getCommandName().getName());
                if (!ADANCED_OPTIONS.contains(cmd.getCommandName().getName())) {
                    logger.debug("not contained within filtered list. adding to retval");
                    retval.add(cmd);
                }
            }
        }
        logger.debug("returning: " + retval);
        return Collections.unmodifiableSet(retval);
    }
    
    /**
     * @return the download url suffix
     */
    public String getUrl() {
        for (KickstartCommand c : getOptions()) {
            if (c.getCommandName().getName().equals("url")) {
                Matcher match = URL_REGEX.matcher(c.getArguments());
                if (match.find()) {
                    return match.group(1);
                }
            }
        }
        return "";
    }
     
    /**
     * 
     * @param kd KickstartDefaults to set
     */
    public void setKickstartDefaults(KickstartDefaults kd) {
        this.kickstartDefaults = kd;
    }
    
    /**
     * 
     * @return the Kickstart Defaults assoc w/this Kickstart
     */
    public KickstartDefaults getKickstartDefaults() {
        return this.kickstartDefaults;
    }
        
    /**
     * Conv method 
     * @return Install Type for Kickstart
     */
    public KickstartInstallType getInstallType() {
        if (this.getTree() != null) {
            return getTree().getInstallType(); 
        }   
        return null;
    }

    /**
     * @return if this kickstart profile is rhel  installer type
     */
    public boolean isRhel() {
        if (getInstallType() != null) {
            return getInstallType().isRhel();
        }
        return false;
    }
    
    /**
     * @return if this kickstart profile is rhel 5 installer type
     */
    public boolean isRhel5() {
        if (getInstallType() != null) {
            return getInstallType().isRhel5();
        }
        else {
            return false;
        }
    }

    /**
     * @return if this kickstart profile is rhel 5 installer type or greater (for rhel6)
     */
    public boolean isRhel5OrGreater() {
        if (getInstallType() != null) {
            return (getInstallType().isRhel5OrGreater() || 
                    getInstallType().isFedora());
        }
        else {
            return false;
        }
    }

    /**
     * returns true if this is a fedora kickstart
     * @return if this is a fedora kickstart or not
     */
    public boolean isFedora() {
        if (getInstallType() != null) {
            return getInstallType().isFedora();
        }
        else {
            return false;
        }
    }

    /**
     * returns true if this is a generic kickstart
     * as in non rhel and non fedora.
     * @return if this is a generic kickstart or not
     */
    public boolean isGeneric() {
        if (getInstallType() != null) {
            return getInstallType().isGeneric();
        }
        else {
            return false;
        }
    }
        
    /**
     * @return if this kickstart profile is rhel 4 installer type
     */
    public boolean isRhel4() {
        if (getInstallType() != null) {
            return getInstallType().isRhel4();
        }
        else {
            return false;
        }
    }

    /**
     * @return if this kickstart profile is rhel 3 installer type
     */
    public boolean isRhel3() {
        if (getInstallType() != null) {
            return getInstallType().isRhel3();
        }
        else {
            return false;
        }
    }
    
    /**
     * 
     * @return if this kickstart profile is rhel 2 installer type
     */
    public boolean isRhel2() {
        if (getInstallType() != null) {
            return getInstallType().isRhel2();
        }
        else {
            return false;
        }
    }

    /**
     * 
     * @return Set of IpRanges for Kickstart
     */
    public Set<KickstartIpRange> getIps() {
        return ips;
    }

    /**
     * 
     * @param ipsIn Set of IPRanges to set
     */
    public void setIps(Set ipsIn) {        
        this.ips = ipsIn;
    }    
    
    /**
     * 
     * @param ipIn KickstartIpRange to add
     */
    public void addIpRange(KickstartIpRange ipIn) {
        ips.add(ipIn);
    }

    /**
     * Convenience method to get the KickstartableTree object
     * @return KickstartableTree object associated with this KSData.
     */
    public KickstartableTree getTree() {
        if (this.getKickstartDefaults() != null) {
            return this.getKickstartDefaults().getKstree();
        }
        return null;
    }

    /**
     * Setter for KickstartableTree object
     * @param kstreeIn the KickstartableTree to set
     */
    public void setTree(KickstartableTree kstreeIn) {
        this.getKickstartDefaults().setKstree(kstreeIn);
    }
     
    /**
     * @return the scripts
     */
    public Set<KickstartScript> getScripts() {
        return scripts;
    }

    
    /**
     * @param scriptsIn The scripts to set.
     */
    public void setScripts(Set scriptsIn) {
        this.scripts = scriptsIn;
    }

    /**
     * Add a KickstartScript to the KickstartData
     * @param ksIn to add
     */
    public void addScript(KickstartScript ksIn) {
        // Calc the max position and add this script at the end
        Iterator i = scripts.iterator();
        long maxPosition = 0;
        while (i.hasNext()) {
            KickstartScript kss = (KickstartScript) i.next();
            if (kss.getPosition().longValue() > maxPosition) {
                maxPosition = kss.getPosition().longValue();
            }
        }
        ksIn.setPosition(new Long(maxPosition + 1));
        ksIn.setKsdata(this);
        
        scripts.add(ksIn);
    }
    
    /**
     * Remove a KickstartScript from this Profile.
     * @param ksIn to remove.
     */
    public void removeScript(KickstartScript ksIn) {
        scripts.remove(ksIn);
    }


    /**
     * Is ELILO required for this kickstart profile?
     * We base this off of the channel arch, because IA64 systems
     * require elilo
     * @return boolean - required, or not
     */
    public boolean getEliloRequired() {
        return this.getKickstartDefaults().getKstree().getChannel()
            .getChannelArch().getLabel().equals("channel-ia64");
    }

    /**
     * Get the bootloader type
     *
     * @return String: lilo or grub
     */
    public String getBootloaderType() {
        KickstartCommand bootloaderCommand = this.getCommand("bootloader");

        if (bootloaderCommand == null || bootloaderCommand.getArguments() == null) {
            return "grub";
        }

        String regEx = ".*--useLilo.*";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(bootloaderCommand.getArguments());

        if (matcher.matches()) {
            return "lilo";
        }
        else {
            return "grub";
        }
    }
    
    /**
     * Changes the bootloader
     * @param type either "grub" or "lilo"
     * @return true if changed, false otherwise
     */
    public boolean changeBootloaderType(String type) {
        boolean retval = false;
        KickstartCommand bootloaderCommand = this.getCommand("bootloader");
        if (bootloaderCommand != null) {
            retval =  true;
            bootloaderCommand.setArguments(
                    bootloaderCommand.getArguments().replaceAll(
                            "--useLilo", "").trim());            
            if (type.equalsIgnoreCase("lilo")) {
                bootloaderCommand.setArguments(bootloaderCommand.getArguments() + 
                        " --useLilo");
            }
        }
        
        return retval;
    }
    
    /**
     * Convenience method to get the Channel associated with this profile
     * KickstartData -> KickstartDefault -> KickstartTree -> Channel
     * @return Channel object associated with this KickstartData
     */
    public Channel getChannel() {
        if (this.kickstartDefaults != null) {
            if (this.kickstartDefaults.getKstree() != null) {
                return this.kickstartDefaults.getKstree().getChannel();
            }
        }
        return null;
    }

    /**
     * Get the timezone - just the timezone, not the --utc or other args
     *
     * @return String: The timezone (like "Asia/Qatar")
     */
    public String getTimezone() {
        KickstartCommand tzCommand = this.getCommand("timezone");

        // my @args = grep { not /--/ } split / /, $tzCommand;
        // return @args ? $args[0] : "";

        if (tzCommand == null || tzCommand.getArguments() == null) {
            return "";
        }

        LinkedList tokens =
            (LinkedList) StringUtil.stringToList(tzCommand.getArguments());

        Iterator iter = tokens.iterator();

        while (iter.hasNext()) {
            String token = (String) iter.next();

            if (!token.startsWith("--")) {
                return token;
            }
        }

        return null;
    }

    /**
     * Will the system hardware clock use UTC
     *
     * @return Boolean Are we using UTC?
     */
    public Boolean isUsingUtc() {
        KickstartCommand tzCommand = this.getCommand("timezone");

        if (tzCommand == null || tzCommand.getArguments() == null) {
            return Boolean.FALSE;
        }

        LinkedList tokens =
            (LinkedList) StringUtil.stringToList(tzCommand.getArguments());

        Iterator iter = tokens.iterator();

        while (iter.hasNext()) {
            String token = (String) iter.next();

            if (token.equals("--utc")) {
                return Boolean.TRUE;
            }
        }

        return Boolean.FALSE;
    }

    /**
     * Copy this KickstartData into a new one.  NOTE:  We don't clone
     * the following sub-objects:
     * 
     * KickstartIpRange
     * 
     * NOTE: We also don't clone isOrgDefault.
     * 
     * @param user who is doing the cloning
     * @param newLabel to set on the cloned object
     * @return KickstartData that is cloned.
     */
    public KickstartData deepCopy(User user, String newLabel) {
        KickstartData cloned = new KickstartData();
        updateCloneDetails(cloned, user, newLabel);
        return cloned;
    }
    
    protected void updateCloneDetails(KickstartData cloned, User user, 
                                    String newLabel) {
        cloned.setLabel(newLabel);
        cloned.setActive(this.isActive());
        cloned.setPostLog(this.getPostLog());
        cloned.setPreLog(this.getPreLog());
        cloned.setKsCfg(this.getKsCfg());
        cloned.setComments(this.getComments());
        cloned.setNonChrootPost(this.getNonChrootPost());
        cloned.setVerboseUp2date(this.getVerboseUp2date());
        cloned.setOrg(this.getOrg());
        cloned.setChildChannels(new HashSet(this.getChildChannels()));
        
        if (this.getCommands() != null) {
            Iterator i = this.getCommands().iterator();
            while (i.hasNext()) {
                KickstartCommand cmd = (KickstartCommand) i.next();
                KickstartCommand clonedCmd = cmd.deepCopy(cloned);
                cloned.addCommand(clonedCmd);
            }
        }
        
        // Gotta remember to create a new HashSet with
        // the other objects.  Otherwise hibernate will
        // complain that you are using the same collection
        // in two objects.
        if (this.getCryptoKeys() != null) {
            cloned.setCryptoKeys(new HashSet(this.getCryptoKeys()));
        }
        
        if (this.getDefaultRegTokens() != null) {
            cloned.setDefaultRegTokens(new HashSet(this.getDefaultRegTokens()));
        }

        // NOTE: Make sure we *DONT* clone isOrgDefault
        cloned.setIsOrgDefault(Boolean.FALSE);
        cloned.setKernelParams(this.getKernelParams());
        if (this.getKickstartDefaults() != null) {
            cloned.setKickstartDefaults(this.getKickstartDefaults().deepCopy(cloned));
        }
        cloned.setOrg(this.getOrg());
        for (KickstartPackage kp : this.getKsPackages()) {
            cloned.getKsPackages().add(kp.deepCopy(cloned));
        }
        
        if (this.getPreserveFileLists() != null) {
            cloned.setPreserveFileLists(new HashSet(this.getPreserveFileLists()));
        }
        
        if (this.getScripts() != null) {
            Iterator i = this.getScripts().iterator();
            while (i.hasNext()) {
                KickstartScript kss = (KickstartScript) i.next();
                KickstartScript ksscloned = kss.deepCopy(cloned);
                cloned.addScript(ksscloned);   
            }
        }
    }
    
    // Helper method to copy KickstartCommands
    private static void copyKickstartCommands(Set commands, KickstartData cloned) {
        if (commands != null) {
            Iterator i = commands.iterator();
            while (i.hasNext()) {
                KickstartCommand cmd = (KickstartCommand) i.next();
                KickstartCommand clonedCmd = cmd.deepCopy(cloned);
                cloned.addCommand(clonedCmd);
            }
        }
    }
    
    /**
     * Add a kickstartCommand object
     * @param clonedCmd The kickstartCommand to add
     */
    public void addCommand(KickstartCommand clonedCmd) {
        commands.add(clonedCmd);
    }
    
    /**
     * Util method to determine if we are RHEL3/2.1
     * @return boolean if this KickstartData is using RHEL2.1 or RHEL3
     */
    public boolean isLegacyKickstart() {
        if (this.getTree() != null && this.getTree().getInstallType() != null) {
            String installType = this.getTree().getInstallType().getLabel();
            return (installType.equals(KickstartInstallType.RHEL_21) ||
                    installType.equals(KickstartInstallType.RHEL_3));
        }
        else {
            return false;
        }
    }
        
    /**
     * Bean wrapper so we can call isLegacyKickstart() from JSTL
     * @return boolean if this KickstartData is using RHEL2.1 or RHEL3
     */
    public boolean getLegacyKickstart() {
        return isLegacyKickstart();
    }

    /**
     * Get the name of the kickstart package this KS will use.
     * @return String kickstart package like auto-kickstart-ks-rhel-i386-as-4
     */
    public String getKickstartPackageName() {
        return ConfigDefaults.get().getKickstartPackageName();

    }
    
    /**
     * @return Returns if the post scripts should be logged.
     */
    public Boolean getPostLog() {
        return postLog;
    }

    /**
     * @return Returns if the pre scripts should be logged.
     */
    public Boolean getPreLog() {
        return preLog;
    }

    /**
     * @return Returns if we should copy ks.cfg and %include'd fragments to /root
     */
    public Boolean getKsCfg() {
        return ksCfg;
    }
    
    /**
     * @param postLogIn The postLog to set.
     */
    public void setPostLog(Boolean postLogIn) {
        this.postLog = postLogIn;
    }

    /**
     * @param preLogIn The preLog to set.
     */
    public void setPreLog(Boolean preLogIn) {
        this.preLog = preLogIn;
    }

    /**
     * @param ksCfgIn The ksCfg to set.
     */
    public void setKsCfg(Boolean ksCfgIn) {
        this.ksCfg = ksCfgIn;
    }
    
    /**
     * Returns the SE Linux mode associated to this kickstart profile
     * @return the se linux mode or the default SE Liunx mode (i.e. enforcing)..
     */
    public SELinuxMode getSELinuxMode() {
        KickstartCommand cmd = getCommand(SELINUX_MODE_COMMAND);
        if (cmd != null) {
            String args = cmd.getArguments();
            if (!StringUtils.isBlank(args)) {
                if (args.endsWith(SELinuxMode.PERMISSIVE.getValue())) {
                    return SELinuxMode.PERMISSIVE;
                }
                else if (args.endsWith(SELinuxMode.ENFORCING.getValue())) {
                    return SELinuxMode.ENFORCING;
                }
                else if (args.endsWith(SELinuxMode.DISABLED.getValue())) {
                    return SELinuxMode.DISABLED;
                }
            }
        }
        return SELinuxMode.ENFORCING;
    }
    
    /**
     * True if config management is enabled in this profile..
     * @return True if config management is enabled in this profile..
     */
    public boolean isConfigManageable() {
        return getKickstartDefaults() != null && 
            getKickstartDefaults().getCfgManagementFlag();
    }
    
    /**
     * True if remote command flag is  enabled in this profile..
     * @return True if remote command flag is  enabled in this profile..
     */
    public boolean isRemoteCommandable() {
        return getKickstartDefaults() != null && 
            getKickstartDefaults().getRemoteCommandFlag();
    }
    
    /**
     * @return the cobblerName
     */
    public String getCobblerFileName() {
        if (getCobblerId() != null) {
            Profile prof = Profile.lookupById(
                   CobblerXMLRPCHelper.getConnection(
                   Config.get().getString(ConfigDefaults.COBBLER_AUTOMATED_USER)), 
                       getCobblerId());
            if (prof != null && !StringUtils.isBlank(prof.getKickstart())) {
                return prof.getKickstart();
            }
        }

        String path = "";

        if (isRawData()) {
            return CobblerCommand.makeCobblerFileName(RAW_DIR + "/" + getLabel(), getOrg());
        }
        else {
            return CobblerCommand.makeCobblerFileName(WIZARD_DIR + "/" + getLabel(),
                    getOrg());
        }
    }
    

    /**
     * @return Returns if up2date/yum should be verbose
     */
    public Boolean getVerboseUp2date() {
        return this.verboseUp2date;
    }

    /**
     * @param verboseup2dateIn The verboseup2date to set.
     */
    public void setVerboseUp2date(Boolean verboseup2dateIn) {
        this.verboseUp2date = verboseup2dateIn;
    }

    /**
     * @return Returns if nonchroot post script is to be logged
     */
    public Boolean getNonChrootPost() {
        return this.nonChrootPost;
    }


    /**
     * @param nonchrootpostIn The nonchrootpost to set.
     */
    public void setNonChrootPost(Boolean nonchrootpostIn) {
        this.nonChrootPost = nonchrootpostIn;
    }
    
    /**
     * Returns true if this is a 
     * raw mode data .
     * @return true or false.
     */
    public boolean isRawData() {
        return false;
    }
    
    /**
     * Return the string containing the kickstart file 
     * @param host the kickstart host
     * @param session the kickstart session,
     *               can be null if the data 
     *               is not part of a session 
     * @return String containing kickstart file
     */
    public String getFileData(String host, 
                    KickstartSession session) {
        KickstartFormatter formatter = new KickstartFormatter(host, this, session);
        return formatter.getFileData();
    }

    
    /**
     * @return Returns the cobblerId.
     */
    public String getCobblerId() {
        return cobblerId;
    }

    
    /**
     * @param cobblerIdIn The cobblerId to set.
     */
    public void setCobblerId(String cobblerIdIn) {
        this.cobblerId = cobblerIdIn;
    }

    
    /**
     * @return the kickstartType
     */
    protected String getKickstartType() {
        return kickstartType;
    }

    
    /**
     * @param kickstartTypeIn the kickstartType to set
     */
    protected void setKickstartType(String kickstartTypeIn) {
        this.kickstartType = kickstartTypeIn;
    }
    
    /**
     * Get the default virt bridge for this KickstartData object.
     * 
     * @return String virt bridge (xenbr0, virbr0)
     */
    public String getDefaultVirtBridge() {
        if (this.getKickstartDefaults().getVirtualizationType().getLabel()
                .equals(KickstartVirtualizationType.KVM_FULLYVIRT)) {
            return ConfigDefaults.get().getDefaultKVMVirtBridge();
        } 
        else {
            return ConfigDefaults.get().getDefaultXenVirtBridge();
        }
    }

    /**
     * Returns the cobbler object associated to 
     * to this profile.
     * @param user the user object needed for connection,
     *              enter null if you want to use the 
     *              automated connection as provided by
     *              taskomatic.
     * @return the Profile associated to this ks data
     */
    public Profile getCobblerObject(User user) {
        if (StringUtils.isBlank(getCobblerId())) {
            return null;
        }
        CobblerConnection con;
        if (user == null) {
            con = CobblerXMLRPCHelper.getAutomatedConnection();
        }
        else {
            con = CobblerXMLRPCHelper.getConnection(user);
        }
        return Profile.lookupById(con, getCobblerId());
    }

    /**
     * Method to determine if the profile
     * is valid or if it needs to be corrected.
     * @return true if the profile is synced to cobbler
     * and the distro it hosts is valid.
     */
    public boolean isValid() {
        return !StringUtils.isBlank(getCobblerId()) && getTree().isValid(); 
    }
}
