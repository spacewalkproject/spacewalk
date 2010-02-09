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
package com.redhat.rhn.domain.rhnpackage;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * ChangeLogEntry
 * @version $Rev$
 */
public class ChangeLogEntry extends BaseDomainHelper implements Serializable {

    private Long id;
    private Package rhnPackage;
    private String name;
    private String text;
    private Date time;

    /**
     * @return Returns the name of the author
     */
    public String getName() {
        return name;
    }

    /**
     * @param nameIn The name of the author to set
     */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /**
     * @return Returns the rhnPackage
     */
    public Package getRhnPackage() {
        return rhnPackage;
    }

    /**
     * @param rhnPackageIn The package to set
     */
    public void setRhnPackage(Package rhnPackageIn) {
        this.rhnPackage = rhnPackageIn;
    }

    /**
     * @return Returns the text of the change log entry
     */
    public String getText() {
        return text;
    }

    /**
     * @param textIn the text to set.
     */
    public void setText(String textIn) {
        this.text = textIn;
    }

    /**
     * @return Returns the time for the change log entry
     */
    public Date getTime() {
        return time;
    }

    /**
     * @param timeIn The time to set
     */
    public void setTime(Date timeIn) {
        this.time = timeIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ChangeLogEntry)) {
            return false;
        }
        ChangeLogEntry castOther = (ChangeLogEntry) other;
        return new EqualsBuilder().append(name, castOther.name).append(rhnPackage,
                castOther.rhnPackage).append(text, castOther.text).append(time,
                castOther.time).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(rhnPackage).append(name).append(text).append(
                time).toHashCode();
    }

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
}
