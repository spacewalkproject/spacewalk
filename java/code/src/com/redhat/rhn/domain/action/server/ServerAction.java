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
package com.redhat.rhn.domain.action.server;

import com.redhat.rhn.domain.action.ActionChild;
import com.redhat.rhn.domain.action.ActionStatus;
import com.redhat.rhn.domain.server.Server;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ServerActionDetails - Class representation of the table rhnServerAction.
 * 
 * @version $Rev$
 */
public class ServerAction extends ActionChild implements Serializable {

    private Long resultCode;
    private Long serverId;
    private String resultMsg;
    private Date pickupTime;
    private Date completionTime;
    private Long remainingTries;
    
    private ActionStatus status;
    private Server server;

    
    /** 
     * Getter for status 
     * @return ActionStatus to get
    */
    public ActionStatus getStatus() {
        return this.status;
    }

    /** 
     * Setter for status 
     * @param statusIn to set
    */
    public void setStatus(ActionStatus statusIn) {
        this.status = statusIn;
    }

    /** 
     * Getter for resultCode 
     * @return Long to get
    */
    public Long getResultCode() {
        return this.resultCode;
    }

    /** 
     * Setter for resultCode 
     * @param resultCodeIn to set
    */
    public void setResultCode(Long resultCodeIn) {
        this.resultCode = resultCodeIn;
    }

    /** 
     * Getter for resultMsg 
     * @return String to get
    */
    public String getResultMsg() {
        return this.resultMsg;
    }

    /** 
     * Setter for resultMsg 
     * @param resultMsgIn to set
    */
    public void setResultMsg(String resultMsgIn) {
        this.resultMsg = resultMsgIn;
    }

    /** 
     * Getter for pickupTime 
     * @return Date to get
    */
    public Date getPickupTime() {
        return this.pickupTime;
    }

    /** 
     * Setter for pickupTime 
     * @param pickupTimeIn to set
    */
    public void setPickupTime(Date pickupTimeIn) {
        this.pickupTime = pickupTimeIn;
    }

    /** 
     * Getter for completionTime 
     * @return Date to get
    */
    public Date getCompletionTime() {
        return this.completionTime;
    }

    /** 
     * Setter for completionTime 
     * @param completionTimeIn to set
    */
    public void setCompletionTime(Date completionTimeIn) {
        this.completionTime = completionTimeIn;
    }

    /** 
     * Getter for remainingTries 
     * @return Long to get
    */
    public Long getRemainingTries() {
        return this.remainingTries;
    }

    /** 
     * Setter for remainingTries 
     * @param remainingTriesIn to set
    */
    public void setRemainingTries(Long remainingTriesIn) {
        this.remainingTries = remainingTriesIn;
    }
    
    /**
     * Gets the Server associated with this ServerAction record
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }
    
    /**
     * Sets the Server associated with this ServerAction record
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
        this.setServerId(serverIn.getId());
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof ServerAction)) {
            return false;
        }
        ServerAction castOther = (ServerAction) other;
        return new EqualsBuilder().append(getParentAction(), castOther.getParentAction())
                                  .append(server, castOther.getServer()).isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getParentAction().getId()).append(server)
                .toHashCode();
    }

    
    /**
     * get the server ID
     * @return the server id
     */
    public Long getServerId() {
        return serverId;
    }

    /**
     * Set the server id
     * @param serverIdIn the serverid 
     */
    public void setServerId(Long serverIdIn) {
        this.serverId = serverIdIn;
    }

}
