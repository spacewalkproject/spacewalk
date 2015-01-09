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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.errata.Errata;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.channel.InvalidGPGFingerprintException;
import com.redhat.rhn.manager.errata.ErrataManager;
import com.redhat.rhn.manager.user.UserManager;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;

import org.apache.commons.lang.StringUtils;

import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * NewChannelHelper
 * Class to help in cloning a channel
 * @version $Rev$
 */
@Deprecated
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
    private ProductName productName;
    private String maintainerName;
    private String maintainerEmail;
    private String maintainerPhone;
    private String supportPolicy;
    private String access;
    private ChecksumType checksumType;

    /**
     * Creates a cloned channel based off the info contained within this object
     *      and the packages in the toClone
     * @param originalState if false clone all packages and errata, if true
     *      only clone the original packages and no errata
     * @param toClone the channel to clone
     * @return the cloned channel
     */
    @Deprecated
    public Channel clone(boolean originalState, Channel toClone) {

        if (!verifyName(name)) {
            throw new InvalidChannelNameException(name,
                    InvalidChannelNameException.Reason.REGEX_FAILS,
                    "edit.channel.invalidchannelname.supportedregex", "");
        }

        if (!verifyLabel(label)) {
            throw new InvalidChannelLabelException(label,
                    InvalidChannelLabelException.Reason.REGEX_FAILS,
                    "edit.channel.invalidchannellabel.supportedregex", "");
        }

        if (summary == null || StringUtils.isEmpty(summary)) {
            throw new InvalidChannelParameter("Summary", "Summary must be provided.");
        }

        if (gpgFingerprint != null && !verifyGpgFingerprint(gpgFingerprint)) {
            throw new InvalidGPGFingerprintException();
        }

        if (gpgUrl != null && !verifyGpgUrl(gpgUrl)) {
            throw new InvalidGPGUrlException();
        }

        if (gpgId != null && !verifyGpgId(gpgId)) {
            throw new InvalidGPGKeyException();
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
        cloned.setProductName(productName);
        cloned.setMaintainerName(maintainerName);
        cloned.setMaintainerEmail(maintainerEmail);
        cloned.setMaintainerPhone(maintainerPhone);
        cloned.setSupportPolicy(supportPolicy);
        cloned.setAccess(access);
        cloned.setChecksumType(checksumType);

        if (parent != null) {
           cloned.setParentChannel(parent);
            List<Map<String, String>> compatibleArches = ChannelManager
                    .compatibleChildChannelArches(parent.getChannelArch().getLabel());
            Set<String> compatibleArchLabels = new HashSet<String>();

            for (Map<String, String> compatibleArch : compatibleArches) {
                compatibleArchLabels.add(compatibleArch.get("label"));
            }

            if (!compatibleArchLabels.contains(arch.getLabel())) {
                throw new IllegalArgumentException(
                        "Incompatible parent and child channel architectures");
            }
        }
        //must save and reload the object here, in order to further work with it
        ChannelFactory.save(cloned);
        cloned = (ClonedChannel)ChannelFactory.reload(cloned);

        cloned.setGloballySubscribable(true, cloned.getOrg());

        if (originalState) {
            List<Long> originalPacks = ChannelFactory.findOriginalPackages(toClone);
            Long clonedChannelId = cloned.getId();
            for (Long pid : originalPacks) {
                if (UserManager.verifyPackageAccess(user.getOrg(), pid)) {
                   ChannelFactory.addChannelPackage(clonedChannelId, pid);
                }
            }
        }
        else {
            cloned.getPackages().addAll(toClone.getPackages());
            ErrataManager.publishErrataToChannelAsync(cloned,
                    getErrataIds(toClone.getErratas()), user);
        }

        //adopt the channel into the org's channelfamily
        ChannelFamily family = ChannelFamilyFactory.lookupOrCreatePrivateFamily(
            user.getOrg());

        family.getChannels().add(cloned);
        cloned.setChannelFamily(family);

        return cloned;
    }

    private Set<Long> getErrataIds(Set<Errata> errata) {
        Set<Long> ids = new HashSet();
        for (Errata erratum : errata) {
            ids.add(erratum.getId());
        }
        return ids;
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

        pattern = Pattern.compile("^[a-z\\d][a-z\\d\\-\\.\\_]*$", Pattern.CASE_INSENSITIVE);
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
     * @param productNameIn Product name to set.
     */
    public void setProductName(ProductName productNameIn) {
        this.productName = productNameIn;
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

    /**
     * @return the maintainer name
     */
    public String getMaintainerName() {
        return maintainerName;
    }

    /**
     * @param maintainerNameIn the maintainer name to set
     */
    public void setMaintainerName(String maintainerNameIn) {
        this.maintainerName = maintainerNameIn;
    }

    /**
     * @return the maintainer email
     */
    public String getMaintainerEmail() {
        return maintainerEmail;
    }

    /**
     * @param maintainerEmailIn the maintainer email to set
     */
    public void setMaintainerEmail(String maintainerEmailIn) {
        this.maintainerEmail = maintainerEmailIn;
    }

    /**
     * @return the maintainer phone
     */
    public String getMaintainerPhone() {
        return maintainerPhone;
    }

    /**
     * @param maintainerPhoneIn the maintainer phone to set
     */
    public void setMaintainerPhone(String maintainerPhoneIn) {
        this.maintainerPhone = maintainerPhoneIn;
    }

    /**
     * @return the support policy
     */
    public String getSupportPolicy() {
        return supportPolicy;
    }

    /**
     * @param supportPolicyIn the support policy to set
     */
    public void setSupportPolicy(String supportPolicyIn) {
        this.supportPolicy = supportPolicyIn;
    }

    /**
     * @return the access
     */
    public String getAccess() {
        return access;
    }

    /**
     * @param accessIn the access to set
     */
    public void setAccess(String accessIn) {
        this.access = accessIn;
    }

    /**
     * @return the checksum type
     */
    public ChecksumType getChecksumType() {
        return checksumType;
    }

    /**
     * @param checksumTypeIn the checksum type to set
     */
    public void setChecksumType(ChecksumType checksumTypeIn) {
        this.checksumType = checksumTypeIn;
    }

}
