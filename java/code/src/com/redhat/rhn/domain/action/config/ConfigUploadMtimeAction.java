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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.Server;

import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;


/**
 * ConfigUploadMtimeAction - Class representing ActionType.TYPE_CONFIGFILES_MTIME_UPLOAD: 23
 * @version $Rev$
 */
public class ConfigUploadMtimeAction extends Action {
    
    private Set configDateFileActions;
    
    private Set rhnActionConfigChannel;

    private ConfigDateDetails configDateDetails;
    
    /**
     * @return Returns the configDateFileActions.
     */
    public Set getConfigDateFileActions() {
        return configDateFileActions;
    }
    /**
     * @param configDateFileActionsIn The configDateFileActions to set.
     */
    public void setConfigDateFileActions(Set configDateFileActionsIn) {
        this.configDateFileActions = configDateFileActionsIn;
    }
    
    /**
     * Add a ConfigDateFileAction to the collection.
     * @param cdIn the ConfigDateFileAction to add
     */
    public void addConfigDateFileAction(ConfigDateFileAction cdIn) {
        if (configDateFileActions == null) {
            configDateFileActions = new HashSet();
        }
        cdIn.setParentAction(this);
        configDateFileActions.add(cdIn);
    }


    /**
     * @return Returns the configChannels associated with this Action
     */
    public ConfigChannel[] getConfigChannels() {
        Iterator i = rhnActionConfigChannel.iterator();
        Set retval = new HashSet();
        while (i.hasNext()) {
            ConfigChannelAssociation ca = (ConfigChannelAssociation)i.next();
            retval.add(ca.getConfigChannel());
        }
        return (ConfigChannel[])retval.toArray(new ConfigChannel[0]);
    }
    
    /**
     * @return Returns the servers associated with this Action
     */
    public Server[] getServers() {
        Iterator i = rhnActionConfigChannel.iterator();
        Set retval = new HashSet();
        while (i.hasNext()) {
            ConfigChannelAssociation ca = (ConfigChannelAssociation)i.next();
            retval.add(ca.getServer());
        }
        return (Server[])retval.toArray(new Server[0]);
    }

    /**
     * Add a ConfigChannel and a Server to this action.  They must be added in pairs.
     * 
     * @param ccIn the ConfigChannel we want to asssociate with this Action
     * @param serverIn the Server we want to associate with this Action
     */
    public void addConfigChannelAndServer(ConfigChannel ccIn, Server serverIn) {
        ConfigChannelAssociation newCA = new ConfigChannelAssociation();
        newCA.setConfigChannel(ccIn);
        newCA.setServer(serverIn);
        newCA.setModified(new Date());
        newCA.setCreated(new Date());
        if (rhnActionConfigChannel == null) {
            rhnActionConfigChannel = new HashSet();
        }
        newCA.setParentAction(this);
        rhnActionConfigChannel.add(newCA);
    }
    
    /**
     * @return Returns the rhnActionConfigChannel.
     */
    public Set getRhnActionConfigChannel() {
        return rhnActionConfigChannel;
    }
    /**
     * @param rhnActionConfigChannelIn The rhnActionConfigChannel to set.
     */
    public void setRhnActionConfigChannel(Set rhnActionConfigChannelIn) {
        this.rhnActionConfigChannel = rhnActionConfigChannelIn;
    }
    
    /**
     * @return Returns the configDateDetails.
     */
    public ConfigDateDetails getConfigDateDetails() {
        return configDateDetails;
    }
    /**
     * @param configDateDetailsIn The configDateDetails to set.
     */
    public void setConfigDateDetails(ConfigDateDetails configDateDetailsIn) {
        this.configDateDetails = configDateDetailsIn;
    }
    
}
