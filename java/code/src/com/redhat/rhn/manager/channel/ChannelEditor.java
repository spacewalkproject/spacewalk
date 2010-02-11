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

import com.redhat.rhn.common.db.datasource.CallableMode;
import com.redhat.rhn.common.db.datasource.ModeFactory;
import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.common.security.PermissionException;
import com.redhat.rhn.domain.channel.Channel;
import com.redhat.rhn.domain.channel.ChannelFactory;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.user.UserManager;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * ChannelEditor
 * @version $Rev$
 */
public class ChannelEditor {
    
    // private instance
    private static ChannelEditor editor = new ChannelEditor();
    
    // private constructor
    private ChannelEditor() {
    }
    
    /**
     * @return Returns the running instance of ChannelEditor
     */
    public static ChannelEditor getInstance() {
        return editor;
    }
    
    /**
     * Adds a list of packages to a channel.
     * @param user The user requesting the package additions
     * @param channel The channel to add the packages to
     * @param packageIds A list containing the ids of packages to add.
     */
    public void addPackages(User user, Channel channel, Collection packageIds) {
        changePackages(user, channel, packageIds, true);
    }
    
    /**
     * Removes a list of packages from a channel
     * @param user The user requesting the package removals
     * @param channel The channel to remove the packages from
     * @param packageIds A list containing the ids of packages to remove.
     */
    public void removePackages(User user, Channel channel, Collection packageIds) {
        changePackages(user, channel, packageIds, false);
    }
    
    /*
     * This is kind of hokey, but I didn't want to replicate all of this code twice.
     * @param add If true, we are adding the list of packages to the channel. Otherwise,
     * remove the list of packages from the channel.
     */
    private void changePackages(User user, Channel channel,
                                Collection packageIds, boolean add) {
        //Make sure the person adding packages is a channel admin
        if (!UserManager.verifyChannelAdmin(user, channel)) {
            StringBuffer msg = new StringBuffer("User: ");
            msg.append(user.getLogin());
            msg.append(" does not have channel admin access to channel: ");
            msg.append(channel.getLabel());
            
            //Throw an exception with a nice error message so the user
            //knows what went wrong.
            LocalizationService ls = LocalizationService.getInstance();
            PermissionException pex = new PermissionException(msg.toString());
            pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.channel"));
            pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.channel"));
            throw pex;
        }
        
        //Loop through packageIds and make sure user has access to the package
        for (Iterator itr = packageIds.iterator(); itr.hasNext();) {
            Long pid = convertObjectToLong(itr.next());
            if (!UserManager.verifyPackageAccess(user.getOrg(), pid)) {
                StringBuffer msg = new StringBuffer("User: ");
                msg.append(user.getLogin());
                msg.append(" does not have access to package: ");
                msg.append(pid);
                
                //Throw an exception with a nice error message so the user
                //knows what went wrong.
                LocalizationService ls = LocalizationService.getInstance();
                PermissionException pex = new PermissionException(msg.toString());
                pex.setLocalizedTitle(ls.getMessage("permission.jsp.title.package"));
                pex.setLocalizedSummary(ls.getMessage("permission.jsp.summary.package"));
                throw pex;
            }
        }
        
        List<Long> existingPids = ChannelFactory.getPackageIds(channel.getId());

        List list = new ArrayList();
        for (Iterator itr = packageIds.iterator(); itr.hasNext();) {
            Long pid = convertObjectToLong(itr.next());
            if (!add || !existingPids.contains(pid)) {
                list.add(pid);
            }
        }
        if (add) {
            ChannelManager.addPackages(channel, list, user);
        }
        else {
            ChannelManager.removePackages(channel, list, user);
        }
                
        // Mark the affected channel to have it smetadata evaluated, where necessary
        // (RHEL5+, mostly)
        ChannelManager.queueChannelChange(channel.getLabel(), "java::changePackages", null);
        
        ChannelFactory.save(channel);
        //call update_channel stored proc
        updateChannel(channel);
    }
    
    /**
     * Private Helper method to convert an object to a Long. We need this since the list of
     * package ids could either contain Longs (if we were called from java code) or Integers
     * (if we were called from Xml-Rpc). 
     * @param number An object to be converted (itr.next() from the list)
     * @return Returns a Long object or null if the object is neither a Long nor an Integer
     */
    private Long convertObjectToLong(Object number) {
        if (number instanceof Long) {
            return (Long) number;
        }
        else if (number instanceof Integer) {
            Integer integer = (Integer) number;
            return new Long(integer.longValue());
        }
        return null;
    }
    
    /**
     * Calls the rhn_channel.update_channel stored proc
     * @param channel The channel to update
     */
    private void updateChannel(Channel channel) {
        CallableMode m = ModeFactory.getCallableMode("Package_queries", "update_channel");
        Map params = new HashMap();
        params.put("cid", channel.getId());
        m.execute(params, new HashMap());
    }
 }
