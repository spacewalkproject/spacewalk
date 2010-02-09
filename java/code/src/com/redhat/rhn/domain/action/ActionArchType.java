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
package com.redhat.rhn.domain.action;

import com.redhat.rhn.domain.BaseDomainHelper;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * ActionType
 * @version $Rev$
 */
public class ActionArchType extends BaseDomainHelper implements Serializable {

    private Long archTypeId;
    private String actionStyle;
        
    private ActionType actionType;

    /** 
     * Getter for archTypeId 
     * @return Long to get
    */
    public Long getArchTypeId() {
        return this.archTypeId;
    }

    /** 
     * Setter for archTypeId 
     * @param archTypeIdIn to set
    */
    public void setArchTypeId(Long archTypeIdIn) {
        this.archTypeId = archTypeIdIn;
    }

    /** 
     * Getter for actionStyle 
     * @return String to get
    */
    public String getActionStyle() {
        return this.actionStyle;
    }

    /** 
     * Setter for actionStyle 
     * @param actionStyleIn to set
    */
    public void setActionStyle(String actionStyleIn) {
        this.actionStyle = actionStyleIn;
    }

    /**
     * @return Returns the actionType.
     */
    public ActionType getActionType() {
        return actionType;
    }
    /**
     * @param actionTypeIn The actionType to set.
     */
    public void setActionType(ActionType actionTypeIn) {
        this.actionType = actionTypeIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof ActionArchType)) {
            return false;
        }
        ActionArchType castOther = (ActionArchType) other;
        return new EqualsBuilder().append(archTypeId, castOther.archTypeId).append(
                actionStyle, castOther.actionStyle).isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(archTypeId).append(actionStyle)
                .toHashCode();
    }

}
