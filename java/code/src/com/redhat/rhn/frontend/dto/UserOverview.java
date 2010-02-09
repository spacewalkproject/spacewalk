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

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.lang.StringEscapeUtils;

import java.util.Date;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 * 
 * @version $Rev$
 */
public class UserOverview extends BaseDto {
    private Long orgId;
    private Long id;
    private String login;
    private String loginUc;
    private String userLogin;
    private String userFirstName;
    private String userLastName;
    private String roleNames;
    private Integer serverCount;
    private Integer serverGroupCount;
    private Date lastLoggedIn;
    private String status;
    private Date changeDate;
    private String changedByFirstName;
    private String changedByLastName;

    /**
     * @return Returns the changeDate.
     */
    public String getChangeDate() {
        if (changeDate == null) {
            return "";
        }
        return LocalizationService.getInstance().formatDate(changeDate);
    }
    /**
     * @return Returns the changedByFirstName.
     */
    public String getChangedByFirstName() {
        return changedByFirstName;
    }
    /**
     * @param changedByFirstNameIn The changedByFirstName to set.
     */
    public void setChangedByFirstName(String changedByFirstNameIn) {
        this.changedByFirstName = changedByFirstNameIn;
    }
    /**
     * @return Returns the changedByLastName.
     */
    public String getChangedByLastName() {
        return changedByLastName;
    }
    /**
     * @param changedByLastNameIn The changedByLastName to set.
     */
    public void setChangedByLastName(String changedByLastNameIn) {
        this.changedByLastName = changedByLastNameIn;
    }
    /**
     * @return Returns the status.
     */
    public String getStatus() {
        return status;
    }
    /**
     * @param statusIn The status to set.
     */
    public void setStatus(String statusIn) {
        this.status = statusIn;
    }
    /**
     * get the id
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * get the user login
     * @return the user login
     */
    public String getUserLogin() {
        return StringEscapeUtils.escapeHtml(userLogin);
    }
    
    /**
     * get the login
     * @return the login
     */
    public String getLogin() {
        return login;
    }
    
    /**
     * get the login Uppercased
     * @return the login Uppercased
     */
    public String getLoginUc() {
        return loginUc;
    }
    
    /**
     * get the user's first name
     * Don't escape this using StringEscapeUtils.escapeHtml, because it should be 
     *   escaped at display time .
     * @return the user's first name
     */
    public String getUserFirstName() {
        return userFirstName;
    }
    
    /**
     * get the user's last name
     * Don't escape this using StringEscapeUtils.escapeHtml, because it should be 
     *   escaped at display time .
     * @return the user's last name
     */
    public String getUserLastName() {
        return userLastName;
    }
    
    /**
     * get the Role names
     * @return the role names
     */
    public String getRoleNames() {
        return roleNames;
    }
    
    /**
     * get the number of servers
     * @return the number of servers
     */
    public Integer getServerCount() {
        return serverCount;
    }
    
    /**
     * get the number of server groups
     * @return the number of server groups
     */
    public Integer getServerGroupCount() {
        return serverGroupCount;
    }
    
    /**
     * get the last logged in time
     * @return the last logged in time
     */
    public String getLastLoggedIn() {
        if (lastLoggedIn == null) {
            return "";
        }
        // return new SimpleDateFormat("yyyy-MM-dd hh:mm:ss a z").format(lastLoggedIn);
        return LocalizationService.getInstance().formatDate(lastLoggedIn);
    }

    /**
     * Set the id
     * @param i the id to set.
     */
    public void setId(Long i) {
        id = i;
    }

    /**
     * Set the login
     * @param l the login to set.
     */
    public void setLogin(String l) {
        login = l;
    }
    
    /**
     * Set the upper case login
     * @param l the login to set.
     */
    public void setLoginUc(String l) {
        loginUc = l;
    }
    
    /**
     * Set the user login
     * @param l the id to set.
     */
    public void setUserLogin(String l) {
        userLogin = l;
    }
    
    /**
     * Set the first name
     * @param fname the first nameto set.
     */
    public void setUserFirstName(String fname) {
        userFirstName = fname;
    }
    
    /**
     * Set the last name
     * @param lname the last name to set.
     */
    public void setUserLastName(String lname) {
        userLastName = lname;
    }
    
    /**
     * Set the role names
     * @param rnames the role names to set.
     */
    public void setRoleNames(String rnames) {
        roleNames = rnames;
    }
    
    /**
     * Set the server count
     * @param scount the server count to set.
     */
    public void setServerCount(Integer scount) {
        serverCount = scount;
    }
    
    /**
     * Set the server group count
     * @param sgcount the server group count to set.
     */
    public void setServerGroupCount(Integer sgcount) {
        serverGroupCount = sgcount;
    }
    
    /**
     * Set the last logged in time
     * @param lastLogin the last logged in time to set.
     */
    public void setLastLoggedIn(Date lastLogin) {
        
        if (lastLogin == null) {
            return;
        }
        lastLoggedIn = lastLogin;
    }
    /**
     * @param changeDateIn The changeDate to set.
     */
    public void setChangeDate(Date changeDateIn) {
        if (changeDateIn == null) {
            return;
        }
        changeDate = changeDateIn;
    }
    
    /**
     * gets the org ID
     * @return the org id
     */
    public Long getOrgId() {
        return orgId;
    }
    
    
    /**
     * Sets the org id
     * @param orgIdIn the orgid
     */    
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }
}

