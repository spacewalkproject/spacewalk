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
package com.redhat.rhn.frontend.dto;
/**
 * FilePreservationDto
 * @version $Rev$
 */

public class HardwareDeviceDto extends BaseDto {
    private Long id;
    private Long serverId;
    private String device;
    private String description;
    private String driver;
    private String deviceId;
    private String vendorId;
    private String subVendorId;
    private String subDeviceId;
    /**
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn the id to set
     */
    public void setId(Long idIn) {
        this.id = idIn;
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
     * @return the serverId
     */
    public Long getServerId() {
        return serverId;
    }

    /**
     * @param serverIdIn the serverId to set
     */
    public void setServerId(Long serverIdIn) {
        this.serverId = serverIdIn;
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
}
