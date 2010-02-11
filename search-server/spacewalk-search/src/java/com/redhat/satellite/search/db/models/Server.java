/**
 * Copyright (c) 2008--2010 Red Hat, Inc.
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

import java.util.Date;

import org.apache.lucene.document.DateTools;
import org.apache.lucene.document.NumberTools;


/**
 * Server
 * @version $Rev$
 */
public class Server extends GenericRecord {

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

    /* CPU Info */
    private String cpuBogoMIPS;
    private String cpuCache;
    private String cpuFamily;
    private String cpuMhz;
    private String cpuStepping;
    private String cpuFlags;
    private String cpuModel;
    private String cpuVersion;
    private String cpuVendor;
    private String cpuNumberOfCpus;
    private String cpuAcpiVersion;
    private String cpuApic;
    private String cpuApmVersion;
    private String cpuChipset;

    private String checkin;
    private String registered;

    private String ram;
    private String swap;

    private String runningKernel;

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

    /**
     * @return the cpuBogoMIPS
     */
    public String getCpuBogoMIPS() {
        return cpuBogoMIPS;
    }

    /**
     * @param cpuBogoMIPSIn the cpuBogoMIPS to set
     */
    public void setCpuBogoMIPS(String cpuBogoMIPSIn) {
        if (cpuBogoMIPSIn != null) {
            Float f = Float.parseFloat(cpuBogoMIPSIn);
            this.cpuBogoMIPS = NumberTools.longToString(f.longValue());
        }
        else {
            this.cpuBogoMIPS = null;
        }
    }

    /**
     * @return the cpuCache
     */
    public String getCpuCache() {
        return cpuCache;
    }

    /**
     * @param cpuCacheIn the cpuCache to set
     */
    public void setCpuCache(String cpuCacheIn) {
        this.cpuCache = cpuCacheIn;
    }

    /**
     * @return the cpuFamily
     */
    public String getCpuFamily() {
        return cpuFamily;
    }

    /**
     * @param cpuFamilyIn the cpuFamily to set
     */
    public void setCpuFamily(String cpuFamilyIn) {
        this.cpuFamily = cpuFamilyIn;
    }

    /**
     * @return the cpuMhz
     */
    public String getCpuMhz() {
        return cpuMhz;
    }

    /**
     * @param cpuMhzIn the cpuMhz to set
     */
    public void setCpuMhz(String cpuMhzIn) {
        if (cpuMhzIn != null) {
            this.cpuMhz = NumberTools.longToString(Long.parseLong(cpuMhzIn));
        }
        else {
            this.cpuMhz = null;
        }
    }

    /**
     * @return the cpuStepping
     */
    public String getCpuStepping() {
        return cpuStepping;
    }

    /**
     * @param cpuSteppingIn the cpuStepping to set
     */
    public void setCpuStepping(String cpuSteppingIn) {
        this.cpuStepping = cpuSteppingIn;
    }

    /**
     * @return the cpuFlags
     */
    public String getCpuFlags() {
        return cpuFlags;
    }

    /**
     * @param cpuFlagsIn the cpuFlags to set
     */
    public void setCpuFlags(String cpuFlagsIn) {
        this.cpuFlags = cpuFlagsIn;
    }

    /**
     * @return the cpuModel
     */
    public String getCpuModel() {
        return cpuModel;
    }

    /**
     * @param cpuModelIn the cpuModel to set
     */
    public void setCpuModel(String cpuModelIn) {
        this.cpuModel = cpuModelIn;
    }

    /**
     * @return the cpuVersion
     */
    public String getCpuVersion() {
        return cpuVersion;
    }

    /**
     * @param cpuVersionIn the cpuVersion to set
     */
    public void setCpuVersion(String cpuVersionIn) {
        this.cpuVersion = cpuVersionIn;
    }

    /**
     * @return the cpuVendor
     */
    public String getCpuVendor() {
        return cpuVendor;
    }

