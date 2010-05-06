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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.taskomatic.task.RepoSyncTask;

import org.apache.commons.lang.StringUtils;

import java.util.regex.Pattern;

/**
 * CreateChannelCommand - command to create a new channel.
 * @version $Rev$
 */
public class CreateChannelCommand {

    public static final int CHANNEL_NAME_MIN_LENGTH = 6;
    public static final int CHANNEL_NAME_MAX_LENGTH = 64;
    public static final int CHANNEL_LABEL_MIN_LENGTH = 6;

    protected static final String CHANNEL_NAME_REGEX =
        "^[a-zA-Z\\d][\\w\\d\\s\\-\\.\\'\\(\\)\\/\\_]*$";
    protected static final String CHANNEL_LABEL_REGEX =
        "^[a-z\\d][a-z\\d\\-\\.\\_]*$";

    // we ignore case with the red hat regex
    protected static final String REDHAT_REGEX = "^(rhn|red\\s*hat)";
    protected static final String GPG_KEY_REGEX = "^[0-9A-F]{8}$";
    protected static final String GPG_URL_REGEX = "^(https?|file)://.*?$";
    protected static final String GPG_FP_REGEX = "^(\\s*[0-9A-F]{4}\\s*){10}$";
    protected static final String WEB_CHANNEL_CREATED = "web.channel_created";
    
    protected User user;
    protected String label;
    protected String name;
    protected String summary;
    protected String description;
    protected String archLabel;
    protected String parentLabel;
    protected Long parentId;
    protected String gpgKeyUrl;
    protected String gpgKeyId;
    protected String gpgKeyFp;
    protected String checksum;
    

    protected String maintainerName;
    protected String maintainerEmail;
    protected String maintainerPhone;
    protected String supportPolicy;
    protected String access = Channel.PRIVATE;
    protected String yumUrl;
    protected String repoLabel;
    protected boolean syncRepo = false;
    

    


    /**
     * default constructor.
     */
    public CreateChannelCommand() {
        user = null;
        label = null;
        name = null;
        summary = null;
        archLabel = null;
        checksum = null;
        parentLabel = null;
        parentId = null;
    }

    /**
     * @param archLabelIn The archLabel to set.
     */
    public void setArchLabel(String archLabelIn) {
        archLabel = archLabelIn;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        name = nameIn;
    }

    /**
     * @param checksumIn The name to set.
     */
    public void setChecksum(String checksumIn) {
        this.checksum = checksumIn;
    }

    /**
     * @param parentLabelIn The parentLabel to set.
     */
    public void setParentLabel(String parentLabelIn) {
        parentLabel = parentLabelIn;
    }

    /**
     * @param pid The parent id to set.
     */
    public void setParentId(Long pid) {
        parentId = pid;
    }
    
    
    /**
     * @param fp gpgkey fingerprint
     */
    public void setGpgKeyFp(String fp) {
        gpgKeyFp = fp;
    }

    
    /**
     * @param id gpgkey id
     */
    public void setGpgKeyId(String id) {
        gpgKeyId = id;
    }

    
    /**
     * @param url gpgkey url
     */
    public void setGpgKeyUrl(String url) {
        gpgKeyUrl = url;
    }

    
    /**
     * @param email maintainer's email address
     */
    public void setMaintainerEmail(String email) {
        maintainerEmail = email;
    }

    
    /**
     * @param mname maintainers name
     */
    public void setMaintainerName(String mname) {
        maintainerName = mname;
    }

    /**
     * @param phone maintainer's phone number (string)
     */
    public void setMaintainerPhone(String phone) {
        maintainerPhone = phone;
    }

    
    /**
     * @param policy support policy
     */
    public void setSupportPolicy(String policy) {
        supportPolicy = policy;
    }

