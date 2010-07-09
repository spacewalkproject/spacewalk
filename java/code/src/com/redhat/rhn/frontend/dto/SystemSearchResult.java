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

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.Calendar;


/**
 * SystemSearchResult
 * @version $Rev$
 */
public class SystemSearchResult extends SystemOverview {

    private String matchingField;
    private String matchingFieldValue;
    private String hostname;
    private String description;
    private String runningKernel;
    private Long cpuNumberOfCpus;
    private String cpuMhz;
    private String cpuModel;
    private String dmiSystem;
    private String dmiBiosVendor;
    private String dmiBiosVersion;
    private String dmiBiosRelease;
    private String dmiAsset;
    private String ipaddr;
    private String machine;
    private String rack;
    private String room;
    private String building;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String country;
    private Long ram;
    private String packageName;
    private HardwareDeviceDto hw;
    private Integer rank;
    private Double score;

    private static Logger log = Logger.getLogger(SystemSearchResult.class);
    /**
     * This method will look up the value of "matchingField" it will then
     * return the value of the variable name which matches it.
     * NOTE:  This method requires that the result has been elaborated, or else data
     * is potentially missing.  As an alternate you can use "getMatchingFieldValue" to
     * use the data returned from search server.
     * @return String of the matching field value
     */
    public String getLookupMatchingField() {
        String value = "";
        String field = getMatchingField();
        log.info("Will look up field <" + field + "> to determine why" +
                " this matched");
        try {
            if ((field != null) && (!StringUtils.isBlank(field))) {
                value = BeanUtils.getProperty(this, field);
                log.info("SystemSearchResult.Id = " + getId() +
                        " BeanUtils.getProperty(sr, " +
                        field + ") = " + value);
            }
            else {
                log.info("SystemSearchResult.ID = " + getId() +
                        " matchingField was null or blank");
            }
        }
        catch (IllegalAccessException e) {
            e.printStackTrace();
            // ignore
        }
        catch (NoSuchMethodException e) {
            log.info("SystemSearchResult.lookupMatchingField() " +
                    "NoSuchMethodException caught looking up: " + field +
                    ", for system id = " + getId() + ">");
        }
        catch (InvocationTargetException e) {
            e.printStackTrace();
            // ignore
        }
        return value;
    }

    /**
     * @return returns the data in the field
     * that was searched on
     */
    public String getMatchingField() {
        return matchingField;
    }

    /**
     * @param matchingFieldIn The matchingField to set.
     */
    public void setMatchingField(String matchingFieldIn) {
        this.matchingField = matchingFieldIn;
    }

    /**
     * Takes care of cases where the DB will be returning numerical
     * instead of varchar vlues
     * @param matchingFieldIn matchingField to set
     */
    public void setMatchingField(Long matchingFieldIn) {
        this.matchingField = matchingFieldIn.toString();
    }

    /**
     * @return returns the data in the field
     * that was searched on
     */
    public String getMatchingFieldValue() {
        return matchingFieldValue;
    }

    /**
     * @param matchingFieldValueIn The matchingFieldValue to set.
     */
    public void setMatchingFieldValue(String matchingFieldValueIn) {
        this.matchingFieldValue = matchingFieldValueIn;
    }

    /**
     * Takes care of cases where the DB will be returning numerical
     * instead of varchar vlues
     * @param matchingFieldValueIn matchingFieldValue to set
     */
    public void setMatchingFieldValue(Long matchingFieldValueIn) {
        this.matchingFieldValue = matchingFieldValueIn.toString();
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
     * @return the runningKernel
     */
    public String getRunningKernel() {
        return runningKernel;
    }

    /**
     * @param runningKernelIn the runningKernel to set
     */
    public void setRunningKernel(String runningKernelIn) {
        this.runningKernel = runningKernelIn;
    }

    /**
     * @return the cpuNumberOfCpus
     */
    public Long getCpuNumberOfCpus() {
        return cpuNumberOfCpus;
    }

    /**
     * @param cpuNumberOfCpusIn the cpuNumberOfCpus to set
     */
    public void setCpuNumberOfCpus(Long cpuNumberOfCpusIn) {
        this.cpuNumberOfCpus = cpuNumberOfCpusIn;
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
        this.cpuMhz = cpuMhzIn;
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
     * @return the ram
     */
    public Long getRam() {
        return ram;
    }

    /**
     * @param ramIn the ram to set
     */
    public void setRam(Long ramIn) {
        this.ram = ramIn;
    }

    /**
     * @return days ago this system checked in with server
     */
    public Long getCheckin() {
        long now = Calendar.getInstance().getTime().getTime();
        long reg = getLastCheckinDate().getTime();
        long diff = now - reg;
        return diff / (1000 * 60 * 60 * 24);
    }

    /**
     * @return number of days since this system was registered with server
     */
    public Long getRegistered() {
        long now = Calendar.getInstance().getTime().getTime();
        long reg = getCreated().getTime();
        long diff = now - reg;
        return diff / (1000 * 60 * 60 * 24);
    }

    /**
     * @return the packageName
     */
    public String getPackageName() {
        return packageName;
    }

    /**
     * @param packageNameIn the packageName to set
     */
    public void setPackageName(String packageNameIn) {
        this.packageName = packageNameIn;
    }
    /**
     * @return the hw
     */
    public HardwareDeviceDto getHw() {
        return hw;
    }

    /**
     * @param hwIn the hw to set
     */
    public void setHw(HardwareDeviceDto hwIn) {
        this.hw = hwIn;
    }

    /**
     * @return the rank
     */
    public Integer getRank() {
        return rank;
    }

    /**
     * @param rankIn the rank to set
     */
    public void setRank(Integer rankIn) {
        this.rank = rankIn;
    }

    /**
     * @return the score
     */
    public Double getScore() {
        return score;
    }

    /**
     * @param scoreIn the score to set
     */
    public void setScore(Double scoreIn) {
        this.score = scoreIn;
    }
}
