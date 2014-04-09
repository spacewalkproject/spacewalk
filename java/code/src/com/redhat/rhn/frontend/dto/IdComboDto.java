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

    protected String idCombo;
    protected Long idOne;
    protected Long idTwo;
    protected Long idThree;

    /**
     * @return Returns the idCombo.
     */
    public String getIdCombo() {
        return idCombo;
    }

    /**
     * @param idComboIn The idCombo to set.
     */
    public void setIdCombo(String idComboIn) {
        idCombo = idComboIn;
        if (idComboIn != null) {
            String[] ids = idCombo.split("\\|");
            if (ids.length > 0) {
                idOne = Long.valueOf(ids[0]);
            }
            if (ids.length > 1) {
                idTwo = Long.valueOf(ids[1]);
            }
            if (ids.length > 2) {
                idThree = Long.valueOf(ids[2]);
            }
        }
    }

    /**
     * Returns id to be stored in RhnSet.
     * @return id to be stored in RhnSet.
     */
    public Long getIdOne() {
        return idOne;
    }

    /**
     * Returns idTwo to be stored in RhnSet.
     * @return idTwo to be stored in RhnSet.
     */
    public Long getIdTwo() {
        return idTwo;
    }

    /**
     * Returns idThree to be stored in RhnSet.
     * @return idThree to be stored in RhnSet.
     */
    public Long getIdThree() {
        return idThree;
    }

    /**
     * Overrides method in AbstractDto.
     * Adds this object to the set using both applicable ids.
     * @param set The set to which we are adding this object's ids
     */
    public void addToSet(RhnSet set) {
        set.addElement(idOne, idTwo, idThree);
    }

}
