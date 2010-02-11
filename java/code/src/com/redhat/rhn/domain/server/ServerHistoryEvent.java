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

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;


/**
 * Class representation of the rhnserverhistory table
 * ServerHistoryEvent
 * @version $Rev$
 */
public class ServerHistoryEvent extends BaseDomainHelper {

    private Long id;
    private Server server;
    private String summary;
    private String details;

    /**
     * Constructor for ServerHistoryEvent
     */
    public ServerHistoryEvent() {
        
    }    
    
    
    /**
     * Getter for details
     * @return the details of the event
     */
    public String getDetails() {
        return details;
    }
    
    /**
     * Set the details of an event
     * @param detailsIn the details to set
     */
    public void setDetails(String detailsIn) {
        this.details = detailsIn;
    }
    
    /**
     * Getter for id
     * @return the id of the event
     */
    public Long getId() {
        return id;
    }
    
    
    /**
     * Set the id of an event
     * @param idIn the id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * Getter for server
     * @return the server associated with the event
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * associate a server with the event
     * @param serverIn the Server to associate
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }
    
    /**
     * Getter for summary
     * @return the summary of the event
     */
    public String getSummary() {
        return summary;
    }
    
    /**
     * sets the summary of the event
     * @param summaryIn the summary to set
     */
    public void setSummary(String summaryIn) {
        this.summary = summaryIn;
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        ServerHistoryEvent that = (ServerHistoryEvent) obj;
        return new EqualsBuilder().
                append(this.getId(), that.getId()).
                append(this.getServer(), that.getServer()).
                isEquals();
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {

       HashCodeBuilder builder = new HashCodeBuilder();
       builder.append(this.getId());
       builder.append(this.getServer());
       return builder.toHashCode();
    }
}

