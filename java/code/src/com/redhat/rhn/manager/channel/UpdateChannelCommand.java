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
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.task.TaskFactory;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.taskomatic.task.RepoSyncTask;

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
        verifyGpgInformation();
        
        // lookup the channel first.
        Channel c = ChannelFactory.lookupById(cid);
        
        if (ChannelFactory.doesChannelNameExist(name) &&
                !name.equals(c.getName())) {
            throw new InvalidChannelNameException();
        }
        
        if (ChannelFactory.findArchByLabel(archLabel) == null) {
            throw new IllegalArgumentException("Invalid architecture label");
        }
        
        ChecksumType ct = ChannelFactory.findChecksumTypeByLabel(checksum);
        if (!ct.getLabel().equals(c.getChecksumTypeLabel()) && c.getPackageCount() > 0) {
            // schedule repo re generation if the checksum type changed 
            // and the channel has packages
            ChannelManager.queueChannelChange(c.getLabel(), 
                    "java::updateChannelCommon", null);
        }

        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
        c.setOrg(user.getOrg());
        c.setBaseDir("/dev/null");
        c.setGPGKeyId(gpgKeyId);
        c.setGPGKeyUrl(gpgKeyUrl);
        c.setGPGKeyFp(gpgKeyFp);
        c.setChecksumType(ct);
        c.setAccess(access);
        c.setMaintainerName(maintainerName);
        c.setMaintainerEmail(maintainerEmail);
        c.setMaintainerPhone(maintainerPhone);
        c.setSupportPolicy(supportPolicy);

        // need to save before calling stored proc below
        ChannelFactory.save(c);

        return c;
    }
}
