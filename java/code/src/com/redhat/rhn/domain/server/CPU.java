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
 * CPU
 * @version $Rev$
 */
public class CPU extends BaseDomainHelper {

    private Long id;
    private Server server;
    private String bogomips;
    private String cache;
    private String family;
    private String MHz;
    private String stepping;
    private String flags;
    private String model;
    private String version;
    private String vendor;
    private Long nrCPU;
    private String acpiVersion;
    private String apic;
    private String apmVersion;
    private String chipSet;
    private CPUArch arch;


    /**
     * @return Returns the acpiVersion.
     */
    public String getAcpiVersion() {
        return acpiVersion;
    }

    /**
     * @param acpiVersionIn The acpiVersion to set.
     */
    public void setAcpiVersion(String acpiVersionIn) {
        this.acpiVersion = acpiVersionIn;
    }

    /**
     * @return Returns the apic.
     */
    public String getApic() {
        return apic;
    }

    /**
     * @param apicIn The apic to set.
     */
    public void setApic(String apicIn) {
        this.apic = apicIn;
    }

    /**
     * @return Returns the apmVersion.
     */
    public String getApmVersion() {
        return apmVersion;
    }

    /**
     * @param apmVersionIn The apmVersion to set.
     */
    public void setApmVersion(String apmVersionIn) {
        this.apmVersion = apmVersionIn;
    }

    /**
     * @return Returns the arch.
     */
    public CPUArch getArch() {
        return arch;
    }

    /**
     * @param archIn The arch to set.
     */
    public void setArch(CPUArch archIn) {
        this.arch = archIn;
    }

    /**
     * @return Returns the bogomips.
     */
    public String getBogomips() {
        return bogomips;
    }

    /**
     * @param bogomipsIn The bogomips to set.
     */
    public void setBogomips(String bogomipsIn) {
        this.bogomips = bogomipsIn;
    }

    /**
     * @return Returns the cache.
     */
    public String getCache() {
        return cache;
    }

    /**
     * @param cacheIn The cache to set.
     */
    public void setCache(String cacheIn) {
        this.cache = cacheIn;
    }

    /**
     * @return Returns the chipSet.
     */
    public String getChipSet() {
        return chipSet;
    }

    /**
     * @param chipSetIn The chipSet to set.
     */
    public void setChipSet(String chipSetIn) {
        this.chipSet = chipSetIn;
    }

    /**
     * @return Returns the family.
     */
    public String getFamily() {
        return family;
    }

    /**
     * @param familyIn The family to set.
     */
    public void setFamily(String familyIn) {
        this.family = familyIn;
    }

    /**
     * @return Returns the flags.
     */
    public String getFlags() {
        return flags;
    }

    /**
     * @param flagsIn The flags to set.
     */
    public void setFlags(String flagsIn) {
        this.flags = flagsIn;
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
        this.id = idIn;
    }

    /**
     * @return Returns the mHz.
     */
    public String getMHz() {
        return MHz;
    }

    /**
     * @param mhzIn The mHz to set.
     */
    public void setMHz(String mhzIn) {
        MHz = mhzIn;
    }

    /**
     * @return Returns the model.
     */
    public String getModel() {
        return model;
    }

    /**
     * @param modelIn The model to set.
     */
    public void setModel(String modelIn) {
        this.model = modelIn;
    }

    /**
     * @return Returns the nrCPU.
     */
    public Long getNrCPU() {
        return nrCPU;
    }

    /**
     * @param nrCPUIn The nrCPU to set.
     */
    public void setNrCPU(Long nrCPUIn) {
        this.nrCPU = nrCPUIn;
    }

    /**
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        this.server = serverIn;
    }

    /**
     * @return Returns the stepping.
     */
    public String getStepping() {
        return stepping;
    }

    /**
     * @param steppingIn The stepping to set.
     */
    public void setStepping(String steppingIn) {
        this.stepping = steppingIn;
    }

    /**
     * @return Returns the vendor.
     */
    public String getVendor() {
        return vendor;
    }

    /**
     * @param vendorIn The vendor to set.
     */
    public void setVendor(String vendorIn) {
        this.vendor = vendorIn;
    }

    /**
     * @return Returns the version.
     */
    public String getVersion() {
        return version;
    }

    /**
     * @param versionIn The version to set.
     */
    public void setVersion(String versionIn) {
        this.version = versionIn;
    }

    /**
     * provides the cpuarch name, which is really the only usefull info for the
     *  cpu arch object
     * @return the arch that the cpu is.
     */
    public String  getArchName() {
        return arch.getName();
    }
}
