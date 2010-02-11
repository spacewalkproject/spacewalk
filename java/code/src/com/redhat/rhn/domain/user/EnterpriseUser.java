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
package com.redhat.rhn.domain.user;

import java.util.Date;
import java.util.Iterator;

/**
 * The interface definition of the enterprise user.
 * EnterpriseUser
 * @version $Rev$
 */
public interface EnterpriseUser {
    /**
     * Gets the current value of id
     * @return long the current value
     */
    Long getId();

    /**
     * Set the current value of id
     * @param l long value
     */
    void setId(Long l);

    /**
     * Add a User to this instance.
     * @param u a User to add
     */
    void addUser(User u);

    /**
     * Remove a User from this instance.
     * @param u the User to remove
     */
    void removeUser(User u);

    /**
     * Return an iterator over all Users associated with
     * this instance.
     * @return  an iterator over all users
     */
    Iterator allUsers();

    /**
     * Find the user having the id provided. Return null if
     * not found.
     * @param id to use
     * @return User or null
     */
    User findUserById(Long id);


    /**
     * Gets the current value of login
     * @return String the current value
     */
    String getLogin();

    /**
     * Sets the value of login to new value
     * @param loginIn New value for login
     */
    void setLogin(String loginIn);

    /**
     * Gets the current value of password
     * @return String the current value
     */
    String getPassword();

    /**
     * Sets the value of password to new value
     * @param passwordIn New value for password
     */
    void setPassword(String passwordIn);

    /**
     * Gets the current value of prefix
     * @return String the current value
     */
    String getPrefix();

    /**
     * Sets the value of prefix to new value
     * @param prefixIn New value for prefix
     */
    void setPrefix(String prefixIn);

    /**
     * Gets the current value of firstNames
     * @return String the current value
     */
    String getFirstNames();

    /**
     * Sets the value of firstNames to new value
     * @param firstNamesIn New value for firstNames
     */
    void setFirstNames(String firstNamesIn);

    /**
     * Gets the current value of lastName
     * @return String the current value
     */
    String getLastName();

    /**
     * Sets the value of lastName to new value
     * @param lastNameIn New value for lastName
     */
    void setLastName(String lastNameIn);

    /**
     * Gets the current value of title
     * @return String the current value
     */
    String getTitle();

    /**
     * Sets the value of title to new value
     * @param titleIn New value for title
     */
    void setTitle(String titleIn);

    /**
     * Gets the current value of email
     * @return String the current value
     */
    String getEmail();

    /**
     * Sets the value of email to new value
     * @param emailIn New value for email
     */
    void setEmail(String emailIn);

    /**
     * Getter for lastLoggedIn
     * @return lastLoggedIn
     */
    Date getLastLoggedIn();

    /**
     * Setter for lastLoggedIn
     * @param lastLoggedInIn New value for lastLoggedIn
     */
    void setLastLoggedIn(Date lastLoggedInIn);

    /**
     * Gets the current value of created
     * @return Date the current value
     */
    Date getCreated();

    /**
     * Sets the value of created to new value
     * @param createdIn New value for created
     */
    void setCreated(Date createdIn);

    /**
     * Gets the current value of modified
     * @return Date the modified date
     */
    Date getModified();


    /**
     * Set the value of the modified date.
     * @param modifiedIn new value for modified
     */
    void setModified(Date modifiedIn);

    /**
     * Get the timezone for this enterprise user.
     * @return Returns the timeZone.
     */
    RhnTimeZone getTimeZone();

    /**
     * Set the timezone for this enterprise user.
     * @param timeZoneIn The timeZone to set.
     */
    void setTimeZone(RhnTimeZone timeZoneIn);

    /**
     * Set the address for this enterprise user.
     * @param address the address to set
     */
    void setAddress(Address address);

    /**
     * Get the address for this enterprise user.
     * @return returns the address info
     */
    Address getAddress();

    /**
     * Set the company for this enterprise user
     * @param companyIn the company value
     */
    void setCompany(String companyIn);

    /**
     * Get the company for this enterprise user.
     * @return returns the company value
     */
    String getCompany();
}
