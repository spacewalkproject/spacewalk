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
package com.redhat.rhn.frontend.xmlrpc.channel;

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.dto.ChannelTreeNode;
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
     *          #prop("string", "label")
     *          #prop("string", "name")
     *          #prop("string", "parent_label")
     *          #prop("string", "end_of_life")
     *          #prop("string", "arch")
     *      #struct_end()
     *  #array_end()
     */
    public Object[] listSoftwareChannels(String sessionKey) {

        User user = ChannelHandler.getLoggedInUser(sessionKey);
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
            newItem.put("label", item.get("channel_label"));
            String selfLabel = (String) item.get("parent_or_self_label");
            if (selfLabel.equals(item.get("channel_label"))) {
                newItem.put("parent_label", "");
            }
            else {
                newItem.put("parent_label",
                        item.get("parent_or_self_label"));
            }
            newItem.put("name", item.get("name"));
            newItem.put("end_of_life",
                    StringUtils.defaultString(
                            (String)item.get("end_of_life")));
            newItem.put("arch", item.get("channel_arch"));
                        
            
            returnList.add(newItem);
        }

        return returnList.toArray();
    }
    
    /**
     * Lists all software channels that the user's organization is entitled to.
     * @param sessionKey session containing User information.
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List all software channels that the user's organization is entitled to.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listAllChannels(String sessionKey) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.allChannelTree(user, null);
        dr.elaborate();
        return dr.toArray();
    }
    
    /**
     * Lists all Red Hat software channels that the user's organization is entitled to.
     * @param sessionKey session containing User information.
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List all Red Hat software channels that the user's organization is 
     * entitled to.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listRedHatChannels(String sessionKey) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.redHatChannelTree(user, null);
        dr.elaborate();
        return dr.toArray();
    }
    
    /**
     * Lists the most popular software channels based on the popularity
     * count given.
     * @param sessionKey session containing User information.
     * @param popularityCount channels with at least this many systems subscribed
     * will be returned
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List the most popular software channels.  Channels that have at least
     * the number of systems subscribed as specified by the popularity count will be 
     * returned.
     * @xmlrpc.param #session_key()
     * @xmlrpc.param #prop("int", "popularityCount")
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listPopularChannels(String sessionKey, Integer popularityCount) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.popularChannelTree(user, 
                new Long(popularityCount), null);
        dr.elaborate();
        return dr.toArray();
    }
    
    /**
     * Lists all software channels that belong to the user's organization.
     * @param sessionKey session containing User information.
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List all software channels that belong to the user's organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listMyChannels(String sessionKey) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.myChannelTree(user, null);
        dr.elaborate();
        return dr.toArray();
    }
    
    /**
     * List all software channels that may be shared by the user's organization.
     * @param sessionKey session containing User information.
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List all software channels that may be shared by the user's 
     * organization.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listSharedChannels(String sessionKey) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.sharedChannelTree(user, null);
        dr.elaborate();
        return dr.toArray();
    }
    
    /**
     * List all retired software channels.  These are channels that the user's organization
     * is entitled to, but are no longer supported as they have reached their 'end-of-life'
     * date.
     * @param sessionKey session containing User information.
     * @return Returns array of channels with info such as channel_label, channel_name,
     * channel_parent_label, packages and systems.
     * 
     * @xmlrpc.doc List all retired software channels.  These are channels that the user's 
     * organization is entitled to, but are no longer supported because they have reached 
     * their 'end-of-life' date.
     * @xmlrpc.param #session_key()
     * @xmlrpc.returntype 
     *     #array()
     *         $ChannelTreeNodeSerializer
     *     #array_end()
     */
    public Object[] listRetiredChannels(String sessionKey) {
        User user = ChannelHandler.getLoggedInUser(sessionKey);
        DataResult<ChannelTreeNode> dr = ChannelManager.retiredChannelTree(user, null);
        dr.elaborate();
        return dr.toArray();
    }
}
