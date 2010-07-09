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
package com.redhat.rhn.domain.rhnset;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

import java.io.Serializable;

/**
 * RhnSetElement
 * @version $Rev$
 */
public class RhnSetElement implements Serializable {
    private Long userid;
    private String label;
    private Long element;
    private Long elementTwo;
    private Long elementThree;

    /**
     * default constructor.
     */
    public RhnSetElement() {
        this(null, null, null, null, null);
    }

    /**
     * Constructs an element with two identifiers.
     * @param uid User id associated with this element.
     * @param lbl Element label.
     * @param elem Element value.
     * @param elemTwo Element two value.
     */
    public RhnSetElement(Long uid, String lbl, Long elem, Long elemTwo) {
        this(uid, lbl, elem, elemTwo, null);
    }

    /**
     * Constructs an element with three identifiers.
     * @param uid user id associated with this element
     * @param lbl element label
     * @param elem element value
     * @param elemTwo element value
     * @param elemThree element value
     */
    public RhnSetElement(Long uid, String lbl, Long elem, Long elemTwo, Long elemThree) {
        setup(uid, lbl, elem, elemTwo, elemThree);
    }

    /**
     * @param uid User id associated with this element.
     * @param lbl Element label.
     * @param elem Element value.
     * @param elemTwo Element two value.
     * @param elemThree Element three value.
     */
    private void setup(Long uid, String lbl, Long elem, Long elemTwo, Long elemThree) {
        userid = uid;
        label = lbl;
        element = elem;
        elementTwo = elemTwo;
        elementThree = elemThree;
    }

    /**
     * Constructs a fully populated rhset element.
     * from a string
     * @param elements Element1 or Element1|Element2 or Element1|Element2|Element3
     * @param uid User id associated with this element.
     * @param lbl Element label.
     */
    public  RhnSetElement(Long uid, String lbl, String elements) {
        String[] parts = elements.split("\\|");
        if (parts.length > 2) {
            setup(uid, lbl, new Long(parts[0].trim()), new Long(parts[1].trim()),
                new Long(parts[2].trim()));
        }
        else if (parts.length > 1) {
            setup(uid, lbl, new Long(parts[0].trim()), new Long(parts[1].trim()), null);
        }
        else {
            setup(uid, lbl, new Long(parts[0].trim()), null, null);
        }
    }

    /**
     * Sets the userid associated with this element.
     * @param id Userid associated with this element.
     */
    public void setUserId(Long id) {
        userid = id;
    }

    /**
     * Returns the userid associated with this element.
     * @return the userid associated with this element.
     */
    public Long getUserId() {
        return userid;
    }

    /**
     * Sets the element's label.
     * @param lbl the element's label.
     */
    public void setLabel(String lbl) {
        label = lbl;
    }

    /**
     * Returns the element's label.
     * @return the element's label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * Sets the element's value.
     * @param elem the element's value.
     */
    public void setElement(Long elem) {
        element = elem;
    }

    /**
     * Returns the element's value.
     * @return the element's value.
     */
    public Long getElement() {
        return element;
    }

    /**
     * Sets the optional element value.
     * @param elem the optional element value.
     */
    public void setElementTwo(Long elem) {
        elementTwo = elem;
    }

    /**
     * Returns the optional element value.
     * @return the optional element value.
     */
    public Long getElementTwo() {
        return elementTwo;
    }

    /**
     * Sets the second optional element value.
     * @param elem the second optional element value.
     */
    public void setElementThree(Long elem) {
        elementThree = elem;
    }

    /**
     * Returns the second optional element value.
     * @return the second optional element value.
     */
    public Long getElementThree() {
        return elementThree;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof RhnSetElement)) {
            return false;
        }

        RhnSetElement rse = (RhnSetElement)obj;
        return new EqualsBuilder().append(userid, rse.getUserId())
                                  .append(label, rse.getLabel())
                                  .append(element, rse.getElement())
                                  .append(elementTwo, rse.getElementTwo())
                                  .append(elementThree, rse.getElementThree())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(userid).append(label)
                                    .append(element).append(elementTwo)
                                    .append(elementThree).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("userid", userid).append(
                "label", label).append("element", element).append("elementTwo",
                elementTwo).append("elementThree", elementThree).toString();
    }

}
