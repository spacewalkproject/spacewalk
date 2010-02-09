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

import com.redhat.rhn.common.localization.LocalizationService;
import com.redhat.rhn.domain.org.Org;


/**
 * OrgSoftwareEntitlementDto
 * @version $Rev$
 */
public class OrgSoftwareEntitlementDto {

    private Org org;
    private Long currentMembers;
    private Long maxMembers;
    private Long maxPossibleAllocation;
    
    /**
     * Constructor
     * @param orgIn Org
     * @param currentMembersIn Current member count
     * @param maxMembersIn Current max member count
     * @param maxPossibleAllocationIn Maximum possible allocation
     */
    public OrgSoftwareEntitlementDto(Org orgIn, Long currentMembersIn, Long maxMembersIn, 
            Long maxPossibleAllocationIn) {
        this.org = orgIn;
        this.currentMembers = currentMembersIn;
        this.maxMembers = maxMembersIn;
        this.maxPossibleAllocation = maxPossibleAllocationIn;
    }
    
    /**
     * @return The org in question.
     */
    public Org getOrg() {
        return org;
    }
    
    /**
     * @return Current membership for this entitlement
     */
    public Long getCurrentMembers() {
        return currentMembers;
    }

    /**
     * @return max membership for this software entitlement.
     */
    public Long getMaxMembers() {
        return maxMembers;
    }
    
    /**
     * 
     * @return Display version of max members total. Takes into account that null
     * means unlimited.
     */
    public String getMaxMembersDisplay() {
        LocalizationService ls = LocalizationService.getInstance();
        if (maxMembers == null) {
            return ls.getMessage("softwareEntitlements.unlimited");
        }
        else {
            return maxMembers.toString();
        }
    }

    
    /**
     * @return Organization name.
     */
    public String getOrgName() {
        return org.getName();
    }
    
    /**
     * Return the maximum possible entitlement allocation this organization can be given.
     * @return Max possible allocation.
     */
    public Long getMaxPossibleAllocation() {
        return maxPossibleAllocation;
    }
}
