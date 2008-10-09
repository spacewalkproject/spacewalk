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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * DTO for a com.redhat.rhn.domain.kickstart.KickStartData
 * @version $Rev: 50942 $
 */
public class KickstartDto extends BaseDto {

    private Long id;
    private Long orgId;
    private Long kstreeId;
    private String name;
    private String label;
    private String bootImage;
    private String isOrgDefault;
    private boolean active;
    private Integer advancedMode;
    
    /**
     * @return if this is a raw KS
     */
    public boolean isAdvancedMode() {
        return advancedMode != null && 1 == advancedMode;
    }

    
    /**
     * @param raw the raw to set
     */
    public void setAdvancedMode(Integer raw) {
        this.advancedMode = raw;
    }

    /**
     * @return the id
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
     * @return the orgId
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * @param orgIdIn The id to set.
     */
     public void setOrgId(Long orgIdIn) {
         this.orgId = orgIdIn;
     }

    /**
     * @return the kickstart tree id
     */
    public Long getKstreeId() {
        return kstreeId;
    }

    /**
     * @param kstreeIdIn The kstree id to set.
     */
     public void setKstreeId(Long kstreeIdIn) {
         this.kstreeId = kstreeIdIn;
     }
     
    /**
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn The name to set.
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return Returns the bootImage.
     */
    public String getBootImage() {
        return bootImage;
    }

    /**
     * @param bootImageIn The bootImage to set.
     */
    public void setBootImage(String bootImageIn) {
        this.bootImage = bootImageIn;
    }
    
    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The name to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Returns the active flag.
     */
    public boolean isActive() {
        return active;
    }

    /**
     * @param activeIn The server id, null if not a satellite
     */
    public void setActive(boolean activeIn) {
        this.active = activeIn;
    }

    
    /**
     * @return Returns the isOrgDefault.
     */
    public String getIsOrgDefault() {
        return isOrgDefault;
    }

    
    /**
     * @param isOrgDefaultIn The isOrgDefault to set.
     */
    public void setIsOrgDefault(String isOrgDefaultIn) {
        this.isOrgDefault = isOrgDefaultIn;
    }

}
