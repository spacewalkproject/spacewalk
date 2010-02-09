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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.config.ConfigurationFactory;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;

/**
 * ConfigGlobalDeployDto
 * @version $Rev$
 */
public class ConfigGlobalDeployDto extends BaseDto {

    private Long id;
    private Long revId;
    private String name;
    private Long outrankedCount;
    private Long overrideCount;
    private boolean deployable;
    
    /**
     * @return true if deployable, as in config capable + featured
     */
    public boolean isDeployable() {
        return deployable;
    }

    
    /**
     * set true if ht efile is deployable.
     * @param deployableIn true if deployable 
     */
    public void setDeployable(Integer deployableIn) {
        this.deployable = Integer.valueOf(1).equals(deployableIn);
    }

    /**
     * @return system-id of the system whose deploy-state is the rest of the Dto data
     */
    public Long getId() {
        return this.id;
    }
    
    /**
     * @param inId sets the system-id
     */
    public void setId(Long inId) {
        this.id = inId;
    }
    
    /**
     * @return system name
     */
    public String getName() {
        return this.name;
    }

    /**
     * Sets system-name of system getId()
     * @param inName system name
     */
    public void setName(String inName) {
        this.name = inName;
    }

    /**
     * @return number of channels w/files w/same name as getRevId() that this system has 
     * set to a higher priority than getRevId().getFile().getChannel()
     */
    public Long getOutrankedCount() {
        return this.outrankedCount;
    }

    /**
     * @param outranked # outranking channels
     */
    public void setOutrankedCount(Long outranked) {
        this.outrankedCount = outranked;
    }

    /**
     * @return 1 if there's a local-override channel containing a file w/the same name
     * as getRevId()
     */
    public Long getOverrideCount() {
        return this.overrideCount;
    }
    
    /**
     * Set override count
     * @param overridden # local channels overriding this file (0 or 1)
     */
    public void setOverrideCount(Long overridden) {
        this.overrideCount = overridden;
    }
    
    /**
     * @return get the revision-id of a specific file whose deploy status we're 
     * storing in this Dto
     */
    public Long getRevId() {
        return this.revId;
    }

    /**
     * Set the rev-id fo the file of interest
     * @param crid revision-id
     */
    public void setRevId(Long crid) {
        this.revId = crid;
    }

    /**
     * @return Given that rev-id is set, return the associated ConfigRevision
     * object
     */
    public ConfigRevision getLastDeployedRevision() {
        ConfigRevision cr = null;
        if (getRevId() != null) {
            Long crid = new Long(getRevId().longValue());
            cr = ConfigurationFactory.
                lookupConfigRevisionById(crid);
        }
        return cr;
    }
    
    /**
     * Given that id is set, return the associated Server object
     * @return serv whose id is getId()
     */
    public Server getServer() {
        Server s = null;
        if (getId() != null) {
            Long sid = new Long(getId().longValue());
            s = ServerFactory.lookupById(sid);
        }
        return s;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean isSelectable() {
        return getOutrankedCount().intValue() == 0 && 
                    getOverrideCount().intValue() == 0 && isDeployable();
    }
    
    
    
    
}
