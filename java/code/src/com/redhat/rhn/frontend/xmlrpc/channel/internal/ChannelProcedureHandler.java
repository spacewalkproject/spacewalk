/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.frontend.xmlrpc.channel.internal;

import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.domain.user.UserFactory;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.channel.ChannelManager;
import com.redhat.rhn.manager.system.SystemManager;
import com.redhat.rhn.manager.system.UpdateBaseChannelCommand;


/**
 * ChannelProcedureHandler
 * @version $Rev$
 */
public class ChannelProcedureHandler extends BaseHandler {
    /**
     * Runs the subscribe channel procedure
     * @param serverId the id of the server
     * @param channelId the id of the channel
     * @param userId the id of the user
     * @return 1 on success exception otherwise
     */
    public int subscribe(Integer serverId, 
                                Integer channelId, Integer userId) {
        User user = UserFactory.lookupById(userId.longValue());
        Channel channel = ChannelManager.lookupByIdAndUser(channelId.longValue(), user);
        Server server = SystemManager.lookupByIdAndUser(serverId.longValue(), user);
        if (channel.isBaseChannel()) {
            UpdateBaseChannelCommand cmd = 
                new UpdateBaseChannelCommand(user, server, channel.getId());
            cmd.store();
        }
        else {
            SystemManager.subscribeServerToChannel(user, server, channel);
        }
        
        return 1;
    }
    
    /**
     * Runs the subscribe channel procedure
     * @param serverId the id of the server
     * @param channelId the id of the channel
     * @return 1 on success exception otherwise
     */
    public int subscribeNoUser(Integer serverId, 
                                Integer channelId) {
        
        Channel channel = ChannelFactory.lookupById(channelId.longValue());
        Server server = ServerFactory.lookupById(serverId.longValue());
        SystemManager.subscribeServerToChannel(null, server, channel);
        return 1;
    }    
}
