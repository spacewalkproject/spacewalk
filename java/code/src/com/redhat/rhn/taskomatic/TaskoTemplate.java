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
package com.redhat.rhn.taskomatic;

import java.util.Date;


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

    /**
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @param id The id to set.
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * @return Returns the bunch.
     */
    public TaskoBunch getBunch() {
        return bunch;
    }

    /**
     * @param bunch The bunch to set.
     */
    public void setBunch(TaskoBunch bunch) {
        this.bunch = bunch;
    }

    /**
     * @return Returns the task.
     */
    public TaskoTask getTask() {
        return task;
    }

    /**
     * @param task The task to set.
     */
    public void setTask(TaskoTask task) {
        this.task = task;
    }

    /**
     * @return Returns the ordering.
     */
    public Long getOrdering() {
        return ordering;
    }

    /**
     * @param ordering The ordering to set.
     */
    public void setOrdering(Long ordering) {
        this.ordering = ordering;
    }

    /**
     * @return Returns the startIf.
     */
    public String getStartIf() {
        return startIf;
    }

    /**
     * @param startIf The startIf to set.
     */
    public void setStartIf(String startIf) {
        this.startIf = startIf;
    }

    /**
     * @return Returns the created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param created The created to set.
     */
    public void setCreated(Date created) {
        this.created = created;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param modified The modified to set.
     */
    public void setModified(Date modified) {
        this.modified = modified;
    }

}