    /**
     * @param cpuVendorIn the cpuVendor to set
     */
    public void setCpuVendor(String cpuVendorIn) {
        this.cpuVendor = cpuVendorIn;
    }

    /**
     * @return the cpuNrCpu
     */
    public String getCpuNumberOfCpus() {
        return cpuNumberOfCpus;
    }

    /**
     * @param cpuNumberOfCpusIn the cpuNumberOfCpus to set
     */
    public void setCpuNumberOfCpus(String cpuNumberOfCpusIn) {
        if (cpuNumberOfCpusIn != null) {
            this.cpuNumberOfCpus = 
                NumberTools.longToString(Long.parseLong(cpuNumberOfCpusIn));
        }
        else {
            this.cpuNumberOfCpus = null;
        }
    }

    /**
     * @return the cpuAcpiVersion
     */
    public String getCpuAcpiVersion() {
        return cpuAcpiVersion;
    }

    /**
     * @param cpuAcpiVersionIn the cpuAcpiVersion to set
     */
    public void setCpuAcpiVersion(String cpuAcpiVersionIn) {
        this.cpuAcpiVersion = cpuAcpiVersionIn;
    }

    /**
     * @return the cpuApic
     */
    public String getCpuApic() {
        return cpuApic;
    }

    /**
     * @param cpuApicIn the cpuApic to set
     */
    public void setCpuApic(String cpuApicIn) {
        this.cpuApic = cpuApicIn;
    }

    /**
     * @return the cpuApmVersion
     */
    public String getCpuApmVersion() {
        return cpuApmVersion;
    }

    /**
     * @param cpuApmVersionIn the cpuApmVersion to set
     */
    public void setCpuApmVersion(String cpuApmVersionIn) {
        this.cpuApmVersion = cpuApmVersionIn;
    }

    /**
     * @return the cpuChipset
     */
    public String getCpuChipset() {
        return cpuChipset;
    }

    /**
     * @param cpuChipsetIn the cpuChipset to set
     */
    public void setCpuChipset(String cpuChipsetIn) {
        this.cpuChipset = cpuChipsetIn;
    }

    /**
     * @return the checkin
     */
    public String getCheckin() {
        return checkin;
    }

    /**
     * @param checkinIn the checkin to set
     */
    public void setCheckin(Date checkinIn) {
        if (checkinIn != null) {
            this.checkin = DateTools.dateToString(checkinIn,
                DateTools.Resolution.MINUTE);
        }
        else {
            this.checkin = null;
        }
    }

    /**
     * @return the registered
     */
    public String getRegistered() {
        return registered;
    }

    /**
     * @param registeredIn the registered to set
     */
    public void setRegistered(Date registeredIn) {
        if (registeredIn != null) {
            this.registered = DateTools.dateToString(registeredIn,
                DateTools.Resolution.MINUTE);
        }
        else {
            this.registered = null;
        }
    }

    /**
     * @return the ram
     */
    public String getRam() {
        return ram;
    }

    /**
     * @param ramIn the ram to set
     */
    public void setRam(String ramIn) {
        if (ramIn != null) {
            this.ram = NumberTools.longToString(Long.parseLong(ramIn));
        }
        else {
            this.ram = null;
        }
    }

    /**
     * @return the swap
     */
    public String getSwap() {
        return swap;
    }

    /**
     * @param swapIn the swap to set
     */
    public void setSwap(String swapIn) {
        if (swapIn != null) {
            this.swap = NumberTools.longToString(Long.parseLong(swapIn));
        }
        else {
            this.swap = null;
        }
    }

    /**
     * @return the running kernel
     */
    public String getRunningKernel() {
        return runningKernel;
    }

    /**
     * @param runningKernelIn the runningKernel to set
     */
    public void setRunningKernel(String runningKernelIn) {
        if (runningKernelIn != null) {
            this.runningKernel = runningKernelIn;
        }
        else {
            this.runningKernel = null;
        }
    }
}
