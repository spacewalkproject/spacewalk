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

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.hibernate.LookupException;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.ChannelSubscriptionException;
import com.redhat.rhn.frontend.xmlrpc.InvalidChannelException;
import com.redhat.rhn.frontend.xmlrpc.PermissionCheckFailureException;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.log4j.Logger;

import java.util.ArrayList;
import java.util.Set;
import java.util.List;


/**
 * UpdateChildChannelsCommand - this will *NOT* remove Proxy or Satellite child channel
 * subscriptions.  
 * @version $Rev$
 */
public class UpdateChildChannelsCommand extends BaseUpdateChannelCommand {
    /**
     * Logger for this class
     */
    private static Logger log = Logger.getLogger(UpdateChildChannelsCommand.class);

    private List<Long> cids;
    private Server server;
    
    /**
     * Constructor
     * @param userIn making the call
     * @param s server to update
     * @param channelIdsIn List of Long channel ids
     */
    public UpdateChildChannelsCommand(User userIn, Server s, List <Long> channelIdsIn) {
        this.cids = channelIdsIn;
        this.user = userIn;
        this.server = s;
    }
    
    /**
     * {@inheritDoc}
     */
    public ValidatorError store() {
        List<Long> remove = new ArrayList<Long>();
        /*
         * Loop through the server channels and take any channels the server is already
         * subscribed to out of the cids list. Also, keep track of any we will have to 
         * unsubscribe from in the remove list.
         */
        for (Channel c : server.getChannels()) {
            if (cids.contains(c.getId())) {
                // already subscribed
                cids.remove(c.getId());
            }
            else if (!c.isProxy() && !c.isSatellite() && !c.isBaseChannel()) {
                // Don't remove base channels, satellite or proxy subscriptions
                // need to unsubscribe since it is not in cids
                remove.add(c.getId());
            }
        }
        
        // Check whether channelsIds are childs of the current base if the system has a base
        if (server.getBaseChannel() != null) {
            Set subscribableChannelIds = SystemManager.subscribableChannelIds(
                            server.getId(), user.getId(), server.getBaseChannel().getId());
            for (Long channelId : cids) {
                if (!subscribableChannelIds.contains(channelId)) {
                    Channel channel = ChannelFactory.lookupById(channelId);
                    if (channel == null) {
                        throw new InvalidChannelException();
                    }
                    else {
                        throw new ChannelSubscriptionException(channel.getLabel());
                    }
                }
            }
        }

        //Subscribe to new channels
        log.debug("subscribing to new channels");
        boolean failedChannels = subscribeToNewChannels(user, cids, server);
        
        //Unsubscribe from any channels in remove
        log.debug("unsubscribing from other channels");
        unsubscribeFromOldChannels(user, remove, server);
        
        super.store();
        
        if (failedChannels) {
            return new ValidatorError("sdc.channels.edit.failed_channels");
        }
        else {
            return null;
        }
    }
    
    private static boolean subscribeToNewChannels(User loggedInUser, 
            List<Long> channelIds, Server serverIn)
        throws FaultException {
        
        boolean failedChannels = false;
        
        /*
         * Loop through the list of new channel ids for the server. Make sure each one is
         * a valid child channel (parentChannel == null) and subscribe the server to the
         * channel.
         */
        for (Long cid : channelIds) {

            Channel channel = null;
            try {
                channel = ChannelManager.lookupByIdAndUser(cid, loggedInUser);
            }
            catch (LookupException e) {
                //convert to FaultException
                throw new InvalidChannelException();
            }
            // Make sure we have a valid child channel
            if (channel.isBaseChannel()) {
                throw new InvalidChannelException();
            }

            if (channel != null && log.isDebugEnabled()) {
                log.debug("checking to see if we can sub: " + channel.getLabel());
            }
            if (!SystemManager.canServerSubscribeToChannel(loggedInUser.getOrg(),
                    serverIn, channel)) {
                log.debug("we can't subscribe to the channel.");
                failedChannels = true;
            }
            else {
                // do quick unsubscribe + quick subscribe... I don't know why we do the 
                // unsubscribe first... It is what the perl code does though.
                try {
                    log.debug("unsub from channel to be sure");
                    SystemManager.unsubscribeServerFromChannel(loggedInUser, 
                            serverIn, channel);
                    log.debug("Sub to channel.");
                    SystemManager.subscribeServerToChannel(loggedInUser, serverIn, channel, 
                            false);
                }
                catch (IncompatibleArchException iae) {
                    throw new InvalidChannelException(iae);
                }
                catch (PermissionException e) {
                    //convert to FaultException
                    throw new PermissionCheckFailureException();
                }
            }
        }
        
        return failedChannels;
    }

    private static void unsubscribeFromOldChannels(User loggedInUser, 
            List<Long> remove, Server serverIn)
            throws FaultException {
        /*
         * Loop through the list of cids to remove and unsubscribe the server from the 
         * channel. Make sure we don't do anything to the base channel.
         */
        for (Long cid : remove) {

            Channel channel = null;
            try {
                channel = ChannelManager.lookupByIdAndUser(cid, loggedInUser);
            }
            catch (LookupException e) {
                throw new InvalidChannelException();
            }

            // unsubscribe from channel
            try {
                SystemManager.unsubscribeServerFromChannel(loggedInUser, 
                        serverIn, channel);
            }
            catch (PermissionException e) {
                //convert to FaultException
                throw new PermissionCheckFailureException();
            }
        }
    }
}
