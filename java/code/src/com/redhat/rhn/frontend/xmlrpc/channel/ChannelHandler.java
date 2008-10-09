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
package com.redhat.rhn.frontend.xmlrpc.channel;

import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.xmlrpc.BaseHandler;
import com.redhat.rhn.manager.channel.ChannelManager;

import org.apache.commons.lang.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ChannelHandler
 * @version $Rev$
 * @xmlrpc.namespace channel
 * @xmlrpc.doc Provides method to get back a list of Software Channels.
 */
public class ChannelHandler extends BaseHandler {

    /**
     * Lists all visible software channels. For all child channels,
     * 'channel_parent_label' will be the channel label of the parent channel.
     * For all base channels, 'channel_parent_label' will be an empty string.
     * @param sessionKey WebSession containing User information.
     * @return Returns array of Maps with the following keys:
     * channel_label, channel_parent_label, channel_name, channel_end_of_life,
     * channel_arch
     * 
     * @xmlrpc.doc List all visible software channels.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *  #array()
     *      #struct("channel")
     *          #prop("string", "channel_label")
     *          #prop("string", "channel_name")
     *          #prop("string", "channel_parent_label")
     *          #prop("string", "channel_end_of_life")
     *          #prop("string", "channel_arch")
     *      #struct_end()
     *  #array_end()
     */
    public Object[] listSoftwareChannels(String sessionKey) {

        User user = this.getLoggedInUser(sessionKey);
        List items = ChannelManager.allChannelsTree(user);

        // perl just makes stuff so much harder since it
        // transforms data in a map with one line, but it's
        // still looping through the list more than once.
        // To keep backwards compatiblity I need to transform
        // this list of maps into a different list of maps.
        //
        // Just because it is ONE line it doesn't make it efficient.
        
        List returnList = new ArrayList(items.size());
        for (Iterator itr = items.iterator(); itr.hasNext();) {
            Map item = (Map) itr.next();
            
            // Deprecated stupid code
            // this is some really stupid code, but oh well, c'est la vie
            Map newItem = new HashMap();
            newItem.put("channel_label", item.get("channel_label"));
            String selfLabel = (String) item.get("parent_or_self_label");
            if (selfLabel.equals(item.get("channel_label"))) {
                newItem.put("channel_parent_label", "");
            }
            else {
                newItem.put("channel_parent_label",
                        item.get("parent_or_self_label"));
            }
            newItem.put("channel_name", item.get("name"));
            newItem.put("channel_end_of_life",
                    StringUtils.defaultString(
                            (String)item.get("end_of_life")));
            newItem.put("channel_arch", item.get("channel_arch"));
                        
            
            returnList.add(newItem);
        }

        return returnList.toArray();
    }
}
