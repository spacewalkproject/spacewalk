/**
 * Copyright (c) 2008 Red Hat, Inc.
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
package com.redhat.satellite.search.db.models;

/**
 * Server
 * @version $Rev$
 */
public class Server {

    private long id;
    private String name;
    private String info;
    private String description;

    /* Location */
    private String machine;
    private String rack;
    private String room;
    private String building;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String country;

    /* Hardware Info */
    /** Waiting for implementation
    private String hwClass;
    private String hwBus;
    private String hwDevice;
    private String hwDriver;
    private String hwDescription;
    private String hwVendor_id;
    private String hwDeviceId;
    private String hwSubvendorId;
    private String hwSubdeviceId;
    **/

    /* Network Info */
    private String hostname;
    private String ipaddr;

    /* DMI Info */
    private String dmiVendor;
    private String dmiSystem;
    private String dmiProduct;
    private String dmiBiosVendor;
    private String dmiBiosVersion;
    private String dmiBiosRelease;
    private String dmiAsset;
    private String dmiBoard;

    /**
    private String snapshotTagName;

    private Long channelId;
    private Long securityErrata;
    private Long bugErrata;
    private Long enhancementErrata;
    private Long outdatedPackages;
    private String serverName;
    private Long serverAdmins;
    private Long groupCount;
    private Long noteCount;
    private Date modified;
    private String channelLabels;
    private Long historyCount;
    private Long lastCheckinDaysAgo;
    private Long pendingUpdates;

    private String nameOfUserWhoRegisteredSystem;
    private String os;
    private String release;
    private String serverArchName;
    private Date lastCheckin;
    private Date created;
    private Long locked;
    private String monitoringStatus;

    private List status;
    private List actionId;
    private boolean rhnSatellite;
    private boolean rhnProxy;
    private List entitlement;
    private List serverGroupTypeId;
    private List entitlementPermanent;
    private List entitlementIsBase;
    private boolean selectable;
    private String statusDisplay;
    private String lastCheckinString;
    private boolean isVirtualHost;
    private boolean isVirtualGuest;
    **/


    /**
     * @return the id
     */
    public long getId() {
        return id;
    }

    /**
     * @param idIn the id to set
     */
    public void setId(long idIn) {
        this.id = idIn;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }
    /**
     * @param nameIn the name to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return the info
     */
    public String getInfo() {
        return info;
    }

    /**
     * @param infoIn the info to set
     */
    public void setInfo(String infoIn) {
        this.info = infoIn;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn the description to set
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * @return the machine
     */
    public String getMachine() {
        return machine;
    }

    /**
     * @param machineIn the machine to set
     */
    public void setMachine(String machineIn) {
        this.machine = machineIn;
    }

    /**
     * @return the rack
     */
    public String getRack() {
        return rack;
    }

    /**
     * @param rackIn the rack to set
     */
    public void setRack(String rackIn) {
        this.rack = rackIn;
    }

    /**
     * @return the room
     */
    public String getRoom() {
        return room;
    }

    /**
     * @param roomIn the room to set
     */
    public void setRoom(String roomIn) {
        this.room = roomIn;
    }

    /**
     * @return the building
     */
    public String getBuilding() {
        return building;
    }

    /**
     * @param buildingIn the building to set
     */
    public void setBuilding(String buildingIn) {
        this.building = buildingIn;
    }

    /**
     * @return the address1
     */
    public String getAddress1() {
        return address1;
    }

    /**
     * @param address1In the address1 to set
     */
    public void setAddress1(String address1In) {
        this.address1 = address1In;
    }

    /**
     * @return the address2
     */
    public String getAddress2() {
        return address2;
    }

    /**
     * @param address2In the address2 to set
     */
    public void setAddress2(String address2In) {
        this.address2 = address2In;
    }

    /**
     * @return the city
     */
    public String getCity() {
        return city;
    }

    /**
     * @param cityIn the city to set
     */
    public void setCity(String cityIn) {
        this.city = cityIn;
    }

    /**
     * @return the state
     */
    public String getState() {
        return state;
    }

    /**
     * @param stateIn the state to set
     */
    public void setState(String stateIn) {
        this.state = stateIn;
    }

    /**
     * @return the country
     */
    public String getCountry() {
        return country;
    }

    /**
     * @param countryIn the country to set
     */
    public void setCountry(String countryIn) {
        this.country = countryIn;
    }

    /**
     * @return the hostname
     */
    public String getHostname() {
        return hostname;
    }

    /**
     * @param hostnameIn the hostname to set
     */
    public void setHostname(String hostnameIn) {
        this.hostname = hostnameIn;
    }

    /**
     * @return the ipaddr
     */
    public String getIpaddr() {
        return ipaddr;
    }

    /**
     * @param ipaddrIn the ipaddr to set
     */
    public void setIpaddr(String ipaddrIn) {
        this.ipaddr = ipaddrIn;
    }

    /**
     * @return the dmiVendor
     */
    public String getDmiVendor() {
        return dmiVendor;
    }

    /**
     * @param dmiVendorIn the dmiVendor to set
     */
    public void setDmiVendor(String dmiVendorIn) {
        this.dmiVendor = dmiVendorIn;
    }

    /**
     * @return the dmiSystem
     */
    public String getDmiSystem() {
        return dmiSystem;
    }

    /**
     * @param dmiSystemIn the dmiSystem to set
     */
    public void setDmiSystem(String dmiSystemIn) {
        this.dmiSystem = dmiSystemIn;
    }

    /**
     * @return the dmiProduct
     */
    public String getDmiProduct() {
        return dmiProduct;
    }

    /**
     * @param dmiProductIn the dmiProduct to set
     */
    public void setDmiProduct(String dmiProductIn) {
        this.dmiProduct = dmiProductIn;
    }

    /**
     * @return the dmiBiosVendor
     */
    public String getDmiBiosVendor() {
        return dmiBiosVendor;
    }

    /**
     * @param dmiBiosVendorIn the dmiBiosVendor to set
     */
    public void setDmiBiosVendor(String dmiBiosVendorIn) {
        this.dmiBiosVendor = dmiBiosVendorIn;
    }

    /**
     * @return the dmiBiosVersion
     */
    public String getDmiBiosVersion() {
        return dmiBiosVersion;
    }

    /**
     * @param dmiBiosVersionIn the dmiBiosVersion to set
     */
    public void setDmiBiosVersion(String dmiBiosVersionIn) {
        this.dmiBiosVersion = dmiBiosVersionIn;
    }

    /**
     * @return the dmiBiosRelease
     */
    public String getDmiBiosRelease() {
        return dmiBiosRelease;
    }

    /**
     * @param dmiBiosReleaseIn the dmiBiosRelease to set
     */
    public void setDmiBiosRelease(String dmiBiosReleaseIn) {
        this.dmiBiosRelease = dmiBiosReleaseIn;
    }

    /**
     * @return the dmiAsset
     */
    public String getDmiAsset() {
        return dmiAsset;
    }

    /**
     * @param dmiAssetIn the dmiAsset to set
     */
    public void setDmiAsset(String dmiAssetIn) {
        this.dmiAsset = dmiAssetIn;
    }

    /**
     * @return the dmiBoard
     */
    public String getDmiBoard() {
        return dmiBoard;
    }

    /**
     * @param dmiBoardIn the dmiBoard to set
     */
    public void setDmiBoard(String dmiBoardIn) {
        this.dmiBoard = dmiBoardIn;
    }
}
