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

import java.math.BigDecimal;


/**
 * MultiOrgEntitlementsDto
 * @version $Rev$
 */
public class MultiOrgEntitlementsDto extends BaseDto {
    private Long id;
    private Long total, used, available;
    private String label;
    private String name;

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getId() {
        return id;
    } 
    
    /**
     * @param val the id to set
     */
    public void setId(Long val) {
        this.id = val;
    }
    
    /**
     * @return the total
     */
    public Long getTotal() {
        return total;
    }

    
    /**
     * @param totalIn the total to set
     */
    public void setTotal(Long totalIn) {
        this.total = totalIn;
    }

    
    /**
     * @return the current
     */
    public Long getUsed() {
        return used;
    }

    
    /**
     * @param currentMem the current to set
     */
    public void setUsed(Long currentMem) {
        this.used = currentMem;
    }

    
    /**
     * @return the available
     */
    public Long getAvailable() {
        return available;
    }

    
    /**
     * @param availableIn the available to set
     */
    public void setAvailable(Long availableIn) {
        this.available = availableIn;
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
    
    /**
     * @return the number of used slots.
     */
    public Long getAllocated() {
        return getTotal() - getAvailable();
    }


    
    /**
     * @return the label
     */
    public String getLabel() {
        return label;
    }


    
    /**
     * @param labelIn the label to set
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }
    

    
    /**
     * @return the name
     */
    public String getName() {
        return name;
    }
    
    /**
     * @param nameIn the name to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }    
}
