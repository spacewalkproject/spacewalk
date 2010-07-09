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
package com.redhat.rhn.domain;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.util.Date;


/**
 * A Label is essentially a constant because Label implementations are mapped to read-only,
 * reference tables where the Label objects/rows already exist. Reference tables like these
 * consist of (at least) the following columns:
 *
 * <ul>
 *   <li>ID</li>
 *   <li>NAME</li>
 *   <li>LABEL</li>
 *   <li>CREATED</li>
 *   <li>MODIFIED</li>
 * </ul>
 *
 * Examples of these types of tables include <code>rhnServerGroupType</code> and <code>
 * rhnVirtualInstanceType</code>. Additional columns can be mapped in subclasses.
 *
 * <br/><br/>
 *
 * {@link AbstractLabelNameHelper} is conceptually the same as this class; however, it is
 * not implemented as an immutable like this class.
 *
 * <br/><br/>
 *
 * For an example of how to implement a Label, take a look at VirtualInstanceType and
 * VirtualInstanceTypeFactory.
 *
 * @see com.redhat.rhn.domain.server.VirtualInstanceType
 *
 * @version $Rev$
 */
public abstract class Label {

    private Long id;
    private String name;
    private String label;
    private Date created;
    private Date modified;

    /**
     * Returns the primary key.
     *
     * @return The primary key
     */
    public Long getId() {
        return id;
    }

    private void setId(Long newId) {
        id = newId;
    }

    /**
     * Returns the name of this label.
     *
     * @return The name of this label
     */
    public String getName() {
        return name;
    }

    private void setName(String newName) {
        name = newName;
    }

    /**
     * Returns the label text of this label.
     *
     * @return The label text of this label
     */
    public String getLabel() {
        return label;
    }

    private void setLabel(String newLabel) {
        label = newLabel;
    }

    /**
     * Get the date on which this label was created.
     *
     * @return The date on which this label was created.
     */
    public Date getCreated() {
        return created;
    }

    private void setCreated(Date date) {
        created = date;
    }

    /**
     * Get the date of last modification.
     *
     * @return The date of last modification.
     */
    public Date getModified() {
        return modified;
    }

    private void setModified(Date date) {
        modified = date;
    }

    /**
     * Two labels are considered equal when they have the same name and label text.
     *
     * @param object The object to compare against this label
     *
     * @return <code>true</code> if <code>object</code> is a label and its
     * label text and name are the same as this label.
     */
    public boolean equals(Object object) {
        if (object == null || object.getClass() != getClass()) {
            return false;
        }

        Label that = (Label)object;

        return new EqualsBuilder().append(this.getName(), that.getName())
                .append(this.getLabel(), that.getLabel()).isEquals();
    }

    /**
     *
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getName()).append(getLabel()).toHashCode();
    }

}
