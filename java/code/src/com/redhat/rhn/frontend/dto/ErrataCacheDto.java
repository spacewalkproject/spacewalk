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

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * ErrataCacheDto
 * @version $Rev$
 */
public class ErrataCacheDto {

    private Long serverId;
    private Long errataId;
    private Long packageId;
    
    /**
     * Default constructor
     */
    public ErrataCacheDto() {
        serverId = new Long(0);
        errataId = new Long(0);
        packageId = new Long(0);
    }
    /**
     * @return Returns the errataId.
     */
    public Long getErrataId() {
        return errataId;
    }
    
    /**
     * @param errataIdIn The errataId to set.
     */
    public void setErrataId(Long errataIdIn) {
        errataId = errataIdIn;
    }
        
    /**
     * @return Returns the packageId.
     */
    public Long getPackageId() {
        return packageId;
    }
    
    /**
     * @param packageIdIn The packageId to set.
     */
    public void setPackageId(Long packageIdIn) {
        packageId = packageIdIn;
    }
    
    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }
    
    /**
     * @param serverIdIn The serverId to set.
     */
    public void setServerId(Long serverIdIn) {
        serverId = serverIdIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        ErrataCacheDto ecd = (ErrataCacheDto) obj;
        
        return new EqualsBuilder().append(getErrataId(), ecd.getErrataId())
                                  .append(getPackageId(), ecd.getPackageId())
                                  .append(getServerId(), ecd.getServerId())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getErrataId())
                                    .append(getPackageId())
                                    .append(getServerId())
                                    .toHashCode();
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("errata_id", getErrataId())
                                        .append("package_id", getPackageId())
                                        .append("server_id", getServerId())
                                        .toString();
    }
    
}
