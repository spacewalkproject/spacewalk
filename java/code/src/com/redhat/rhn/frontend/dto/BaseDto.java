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

import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.frontend.struts.Selectable;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * All dtos used for listviews should extend this class allowing us to treat
 * dtos as a common object. Currently used mainly by RhnSetAction to perform a
 * select all.
 * @version $Rev: 60953 $
 */
public abstract class BaseDto implements Selectable { 
    
    private boolean selected;
    protected static final Integer ONE = new Integer(1);
    protected static final Integer ZERO = new Integer(0);
    
    /**
     * Returns id to be stored in RhnSet.
     * @return id to be stored in RhnSet.
     */
    public abstract Long getId();

    /**
     * This says whether this object is selectable on a page with a set The
     * default as can be seen is true. Any dto class that cares should override
     * this method. This is used by RhnSet in the select all method. In order to
     * disable checkboxes on a page use <code>&lt;rhn:set value="${current.id}"
     * disabled="${not current.selectable}"  /&gt;</code>
     * @return whether this object is selectable for RhnSet
     */
    public boolean isSelectable() {
        return true;
    }

    /**
     * Adds the id of this object to a given set. For adding IdCombos to a set,
     * @see com.redhat.rhn.frontend.dto.IdComboDto
     * @param set The set to which we are adding an element.
     */
    public void addToSet(RhnSet set) {
        set.addElement(new Long(getId().longValue()));
    }
    

    
    /**
     * @return the selected
     */
    public boolean isSelected() {
        return selected;
    }

    
    /**
     * @param isSelected the selected to set
     */
    public void setSelected(boolean isSelected) {
        this.selected = isSelected;
    }    
    
    /**
     * 
     * {@inheritDoc}
     */
    public String getSelectionKey() {
        return String.valueOf(getId());
    }
    

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
