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
public class HardwareDevice extends GenericRecord {

    private long serverId;
    private String classInfo;
    private String bus;
    private long detached;
    private String device;
    private String driver;
    private String description;
    private String vendorId;
    private String deviceId;
    private String subVendorId;
    private String subDeviceId;
    private long pciType;

    /**
     * @return the serverId
     */
    public long getServerId() {
        return serverId;
    }
    /**
     * @param serverIdIn the serverId to set
     */
    public void setServerId(long serverIdIn) {
        this.serverId = serverIdIn;
    }
    /**
     * @return the classInfo
     */
    public String getClassInfo() {
        return classInfo;
    }
    /**
     * @param classInfoIn the classInfo to set
     */
    public void setClassInfo(String classInfoIn) {
        this.classInfo = classInfoIn;
    }
    /**
     * @return the bus
     */
    public String getBus() {
        return bus;
    }
    /**
     * @param busIn the bus to set
     */
    public void setBus(String busIn) {
        this.bus = busIn;
    }
    /**
     * @return the detached
     */
    public long getDetached() {
        return detached;
    }
    /**
     * @param detachedIn the detached to set
     */
    public void setDetached(long detachedIn) {
        this.detached = detachedIn;
    }
    /**
     * @return the device
     */
    public String getDevice() {
        return device;
    }
    /**
     * @param deviceIn the device to set
     */
    public void setDevice(String deviceIn) {
        this.device = deviceIn;
    }
    /**
     * @return the driver
     */
    public String getDriver() {
        return driver;
    }
    /**
     * @param driverIn the driver to set
     */
    public void setDriver(String driverIn) {
        this.driver = driverIn;
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
     * @return the vendorId
     */
    public String getVendorId() {
        return vendorId;
    }
    /**
     * @param vendorIdIn the vendorId to set
     */
    public void setVendorId(String vendorIdIn) {
        this.vendorId = vendorIdIn;
    }
    /**
     * @return the deviceId
     */
    public String getDeviceId() {
        return deviceId;
    }
    /**
     * @param deviceIdIn the deviceId to set
     */
    public void setDeviceId(String deviceIdIn) {
        this.deviceId = deviceIdIn;
    }
    /**
     * @return the subVendorId
     */
    public String getSubVendorId() {
        return subVendorId;
    }
    /**
     * @param subVendorIdIn the subVendorId to set
     */
    public void setSubVendorId(String subVendorIdIn) {
        this.subVendorId = subVendorIdIn;
    }
    /**
     * @return the subDeviceId
     */
    public String getSubDeviceId() {
        return subDeviceId;
    }
    /**
     * @param subDeviceIdIn the subDeviceId to set
     */
    public void setSubDeviceId(String subDeviceIdIn) {
        this.subDeviceId = subDeviceIdIn;
    }
    /**
     * @return the pciType
     */
    public long getPciType() {
        return pciType;
    }
    /**
     * @param pciTypeIn the pciType to set
     */
    public void setPciType(long pciTypeIn) {
        this.pciType = pciTypeIn;
    }



}
