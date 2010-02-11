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

import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

/**
 * OrgSystemEntitlementDto
 * @version $Rev$
 */
public class OrgSystemEntitlementDto {

    private Long orgid;
    private String orgname;
    private OrgEntitlementDto orgEntDto;
    private String entname;
    private Long availableEntitlements;    
    private Long currentEntitlements;    
    private Long satelliteTotal;    
 
    /**
     * Constructor ..
     */
    public OrgSystemEntitlementDto() { 
    }
   
    /**
     * returns the orgid as a Long
     * @return the orgid as a Long
     */
    public Long getOrgid() {
        return orgid;
    }

    /**
     * 
     * @param orgId OrgIn Id 
     */
    public void setOrgid(Long orgId) {
        this.orgid = orgId;
    }

    /**
     * 
     * @return Name of Org
     */
    public String getOrgname() {
        return orgname;
    }

    /**
     * 
     * @param orgName of Org to set
     */
    public void setOrgname(String orgName) {
        this.orgname = orgName;
    }
 
    /**
     * 
     * @return Name of Ent
     */
    public String getEntname() {
        return this.entname;
    }

    /**
     * 
     * @param entName of Ent to set
     */
    public void setEntname(String entName) {
        this.entname = entName;
    }

    /**
     * Get the count of the number of used slots.
     * @return Long this.currentEntitlements, null if unlimited
     */
    public Long getCurrentEntitlements() {
        return getDto().getCurrentEntitlements();
    }
    

    /**
     * Get the count of the number of available slots.
     * @return Long this.availableEntitlements, null if unlimited
     */
    public Long getAvailableEntitlements() {
        return getDto().getAvailbleEntitlements();
    }

    
    /**
     * 
     * @return Long total of the available Entitlements in the default Org
     */
    public Long getSatelliteTotal() {
        return getDto().getSatelliteTotal();
    }

    /**
     * 
     * @return OrgEntitlementDto object
     */
    public OrgEntitlementDto getDto() {
        if (this.orgEntDto == null) {
            Org orgObj = OrgFactory.lookupById(
                 new Long(this.orgid.longValue()));
            this.orgEntDto = new OrgEntitlementDto(
                 EntitlementManager.getByName(this.entname), orgObj);
        }
        return this.orgEntDto;
    }

}
