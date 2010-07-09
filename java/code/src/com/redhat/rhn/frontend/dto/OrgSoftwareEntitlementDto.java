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
    private Long currentFlex;
    private Long maxFlex;
    private Long maxPossibleFlexAllocation;

    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        org = orgIn;
    }


    /**
     * @param currentMembersIn The currentMembers to set.
     */
    public void setCurrentMembers(Long currentMembersIn) {
        currentMembers = currentMembersIn;
    }


    /**
     * @param maxMembersIn The maxMembers to set.
     */
    public void setMaxMembers(Long maxMembersIn) {
        maxMembers = maxMembersIn;
    }


    /**
     * @param maxPossibleAllocationIn The maxPossibleAllocation to set.
     */
    public void setMaxPossibleAllocation(Long maxPossibleAllocationIn) {
        maxPossibleAllocation = maxPossibleAllocationIn;
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
        if (maxPossibleAllocation == null) {
            return 0L;
        }
        return maxPossibleAllocation;
    }


    /**
     * @return Returns the currentFlex.
     */
    public Long getCurrentFlex() {
        return currentFlex;
    }


    /**
     * @param currentFlexIn The currentFlex to set.
     */
    public void setCurrentFlex(Long currentFlexIn) {
        currentFlex = currentFlexIn;
    }


    /**
     * @return Returns the maxFlex.
     */
    public Long getMaxFlex() {
        return maxFlex;
    }


    /**
     * @param maxFlexIn The maxFlex to set.
     */
    public void setMaxFlex(Long maxFlexIn) {
        maxFlex = maxFlexIn;
    }


    /**
     * @return Returns the maxPossibleFlexAllocation.
     */
    public Long getMaxPossibleFlexAllocation() {
        if (maxPossibleFlexAllocation == null) {
            return 0L;
        }
        return maxPossibleFlexAllocation;
    }


    /**
     * @param maxPossibleFlexAllocationIn The maxPossibleFlexAllocation to set.
     */
    public void setMaxPossibleFlexAllocation(Long maxPossibleFlexAllocationIn) {
        maxPossibleFlexAllocation = maxPossibleFlexAllocationIn;
    }


    /**
     * @return the key
     */
    public String getKey() {
        return makeKey(getOrg().getId());
    }

    /**
     * @return the key
     */
    public String getFlexKey() {
        return makeFlexKey(getOrg().getId());
    }


    /**
     * @param id the id of the channel family
     * @return the key
     */
    public static String makeKey(Long id) {
        return String.valueOf(id);
    }


    /**
     * @param id the id of the channel family
     * @return the key
     */
    public static String makeFlexKey(Long id) {
        return id + "-flex";
    }
}
