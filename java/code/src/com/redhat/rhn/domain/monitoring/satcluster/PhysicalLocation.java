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
package com.redhat.rhn.domain.monitoring.satcluster;

import java.util.Date;

/**
 * PhysicalLocation - Class representation of the table rhn_physical_location.
 * @version $Rev: 1 $
 */
public class PhysicalLocation {

    private Long id;
    private String locationName;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String country;
    private String zipcode;
    private String phone;
    private String deleted;
    private String lastUpdateUser;
    private Date lastUpdateDate;
    private Long customerId;
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
     * Getter for locationName
     * @return String to get
    */
    public String getLocationName() {
        return this.locationName;
    }

    /**
     * Setter for locationName
     * @param locationNameIn to set
    */
    public void setLocationName(String locationNameIn) {
        this.locationName = locationNameIn;
    }

    /**
     * Getter for address1
     * @return String to get
    */
    public String getAddress1() {
        return this.address1;
    }

    /**
     * Setter for address1
     * @param address1In to set
    */
    public void setAddress1(String address1In) {
        this.address1 = address1In;
    }

    /**
     * Getter for address2
     * @return String to get
    */
    public String getAddress2() {
        return this.address2;
    }

    /**
     * Setter for address2
     * @param address2In to set
    */
    public void setAddress2(String address2In) {
        this.address2 = address2In;
    }

    /**
     * Getter for city
     * @return String to get
    */
    public String getCity() {
        return this.city;
    }

    /**
     * Setter for city
     * @param cityIn to set
    */
    public void setCity(String cityIn) {
        this.city = cityIn;
    }

    /**
     * Getter for state
     * @return String to get
    */
    public String getState() {
        return this.state;
    }

    /**
     * Setter for state
     * @param stateIn to set
    */
    public void setState(String stateIn) {
        this.state = stateIn;
    }

    /**
     * Getter for country
     * @return String to get
    */
    public String getCountry() {
        return this.country;
    }

    /**
     * Setter for country
     * @param countryIn to set
    */
    public void setCountry(String countryIn) {
        this.country = countryIn;
    }

    /**
     * Getter for zipcode
     * @return String to get
    */
    public String getZipcode() {
        return this.zipcode;
    }

    /**
     * Setter for zipcode
     * @param zipcodeIn to set
    */
    public void setZipcode(String zipcodeIn) {
        this.zipcode = zipcodeIn;
    }

    /**
     * Getter for phone
     * @return String to get
    */
    public String getPhone() {
        return this.phone;
    }

    /**
     * Setter for phone
     * @param phoneIn to set
    */
    public void setPhone(String phoneIn) {
        this.phone = phoneIn;
    }

    /**
     * Getter for deleted
     * @return String to get
    */
    public String getDeleted() {
        return this.deleted;
    }

    /**
     * Setter for deleted
     * @param deletedIn to set
    */
    public void setDeleted(String deletedIn) {
        this.deleted = deletedIn;
    }

    /**
     * Getter for lastUpdateUser
     * @return String to get
    */
    public String getLastUpdateUser() {
        return this.lastUpdateUser;
    }

    /**
     * Setter for lastUpdateUser
     * @param lastUpdateUserIn to set
    */
    public void setLastUpdateUser(String lastUpdateUserIn) {
        this.lastUpdateUser = lastUpdateUserIn;
    }

    /**
     * Getter for lastUpdateDate
     * @return Date to get
    */
    public Date getLastUpdateDate() {
        return this.lastUpdateDate;
    }

    /**
     * Setter for lastUpdateDate
     * @param lastUpdateDateIn to set
    */
    public void setLastUpdateDate(Date lastUpdateDateIn) {
        this.lastUpdateDate = lastUpdateDateIn;
    }

    /**
     * Getter for customerId
     * @return Long to get
    */
    public Long getCustomerId() {
        return this.customerId;
    }

    /**
     * Setter for customerId
     * @param customerIdIn to set
    */
    public void setCustomerId(Long customerIdIn) {
        this.customerId = customerIdIn;
    }

}
