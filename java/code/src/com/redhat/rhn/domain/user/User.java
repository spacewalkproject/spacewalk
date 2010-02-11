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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.role.Role;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.legacy.PersonalInfo;
import com.redhat.rhn.domain.user.legacy.UserInfo;

import java.util.Date;
import java.util.List;
import java.util.Set;

/**
 * Class User that reflects the DB representation of web_contact
 * and ancillary tables.
 * DB table: web_contact
 * @version $Rev$
 */
public interface User {
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

    // ******************************************
    // RhnUser Interface
    // ******************************************
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
     * Gets the current value of pageSize
     * @return int the current value
     */
    int getPageSize();

    /**
     * Sets the value of pageSize to new value
     * @param pageSizeIn New value for pageSize
     */
    void setPageSize(int pageSizeIn);

    /**
     * Gets the current value of usePamAuthentication
     * @return String the current value
     */
    boolean getUsePamAuthentication();

    /**
     * Sets the value of usePamAuthentication to new value
     * @param usePamAuthenticationIn New value for usePamAuthentication
     */
    void setUsePamAuthentication(boolean usePamAuthenticationIn);

    /**
     * Gets the current value of showSystemGroupList
     * @return String the current value
     */
    String getShowSystemGroupList();

    /**
     * Sets the value of showSystemGroupList to new value
     * @param showSystemGroupListIn New value for showSystemGroupList
     */
    void setShowSystemGroupList(String showSystemGroupListIn);

    /**
     * Gets the roles assigned to this user.
     * The Map returned from this method has been decorated
     * with a call to {@link java.util.Collections#unmodifiableMap}
     * in order to enforce the rule that roles are not changeable
     * during runtime.
     * If this requirement changes then we will need to remove this
     * restriction later.
     * @return Set of Roles that this user has
     */
    Set<Role> getRoles();

    /**
    * Check to see if this user has the passed in label
    * in the Collection of Roles assigned to this user
    * @param label the label used to lookup
    * @return if the user has the role assigned or not.
    */
    boolean hasRole(Role label);

    /**
    * Add a role to this User's Role Set.
    * @param label The label of the Role you want to add.
    */
    void addRole(Role label);

    /**
    * Remove a role to this User's Role Set.
    * @param label The label of the Role you want to remove.
    */
    void removeRole(Role label);

    /**
     * Authenticate the user
     * @todo  Deal with encoded passwords.
     * @param thePassword password to check if matches against this User's
     * @return boolean if the password is correct
     */
    boolean authenticate(String thePassword);

    /**
     * helper method to get the associated Org for the user
     * @return Org associated with this User
     */
    Org getOrg();

    /**
     * set the org of this user
     * @param orgIn to set
     */

    void setOrg(Org orgIn);

    /**
     * Gets the Set of SystemGroup IDs (Long) associated with this User.
     * @return Set the current value
     */
    Set getDefaultSystemGroupIds();

    /**
     * Updates the User's Default System groups.  This
     * @param groups Set of Long System Group IDs
     */
    void setDefaultSystemGroupIds(Set groups);

    /**
     * Tells whether or not a user is disabled
     * @return Returns true if the user is disabled
     */
    boolean isDisabled();

    /**
     * Add a change to the users stateChanges set
     * @param change The change to add
     */
    void addChange(StateChange change);

    /**
     * Returns the set of state changes for a user. These consist
     * of disable/enable events in rhnWebContactChangeLog
     * @return Returns the set of stateChanges
     */
    Set getStateChanges();

    /**
     * Set the notification method set.
     * @param methodsIn notification methods
     */
    void setNotificationMethods(Set methodsIn);

    /**
     * Get the notification methods set
     * @return Set notification methods
     */
    Set getNotificationMethods();



    // ******************************************
    // RhnEUserProxy Interface
    // ******************************************
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
     * Gets the current value of loginUc
     * @return String the current value
     */
    String getLoginUc();

    /**
     * Sets the value of loginUc to new value
     * @param loginUcIn New value for loginUc
     */
    void setLoginUc(String loginUcIn);

    /**
     * Gets the current value of password
     * @return String the current value
     */
    String getPassword();

    /**
     * Sets the password.
     * @param passwordIn the password to set
     */
    void setPassword(String passwordIn);

    /**
     * Gets the current value of lastLoggedIn
     * @return Date the current value
     */
    Date getLastLoggedIn();

    /**
     * Sets the value of lastLoggedIn to new value
     * @param lastLoggedInIn New value for lastLoggedIn
     */
    void setLastLoggedIn(Date lastLoggedInIn);

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
     * Sets the email value
     * @param emailIn the email value to set
     */
    void setEmail(String emailIn);

