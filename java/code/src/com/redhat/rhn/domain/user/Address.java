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

/**
 * Class Address that reflects the DB representation of WEB_USER_SITE_INFO
 * and ancillary tables.
 * DB table: WEB_USER_SITE_INFO
 * @version $Rev: 623 $
 */
public interface Address {

    /**
    * Public string representing the marketing type of address
    */
    String TYPE_MARKETING = "M";

    /**
     * Getter for id
     * @return Id
     */
    Long getId();

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
     * Getter for type
     * @return Type
     */
    String getType();


    /**
     * Getter for created
     * @return created
     */
    Date getCreated();

    /**
     * Setter for created
     * @param createdIn New value for created
     */
    void setCreated(Date createdIn);

    /**
     * Getter for modified
     * @return modified
     */
    Date getModified();

    /**
     * Setter for modified
     * @param modifiedIn New value for modified
     */
    void setModified(Date modifiedIn);

}