    /**
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        summary = summaryIn;
    }

    /**
     * @param desc The description.
     */
    public void setDescription(String desc) {
        description = desc;
    }

    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        user = userIn;
    }

    /**
     * @param acc public, protected, or private
     */
    public void setAccess(String acc) {
        if (acc == null || acc.equals("")) {
            access = Channel.PRIVATE;
        }
        else {
            access = acc;
        }
    }

    /**
     * Creates the Channel based on the parameters that were set.
     * @return the newly created Channel
     * @throws InvalidChannelLabelException thrown if label is in use or invalid.
     * @throws InvalidChannelNameException throw if name is in use or invalid.
     * @throws IllegalArgumentException thrown if label, name or user are null.
     * @throws InvalidParentChannelException thrown if parent label is not a
     * valid base channel.
     */
    public Channel create()
        throws InvalidChannelLabelException, InvalidChannelNameException,
        InvalidParentChannelException {

        verifyRequiredParameters();
        verifyChannelName(name);
        verifyChannelLabel(label);
        verifyGpgInformation();
        
        if (ChannelFactory.doesChannelNameExist(name)) {
            throw new InvalidChannelNameException(name,
                InvalidChannelNameException.Reason.NAME_IN_USE,
                "edit.channel.invalidchannelname.nameinuse", name);
        }
        
        if (ChannelFactory.doesChannelLabelExist(label)) {
            throw new InvalidChannelLabelException(label,
                InvalidChannelLabelException.Reason.LABEL_IN_USE,
                "edit.channel.invalidchannellabel.labelinuse", label);
        }
        
        ChannelArch ca = ChannelFactory.findArchByLabel(archLabel);
        if (ca == null) {
            throw new IllegalArgumentException("Invalid architecture label");
        }
        
        ChecksumType ct = ChannelFactory.findChecksumTypeByLabel(checksum);
        
        
        Channel c = ChannelFactory.createChannel();
        c.setLabel(label);
        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
        c.setOrg(user.getOrg());
        c.setBaseDir("/dev/null");
        c.setChannelArch(ca);
        c.setChecksumType(ct);
        c.setGPGKeyId(gpgKeyId);
        c.setGPGKeyUrl(gpgKeyUrl);
        c.setGPGKeyFp(gpgKeyFp);
        c.setAccess(access);
        c.setMaintainerName(maintainerName);
        c.setMaintainerEmail(maintainerEmail);
        c.setMaintainerPhone(maintainerPhone);
        c.setSupportPolicy(supportPolicy);
        c.setYumContentSource(yumUrl, repoLabel);

        // handles either parent id or label
        setParentChannel(c, user, parentLabel, parentId);
        
        c.addChannelFamily(user.getOrg().getPrivateChannelFamily());
        
        // need to save before calling stored proc below
        ChannelFactory.save(c);
        
        ChannelManager.queueChannelChange(c.getLabel(), "createchannel", "createchannel");
        ChannelFactory.refreshNewestPackageCache(c, WEB_CHANNEL_CREATED);
        
        if (syncRepo && !c.getContentSources().isEmpty()) {
            TaskFactory.createTask(user.getOrg(), RepoSyncTask.DISPLAY_NAME,
                    c.getContentSources().iterator().next().getId());
        }
        
        return c;
    }

    /**
     * sets the parent channel of the given affected channel if pLabel or pid
     * is given. pLabel is preferred if both are given. If both pLabel and
     * pid are null or if no channel is found for the given label or pid, the
     * affected channel is unchanged.
     * @param affected The Channel to receive a new parent, if one is found.
     * @param usr The usr
     * @param lbl The parent Channel label, can be null.
     * @param pid The parent Channel id, can be null.
     */
    protected void setParentChannel(Channel affected, User usr,
                                    String lbl, Long pid) {
        Channel parent = null;

        if ((lbl == null || lbl.equals("")) &&
            pid == null) {
            // these are not the droids you seek
            return;
        }

        if (lbl != null && !lbl.equals("")) {
            parent = ChannelManager.lookupByLabelAndUser(lbl, usr);
        }
        else if (pid != null) {
            parent = ChannelManager.lookupByIdAndUser(pid, usr);
        }

        if (parent == null) {
            throw new IllegalArgumentException("Invalid Parent Channel lbl");
        }

        if (!parent.isBaseChannel()) {
            throw new InvalidParentChannelException();
        }

        // man that's a lot of conditionals :) finally we do what 
        // we came here to do.
        affected.setParentChannel(parent);
    }

    /**
     * Verifies that the required parameters are not null.
     * @throws IllegalArgumentException thrown if label, name, user or summary
     *  are null.
     */
    protected void verifyRequiredParameters() {
        if (user == null || StringUtils.isEmpty(summary)) {
            throw new IllegalArgumentException(
                    "edit.channel.invalidchannelsummary");
        }
        
        if (!StringUtils.isEmpty(yumUrl) && StringUtils.isEmpty(repoLabel)) {
            throw new IllegalArgumentException(
                "edit.channel.invalidrepolabel.missing");
        }
        
    }
    
    protected void verifyChannelName(String cname) throws InvalidChannelNameException {
        if (user == null) {
            // can never be too careful
            throw new IllegalArgumentException("Required param [user] is null");
        }
        
        if (cname == null || cname.trim().length() == 0) {
            throw new InvalidChannelNameException(cname,
                InvalidChannelNameException.Reason.IS_MISSING,
                "edit.channel.invalidchannelname.missing", "");
        }

        if (!Pattern.compile(CHANNEL_NAME_REGEX).matcher(cname).find()) {
            throw new InvalidChannelNameException(cname,
                InvalidChannelNameException.Reason.REGEX_FAILS,
                "edit.channel.invalidchannelname.supportedregex", "");
        }

        if (cname.length() < CHANNEL_NAME_MIN_LENGTH) {
            Integer minLength = new Integer(CreateChannelCommand.CHANNEL_NAME_MIN_LENGTH);
            throw new InvalidChannelNameException(cname,
                InvalidChannelNameException.Reason.TOO_SHORT,
                "edit.channel.invalidchannelname.minlength",
                minLength.toString());
        }
        
        if (cname.length() > CHANNEL_NAME_MAX_LENGTH) {
            Integer maxLength = new Integer(CreateChannelCommand.CHANNEL_NAME_MAX_LENGTH);
            throw new InvalidChannelNameException(cname,
                InvalidChannelNameException.Reason.TOO_LONG,
                "edit.channel.invalidchannelname.maxlength",
                maxLength.toString());
        }

        // the perl code used to ignore case with a /i at the end of
        // the regex, so we toLowerCase() the channel name to make it
        // work the same.
        if (!user.hasRole(RoleFactory.RHN_SUPERUSER) &&
            Pattern.compile(REDHAT_REGEX).matcher(cname.toLowerCase()).find()) {
            throw new InvalidChannelNameException(cname,
                InvalidChannelNameException.Reason.RHN_CHANNEL_BAD_PERMISSIONS,
                "edit.channel.invalidchannelname.redhat", "");
        }
    }
    
    protected void verifyChannelLabel(String clabel) throws InvalidChannelLabelException {
        
        if (user == null) {
            // can never be too careful
            throw new IllegalArgumentException("Required param is null");
        }
        
        if (clabel == null || clabel.trim().length() == 0) {
            throw new InvalidChannelLabelException(clabel,
                InvalidChannelLabelException.Reason.IS_MISSING,
                "edit.channel.invalidchannellabel.missing", "");
        }

        if (!Pattern.compile(CHANNEL_LABEL_REGEX).matcher(clabel).find()) {
            throw new InvalidChannelLabelException(clabel,
                InvalidChannelLabelException.Reason.REGEX_FAILS,
                "edit.channel.invalidchannellabel.supportedregex", "");
        }

        if (clabel.length() < CHANNEL_LABEL_MIN_LENGTH) {
            Integer minLength = new Integer(CreateChannelCommand.CHANNEL_LABEL_MIN_LENGTH);
            throw new InvalidChannelLabelException(clabel,
                InvalidChannelLabelException.Reason.TOO_SHORT,
                "edit.channel.invalidchannellabel.minlength",
                minLength.toString());
        }
        
        // the perl code used to ignore case with a /i at the end of
        // the regex, so we toLowerCase() the channel name to make it
        // work the same.
        if (!user.hasRole(RoleFactory.RHN_SUPERUSER) &&
            Pattern.compile(REDHAT_REGEX).matcher(clabel.toLowerCase()).find()) {
            throw new InvalidChannelLabelException(clabel,
                InvalidChannelLabelException.Reason.RHN_CHANNEL_BAD_PERMISSIONS,
                "edit.channel.invalidchannellabel.redhat", "");
        }
    }
    
    protected void verifyGpgInformation() {
        if (gpgKeyId != null && !gpgKeyId.equals("") &&
                !Pattern.compile(GPG_KEY_REGEX).matcher(gpgKeyId).find()) {
            throw new InvalidGPGKeyException();
        }
        
        if (gpgKeyFp != null && !gpgKeyFp.equals("") &&
                !Pattern.compile(GPG_FP_REGEX).matcher(gpgKeyFp).find()) {
            throw new InvalidGPGFingerprintException();
        }
        
        if (gpgKeyUrl != null && !gpgKeyUrl.equals("") &&
                !Pattern.compile(GPG_URL_REGEX).matcher(gpgKeyUrl).find()) {
            throw new InvalidGPGUrlException();
        }
    }
    
    /**
     * @param yumUrlIn The yumUrl to set.
     */
    public void setYumUrl(String yumUrlIn) {
        this.yumUrl = yumUrlIn;
    }

    /**
     * @param repoLabelIn The repoLabel to set.
     */
    public void setRepoLabel(String repoLabelIn) {
        this.repoLabel = repoLabelIn;
    }


    /**
     * @param syncRepoIn The syncRepo to set.
     */
    public void setSyncRepo(boolean syncRepoIn) {
        this.syncRepo = syncRepoIn;
    }
    
}
