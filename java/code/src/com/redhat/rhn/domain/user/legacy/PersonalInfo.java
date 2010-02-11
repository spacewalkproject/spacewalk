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

package com.redhat.rhn.domain.user.legacy;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.common.util.MD5Crypt;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import java.util.Set;

/**
 * Class PersonalInfo that reflects the DB representation of WEB_USER_PERSONAL_INFO
 * DB table: WEB_USER_PERSONAL_INFO
 * @version $Rev: 59372 $
 */
public class PersonalInfo extends AbstractUserChild {

    private Long id;
    private String prefix;
    private String firstNames;
    private String lastName;
    private String company;
    private String title;
    private String phone;
    private String fax;
    private String email;
    private String password;
    private String login;
    private String loginUc;
    private Set<User> users;
    private Org defaultOrg;
    private UserInfo userInfo;
    
    /**
     * Create a new empty user
     */
    protected PersonalInfo() {
    }
    
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    
    /**
     * @param id The id to set.
     */
    public void setId(Long id) {
        this.id = id;
    }
    
    /**
     * @return Returns the login.
     */
    public String getLogin() {
        return login;
    }

    
    /**
     * @param loginIn The login to set.
     */
    public void setLogin(String loginIn) {
        this.setLoginUc(loginIn.toUpperCase());
        this.login = loginIn;
    }

    
    /**
     * @return Returns the loginUC.
     */
    public String getLoginUc() {
        return loginUc;
    }

    
    /**
     * @param loginUCIn The loginUC to set.
     */
    public void setLoginUc(String loginUCIn) {
        this.loginUc = loginUCIn;
    }

    /**
     * @return Returns the password.
     */
    public String getPassword() {
        return password;
    }
    
    /**
     * @param passwordIn The password to set.
     */
    public void setPassword(String passwordIn) {
        /**
         * If we're using encrypted passwords, encode the
         * password before setting it. Otherwise, just
         * set it.
         */
        if (Config.get().getBoolean(ConfigDefaults.WEB_ENCRYPTED_PASSWORDS)) {
            this.password = MD5Crypt.crypt(passwordIn);
        }
        else {
            this.password = passwordIn;
        }
    }

    protected void setUsers(Set<User> u) {
        users = u;
    }

    protected Set<User> getUsers() {
        return users;
    }

    /**
     * Gets the current value of prefix
     * @return String the current value
     */
    public String getPrefix() {
        return this.prefix;
    }

    /**
     * Sets the value of prefix to new value
     * @param prefixIn New value for prefix
     */
    public void setPrefix(String prefixIn) {
        this.prefix = prefixIn;
    }

    /**
     * Gets the current value of firstNames
     * @return String the current value
     */
    public String getFirstNames() {
        return this.firstNames;
    }

    /**
     * Sets the value of firstNames to new value
     * @param firstNamesIn New value for firstNames
     */
    public void setFirstNames(String firstNamesIn) {
        this.firstNames = firstNamesIn;
    }

    /**
     * Gets the current value of lastName
     * @return String the current value
     */
    public String getLastName() {
        return this.lastName;
    }

    /**
     * Sets the value of lastName to new value
     * @param lastNameIn New value for lastName
     */
    public void setLastName(String lastNameIn) {
        this.lastName = lastNameIn;
    }

    /**
     * Gets the current value of company
     * @return String the current value
     */
    public String getCompany() {
        return this.company;
    }

    /**
     * Sets the value of company to new value
     * @param companyIn New value for company
     */
    public void setCompany(String companyIn) {
        this.company = companyIn;
    }

    /**
     * Gets the current value of title
     * @return String the current value
     */
    public String getTitle() {
        return this.title;
    }

    /**
     * Sets the value of title to new value
     * @param titleIn New value for title
     */
    public void setTitle(String titleIn) {
        this.title = titleIn;
    }

    /**
     * Gets the current value of phone
     * @return String the current value
     */
    public String getPhone() {
        return this.phone;
    }

    /**
     * Sets the value of phone to new value
     * @param phoneIn New value for phone
     */
    public void setPhone(String phoneIn) {
        this.phone = phoneIn;
    }

    /**
     * Gets the current value of fax
     * @return String the current value
     */
    public String getFax() {
        return this.fax;
    }

    /**
     * Sets the value of fax to new value
     * @param faxIn New value for fax
     */
    public void setFax(String faxIn) {
        this.fax = faxIn;
    }

    /**
     * Gets the current value of email
     * @return String the current value
     */
    public String getEmail() {
        return this.email;
    }

    /**
     * Sets the value of email to new value
     * @param emailIn New value for email
     */
    public void setEmail(String emailIn) {
        this.email = emailIn;
    }


    
    /**
     * @return Returns the defaultOrg.
     */
    public Org getDefaultOrg() {
        return defaultOrg;
    }


    
    /**
     * @param defaultOrgIn The defaultOrg to set.
     */
    public void setDefaultOrg(Org defaultOrgIn) {
        this.defaultOrg = defaultOrgIn;
    }


    
    /**
     * @return Returns the userInfo.
     */
    public UserInfo getUserInfo() {
        return userInfo;
    }


    
    /**
     * @param userInfoIn The userInfo to set.
     */
    public void setUserInfo(UserInfo userInfoIn) {
        this.userInfo = userInfoIn;
    }
}
