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
import org.apache.tools.ant.taskdefs.Mkdir;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;


/**
 * TaskoRun
 * @version $Rev$
 */
public class TaskoRun implements Job {

    private static Logger log = Logger.getLogger(TaskoTask.class);

    public static final String STATUS_READY_TO_RUN = "READY";
    public static final String STATUS_RUNNING = "RUNNING";
    public static final String STATUS_FINISHED = "FINISHED";
    public static final String STATUS_FAILED = "FAILED";
    private String stdLogPrefix = "/var/spacewalk/systemlogs/tasko/";

    private Long id;
    private Integer orgId;
    private TaskoTemplate template;
    private Date startTime;
    private Date endTime;
    private String stdOutputPath = null;
    private String stdErrorPath = null;
    private String status;
    private Date created;
    private Date modified;

    public TaskoRun(Integer orgId, TaskoTemplate template) {
        setOrgId(orgId);
        setTemplate(template);
        File logDir = new File(stdLogPrefix);
        if (!logDir.isDirectory()) {
            if (!logDir.exists()) {
                logDir.mkdirs();
            }
        }
        setStatus(STATUS_READY_TO_RUN);
        TaskoFactory.save(this);
    }

    public void start() {
        if (new File(stdLogPrefix).isDirectory()) {
            String logName = computeStdLogFileName(orgId, template, this);
            setStdOutputPath(stdLogPrefix + logName + "_out");
            setStdErrorPath(stdLogPrefix + logName + "_err");
        }
        else {
            log.warn("Logging disabled. No directory " + stdLogPrefix);
        }
        setStartTime(new Date());
        setStatus(STATUS_RUNNING);
        TaskoFactory.save(this);
    }

    public void finished() {
        setEndTime(new Date());
        setStatus(STATUS_FINISHED);
        TaskoFactory.save(this);
    }

    public void execute(JobExecutionContext context)
        throws JobExecutionException {
            start();
            Class jobClass = template.getTask().getClass();
            try {
                Job job = (Job) jobClass.newInstance();
            }
            catch (InstantiationException e) {
                setStatus(STATUS_FAILED);
                saveToStdError(e.toString());
            }
            catch (IllegalAccessException e) {
                setStatus(STATUS_FAILED);
                saveToStdError(e.toString());
            }

            finished();
            TaskoFactory.commitTransaction();
    }

    private void saveToStdError(String message) {
        if (stdErrorPath != null) {
            try {
                BufferedWriter out = new BufferedWriter(new FileWriter(stdErrorPath));
                out.write(message);
                out.close();
            } catch (IOException io) {
                log.error("Cannot save traceback to " + stdErrorPath);
            }
        }
    }


    private static String computeStdLogFileName(Integer orgId, TaskoTemplate templ, TaskoRun run) {
        String logName = "";
        if (orgId == null) {
            logName += "admin";
        }
        else {
            logName += orgId;
        }
        logName += "_" + templ.getBunch().getName() + "_" + templ.getTask().getName()
            + "_" + run.getId();
        return logName;
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
     * @return Returns the templateId.
     */
    public TaskoTemplate getTemplate() {
        return template;
    }


    /**
     * @param templateId The templateId to set.
     */
    public void setTemplate(TaskoTemplate templateId) {
        this.template = templateId;
    }


    /**
     * @return Returns the startTime.
     */
    public Date getStartTime() {
        return startTime;
    }


    /**
     * @param startTime The startTime to set.
     */
    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }


    /**
     * @return Returns the endTime.
     */
    public Date getEndTime() {
        return endTime;
    }


    /**
     * @param endTime The endTime to set.
     */
    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }


    /**
     * @return Returns the stdOutputPath.
     */
    public String getStdOutputPath() {
        return stdOutputPath;
    }


    /**
     * @param stdOutputPath The stdOutputPath to set.
     */
    public void setStdOutputPath(String stdOutputPath) {
        this.stdOutputPath = stdOutputPath;
    }


    /**
     * @return Returns the stdErrorPath.
     */
    public String getStdErrorPath() {
        return stdErrorPath;
    }


    /**
     * @param stdErrorPath The stdErrorPath to set.
     */
    public void setStdErrorPath(String stdErrorPath) {
        this.stdErrorPath = stdErrorPath;
    }


    /**
     * @return Returns the status.
     */
    public String getStatus() {
        return status;
    }


    /**
     * @param status The status to set.
     */
    public void setStatus(String status) {
        this.status = status;
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


    /**
     * @return Returns the orgId.
     */
    public Integer getOrgId() {
        return orgId;
    }


    /**
     * @param orgId The orgId to set.
     */
    public void setOrgId(Integer orgId) {
        this.orgId = orgId;
    }

}
