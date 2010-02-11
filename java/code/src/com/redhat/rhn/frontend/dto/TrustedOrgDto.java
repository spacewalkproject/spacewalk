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




/**
 * 
 * OrgDto class represents Trusted Org lists
 * @version $Rev$
 */
public class TrustedOrgDto extends BaseDto {
    private Long id;
    private Long sharedChannels;
    private String name;

    /**
     * 
     * {@inheritDoc}
     */
    public Long getId() {
        return id;
    }
    
    /**
     * 
     * @param idIn OrgIn Id 
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /**
     * 
     * @return Name of Org
     */
    public String getName() {
        return name;
    }
    
    /**
     * 
     * @param nameIn of Org to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * 
     * @return number of shared channels
     */
    public Long getSharedChannels() {
        return sharedChannels;
    }

    /**
     * 
     * @param sharedIn shared channels of Org to set
     */
    public void setSharedchannels(Long sharedIn) {
        this.sharedChannels = sharedIn;
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof OrgDto)) {
            return false;
        }
        OrgDto that = (OrgDto) o;
        EqualsBuilder b = new EqualsBuilder();
        b.append(this.getId(), that.getId());
        b.append(this.getName(), that.getName());
        return b.isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    @Override
    public int hashCode() {
        HashCodeBuilder b = new HashCodeBuilder();
        b.append(getId()).append(getName());
        return b.toHashCode();
    }   
    
}
