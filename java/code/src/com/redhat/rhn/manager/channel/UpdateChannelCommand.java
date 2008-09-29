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
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGKeyException;
import com.redhat.rhn.frontend.xmlrpc.InvalidGPGUrlException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.manager.channel.CreateChannelCommand;

import java.util.regex.Pattern;

/**
 * UpdateChannelCommand - command to create a new channel.
 * @version $Rev$
 */
public class UpdateChannelCommand extends CreateChannelCommand {
    
    /**
     * default constructor.
     */
    public UpdateChannelCommand() {
        super();
    }

    /**
     * Updates the Channel based on the parameters that were set.
     * @param cid id of Channel to be updated.
     * @return the updated Channel
     * @throws InvalidChannelLabelException thrown if label is in use or invalid.
     * @throws InvalidChannelNameException throw if name is in use or invalid.
     * @throws IllegalArgumentException thrown if label, name or user are null.
     * @throws InvalidParentChannelException thrown if parent label is not a
     * valid base channel.
     */
    public Channel update(Long cid)
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
        
        Channel c = ChannelFactory.lookupById(cid);
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
}
