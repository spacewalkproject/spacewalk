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

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobDataMap;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.util.Date;


/**
 * TaskoTask
 * @version $Rev$
 */
public class TaskoTask implements Job {

    private static Logger log = Logger.getLogger(TaskoTask.class);
    private Long id;
    private String name;
    private String taskClass;
    private Date created;
    private Date modified;

    public void execute(JobExecutionContext context)
        throws JobExecutionException {

        // if task type already running, reschedule
        // otherwise
        Date start = new Date();
        JobDataMap dataMap = context.getJobDetail().getJobDataMap();
        String jobSays = dataMap.getString("param");
        Date end = new Date();
        log.info("Running TaskoTask from " + start + " till " + end + " params: " + jobSays);
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
     * @return Returns the taskClass.
     */
    public String getTaskClass() {
        return taskClass;
    }


    /**
     * @param taskClass The taskClass to set.
     */
    public void setTaskClass(String taskClass) {
        this.taskClass = taskClass;
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
