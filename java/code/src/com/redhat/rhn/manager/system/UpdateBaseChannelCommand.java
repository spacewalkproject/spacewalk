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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.commons.collections.ListUtils;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;


/**
 * UpdateBaseChannelCommand
 * @version $Rev$
 */
public class UpdateBaseChannelCommand extends BaseUpdateChannelCommand {

    private Server server;
    private Long baseChannelId;
    
    /**
     * Constructor with 
     * @param userIn current logged in user
     * @param s to update the base channel for
     * @param baseChanneldIn to update to
     */
    public UpdateBaseChannelCommand(User userIn, Server s, Long baseChanneldIn) {
        this.server = s;
        this.baseChannelId = baseChanneldIn;
        this.user = userIn;
    }

    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        Channel oldChannel = server.getBaseChannel();
        Channel newChannel = null;
        // If the new ID is -1 we are unsubscribing to a no-base-channel 
        // for the server.
        if (baseChannelId.longValue() != -1) {
            newChannel = ChannelManager.lookupByIdAndUser(
                    new Long(baseChannelId.longValue()), 
                    user);
            // Make sure we got a valid base channel from the user
            if (newChannel == null || newChannel.getParentChannel() != null ||
                   !newChannel.getChannelArch().isCompatible(server.getServerArch())) {
                throw new InvalidChannelException();
            }
        }
        
        // Check for available subs
        if (newChannel != null &&
                !SystemManager.canServerSubscribeToChannel(user.getOrg(), 
                        server, newChannel)) {
            return new ValidatorError("system.channel.nochannelslots");
        }
        List <Long> newKidsToSubscribe = new LinkedList<Long>();
        
        if (oldChannel != null && newChannel != null) {
            Map<Channel, Channel> preservableChildren = ChannelManager.
                            findCompatibleChildren(oldChannel, newChannel, user);
            for (Channel kid : server.getChannels()) {
                if (preservableChildren.containsKey(kid)) {
                    newKidsToSubscribe.add(preservableChildren.get(kid).getId());
                }
            }
        }
         
        // First unsubscribe all the child channels
        UpdateChildChannelsCommand cmd = new UpdateChildChannelsCommand(user, server, 
                ListUtils.EMPTY_LIST);
        cmd.store();
        
        
        // Unsubscribe the server from it's current base channel
        try {
            SystemManager.unsubscribeServerFromChannel(user, server, oldChannel);
        }
        catch (PermissionException e) {
            // convert to FaultException
            throw new PermissionCheckFailureException();
        }
        
        if (newChannel != null) {
            // Subscribe the server to the new base channel
            try {
                SystemManager.subscribeServerToChannel(user, server, newChannel);
                cmd = new UpdateChildChannelsCommand(user, server, 
                        newKidsToSubscribe);
                cmd.store();
                
            }
            catch (PermissionException e) {
                // convert to FaultException
                throw new PermissionCheckFailureException();
            }
        }
        return super.store();
    }

}
