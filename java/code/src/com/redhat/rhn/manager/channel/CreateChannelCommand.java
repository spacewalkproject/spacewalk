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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;

import org.apache.commons.lang.StringUtils;

import java.util.regex.Pattern;

/**
 * CreateChannelCommand - command to create a new channel.
 * @version $Rev$
 */
public class CreateChannelCommand {
    
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
    protected String maintainerName;
    protected String maintainerEmail;
    protected String maintainerPhone;
    protected String supportPolicy;
    protected String access = Channel.PRIVATE;
    
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
    
    /**
     * default constructor.
     */
    public CreateChannelCommand() {
        user = null;
        label = null;
        name = null;
        summary = null;
        archLabel = null;
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
            throw new InvalidChannelNameException();
        }
        
        if (ChannelFactory.doesChannelLabelExist(label)) {
            throw new InvalidChannelLabelException();
        }
        
        ChannelArch ca = ChannelFactory.findArchByLabel(archLabel);
        if (ca == null) {
            throw new IllegalArgumentException("Invalid architecture label");
        }
        
        Channel c = ChannelFactory.createChannel();
        c.setLabel(label);
        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
        c.setOrg(user.getOrg());
        c.setBaseDir("/dev/null");
        c.setChannelArch(ca);
        c.setGPGKeyId(gpgKeyId);
        c.setGPGKeyUrl(gpgKeyUrl);
        c.setGPGKeyFp(gpgKeyFp);
        c.setAccess(access);
        c.setMaintainerName(maintainerName);
        c.setMaintainerEmail(maintainerEmail);
        c.setMaintainerPhone(maintainerPhone);
        c.setSupportPolicy(supportPolicy);

        // handles either parent id or label
        setParentChannel(c, user, parentLabel, parentId);
        
        c.addChannelFamily(user.getOrg().getPrivateChannelFamily());
        
        // need to save before calling stored proc below
        ChannelFactory.save(c);
        
        ChannelFactory.refreshNewestPackageCache(c, WEB_CHANNEL_CREATED);

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
                  "Required parameters not set: user, or summary");
        }
    }
    
    protected void verifyChannelName(String cname) throws InvalidChannelNameException {
        if (user == null) {
            // can never be too careful
            throw new IllegalArgumentException("Required param is null");
        }
        
        if (cname == null || 
                !Pattern.compile(CHANNEL_NAME_REGEX).matcher(cname).find() ||
                cname.length() < 6) {
            throw new InvalidChannelNameException();
        }
        
        // the perl code used to ignore case with a /i at the end of
        // the regex, so we toLowerCase() the channel name to make it
        // work the same.
        if (!user.hasRole(RoleFactory.RHN_SUPERUSER) &&
                Pattern.compile(REDHAT_REGEX).matcher(cname.toLowerCase()).find()) {
            throw new InvalidChannelNameException();
        }
    }
    
    protected void verifyChannelLabel(String clabel) throws InvalidChannelLabelException {
        
        if (user == null) {
            // can never be too careful
            throw new IllegalArgumentException("Required param is null");
        }
        
        if (clabel == null || 
                !Pattern.compile(CHANNEL_LABEL_REGEX).matcher(clabel).find() ||
                clabel.length() < 6) {
            throw new InvalidChannelLabelException();
        }
        
        // the perl code used to ignore case with a /i at the end of
        // the regex, so we toLowerCase() the channel name to make it
        // work the same.
        if (!user.hasRole(RoleFactory.RHN_SUPERUSER) &&
                Pattern.compile(REDHAT_REGEX).matcher(clabel.toLowerCase()).find()) {
            throw new InvalidChannelLabelException();
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
}
