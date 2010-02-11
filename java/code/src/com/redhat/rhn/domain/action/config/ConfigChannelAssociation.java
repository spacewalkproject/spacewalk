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

import com.redhat.rhn.domain.action.ActionChild;
import com.redhat.rhn.domain.config.ConfigChannel;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * ConfigChannelAssocation - Class representation of the table rhnActionConfigChannel.  This
 * class has to exist because we need to map *two* objects with this mapping table instead
 * of the standard one.  usually with Hibernate you don't need a class to represent a 
 * mapping table but since this maps two objects we gotta have a class.
 * 
 * The mapping for this class is a composite element in Action.hbm.xml 
 * 
 * See:
 * http://www.hibernate.org/118.html#A11 
 * 
 * @version $Rev$
 */
public class ConfigChannelAssociation extends ActionChild implements Serializable {

    private Server server;
    private ConfigChannel configChannel;
    
    /**
     * @return Returns the configChannel.
     */
    public ConfigChannel getConfigChannel() {
        return configChannel;
    }
    /**
     * @param configChannelIn The configChannel to set.
     */
    public void setConfigChannel(ConfigChannel configChannelIn) {
        this.configChannel = configChannelIn;
    }
    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof ConfigChannelAssociation)) {
            return false;
        }
       
        ConfigChannelAssociation r = (ConfigChannelAssociation) obj;
        
        return new EqualsBuilder().append(r.getCreated(), getCreated())
                                  .append(r.getModified(), getModified())
                                  .append(r.getServer(), getServer())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getServer())
                                    .append(getCreated())
                                    .append(getModified())
                                    .toHashCode();
    }
    

}
