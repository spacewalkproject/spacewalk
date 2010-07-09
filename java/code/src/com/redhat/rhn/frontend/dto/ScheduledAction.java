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

import com.redhat.rhn.common.db.datasource.RowCallback;
import com.redhat.rhn.common.localization.LocalizationService;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Simple DTO for transfering data from the DB to the UI through datasource.
 *
 * @version $Rev$
 */
public class ScheduledAction extends BaseDto implements RowCallback {

    /** Status of Queued Action */
    private static final String QUEUED = "Queued";
    /** Status of an Action which was picked up to executed. */
    private static final String PICKED_UP = "Picked Up";
    /** Status of a completed Action */
    private static final String COMPLETED = "Completed";
    /** Status of an Action which did not complete */
    private static final String FAILED = "Failed";

    private Long id;
    private Long actionStatusId;
    private Long prerequisite;
    private Date earliest;
    private String typeName;
    private String actionName;
    private Long scheduler;
    private String schedulerName;
    private long queued;
    private long pickedUp;
    private long completed;
    private long failed;
    private long tally;
    private String ageString;
    private String userName;

    /**
     * Returns the Action's id.
     * @return the Action's id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Returns the earliest date the action will be run.
     * @return the earliest date the action will be run.
     */
    public String getEarliest() {
        return LocalizationService.getInstance().formatDate(earliest);
    }

    /**
     * Returns the earliest date the action will be run.
     * @return the earliest date the action will be run.
     */
    public Date getEarliestDate() {
        return earliest;
    }
    /**
     * Returns the type name of the action.
     * @return the type name of the action.
     */
    public String getTypeName() {
        return typeName;
    }

    /**
     * Returns the human readable name of action.
     * @return the human readable name of action.
     */
    public String getActionName() {
        return actionName;
    }

    /**
     * Returns the person or entity which scheduled the action.
     * @return the person or entity which scheduled the action.
     */
    public Long getScheduler() {
        return scheduler;
    }

    /**
     * Returns the name of the person or entity which scheduled the action.
     * @return the person or entity which scheduled the action.
     */
    public String getSchedulerName() {
        return schedulerName;
    }

    /**
     * Sets the Action's id.
     * @param idIn database id.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Sets the earliest date the action will be run.
     * @param early earliest date the action will be run.
     */
    public void setEarliest(Date early) {
        earliest = early;
    }

    /**
     * Sets the name of the Action type.
     * @param tname name of the action type.
     */
    public void setTypeName(String tname) {
        typeName = tname;
    }

    /**
     * Sets the action's name
     * @param aname the action's name.
     */
    public void setActionName(String aname) {
        actionName = aname;
    }

    /**
     * Sets the person or entity which scheduled the action.
     * @param sched the person or entity which scheduled the action.
     */
    public void setScheduler(Long sched) {
        scheduler = sched;
    }

    /**
     * Sets the name of the person or entity which scheduled the action.
     * @param schedName the name of the person or entity which scheduled the action.
     */
    public void setSchedulerName(String schedName) {
        schedulerName = schedName;
    }

    /**
     * Returns the total count of the scheduled actions.
     * @return the total count of the scheduled actions..
     */
    public long getTally() {
        return tally;
    }

    /**
     * Returns the number of completed actions.
     * @return the number of completed actions.
     */
    public long getCompleted() {
        return completed;
    }

    /**
     * Returns the number of failed actions.
     * @return the number of failed actions.
     */
    public long getFailed() {
        return failed;
    }

    /**
     * Returns the number of actions which are in progress.
     * @return the number of actions which are in progress.
     */
    public long getInProgress() {
        return (pickedUp + queued);
    }

    /**
     * {@inheritDoc}
     */
    public void callback(ResultSet rs) throws SQLException {
        if (rs != null) {

            String status = getString(rs, "ACTION_STATUS");
            long count = rs.getLong("TALLY");
            tally += count;
            if (QUEUED.equals(status)) {
                queued += count;
            }
            else if (PICKED_UP.equals(status)) {
                pickedUp += count;
            }
            else if (COMPLETED.equals(status)) {
                completed += count;
            }
            else if (FAILED.equals(status)) {
                failed += count;
            }
        }
    }


    /**
     *
     * {@inheritDoc}
     */
    public List<String> getCallBackColumns() {
        List<String> list = new ArrayList<String>();
        list.add("ACTION_STATUS".toLowerCase());
        list.add("TALLY".toLowerCase());
        return list;
    }


    /**
     * Simple utility method to handle a null value coming
     * from the ResultSet, returns "" if rs.getString() is null.
     * @param rs ResultSet to be queried.
     * @param col Name of column to be looked up.
     * @return The value for the given column name, or empty string "".
     * @throws SQLException if a problem occurs while using the ResultSet.
     */
    private String getString(ResultSet rs, String col) throws SQLException {
        String val = rs.getString(col);
        if (val == null) {
            return "";
        }

        return val;
    }

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
     * Getter for userName
     * @return String to get
     */
    public String getUserName() {
        return this.userName;
    }

    /**
     * Setter for userName
     * @param stringIn String to set userName to
     */
    public void setUserName(String stringIn) {
        this.userName = stringIn;
    }

    /**
     * @return Returns the actionStatusId.
     */
    public Long getActionStatusId() {
        return actionStatusId;
    }

    /**
     * @param actionStatusIdIn The actionStatusId to set.
     */
    public void setActionStatusId(Long actionStatusIdIn) {
        this.actionStatusId = actionStatusIdIn;
    }

    /**
     * Returns the prerequisite for this action.
     * @return Prerequisite action id for this action.
     */
    public Long getPrerequisite() {
        return prerequisite;
    }

    /**
     * @param prerequisiteIn The prerequisite to set.
     */
    public void setPrerequisite(Long prerequisiteIn) {
        prerequisite = prerequisiteIn;
    }

    /**
     * @return True if this entry should be selectable in the UI.
     */
    public boolean isSelectable() {
        return prerequisite == null;
    }

}
