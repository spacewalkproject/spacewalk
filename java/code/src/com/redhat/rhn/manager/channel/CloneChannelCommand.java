/**
 * Copyright (c) 2015 Red Hat, Inc.
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
import com.redhat.rhn.domain.channel.ClonedChannel;
import com.redhat.rhn.domain.common.ChecksumType;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelLabelException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelNameException;
import com.redhat.rhn.frontend.xmlrpc.InvalidParentChannelException;
import com.redhat.rhn.manager.errata.ErrataManager;

/**
 * CreateChannelCommand - command to clone a channel.
 * @version $Rev$
 */
public class CloneChannelCommand extends CreateChannelCommand {

    private boolean originalState;
    private Channel original;

    /**
     * Constructor
     * @param originalStateIn true to clone with no errata, false to clone with all errata
     * @param cloneFrom channel to clone from
     */
    public CloneChannelCommand(boolean originalStateIn, Channel cloneFrom) {
        user = null;
        label = null;
        name = null;
        summary = null;
        archLabel = null;
        checksum = null;
        parentLabel = null;
        parentId = null;
        originalState = originalStateIn;
        original = cloneFrom;
    }

    /**
     * Clones Channel based on the parameters that were set.
     * @return the newly cloned Channel
     * @throws InvalidChannelLabelException thrown if label is in use or invalid.
     * @throws InvalidChannelNameException throw if name is in use or invalid.
     * @throws IllegalArgumentException thrown if label, name or user are null.
     * @throws InvalidParentChannelException thrown if parent label is not a
     * valid base channel.
     */
    public Channel create()
        throws InvalidChannelLabelException, InvalidChannelNameException,
        InvalidParentChannelException {

        ChannelArch ca = ChannelFactory.findArchByLabel(archLabel);
        ChecksumType ct = ChannelFactory.findChecksumTypeByLabel(checksum);
        validateChannel(ca, ct);

        ClonedChannel c = new ClonedChannel();
        c.setLabel(label);
        c.setName(name);
        c.setSummary(summary);
        c.setDescription(description);
        c.setOrg(user.getOrg());
        c.setBaseDir("/dev/null");
        c.setChannelArch(ca);

        // handles either parent id or label
        setParentChannel(c, user, parentLabel, parentId);
        c.setChecksumType(ct);
        c.setGPGKeyId(gpgKeyId);
        c.setGPGKeyUrl(gpgKeyUrl);
        c.setGPGKeyFp(gpgKeyFp);
        c.setAccess(access);
        c.setMaintainerName(maintainerName);
        c.setMaintainerEmail(maintainerEmail);
        c.setMaintainerPhone(maintainerPhone);
        c.setSupportPolicy(supportPolicy);
        c.addChannelFamily(user.getOrg().getPrivateChannelFamily());

        // cloned channel stuff
        c.setProductName(original.getProductName());
        c.setOriginal(original);

        // need to save before calling stored procs below
        ChannelFactory.save(c);
        c = (ClonedChannel) ChannelFactory.reload(c);

        // This ends up being a mode query call so need to save first to get channel id
        c.setGloballySubscribable(globallySubscribable, user.getOrg());

        if (originalState) {
            // original packages only, no errata
            ChannelManager.cloneOriginalChannelPackages(original.getId(), c.getId());
            ChannelFactory.refreshNewestPackageCache(c.getId(), "cloning as original");
        }
        else {
            ChannelManager.cloneChannelPackages(original.getId(), c.getId());
            ChannelFactory.cloneNewestPackageCache(original.getId(), c.getId());
            ErrataManager.cloneChannelErrata(original.getId(), c.getId(), user);
        }

        ChannelManager.queueChannelChange(c.getLabel(), "clonechannel", "cloned from " +
                original.getLabel());

        return c;
    }
}
