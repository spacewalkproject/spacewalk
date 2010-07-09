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

import org.apache.commons.lang.StringEscapeUtils;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev: 101893 $
 */
public class MultiOrgAllUserOverview extends BaseDto {
    private Long id;
    private String login;
    private String loginUc;
    private String userLogin;
    private String userFirstName;
    private String userLastName;
    private String orgName;
    private Long orgAdmin;
    private Long satAdmin;
    private String address;
    private Long orgId;

    /**
     *
     * @return orgId
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     *
     * @param orgIdIn orgId to set
     */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }

    /**
     *
     * @return email address
     */
    public String getAddress() {
        return address;
    }

    /**
     *
     * @param addressIn email address to set
     */
    public void setAddress(String addressIn) {
        this.address = addressIn;
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
     * @return the user's first name
     */
    public String getUserFirstName() {
        return StringEscapeUtils.escapeHtml(userFirstName);
    }

    /**
     * get the user's last name
     * @return the user's last name
     */
    public String getUserLastName() {
        return StringEscapeUtils.escapeHtml(userLastName);
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
     *
     * @return if user is a sat admin
     */
    public Long getSatAdmin() {
        return satAdmin;
    }

    /**
     *
     * @param satAdminIn if user is a org admin
     */
    public void setSatAdmin(Long satAdminIn) {
        this.satAdmin = satAdminIn;
    }

    /**
     *
     * @return if user is a org admin
     */
    public Long getOrgAdmin() {
        return orgAdmin;
    }

    /**
     *
     * @param orgAdminIn if user is a org admin
     */
    public void setOrgAdmin(Long orgAdminIn) {
        this.orgAdmin = orgAdminIn;
    }

    /**
     *
     * @return Org name for this record
     */
    public String getOrgName() {
        return orgName;
    }

    /**
     *
     * @param orgNameIn Org name to set for this record
     */
    public void setOrgName(String orgNameIn) {
        this.orgName = orgNameIn;
    }

}

