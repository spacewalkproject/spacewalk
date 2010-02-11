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


import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * Class AddressImpl that implements Address
 * @version $Rev: 623 $
 */
public class AddressImpl extends BaseDomainHelper implements Address {

    private Long id;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String zip;
    private String country;
    private String phone;
    private String fax;
    private String isPoBox;
    private String privType;

    /**
     * Protect the constructor
     */
    protected AddressImpl() {
    }

    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets the database id for this address.  This
     * is the unique id for this address.
     * @param idIn the in id
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getAddress1() {
        if (address1 == null) {
            address1 = " ";
        }
        return this.address1;
    }

    /**
     * {@inheritDoc}
     */
    public void setAddress1(String address1In) {
        this.address1 = address1In;
    }

    /**
     * {@inheritDoc}
     */
    public String getAddress2() {
        if (address2 == null) {
            address2 = " ";
        }
        return this.address2;
    }

    /**
     * {@inheritDoc}
     */
    public void setAddress2(String address2In) {
        this.address2 = address2In;
    }

    /**
     * {@inheritDoc}
     */
    public String getCity() {
        if (city == null) {
            city = " ";
        }
        return this.city;
    }

    /**
     * {@inheritDoc}
     */
    public void setCity(String cityIn) {
        this.city = cityIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getState() {
        if (state == null) {
            state = " ";
        }
        return this.state;
    }

    /**
     * {@inheritDoc}
     */
    public void setState(String stateIn) {
        this.state = stateIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getZip() {
        if (zip == null) {
            zip = " ";
        }
        return this.zip;
    }

    /**
     * {@inheritDoc}
     */
    public void setZip(String zipIn) {
        this.zip = zipIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getCountry() {
        if (country == null) {
            country = " ";
        }
        return this.country;
    }

    /**
     * {@inheritDoc}
     */
    public void setCountry(String countryIn) {
        this.country = countryIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getPhone() {
        if (phone == null) {
            phone = " ";
        }
        return this.phone;
    }

    /**
     * {@inheritDoc}
     */
    public void setPhone(String phoneIn) {
        this.phone = phoneIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getFax() {
        if (fax == null) {
            fax = " ";
        }
        return this.fax;
    }

    /**
     * {@inheritDoc}
     */
    public void setFax(String faxIn) {
        this.fax = faxIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getIsPoBox() {
        if (isPoBox == null) {
            isPoBox = "0";
        }
        return this.isPoBox;
    }

    /**
     * {@inheritDoc}
     */
    public void setIsPoBox(String isPoBoxIn) {
        this.isPoBox = isPoBoxIn;
    }

    /**
     * {@inheritDoc}
     */
    public String getType() {
        if (privType == null || privType.equals("")) {
            return Address.TYPE_MARKETING;
        }
        return privType;
    }

    /**
     * Output this object to a string
     * @return String value of AddressImpl object
     */
    public String toString() {
        StringBuffer retval = new StringBuffer();
        retval.append("{ID: " + getId());
        retval.append(", type: " + getType());
        retval.append(", created: " + getCreated());
        retval.append(", modified: " + getModified());
        retval.append(", address1: " + getAddress1() + "}");
        return retval.toString();
    }

    // NOTE THIS IS LEGACY REMOVE LATER!!
    /**
     * Set the private type of this address
     * @param pt string to set
     */
    public void setPrivType(String pt) {
        privType = pt;
    }

    /**
     * Get the private type.
     * @return string type
     */
    public String getPrivType() {
        return privType;
    }
}

