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
package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.StringUtils;

import java.util.Date;

/**
 * Location - Class representation of the table rhnServerLocation.
 * @version $Rev: 1 $
 */
public class Location extends BaseDomainHelper {

    private Long id;
    private Server server;
    private String machine;
    private String rack;
    private String room;
    private String building;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String country;
    private Date created;
    private Date modified;
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
     * Getter for server
     * @return server to get
    */
    public Server getServer() {
        return this.server;
    }

    /**
     * Setter for server
     * @param serverIn to set
    */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * Getter for machine
     * @return String to get
    */
    public String getMachine() {
        return this.machine;
    }

    /**
     * Setter for machine
     * @param machineIn to set
    */
    public void setMachine(String machineIn) {
        this.machine = machineIn;
    }

    /**
     * Getter for rack
     * @return String to get
    */
    public String getRack() {
        return this.rack;
    }

    /**
     * Setter for rack
     * @param rackIn to set
    */
    public void setRack(String rackIn) {
        this.rack = rackIn;
    }

    /**
     * Getter for room
     * @return String to get
    */
    public String getRoom() {
        return this.room;
    }

    /**
     * Setter for room
     * @param roomIn to set
    */
    public void setRoom(String roomIn) {
        this.room = roomIn;
    }

    /**
     * Getter for building
     * @return String to get
    */
    public String getBuilding() {
        return this.building;
    }

    /**
     * Setter for building
     * @param buildingIn to set
    */
    public void setBuilding(String buildingIn) {
        this.building = buildingIn;
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
     * Getter for created
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Setter for created
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Getter for modified
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Setter for modified
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * Returns true if all of the attributes are blank.
     * @return true if all of the attributes are blank.
     */
    public boolean isEmpty() {
        return StringUtils.isBlank(machine) &&
            StringUtils.isBlank(rack) &&
            StringUtils.isBlank(room) &&
            StringUtils.isBlank(building) &&
            StringUtils.isBlank(address1) &&
            StringUtils.isBlank(address2) &&
            StringUtils.isBlank(city) &&
            StringUtils.isBlank(state) &&
            StringUtils.isBlank(country);
    }

}
