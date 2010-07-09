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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.domain.action.Action;

import java.util.Date;

/**
 * KickstartSessionHistory - Class representation of the table rhnkickstartsessionhistory.
 * @version $Rev: 1 $
 */
public class KickstartSessionHistory {

    private Long id;

    private String message;

    private KickstartSession session;
    private KickstartSessionState state;
    private Action action;

    private Date time;
    private Date created;
    private Date modified;

    /**
     * Getter for id
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /**
     * Setter for id
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Getter for session
     * @return KickstartSession to get
    */
    public KickstartSession getSession() {
        return this.session;
    }

    /**
     * Setter for session
     * @param sessionIn to set
    */
    public void setSession(KickstartSession sessionIn) {
        this.session = sessionIn;
    }

    /**
     * Getter for action
     * @return Action to get
    */
    public Action getAction() {
        return this.action;
    }

    /**
     * Setter for action
     * @param actionIn to set
    */
    public void setAction(Action actionIn) {
        this.action = actionIn;
    }

    /**
     * Getter for state
     * @return KickstartSessionState to get
    */
    public KickstartSessionState getState() {
        return this.state;
    }

    /**
     * Setter for state
     * @param stateIn to set
    */
    public void setState(KickstartSessionState stateIn) {
        this.state = stateIn;
    }

    /**
     * Getter for time
     * @return Date to get
    */
    public Date getTime() {
        return this.time;
    }

    /**
     * Setter for time
     * @param timeIn to set
    */
    public void setTime(Date timeIn) {
        this.time = timeIn;
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
     * Getter for message
     * @return String to get
    */
    public String getMessage() {
        return this.message;
    }

    /**
     * Setter for message
     * @param messageIn to set
    */
    public void setMessage(String messageIn) {
        this.message = messageIn;
    }

}
