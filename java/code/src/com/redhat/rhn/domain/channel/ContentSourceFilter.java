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
package com.redhat.rhn.domain.channel;

import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * ContentSourceFilter
 * @version $Rev$
 */
public class ContentSourceFilter extends BaseDomainHelper {
    private Long id;
    private Long sourceId;
    private String flag;
    private String filter;
    private int sortOrder;

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
        this.id = idIn;
    }

    /**
     * @return Returns the sourceId.
     */
    public Long getSourceId() {
        return sourceId;
    }

    /**
     * @param sourceIdIn The sourceId to set.
     */
    public void setSourceId(Long sourceIdIn) {
        this.sourceId = sourceIdIn;
    }

    /**
     * @return Returns the flag.
     */
    public String getFlag() {
        return flag;
    }

    /**
     * @param flagIn The flag to set.
     */
    public void setFlag(String flagIn) {
        this.flag = flagIn;
    }

    /**
     * @return Returns the filter.
     */
    public String getFilter() {
        return filter;
    }

    /**
     * @param filterIn The filter to set.
     */
    public void setFilter(String filterIn) {
        this.filter = filterIn;
    }

    /**
     * @return Returns the sortOrder.
     */
    public int getSortOrder() {
        return sortOrder;
    }

    /**
     * @param sortOrderIn The sortOrder to set.
     */
    public void setSortOrder(int sortOrderIn) {
        this.sortOrder = sortOrderIn;
    }
}
