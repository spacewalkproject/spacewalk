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
package com.redhat.rhn.domain.errata.impl;

import com.redhat.rhn.domain.BaseDomainHelper;
import com.redhat.rhn.domain.errata.Bug;
import com.redhat.rhn.domain.errata.Errata;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * Bug
 * @version $Rev$
 */
public class PublishedBug extends BaseDomainHelper implements Bug, Serializable {

    private Long id;
    private String summary;
    private Errata errata;
    
    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }
    
    /**
     * @param i The id to set.
     */
    public void setId(Long i) {
        this.id = i;
    }
    
    /**
     * @return Returns the summary.
     */
    public String getSummary() {
        return summary;
    }
    
    /**
     * @param s The summary to set.
     */
    public void setSummary(String s) {
        this.summary = s;
    }
    
    /**
     * {@inheritDoc}
     */
    public Errata getErrata() {
        return errata;
    }
    
    /**
     * {@inheritDoc}
     */
    public void setErrata(Errata errataIn) {
        this.errata = errataIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof PublishedBug)) {
            return false;
        }
        PublishedBug castOther = (PublishedBug) other;
        return new EqualsBuilder().append(id, castOther.id)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(id)
                                    .toHashCode();
    }
}
