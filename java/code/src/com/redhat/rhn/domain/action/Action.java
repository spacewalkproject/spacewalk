/**
 * Copyright (c) 2009 Red Hat, Inc.
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
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.user.User;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * Action - Class representation of the table rhnAction.
 * @version $Rev$
 */
public class Action extends BaseDomainHelper implements Serializable {
    
    private Long id;
    private String name;
    // private Long scheduler;
    private Date earliestAction;
    private Long version;
    private Long archived;
    private Date created;
    private Date modified;
    private Action prerequisite;
    private ActionType actionType;
    
    private Set serverActions;
    private User schedulerUser;
    private Org org;
    
    private String ageString;
    
    /**
     * The ActionFormatter associated with this Action.  Protected
     * so subclasses can init it.
     */
    protected ActionFormatter formatter;
    
    /** 
     * Getter for ageString
     * @return String to get
     */
    public String getAgeString() {
        return this.ageString;
    }
    
    /** 
     * Setter for ageString
     * @param stringIn String to set ageString to 
     */
    public void setAgeString(String stringIn) {
        this.ageString = stringIn;
    }
    /** 
     * Getter for id 
     * @return Long to get
    */
    public Long getId() {
        return this.id;
    }

    /** 
     * Setter for id 
     * @param idIn to set
    */
    public void setId(Long idIn) {
        this.id = idIn;
    }
    
    /** 
     * Getter for actionType 
     * @return ActionType to get
    */
    public ActionType getActionType() {
        return this.actionType;
    }

    /** 
     * Setter for actionType 
     * @param actionTypeIn to set
    */
    public void setActionType(ActionType actionTypeIn) {
        this.actionType = actionTypeIn;
    }

    /** 
     * Getter for name 
     * @return String to get
    */
    public String getName() {
        return this.name;
    }

    /** 
     * Setter for name 
     * @param nameIn to set
    */
    public void setName(String nameIn) {
        this.name = nameIn;
    }

    /** 
     * Getter for scheduler 
     * @return Long to get
    
    public Long getScheduler() {
        return this.scheduler;
    }*/

    /** 
     * Setter for scheduler 
     * @param schedulerIn to set
    
    public void setScheduler(Long schedulerIn) {
        this.scheduler = schedulerIn;
    }*/

    /** 
     * Getter for earliestAction 
     * @return Date to get
    */
    public Date getEarliestAction() {
        return this.earliestAction;
    }

    /** 
     * Setter for earliestAction 
     * @param earliestActionIn to set
    */
    public void setEarliestAction(Date earliestActionIn) {
        this.earliestAction = earliestActionIn;
    }

    /** 
     * Getter for version 
     * @return Long to get
    */
    public Long getVersion() {
        return this.version;
    }

    /** 
     * Setter for version 
     * @param versionIn to set
    */
    public void setVersion(Long versionIn) {
        this.version = versionIn;
    }

    /** 
     * Getter for archived 
     * @return Long to get
    */
    public Long getArchived() {
        return this.archived;
    }

    /** 
     * Setter for archived 
     * @param archivedIn to set
    */
    public void setArchived(Long archivedIn) {
        this.archived = archivedIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /** 
     * Getter for prerequisite 
     * @return Long to get
    */
    public Action getPrerequisite() {
        return this.prerequisite;
    }

    /** 
     * Setter for prerequisite 
     * @param prerequisiteIn to set
    */
    public void setPrerequisite(Action prerequisiteIn) {
        this.prerequisite = prerequisiteIn;
    }

    /** 
     * Getter for serverActions.  Contains:
     * a collection of: com.redhat.rhn.domain.action.server.ServerAction classes
     * @return Set of com.redhat.rhn.domain.action.server.ServerAction classes
    */
    public Set <ServerAction> getServerActions() {
        return this.serverActions;
    }

    /** 
     * Setter for serverActions.   Contains:
     * a collection of: com.redhat.rhn.domain.action.server.ServerAction classes
     * @param serverActionsIn to set
    */
    public void setServerActions(Set serverActionsIn) {
        this.serverActions = serverActionsIn;
    }

    /**
     * Add a ServerAction to this Action
     * @param saIn serverAction to add
     */
    public void addServerAction(ServerAction saIn) {
        if (serverActions == null) {
            serverActions = new HashSet();
        }
        saIn.setParentAction(this);
        serverActions.add(saIn);
    }
    
    /** 
    * Set the Scheduler User who scheduled this Action
    * @param schedulerIn the User who did the scheduling
    */
    public void setSchedulerUser(User schedulerIn) {
        this.schedulerUser = schedulerIn;
    }
    
    /**
     * Get the User who scheduled this Action.
     * @return User who scheduled this Action
     */
    public User getSchedulerUser() {
        return this.schedulerUser;
    }
     
    /**
     * @return Returns the org.
     */
    public Org getOrg() {
        return org;
    }
    /**
     * @param orgIn The org to set.
     */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }
    /**
     * Get the formatter for this class.  Subclasses may override
     * the ActionFormatter to provide custom output.
     * @return ActionFormatter for this class.
     */
    public ActionFormatter getFormatter() {
        if (formatter == null) {
            formatter = new ActionFormatter(this);
        }
        return formatter;
    }
    
    /** 
     * Get the count of the number of times this action has failed.
     * @return Count of failed actions.
     */
    public Long getFailedCount() {
        return new Long(getActionStatusCount(ActionFactory.STATUS_FAILED));
    }

    /** 
     * Get the count of the number of times this action has succeeded.
     * @return Count of successful actions.
     */
    public Long getSuccessfulCount() {
        return new Long(getActionStatusCount(ActionFactory.STATUS_COMPLETED));
    }
    
    // Get the number of ServerAction objects that match
    // the passed in ActionStatus
    private long getActionStatusCount(ActionStatus status) {
        return ActionFactory.getServerActionCountByStatus(this.getOrg(), this, status);
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof Action)) {
            return false;
        }
        Action castOther = (Action) other;
        return new EqualsBuilder().append(this.getId(), castOther.getId())
                                  .append(this.getOrg(), castOther.getOrg())
                                  .append(this.getName(), castOther.getName())
                                  .append(this.getEarliestAction(), 
                                          castOther.getEarliestAction())
                                  .append(this.getVersion(), castOther.getVersion())
                                  .append(this.getArchived(), castOther.getArchived())
                                  .append(this.getCreated(), castOther.getCreated())
                                  .append(this.getModified(), castOther.getModified())
                                  .append(this.getPrerequisite(), 
                                          castOther.getPrerequisite())
                                  .append(this.getActionType(), castOther.getActionType())
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(this.getId()).append(this.getOrg())
                                    .append(this.getName())
                                    .append(this.getEarliestAction())
                                    .append(this.getVersion())
                                    .append(this.getArchived())
                                    .append(this.getCreated())
                                    .append(this.getModified())
                                    .append(this.getPrerequisite())
                                    .append(this.getActionType()).toHashCode();
    }
    
    /**
     * {@inheritDoc}
     */
    public String toString() {
        StringBuffer result = new StringBuffer();
        result.append(id);
        result.append(" : ");
        result.append(name);
        return result.toString();
    }

}
