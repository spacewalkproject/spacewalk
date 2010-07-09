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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.user.UserManager;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * NewChannelHelper
 * Class to help in cloning a channel
 * @version $Rev$
 */
public class NewChannelHelper {

    //required
    private String name;
    private String label;
    private ChannelArch arch;
    private String summary;
    private User user;

    //optional
    private Channel parent;
    private String gpgId;
    private String gpgUrl;
    private String gpgFingerprint;
    private String description;

    /**
     * Creates a cloned channel based off the info contained within this object
     *      and the packages in the toClone
     * @param originalState if false clone all packages and errata, if true
     *      only clone the original packages and no errata
     * @param toClone the channel to clone
     * @return the cloned channel
     */
    public Channel clone(boolean originalState, Channel toClone) {

        if (!verifyName(name)) {
            throw new InvalidChannelParameter(name, "It must be at least 6 characters " +
                    "long, begin with a letter, and contain only lowercase letters, " +
                    "digits, '-', ' / ', '_' and '.'.  Also, it cannot begin with " +
                    "'rhn', 'redhat', or 'red hat'.");
        }

        if (!verifyLabel(label)) {
            throw new InvalidChannelParameter(label, "It Must  be at least 6 characters " +
                    "long, begin with a letter, and contain only lowercase letters, " +
                    "digits, '-', '_', and '.'.  Also, it cannot begin with 'rhn', " +
                    "'redhat', or 'red hat'.");
        }

        if (gpgFingerprint != null && !verifyGpgFingerprint(gpgFingerprint)) {
             throw new InvalidChannelParameter("GPG Fingerprint", "The GPG fingerprint " +
                    "must be of form 'CA20 8686 2BD6 9DFC 65F6 ECC4 2191 80CD DB42 A60E'");
        }

        if (gpgUrl != null && !verifyGpgUrl(gpgUrl)) {
            throw new InvalidChannelParameter("GPG Url", "The GPG URL must be a" +
                    " valid URL");
        }

        if (gpgId != null && !verifyGpgId(gpgId)) {
            throw new InvalidChannelParameter("GPG Id", "The GPG id must be of form " +
                    "'DB42A60E'");
        }

        ClonedChannel cloned = new ClonedChannel();
        cloned.setName(name);
        cloned.setLabel(label);
        cloned.setChannelArch(arch);
        cloned.setSummary(summary);
        cloned.setGPGKeyUrl(gpgUrl);
        cloned.setGPGKeyId(gpgId);
        cloned.setGPGKeyFp(gpgFingerprint);
        cloned.setDescription(description);
        cloned.setCreated(new Date());
        cloned.setOrg(user.getOrg());
        cloned.setBaseDir("/dev/null");  //this is how the perl code did it
        cloned.setOriginal(toClone);

        if (parent != null) {
           cloned.setParentChannel(parent);
        }
        //must save and reload the object here, in order to further work with it
        ChannelFactory.save(cloned);
        cloned = (ClonedChannel)ChannelFactory.reload(cloned);

        cloned.setGloballySubscribable(true, cloned.getOrg());

        if (originalState) {
            List originalPacks = ChannelFactory.findOriginalPackages(toClone,
                    user.getOrg());
            Long clonedChannelId = cloned.getId();
            for (Iterator it = originalPacks.iterator(); it.hasNext();) {
                Long pid = (Long) it.next();
                if (UserManager.verifyPackageAccess(user.getOrg(), pid)) {
                   ChannelFactory.addChannelPackage(clonedChannelId, pid);
                }
            }
        }
        else {
            cloned.getPackages().addAll(toClone.getPackages());
            cloned.getErratas().addAll(toClone.getErratas());
        }

        //adopt the channel into the org's channelfamily
        ChannelFamily family = ChannelFamilyFactory.lookupOrCreatePrivateFamily(
            user.getOrg());

        family.getChannels().add(cloned);
        cloned.setChannelFamily(family);

        // Mark the affected channel to have it's metadata evaluated, where necessary
        // (RHEL5+, mostly)
        ChannelManager.queueChannelChange(label, "java::cloneChannel", null);

        return cloned;
    }


    /**
     * Verifies a potential name for a channel
     * @param name the name of the channel
     * @return true if it is correct, false otherwise
     */
    public static boolean verifyName(String name) {

        if (name.length() < 6) {
            return false;
        }

        Pattern pattern = Pattern.compile("^(rhn|red\\s*hat).*", Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(name);
        if (match.matches()) {
            return false;
        }
        pattern = Pattern.compile("^[a-z][\\w\\d\\s\\-\\.\\'\\(\\)\\/\\_]*$",
                Pattern.CASE_INSENSITIVE);
        match = pattern.matcher(name);
        if (!match.matches()) {
            return false;
        }
        return true;

    }

    /**
     * Verifies a potential label for a channel
     * @param label the label of the channel
     * @return true if it is correct, false otherwise
     */
    public static boolean verifyLabel(String label) {
        if (label.length() < 6) {
            return false;
        }

        Pattern pattern = Pattern.compile("^(rhn|red\\s*hat).*", Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(label);
        if (match.matches()) {
            return false;
        }

        pattern = Pattern.compile("^[a-z][a-z\\d\\-\\.\\_]*$", Pattern.CASE_INSENSITIVE);
        match = pattern.matcher(label);
        if (!match.matches()) {
            return false;
        }

        return true;
    }

    /**
     * Verifies a potential GPG Fingerprint for a channel
     * @param gpgFp the gpg fingerprint of the channel
     * @return true if it is correct, false otherwise
     */
    public static boolean verifyGpgFingerprint(String gpgFp) {
        Pattern pattern = Pattern.compile("^(\\s*[0-9A-F]{4}\\s*){10}$",
                Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(gpgFp);
        return match.matches();
    }

    /**
     * Verifies a potential GPG ID for a channel
     * @param gpgId the gpg id of the channel
     * @return true if it is correct, false otherwise
     */
    public static boolean verifyGpgId(String gpgId) {
        Pattern pattern = Pattern.compile("^[0-9A-F]{8}$", Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(gpgId);
        return match.matches();
    }

    /**
     * Verifies a potential GPG URL for a channel
     * @param gpgUrl the gpg url of the channel
     * @return true if it is correct, false otherwise
     */
    public static boolean verifyGpgUrl(String gpgUrl) {
        Pattern pattern = Pattern.compile("^(http[s]*|file)?\\://.*?$",
                Pattern.CASE_INSENSITIVE);
        Matcher match = pattern.matcher(gpgUrl);
        return match.matches();
    }


    /**
     * @param archIn The arch to set.
     */
    public void setArch(ChannelArch archIn) {
        this.arch = archIn;
    }

    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * @param gpgFingerprintIn The gpgFingerprint to set.
     */
    public void setGpgFingerprint(String gpgFingerprintIn) {
        this.gpgFingerprint = gpgFingerprintIn;
    }

    /**
     * @param gpgIdIn The gpgId to set.
     */
    public void setGpgId(String gpgIdIn) {
        this.gpgId = gpgIdIn;
    }

    /**
     * @param gpgUrlIn The gpgUrl to set.
     */
    public void setGpgUrl(String gpgUrlIn) {
        this.gpgUrl = gpgUrlIn;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @param parentIn The parent to set.
     */
    public void setParent(Channel parentIn) {
        this.parent = parentIn;
    }

    /**
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }

    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        this.user = userIn;
    }




}
