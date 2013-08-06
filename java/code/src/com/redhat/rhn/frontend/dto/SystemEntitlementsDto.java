/**
 * Copyright (c) 2013 Red Hat, Inc.
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

import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.manager.entitlement.EntitlementManager;

import java.math.BigDecimal;

/**
 * SystemEntitlementsDto
 * @version $Rev$
 */
public class SystemEntitlementsDto extends BaseDto {

    private Long id;
    private String label;

    private Long total;
    private Long available;
    private Long used;

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
        id = idIn;
    }

    /**
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        label = labelIn;
    }

    /**
     * @return Returns the name.
     */
    public String getName() {
        Entitlement ent = EntitlementManager.getByName(getLabel());
        return String.format("%s (%s)", ent.getHumanReadableLabel(),
                                        ent.getHumanReadableTypeLabel());
    }

    /**
     * @return Returns the total.
     */
    public Long getTotal() {
        return total;
    }

    /**
     * @param totalIn The total to set.
     */
    public void setTotal(Long totalIn) {
        total = totalIn;
    }

    /**
     * @return Returns the available.
     */
    public Long getAvailable() {
        return available;
    }


    /**
     * @param availableIn The available to set.
     */
    public void setAvailable(Long availableIn) {
        available = availableIn;
    }

    /**
     * @return Returns the used.
     */
    public Long getUsed() {
        return used;
    }

    /**
     * @param usedIn The used to set.
     */
    public void setUsed(Long usedIn) {
        used = usedIn;
    }

    /**
     * @return Returns the free.
     */
    public Long getFree() {
        if (getUsed() == null) {
            getAllocated();
        }

        return getAllocated() - getUsed();
    }

    /**
     * @return the number of used slots.
     */
    public Long getAllocated() {
        if (getTotal() == null || getAvailable() == null) {
            return 0L;
        }
        return getTotal() - getAvailable();
    }

    /**
     * @return the ratio of current: allocated
     */
    public BigDecimal getRatio() {
        BigDecimal allocated = BigDecimal.valueOf(getAllocated());
        if (!allocated.equals(BigDecimal.ZERO)) {
            BigDecimal hundred = BigDecimal.TEN.multiply(BigDecimal.TEN);
            BigDecimal dividend = BigDecimal.valueOf(getUsed()).multiply(hundred);
            return dividend.divide(allocated, BigDecimal.ROUND_UP);
        }
        return BigDecimal.ZERO;
    }
}