    /**
     * Gets the current timezone
     * @return the current timezone
     */
    RhnTimeZone getTimeZone();

    /**
     * Sets the current timezone
     * @param timeZoneIn The timezone to be set
     */
    void setTimeZone(RhnTimeZone timeZoneIn);

    /**
     *
     * @param companyIn the company value
     */
    void setCompany(String companyIn);

    /**
     *
     * @return returns the company value
     */
    String getCompany();

    // ***********************************
    // Address Interface
    // ***********************************
    /**
     * Set the address value.
     * @param addIn the address to set
     */
    //void setAddress(Address addIn);

    /**
     * Get the address object for this user.
     * @return Address of this user
     */
    //Address getAddress();

    /**
     * Getter for address1
     * @return Address1
     */
    String getAddress1();

    /**
     * Setter for address1
     * @param address1In New value for address1
     */
    void setAddress1(String address1In);

    /**
     * Getter for address2
     * @return Address2
     */
    String getAddress2();

    /**
     * Setter for address2
     * @param address2In New value for address2
     */
    void setAddress2(String address2In);

    /**
     * Getter for city
     * @return City
     */
    String getCity();

    /**
     * Setter for city
     * @param cityIn New value for city
     */
    void setCity(String cityIn);

    /**
     * Getter for state
     * @return State
     */
    String getState();

    /**
     * Setter for state
     * @param stateIn New value for state
     */
    void setState(String stateIn);

    /**
     * Getter for zip
     * @return Zip
     */
    String getZip();

    /**
     * Setter for zip
     * @param zipIn New value for zip
     */
    void setZip(String zipIn);

    /**
     * Getter for country
     * @return Country
     */
    String getCountry();

    /**
     * Setter for country
     * @param countryIn New value for country
     */
    void setCountry(String countryIn);

    /**
     * Getter for phone
     * @return Phone
     */
    String getPhone();

    /**
     * Setter for phone
     * @param phoneIn New value for phone
     */
    void setPhone(String phoneIn);

    /**
     * Getter for fax
     * @return Fax
     */
    String getFax();

    /**
     * Setter for fax
     * @param faxIn New value for fax
     */
    void setFax(String faxIn);

    /**
     * Getter for isPoBox
     * @return isPoBox
     */
    String getIsPoBox();

    /**
     * Setter for isPoBox
     * @param isPoBoxIn New value for isPoBox
     */
    void setIsPoBox(String isPoBoxIn);

    /**
     * Retrieves the set of  Pane object instances
     * This method retrieves the
     * @return Set of panes used by the user
     */
    Set getHiddenPanes();

    /**
     * Sets the set of PaneObjects instances.
     * @param panes a set of pane objects
     */
    void setHiddenPanes(Set panes);
    
    /**
     * Returns the user's preferred locale
     * @return String locale
     */
    String getPreferredLocale();
    
    /**
     * Sets the user's preferred locale
     * @param locale overrides browser locale
     */
    void setPreferredLocale(String locale);
    
    /**
     * Sets the value of emailNotify to new value
     * @param emailNotifyIn New value for emailNotify
     */
    void setEmailNotify(int emailNotifyIn);
    
    /**
     * Gets the current value of emailNotify
     * @return int the current value
     */
    int getEmailNotify();
    
    /**
     * Retrieves the set of server groups associated 
     * to this user.
     * Note: this is NOT getAllServerGroups
     * this is getAssociatedServerGroups
     * Subtle difference here is, 
     * if the user is an ORG Admin the return value 
     * is an empty list, since all the servergroups  
     * are implicitly subscribed.
     * In DB terms the list here directly maps 
     * to rhnUserServerGroupPerms 
     * @return set of server groups
     */
    Set getAssociatedServerGroups();
    
    /**
     * Removes all the associated server groups.
     * This step becomes necessary when 
     */
    //void clearAssociatedServerGroups();

    /**
     * Returns the set of Server's this user has permissions to manage.
     * @return set of servers
     */
    Set getServers();

    /**
     * Give this user permission to manage a server.
     * @param server Server to add permission for.
     */
    void addServer(Server server);

    /**
     * Remover permission for the user to manage this server.
     * @param server Server to remove permission for.
     */
    void removeServer(Server server);
    
    public UserInfo getUserInfo();
    
    public List<Org> getUserOrgs();
    
    public void setPersonalInfo(PersonalInfo pi);
    
    public PersonalInfo getPersonalInfo();
    
    
}
