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
package com.redhat.rhn.manager.channel;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelArch;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.role.RoleFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;

import java.util.regex.Pattern;

/**
 * CreateChannelCommand - command to create a new channel.
 * @version $Rev$
 */
public class CreateChannelCommand {
    
    private User user;
    private String label;
    private String name;
    private String summary;
    private String archLabel;
    private String parentLabel;
    
    private static final String CHANNEL_NAME_REGEX =
        "^[a-zA-Z][\\w\\d\\s\\-\\.\\'\\(\\)\\/\\_]*$";
    private static final String CHANNEL_LABEL_REGEX =
        "^[a-z][a-z\\d\\-\\.\\_]*$";
    // we ignore case with the red hat regex
    private static final String REDHAT_REGEX = "^(rhn|red\\s*hat)";
    private static final String WEB_CHANNEL_CREATED = "web.channel_created";
    
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
     * @param summaryIn The summary to set.
     */
    public void setSummary(String summaryIn) {
        summary = summaryIn;
    }

    /**
     * @param userIn The user to set.
     */
    public void setUser(User userIn) {
        user = userIn;
    }

    /**
     * Creates the Channel based on the parameters that were set.
     * @return true if the creation occurred successfully.
     * @throws InvalidChannelLabelException thrown if label is in use or invalid.
     * @throws InvalidChannelNameException throw if name is in use or invalid.
     * @throws IllegalArgumentException thrown if label, name or user are null.
     * @throws InvalidParentChannelException thrown if parent label is not a
     * valid base channel.
     */
    public boolean create()
        throws InvalidChannelLabelException, InvalidChannelNameException,
        InvalidParentChannelException {

        verifyRequiredParameters();
        verifyChannelName(name);
        verifyChannelLabel(label);
        
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
        c.setOrg(user.getOrg());
        c.setBaseDir("/dev/null");
        c.setChannelArch(ca);

        if (parentLabel != null && !parentLabel.equals("")) {
            Channel parent = ChannelFactory.lookupByLabel(user.getOrg(), parentLabel);

            if (parent == null) {
                throw new IllegalArgumentException("Invalid Parent Channel label");
            }
            
            if (!parent.isBaseChannel()) {
                throw new InvalidParentChannelException();
            }
            
            c.setParentChannel(parent);
        }
        c.addChannelFamily(user.getOrg().getPrivateChannelFamily());
        
        // need to save before calling stored proc below
        ChannelFactory.save(c);
        
        ChannelFactory.refreshNewestPackageCache(c, WEB_CHANNEL_CREATED);

        return true;
    }

    /**
     * Verifies that the required parameters are not null.
     * @throws IllegalArgumentException thrown if label, name, user or summary
     *  are null.
     */
    private void verifyRequiredParameters() {
        if (user == null || summary == null) {
            throw new IllegalArgumentException(
                  "Required parameters not set: user, or summary");
        }
    }
    
    private void verifyChannelName(String cname) throws InvalidChannelNameException {
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
    
    private void verifyChannelLabel(String clabel) throws InvalidChannelLabelException {
        
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
}
