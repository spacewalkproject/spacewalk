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

import com.redhat.rhn.taskomatic.core.SchedulerKernel;

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * TaskoBunch
 * @version $Rev$
 */
public class TaskoBunch implements Job {

    private static Logger log = Logger.getLogger(TaskoBunch.class);
    private Long id;
    private String name;
    private String description;
    private Date activeFrom;
    private Date activeTill;
    private List<TaskoTask> tasks = new ArrayList();
    private Date created;
    private Date modified;

    public void execute(JobExecutionContext context)
        throws JobExecutionException {
        JobDataMap dataMap = context.getJobDetail().getJobDataMap();
        // String bunchName = dataMap.getString("name");
        log.info("Starting " + this.name + " at " + new Date());

        String previousTaskStatus = null;
        for (TaskoTask task : this.tasks) {
            if (task == null) {
                continue;
            }

            if (previousTaskStatus != null) {
                // if (task.startIf == previousTaskStatus) {

                // }
            }
            // job = (Job) taskClass.newInstance();
            task.execute(context);
            previousTaskStatus = "1"; //TaskoFactory.getTaskStatus(bunchId, taskId);
        }

        log.info("Finishing " + this.name + " at " + new Date());
    }


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
     * @return Returns the name.
     */
    public String getName() {
        return name;
    }


    /**
     * @param name The name to set.
     */
    public void setName(String name) {
        this.name = name;
    }


    /**
     * @return Returns the activeFrom.
     */
    public Date getActiveFrom() {
        return activeFrom;
    }


    /**
     * @param activeFrom The activeFrom to set.
     */
    public void setActiveFrom(Date activeFrom) {
        this.activeFrom = activeFrom;
    }


    /**
     * @return Returns the activeTill.
     */
    public Date getActiveTill() {
        return activeTill;
    }


    /**
     * @param activeTill The activeTill to set.
     */
    public void setActiveTill(Date activeTill) {
        this.activeTill = activeTill;
    }



    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }



    /**
     * @param description The description to set.
     */
    public void setDescription(String description) {
        this.description = description;
    }



    /**
     * @return Returns the tasks.
     */
    public List<TaskoTask> getTasks() {
        return tasks;
    }



    /**
     * @param tasks The tasks to set.
     */
    public void setTasks(List<TaskoTask> tasks) {
        this.tasks = tasks;
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
