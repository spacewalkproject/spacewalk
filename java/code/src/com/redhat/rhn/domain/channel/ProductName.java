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

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;

/**
 * 
 * ProductName
 * @version $Rev$
 */
public class ProductName {
    private Long id;
    private String label;
    private String name;
    private Date created;
    private Date modified;
    
    /**
     * @return the id
     */
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
    
    /**
     * @return the created
     */
    public Date getCreated() {
        return created;
    }
    
    /**
     * @param date the created to set
     */
    public void setCreated(Date date) {
        this.created = date;
    }
    
    /**
     * @return the modified
     */
    public Date getModified() {
        return modified;
    }
    
    /**
     * @param date the modified to set
     */
    public void setModified(Date date) {
        this.modified = date;
    }
    /**
     * 
     * {@inheritDoc}
     */
    public int hashCode() {
       return new HashCodeBuilder().append(getId()).
                           append(getName()).append(getLabel()).toHashCode(); 
    }
    
    /**
     * 
     * {@inheritDoc}
     */
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof ProductName)) {
            return false;
        }
        ProductName that = (ProductName) o;
        return new EqualsBuilder().append(this.getId(), that.getId()).
                           append(this.getLabel(), that.getLabel()).
                           append(this.getName(), that.getName()).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
            return new ToStringBuilder(this).append("id", getId())
                    .append("label", getLabel()).
                    append("name", getName()).toString();
    }    
}
