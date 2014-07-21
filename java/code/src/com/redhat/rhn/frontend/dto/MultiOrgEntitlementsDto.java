/**
 * Copyright (c) 2009--2013 Red Hat, Inc.
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

import java.math.BigDecimal;


/**
 * MultiOrgEntitlementsDto
 * @version $Rev$
 */
public class MultiOrgEntitlementsDto extends SystemEntitlementsDto {

    private String name;
    private Long totalFlex, usedFlex, availableFlex;

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
        name = nameIn;
    }

    /**
     * @return Returns the totalFlex.
     */
    public Long getTotalFlex() {
        return totalFlex;
    }

    /**
     * @param totalFlexIn The totalFlex to set.
     */
    public void setTotalFlex(Long totalFlexIn) {
        totalFlex = totalFlexIn;
    }

    /**
     * @return Returns the usedFlex.
     */
    public Long getUsedFlex() {
        return usedFlex;
    }

    /**
     * @param usedFlexIn The usedFlex to set.
     */
    public void setUsedFlex(Long usedFlexIn) {
        usedFlex = usedFlexIn;
    }

    /**
     * @return Returns the availableFlex.
     */
    public Long getAvailableFlex() {
        return availableFlex;
    }

    /**
     * @param availableFlexIn The availableFlex to set.
     */
    public void setAvailableFlex(Long availableFlexIn) {
        availableFlex = availableFlexIn;
    }

    /**
     * @return the number of used slots.
     */
    public Long getAllocatedFlex() {
        if (getTotalFlex() == null || getAvailableFlex() == null) {
            return 0L;
        }
        return getTotalFlex() - getAvailableFlex();
    }

    /**
     * @return the ratio of current: allocated
     */
    public BigDecimal getFlexRatio() {
        BigDecimal allocated = BigDecimal.valueOf(getAllocatedFlex());
        if (!allocated.equals(BigDecimal.ZERO)) {
            BigDecimal hundred = BigDecimal.TEN.multiply(BigDecimal.TEN);
            BigDecimal dividend = BigDecimal.valueOf(getUsedFlex()).multiply(hundred);
            return dividend.divide(allocated, BigDecimal.ROUND_UP);
        }
        return BigDecimal.ZERO;
    }

    /**
     * @return the free flex
     */
    public Long getFreeFlex() {
        if (getUsedFlex() == null) {
            return getAllocatedFlex();
        }

        return getAllocatedFlex() - getUsedFlex();
    }
}
