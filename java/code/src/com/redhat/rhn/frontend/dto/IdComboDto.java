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

/**
 * This describes an object with a combo id
 * that will be stored in an RhnSet.
 * @version $Rev$
 */
public abstract class IdComboDto extends BaseDto {
    
    /**
     * Returns id to be stored in RhnSet.
     * @return id to be stored in RhnSet.
     */
    public abstract Long getIdOne();
    
    /**
     * Returns idTwo to be stored in RhnSet.
     * @return idTwo to be stored in RhnSet.
     */
    public abstract Long getIdTwo();
    
    /**
     * Overrides method in AbstractDto.
     * Adds this object to the set using both applicable ids. 
     * @param set The set to which we are adding this object's ids
     */
    public void addToSet(RhnSet set) {
        set.addElement(new Long(getIdOne().longValue()), new Long(getIdTwo().longValue()));
    }

}
