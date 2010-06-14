/**
 * Copyright (c) 2010 Red Hat, Inc.
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
package com.redhat.rhn.taskomatic;

import java.util.Date;
import java.util.HashSet;
import java.util.Set;


/**
 * TaskoTemplate
 * @version $Rev$
 */
public class TaskoTemplate {
    private Long id;
    private TaskoBunch bunch;
    private TaskoTask task;
    private Long ordering;
    private String startIf;
    private Date created;
    private Date modified;
    private Set<TaskoRun> runHistory = new HashSet();

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * @return Returns the bunch.
     */
    public TaskoBunch getBunch() {
        return bunch;
    }

    /**
     * @param bunchIn The bunch to set.
     */
    public void setBunch(TaskoBunch bunchIn) {
        this.bunch = bunchIn;
    }

    /**
     * @return Returns the task.
     */
    public TaskoTask getTask() {
        return task;
    }

    /**
     * @param taskIn The task to set.
     */
    public void setTask(TaskoTask taskIn) {
        this.task = taskIn;
    }

    /**
     * @return Returns the ordering.
     */
    public Long getOrdering() {
        return ordering;
    }

    /**
     * @param orderingIn The ordering to set.
     */
    public void setOrdering(Long orderingIn) {
        this.ordering = orderingIn;
    }

    /**
     * @return Returns the startIf.
     */
    public String getStartIf() {
        return startIf;
    }

    /**
     * @param startIfIn The startIf to set.
     */
    public void setStartIf(String startIfIn) {
        this.startIf = startIfIn;
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param createdIn The created to set.
     */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }


    /**
     * @return Returns the runHistory.
     */
    public Set<TaskoRun> getRunHistory() {
        return runHistory;
    }


    /**
     * @param runHistoryIn The runHistory to set.
     */
    public void setRunHistory(Set<TaskoRun> runHistoryIn) {
        this.runHistory = runHistoryIn;
    }
}
