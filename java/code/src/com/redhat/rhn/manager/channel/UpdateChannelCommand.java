/**
 * Copyright (c) 2009--2011 Red Hat, Inc.
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
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChecksumLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;

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
     * prefill all channel atrributes
     * @param userIn user, that tries to update the channel
     * @param channelIn to be updated
     */
    public UpdateChannelCommand(User userIn, Channel channelIn) {
        user = userIn;
        label = channelIn.getLabel();
        name = channelIn.getName();
        summary = channelIn.getSummary();
        description = channelIn.getDescription();
        if (channelIn.getChannelArch() == null) {
            archLabel = null;
        }
        else {
            archLabel = channelIn.getChannelArch().getLabel();
        }
        if (channelIn.getParentChannel() == null) {
            parentLabel = null;
        }
        else {
            parentLabel = channelIn.getParentChannel().getLabel();
        }
        if (channelIn.getParentChannel() == null) {
            parentId = null;
        }
        else {
            parentId = channelIn.getParentChannel().getId();
        }
        gpgKeyUrl = channelIn.getGPGKeyUrl();
        gpgKeyId = channelIn.getGPGKeyId();
        gpgKeyFp = channelIn.getGPGKeyFp();
        checksum = channelIn.getChecksumTypeLabel();
        maintainerName = channelIn.getMaintainerName();
        maintainerEmail = channelIn.getMaintainerEmail();
        maintainerPhone = channelIn.getMaintainerPhone();
        supportPolicy = channelIn.getSupportPolicy();
        access = channelIn.getAccess();
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

        ChecksumType ct = null;
        // RHEL <= 4 does not use yum and therefore does not have a checksum
        if (!checksum.equals("")) {
            ct = ChannelFactory.findChecksumTypeByLabel(checksum);
            if (ct == null) {
                throw new InvalidChecksumLabelException(checksum);
            }
            if (checksumChanged(c.getChecksumTypeLabel(), ct) &&
                    c.getPackageCount() > 0) {
                // schedule repo re generation if the checksum type changed
                // and the channel has packages
                ChannelManager.queueChannelChange(c.getLabel(),
                        "java::updateChannelCommon", null);
            }
        }
        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
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

    private boolean checksumChanged(String label, ChecksumType ct) {
        if (ct == null || ct.getLabel() == null) {
            return label != null;
        }
        return !ct.getLabel().equals(label);
    }
}
