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

/**
 * Device represents a hardware device on a server.
 * @version $Rev$
 */
public class Device extends BaseDomainHelper {
    /** Constants for BUS types */
    public static final String BUS_ADB = "ADB";
    public static final String BUS_DDC = "DDC";
    public static final String BUS_FIREWIRE = "FIREWIRE";
    public static final String BUS_IDE = "IDE";
    public static final String BUS_ISAPNP = "ISAPNP";
    public static final String BUS_KEYBOARD = "KEYBOARD";
    public static final String BUS_MACIO = "MACIO";
    public static final String BUS_MISC = "MISC";
    public static final String BUS_PARALLEL = "PARALLEL";
    public static final String BUS_PCMCIA = "PCMCIA";
    public static final String BUS_PSAUX = "PSAUX";
    public static final String BUS_S390 = "S390";
    public static final String BUS_SBUS = "SBUS";
    public static final String BUS_SCSI = "SCSI";
    public static final String BUS_SERIAL = "SERIAL";
    public static final String BUS_USB = "USB";
    public static final String BUS_VIO = "VIO";
    public static final String BUS_PCI = "PCI";

    /** Constants for Device classes */
    public static final String CLASS_AUDIO = "AUDIO";
    public static final String CLASS_CAPTURE = "CAPTURE";
    public static final String CLASS_CDROM = "CDROM";
    public static final String CLASS_FIREWIRE = "FIREWIRE";
    public static final String CLASS_FLOPPY = "FLOPPY";
    public static final String CLASS_HD = "HD";
    public static final String CLASS_IDE = "IDE";
    public static final String CLASS_KEYBOARD = "KEYBOARD";
    public static final String CLASS_MODEM = "MODEM";
    public static final String CLASS_MOUSE = "MOUSE";
    public static final String CLASS_NETWORK = "NETWORK";
    public static final String CLASS_OTHER = "OTHER";
    public static final String CLASS_PRINTER = "PRINTER";
    public static final String CLASS_RAID = "RAID";
    public static final String CLASS_SCANNER = "SCANNER";
    public static final String CLASS_SCSI = "SCSI";
    public static final String CLASS_SOCKET = "SOCKET";
    public static final String CLASS_TAPE = "TAPE";
    public static final String CLASS_UNSPEC = "UNSPEC";
    public static final String CLASS_USB = "USB";
    public static final String CLASS_VIDEO = "VIDEO";

    private Long id;
    private Server server;
    private String deviceClass;
    private String bus;
    private Long detached;
    private String device;
    private String driver;
    private String description;
    private Long pcitype;
    private String prop1;
    private String prop2;
    private String prop3;
    private String prop4;

    /**
     * Default constructor
     */
    public Device() {
        super();
    }

    /**
     * @return Returns the bus.
     */
    public String getBus() {
        return bus;
    }
    /**
     * @param busIn The bus to set.
     */
    public void setBus(String busIn) {
        bus = busIn;
    }
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }
    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        description = descriptionIn;
    }
    /**
     * @return Returns the detached.
     */
    public Long getDetached() {
        return detached;
    }
    /**
     * @param detachedIn The detached to set.
     */
    public void setDetached(Long detachedIn) {
        detached = detachedIn;
    }
    /**
     * @return Returns the device.
     */
    public String getDevice() {
        return device;
    }
    /**
     * @param deviceIn The device to set.
     */
    public void setDevice(String deviceIn) {
        device = deviceIn;
    }
    /**
     * @return Returns the driver.
     */
    public String getDriver() {
        return driver;
    }
    /**
     * @param driverIn The device to set.
     */
    public void setDriver(String driverIn) {
        driver = driverIn;
    }
    /**
     * @return Returns the deviceClass.
     */
    public String getDeviceClass() {
        return deviceClass;
    }
    /**
     * @param deviceClassIn The deviceClass to set.
     */
    public void setDeviceClass(String deviceClassIn) {
        deviceClass = deviceClassIn;
    }
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }
    /**
     * @return Returns the pcitype.
     */
    public Long getPcitype() {
        return pcitype;
    }
    /**
     * @param pcitypeIn The pcitype to set.
     */
    public void setPcitype(Long pcitypeIn) {
        pcitype = pcitypeIn;
    }
    /**
     * @return Returns the serverId.
     */
    public Server getServer() {
        return server;
    }
    /**
     * @param serverIn The serverId to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }
    /**
     * @return Returns the prop1.
     */
    public String getProp1() {
        return prop1;
    }
    /**
     * @param prop1In The prop1 to set.
     */
    public void setProp1(String prop1In) {
        this.prop1 = prop1In;
    }
    /**
     * @return Returns the prop2.
     */
    public String getProp2() {
        return prop2;
    }
    /**
     * @param prop2In The prop2 to set.
     */
    public void setProp2(String prop2In) {
        this.prop2 = prop2In;
    }
    /**
     * @return Returns the prop3.
     */
    public String getProp3() {
        return prop3;
    }
    /**
     * @param prop3In The prop3 to set.
     */
    public void setProp3(String prop3In) {
        this.prop3 = prop3In;
    }
    /**
     * @return Returns the prop4.
     */
    public String getProp4() {
        return prop4;
    }
    /**
     * @param prop4In The prop4 to set.
     */
    public void setProp4(String prop4In) {
        this.prop4 = prop4In;
    }
}
