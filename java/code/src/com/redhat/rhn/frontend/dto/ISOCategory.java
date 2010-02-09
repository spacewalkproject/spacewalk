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


/**
 * ISOCategory - handles DataResult return from 
 *   channel_queries.channel_download_categories_by_type
 * @version $Rev$
 */
public class ISOCategory extends BaseDto {
    private String category;
    private Long minOrder;
    
    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return minOrder;
    }

    /**
     * Get the category-name
     * @return category
     */
    public String getCategory() {
        return category;
    }

    /**
     * Set category-name
     * @param cat category-name to set
     */
    public void setCategory(String cat) {
        category = cat;
    }

    /**
     * Get smallest ordering-number for thall ISOs i nthis category
     * @return min-order
     */
    public Long getMinOrder() {
        return minOrder;
    }

    /**
     * Set min-order
     * @param min minOrder to set
     */
    public void setMinOrder(Long min) {
        minOrder = min;
    }

    /**
     * Set an ID for this category
     * @param newId new id
     */
    public void setId(Long newId) {
        this.minOrder = newId;
    }
}
