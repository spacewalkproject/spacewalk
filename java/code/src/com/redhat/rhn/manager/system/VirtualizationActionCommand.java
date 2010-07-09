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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.common.validator.ValidatorError;
import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.ActionType;
import com.redhat.rhn.domain.action.server.ServerAction;
import com.redhat.rhn.domain.action.virtualization.BaseVirtualizationAction;
import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.manager.common.UninitializedCommandException;

import org.apache.log4j.Logger;

import java.util.Date;
import java.util.Map;

/**
 * Command class for schedule virtualization-related actions
 *
 * @version $Rev $
 */
public class VirtualizationActionCommand {

    private static Logger log = Logger.getLogger(VirtualizationActionCommand.class);

    private User user;
    private Date scheduleDate;
    private ActionType actionType;
    private Server targetSystem;
    private String uuid;
    private Map context;
    private Action action;


    /**
     * Constructor
     * @param userIn User performing the action
     * @param dateIn Earliest execution date/time for the action
     * @param actionTypeIn ActionType of the action being performed.
     * @param targetSystemIn The host system for this action.
     * @param uuidIn String representation of the target instance's UUID
     * @param contextIn Map of optional action arguments.
     */
    public VirtualizationActionCommand(User userIn, Date dateIn, ActionType actionTypeIn,
                                       Server targetSystemIn, String uuidIn,
                                       Map contextIn) {
        this.setUser(userIn);
        this.setScheduleDate(dateIn);
        this.setActionType(actionTypeIn);
        this.setTargetSystem(targetSystemIn);
        this.setUuid(uuidIn);
        this.setContext(contextIn);
    }

    /**
     * Stores virtualization action to be picked up by the client.
     * @return null ALWAYS!
     * @throws UninitializedCommandException if the target system is null.
     */
    public ValidatorError store() throws UninitializedCommandException {
        if (this.getTargetSystem() == null) {
            throw new UninitializedCommandException("No targetSystem for " +
                                                    "VirtualizationActionCommand");
        }

        log.debug("store() called.");

        log.debug("creating virtAction");
        BaseVirtualizationAction virtAction =
            (BaseVirtualizationAction) ActionFactory.createAction(this.getActionType());
        virtAction.setName(this.getActionType().getName());
        virtAction.setOrg(this.getUser().getOrg());
        virtAction.setSchedulerUser(this.getUser());
        virtAction.setEarliestAction(this.getScheduleDate());
        virtAction.setUuid(this.getUuid());

        if (log.isDebugEnabled()) {
            log.debug("virtAction.name: " + virtAction.getName() + " uuid: " +
                    virtAction.getUuid());
        }

        ServerAction serverAction = new ServerAction();
        serverAction.setStatus(ActionFactory.STATUS_QUEUED);
        serverAction.setRemainingTries(new Long(5));
        serverAction.setServer(this.getTargetSystem());
        virtAction.extractParameters(getContext());

        virtAction.addServerAction(serverAction);
        serverAction.setParentAction(virtAction);

        log.debug("saving virtAction.");
        ActionFactory.save(virtAction);
        action = virtAction;
        return null;
    }

    /**
     * gets the action.  Should return null before store() is called.
     * @return the action
     */
    public Action getAction() {
        return action;
    }

    /**
     * Find the appropriate action label for a given action name and current state.
     *
     * @param currentState The current state of the instance
     * @param actionName The name of the action the user wants to perform
     *                   from the button on the form in the web UI.
     * @return The ActionType of the (RHN) action that should be performed.
     */
    public static ActionType lookupActionType(String currentState, String actionName) {
        return VirtualizationActionMap.lookupActionType(currentState, actionName);
    }

    /**
     * Gets the value of user
     *
     * @return the value of user
     */
    public User getUser() {
        return this.user;
    }

    /**
     * Sets the value of user
     *
     * @param argUser Value to assign to this.user
     */
    public void setUser(User argUser) {
        this.user = argUser;
    }

    /**
     * Get the context.
     *
     * @return the context.
     */
    public Map getContext() {
        return context;
    }

    /**
     * Sets the context.
     *
     * @param contextIn Context to set.
     */
    public void setContext(Map contextIn) {
        context = contextIn;
    }

    /**
     * Gets the value of scheduleDate
     *
     * @return the value of scheduleDate
     */
    public Date getScheduleDate() {
        return this.scheduleDate;
    }

    /**
     * Sets the value of scheduleDate
     *
     * @param argScheduleDate Value to assign to this.scheduleDate
     */
    public void setScheduleDate(Date argScheduleDate) {
        this.scheduleDate = argScheduleDate;
    }

    /**
     * Gets the value of actionType
     *
     * @return the value of actionType
     */
    public ActionType getActionType() {
        return this.actionType;
    }

    /**
     * Sets the value of actionType
     *
     * @param argActionType Value to assign to this.actionType
     */
    public void setActionType(ActionType argActionType) {
        this.actionType = argActionType;
    }

    /**
     * Gets the value of targetSystem
     *
     * @return the value of targetSystem
     */
    public Server getTargetSystem() {
        return this.targetSystem;
    }

    /**
     * HashSets the value of targetSystem
     *
     * @param argTargetSystems Value to assign to this.targetSystem
     */
    public void setTargetSystem(Server argTargetSystems) {
        this.targetSystem = argTargetSystems;
    }

    /**
     * Gets the value of uuid
     *
     * @return the value of uuid
     */
    public String getUuid() {
        return this.uuid;
    }

    /**
     * HashSets the value of uuid
     *
     * @param argUuid Value to assign to this.uuid
     */
    public void setUuid(String argUuid) {
        this.uuid = argUuid;
    }

}

