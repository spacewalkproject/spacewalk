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
package com.redhat.rhn.domain.config;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

/**
 * ConfigFileName - Class representation of the table rhnConfigFileName.
 * @version $Rev$
 */
public class ConfigFileName extends BaseDomainHelper {

    private Long id;
    private String path;
    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /** 
     * Getter for path 
     * @return String to get
    */
    public String getPath() {
        return this.path;
    }

    /** 
     * Setter for path 
     * @param pathIn to set
    */
    public void setPath(String pathIn) {
        this.path = pathIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ConfigFileName)) {
            return false;
        }
        ConfigFileName castOther = (ConfigFileName)other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .append(path, castOther.path)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .append(path)
                                    .toHashCode();
    }


}
