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
import com.redhat.rhn.domain.config.ConfigRevision;
import com.redhat.rhn.domain.server.Server;

import java.util.Date;

/**
 * ConfigRevisionAction - Class representation of the table rhnActionConfigRevision.
 * 
 * @version $Rev$
 */
public class ConfigRevisionAction extends ActionChild {

    private Long id;
    private Long failureId;
    private Date created;
    private Date modified;
    
    private Server server;
    private ConfigRevision configRevision;
    private ConfigRevisionActionResult configRevisionActionResult;
    
    /**
     * Get the id
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * Set the id
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    /** 
     * Getter for failureId 
     * @return Long to get
    */
    public Long getFailureId() {
        return this.failureId;
    }

    /** 
     * Setter for failureId 
     * @param failureIdIn to set
    */
    public void setFailureId(Long failureIdIn) {
        this.failureId = failureIdIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }


    /**
     * Get the server object
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * Set the server object
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }
    
    /**
     * Get the configRevision object
     * @return ConfigRevision the configRevision.
     */
    public ConfigRevision getConfigRevision() {
        return configRevision;
    }
    
    /**
     * Set the configRevision object
     * @param configRevisionIn The configRevision to set.
     */
    public void setConfigRevision(ConfigRevision configRevisionIn) {
        this.configRevision = configRevisionIn;
    }

    /**
     * Get the ConfigRevisionActionResult
     * @return Returns the configRevisionActionResult.
     */
    public ConfigRevisionActionResult getConfigRevisionActionResult() {
        return configRevisionActionResult;
    }
    /**
     * Set the ConfigRevisionActionResult
     * @param configRevisionActionResultIn The configRevisionActionResult to set.
     */
    public void setConfigRevisionActionResult(
            ConfigRevisionActionResult configRevisionActionResultIn) {
        this.configRevisionActionResult = configRevisionActionResultIn;
    }
        
}
