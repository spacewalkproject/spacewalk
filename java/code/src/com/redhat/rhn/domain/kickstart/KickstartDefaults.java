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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.domain.rhnpackage.profile.Profile;

import java.util.Date;

/**
 * KickstartDefaults - Class representation of the table rhnkickstartdefaults.
 * @version $Rev: 1 $
 */
public class KickstartDefaults {

    private KickstartData ksdata;
    private KickstartableTree kstree;
    private Profile profile;

    private Long id;
    private Boolean cfgManagementFlag;
    private Boolean remoteCommandFlag;
    private KickstartVirtualizationType virtualizationType;
    private Date created;
    private Date modified;


    /**
     * Getter for id
     * @return ID to get
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
     * Getter for ksdata
     * @return KickstartData to get
    */
    public KickstartData getKsdata() {
        return this.ksdata;
    }

    /**
     * Setter for ksdata
     * @param ksdataIn to set
    */
    public void setKsdata(KickstartData ksdataIn) {
        this.ksdata = ksdataIn;
    }

    /**
     * Getter for kstree
     * @return KickstartableTree to get
    */
    public KickstartableTree getKstree() {
        return this.kstree;
    }

    /**
     * Setter for kstree
     * @param kstreeIn to set
    */
    public void setKstree(KickstartableTree kstreeIn) {
        this.kstree = kstreeIn;
    }

    /**
     * Getter for cfgManagementFlag
     * @return Boolean to get
    */
    public Boolean getCfgManagementFlag() {
        return this.cfgManagementFlag;
    }

    /**
     * Setter for cfgManagementFlag
     * @param cfgManagementFlagIn to set
    */
    public void setCfgManagementFlag(Boolean cfgManagementFlagIn) {
        this.cfgManagementFlag = cfgManagementFlagIn;
    }

    /**
     * Getter for remoteCommandFlag
     * @return Boolean to get
    */
    public Boolean getRemoteCommandFlag() {
        return this.remoteCommandFlag;
    }

    /**
     * Setter for remoteCommandFlag
     * @param remoteCommandFlagIn to set
    */
    public void setRemoteCommandFlag(Boolean remoteCommandFlagIn) {
        this.remoteCommandFlag = remoteCommandFlagIn;
    }

    /**
     * Getter for virtualization type
     * @return KickstartVirtualizationType to get
    */
    public KickstartVirtualizationType getVirtualizationType() {
        return this.virtualizationType;
    }

    /**
     * Setter for virtualization type
     * @param typeIn KickstartVirtualizationType to set
    */
    public void setVirtualizationType(KickstartVirtualizationType typeIn) {
        this.virtualizationType = typeIn;
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
     * @return the profile
     */
    public Profile getProfile() {
        return profile;
    }


    /**
     * @param profileIn The profile to set.
     */
    public void setProfile(Profile profileIn) {
        this.profile = profileIn;
    }

    /**
     * Clone this KickstartDefaults object using a deep copy style routine for
     * all the fields in this object except ID.
     * @param ksDataIn who is going to own the cloned KickstartDefaults
     * @return KickstartDefaults object that is cloned.
     */
    public KickstartDefaults deepCopy(KickstartData ksDataIn) {
        KickstartDefaults cloned = new KickstartDefaults();
        cloned.setCfgManagementFlag(this.getCfgManagementFlag());
        cloned.setKsdata(ksDataIn);
        cloned.setKstree(this.getKstree());
        cloned.setProfile(this.getProfile());
        cloned.setRemoteCommandFlag(this.getRemoteCommandFlag());
        cloned.setVirtualizationType(this.getVirtualizationType());
        return cloned;
    }

}
