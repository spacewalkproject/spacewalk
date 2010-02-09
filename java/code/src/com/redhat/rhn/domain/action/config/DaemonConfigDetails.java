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

import java.util.Date;

/**
 * DamonConfigAction - Class representation of the table rhnActionDaemonConfig.
 * 
 * @version $Rev$
 */
public class DaemonConfigDetails extends ActionChild {

    private Long actionId;
    private Long interval;
    private String restart;
    private Date daemonConfigCreated;
    private Date daemonConfigModified;

    /**
     * @return Returns the actionId.
     */
    public Long getActionId() {
        return actionId;
    }
    /**
     * @param actionIdIn The actionId to set.
     */
    public void setActionId(Long actionIdIn) {
        this.actionId = actionIdIn;
    }
    /** 
     * Getter for interval 
     * @return Long to get
    */
    public Long getInterval() {
        return this.interval;
    }

    /** 
     * Setter for interval 
     * @param intervalIn to set
    */
    public void setInterval(Long intervalIn) {
        this.interval = intervalIn;
    }

    /** 
     * Getter for restart 
     * @return String to get
    */
    public String getRestart() {
        return this.restart;
    }

    /** 
     * Setter for restart 
     * @param restartIn to set
    */
    public void setRestart(String restartIn) {
        this.restart = restartIn;
    }

    /** 
     * Getter for daemonConfigCreated 
     * @return Date to get
    */
    public Date getDaemonConfigCreated() {
        return this.daemonConfigCreated;
    }

    /** 
     * Setter for daemonConfigCreated 
     * @param daemonConfigCreatedIn to set
    */
    public void setDaemonConfigCreated(Date daemonConfigCreatedIn) {
        this.daemonConfigCreated = daemonConfigCreatedIn;
    }

    /** 
     * Getter for daemonConfigModified 
     * @return Date to get
    */
    public Date getDaemonConfigModified() {
        return this.daemonConfigModified;
    }

    /** 
     * Setter for daemonConfigModified 
     * @param daemonConfigModifiedIn to set
    */
    public void setDaemonConfigModified(Date daemonConfigModifiedIn) {
        this.daemonConfigModified = daemonConfigModifiedIn;
    }
}
