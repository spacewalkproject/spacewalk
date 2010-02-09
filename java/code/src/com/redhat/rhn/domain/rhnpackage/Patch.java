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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.solaris.PatchType;

import java.sql.Blob;
import java.util.Date;
import java.util.Set;

/**
 * 
 * Patch
 * @version $Rev$
 */
public class Patch extends com.redhat.rhn.domain.rhnpackage.Package {

    private String solarisRelease;
    private String sunosRelease;
    private PatchType patchType;
    private Date created;
    private Date modified;
    private String patchInfo;
    private Set<PatchSet> patchSets;
    private Blob readme;

    /**
     * @return Returns the readme.
     */
    public Blob getReadme() {
        return readme;
    }

    /**
     * @param readmeIn The readme to set.
     */
    public void setReadme(Blob readmeIn) {
        this.readme = readmeIn;
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * @return Returns the patchinfo.
     */
    public String getPatchInfo() {
        return patchInfo;
    }

    /**
     * @param patchInfoIn The patchinfo to set.
     */
    public void setPatchInfo(String patchInfoIn) {
        this.patchInfo = patchInfoIn;
    }

    /**
     * @return Returns the patchType.
     */
    public PatchType getPatchType() {
        return patchType;
    }

    /**
     * @param patchTypeIn The patchType to set.
     */
    public void setPatchType(PatchType patchTypeIn) {
        this.patchType = patchTypeIn;
    }

    /**
     * @return Returns the solarisRelease.
     */
    public String getSolarisRelease() {
        return solarisRelease;
    }

    /**
     * @param solarisReleaseIn The solarisRelease to set.
     */
    public void setSolarisRelease(String solarisReleaseIn) {
        this.solarisRelease = solarisReleaseIn;
    }

    /**
     * @return Returns the sunosRelease.
     */
    public String getSunosRelease() {
        return sunosRelease;
    }

    /**
     * @param sunosReleaseIn The sunosRelease to set.
     */
    public void setSunosRelease(String sunosReleaseIn) {
        this.sunosRelease = sunosReleaseIn;
    }

    /**
     * @return Returns the patchSets.
     */
    public Set<PatchSet> getPatchSets() {
        return patchSets;
    }

    /**
     * @param patchSetsIn The patchSets to set.
     */
    public void setPatchSets(Set<PatchSet> patchSetsIn) {
        this.patchSets = patchSetsIn;
    }

}
