/**
 * Copyright (c) 2008 Red Hat, Inc.
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


    /**
     * default constructor.
     */
    public RhnSetElement() {
        this(null, null, null, null);
    }
    
    /**
     * Constructs a fully populated element.
     * @param uid User id associated with this element.
     * @param lbl Element label.
     * @param elem Element value.
     * @param elemTwo Element two value.
     */
    public RhnSetElement(Long uid, String lbl, Long elem, Long elemTwo) {
        setup(uid, lbl, elem, elemTwo);
    }

    /**
     * @param uid User id associated with this element.
     * @param lbl Element label.
     * @param elem Element value.
     * @param elemTwo Element two value.
     */
    private void setup(Long uid, String lbl, Long elem, Long elemTwo) {
        userid = uid;
        label = lbl;
        element = elem;
        elementTwo = elemTwo;
    }

    /**
     * Constructs a fully populated rhset element.
     * from a string
     * @param elements Element1 or Element1|Element2
     * @param uid User id associated with this element.
     * @param lbl Element label.
     */
    public  RhnSetElement(Long uid, String lbl, String elements) {
        String[] parts = elements.split("\\|");
        if (parts.length > 1) {                 
            setup(uid, lbl, new Long(parts[0].trim()), new Long(parts[1].trim()));
        }
        else {
            setup(uid, lbl, new Long(parts[0].trim()), null);    
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
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(userid).append(label)
                                    .append(element).append(elementTwo).toHashCode();
    }

    /**
     * {@inheritDoc}
     */
    public String toString() {
        return new ToStringBuilder(this).append("userid", userid).append(
                "label", label).append("element", element).append("elementTwo",
                elementTwo).toString();
    }

}
