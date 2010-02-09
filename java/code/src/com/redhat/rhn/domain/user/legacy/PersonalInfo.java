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

import com.redhat.rhn.domain.user.User;

/**
 * Class PersonalInfo that reflects the DB representation of WEB_USER_PERSONAL_INFO
 * DB table: WEB_USER_PERSONAL_INFO
 * @version $Rev: 59372 $
 */
public class PersonalInfo extends AbstractUserChild {

    private String prefix;
    private String firstNames;
    private String lastName;
    private String company;
    private String title;
    private String phone;
    private String fax;
    private String email;
    private User user;

    /**
     * Create a new empty user
     */
    protected PersonalInfo() {
    }

    protected void setUser(User u) {
        user = u;
    }

    protected User getUser() {
        return user;
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
}
