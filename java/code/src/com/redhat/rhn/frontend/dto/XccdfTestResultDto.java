/**
 * Copyright (c) 2012 Red Hat, Inc.
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

import java.util.Date;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * @version $Rev$
 */
public class XccdfTestResultDto extends XccdfTestResultCounts {

    private Long xid;
    private Long sid;
    private String serverName;
    private String profile;
    private Date completed;
    private String path;

    /**
     * Returns id of xccdf:TestResult
     * @return the xid
     */
    public Long getXid() {
        return this.xid;
    }

    /**
     * Sets the id of xccdf:TestResult
     * @param xidIn to set
     */
    public void setXid(Long xidIn) {
        this.xid = xidIn;
    }

    /**
     * Returns id of targeted system
     * @return the sid
     */
    public Long getSid() {
        return this.sid;
    }

    /**
     * Sets the id of targeted system
     * @param sidIn to set
     */
    public void setSid(Long sidIn) {
        this.sid = sidIn;
    }

    /**
     * Returns name of the targeted system
     * @return the name
     */
    public String getServerName() {
        return this.serverName;
    }

    /**
     * Sets the name of the targeted system
     * @param serverNameIn to set
     */
    public void setServerName(String serverNameIn) {
        this.serverName = serverNameIn;
    }

    /**
     * Returns the name of assigned xccdf:Profile
     * @return the name
     */
    public String getProfile() {
        return this.profile;
    }

    /**
     * Sets the name of assigned xccdf:Profile
     * @param profileIn to set
     */
    public void setProfile(String profileIn) {
        this.profile = profileIn;
    }

    /**
     * Returns completetion time of scan
     * @return completetion time
     */
    public Date getCompleted() {
        return new Date(this.completed.getYear(), this.completed.getMonth(),
                this.completed.getDate(), this.completed.getHours(),
                this.completed.getMinutes(), this.completed.getSeconds());
    }

    /**
     * Sets the completetion time of scan
     * @param completedIn to set
     */
    public void setCompleted(Date completedIn) {
        this.completed = completedIn;
    }

    /**
     * Returns the path of xccdf document
     * @return the path
     */
    public String getPath() {
        return this.path;
    }

    /**
     * Sets the path of xccdf document
     * @param pathIn to set
     */
    public void setPath(String pathIn) {
        this.path = pathIn;
    }
}
