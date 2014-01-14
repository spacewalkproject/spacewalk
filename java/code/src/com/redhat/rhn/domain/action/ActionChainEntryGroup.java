/**
 * Copyright (c) 2014 SUSE
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * aInteger with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * Red Hat trademarks are not licensed under GPLv2. No permission is
 * granted to use or replicate Red Hat trademarks that are incorporated
 * in this software or its documentation.
 */
package com.redhat.rhn.domain.action;

/**
 * Represents a group of Action Chain entries with same sort order and action
 * type.
 * @author Silvio Moioli <smoioli@suse.de>
 */
public class ActionChainEntryGroup {

    /** The sort order. */
    private Integer sortOrder;

    /** A representative action from the group. */
    private Long actionId;

    /** The system count. */
    private Long systemCount;

    /**
     * Default constructor.
     */
    public ActionChainEntryGroup() {
    }

    /**
     * Standard constructor.
     * @param sortOrderIn the sort order
     * @param actionIdIn id for an Action which represents this group
     * @param systemCountIn the system count
     */
    public ActionChainEntryGroup(Integer sortOrderIn, Long actionIdIn,
        Long systemCountIn) {
        setSortOrder(sortOrderIn);
        setActionId(actionIdIn);
        setSystemCount(systemCountIn);
    }

    /**
     * Gets the sort order.
     * @return the sort order
     */
    public Integer getSortOrder() {
        return sortOrder;
    }

    /**
     * Sets the sort order.
     * @param sortOrderIn the new sort order
     */
    public void setSortOrder(Integer sortOrderIn) {
        sortOrder = sortOrderIn;
    }

    /**
     * Gets the action id.
     *
     * @return the action id
     */
    public Long getActionId() {
        return actionId;
    }

    /**
     * Sets the action id.
     *
     * @param actionIdIn the new action id
     */
    public void setActionId(Long actionIdIn) {
        actionId = actionIdIn;
    }

    /**
     * Gets the system count.
     * @return the system count
     */
    public Long getSystemCount() {
        return systemCount;
    }

    /**
     * Sets the system count.
     * @param systemCountIn the new system count
     */
    public void setSystemCount(Long systemCountIn) {
        systemCount = systemCountIn;
    }

    /**
     * Gets the Action type label.
     *
     * @return the action type label
     */
    public String getActionTypeLabel() {
        return ActionFactory.lookupById(actionId).getActionType().getLabel();
    }

    /**
     * Gets a description of the object(s) related to this Action.
     *
     * @return the object description
     */
    public String getRelatedObjectDescription() {
        return ActionFactory.lookupById(actionId).getFormatter()
            .getRelatedObjectDescription();
    }
}
