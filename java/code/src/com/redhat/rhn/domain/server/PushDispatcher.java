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
package com.redhat.rhn.domain.server;

import java.util.Date;

/**
 * PushDispatcher - Class representation of the rhnPushDispatcher table.
 * Contains data used to connect to the osa-dispatcher and trigger a push
 * to clients.
 * 
 * @version $Rev$
 */
public class PushDispatcher {
    
    private Long id;
    private String jabberId;
    private String hostname;
    private Integer port;
    private Date lastCheckin;
    private Date created;
    private Date modified;
    
    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return created;
    }
    
    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }
    
    /** 
     * Getter for hostname 
     * @return String to get
    */
    public String getHostname() {
        return hostname;
    }
    
    /** 
     * Setter for hostname 
     * @param hostnameIn to set
    */
    public void setHostname(String hostnameIn) {
        this.hostname = hostnameIn;
    }
    
    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return id;
    }
    
    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /** 
     * Getter for jabberId 
     * @return String to get
    */
    public String getJabberId() {
        return jabberId;
    }
    
    /** 
     * Setter for jabberId 
     * @param jabberIdIn to set
    */
    public void setJabberId(String jabberIdIn) {
        this.jabberId = jabberIdIn;
    }
    
    /** 
     * Getter for lastCheckin 
     * @return Date to get
    */
    public Date getLastCheckin() {
        return lastCheckin;
    }
    
    /** 
     * Setter for lastCheckin 
     * @param lastCheckinIn to set
    */
    public void setLastCheckin(Date lastCheckinIn) {
        this.lastCheckin = lastCheckinIn;
    }
    
    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return modified;
    }
    
    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }
    
    /** 
     * Getter for port 
     * @return Integer to get
    */
    public Integer getPort() {
        return port;
    }
    
    /** 
     * Setter for port 
     * @param portIn to set
    */
    public void setPort(Integer portIn) {
        this.port = portIn;
    }

}
