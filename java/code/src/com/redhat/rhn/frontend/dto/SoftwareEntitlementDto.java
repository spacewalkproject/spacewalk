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


/**
 * SoftwareEntitlementDto
 * @version $Rev$
 */
public class SoftwareEntitlementDto {

    private String name;
    private Long id;
    private Long allocated;
    private Long notAllocated;
    private Long notInUse;

    /**
     * Constructor
     * @param nameIn Entitlement name.
     * @param idIn Entitlement ID.
     * @param allocatedIn Allocated to set.
     * @param notAllocatedIn Not allocated to set.
     * @param notInUseIn Not in use to set.
     */
    public SoftwareEntitlementDto(String nameIn, Long idIn, Long allocatedIn,
            Long notAllocatedIn, Long notInUseIn) {
        this.name = nameIn;
        this.id = idIn;
        this.allocated = allocatedIn;
        this.notAllocated = notAllocatedIn;
        this.notInUse = notInUseIn;
    }

    /**
     * Constructor
     * @param nameIn Entitlement name.
     * @param idIn Entitlement ID.
     */
    public SoftwareEntitlementDto(String nameIn, Long idIn) {
        this.name = nameIn;
        this.id = idIn;
        this.allocated = new Long(0);
        this.notAllocated = new Long(0);
        this.notInUse = new Long(0);
    }

    /**
     * @return Entitement name.
     */
    public String getName() {
        return name;
    }

    /**
     * @return Entitlement id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Get the number of entitlements allocated to all organizations. (except the default
     * satellite org) Null indicates this entitlement has unlimited allocations.
     * @return Long
     */
    public Long getAllocated() {
        return allocated;
    }

    /**
     * @param allocatedIn Allocated to set.
     */
    public void setAllocated(Long allocatedIn) {
        this.allocated = allocatedIn;
    }

    /**
     *
     * @return Display version of the allocated total. Takes into account that null
     * means unlimited.
     */
    public String getAllocatedDisplay() {
        LocalizationService ls = LocalizationService.getInstance();
        if (allocated == null) {
            return ls.getMessage("softwareEntitlements.unlimited");
        }
        else {
            return allocated.toString();
        }
    }

    /**
     * @return Number of entitlements not yet allocated to an organization. (i.e. still
     * allocated to the default satellite organization, but unused by any system)
     */
    public Long getNotAllocated() {
        return notAllocated;
    }

    /**
     * @param notAllocatedIn Not allocated to set.
     */
    public void setNotAllocated(Long notAllocatedIn) {
        this.notAllocated = notAllocatedIn;
    }

    /**
     * @return Number of entitlements not used by a system. (across all orgs including the
     * default satellite org)
     */
    public Long getNotInUse() {
        return notInUse;
    }

    /**
     * @param notInUseIn Not in use to set.
     */
    public void setNotInUse(Long notInUseIn) {
        this.notInUse = notInUseIn;
    }

    /**
     *
     * @return Display version of the not in use total. Takes into account that null
     * means unlimited.
     */
    public String getNotInUseDisplay() {
        LocalizationService ls = LocalizationService.getInstance();
        if (notInUse == null) {
            return ls.getMessage("softwareEntitlements.notApplicable");
        }
        else {
            return notInUse.toString();
        }
    }

}
