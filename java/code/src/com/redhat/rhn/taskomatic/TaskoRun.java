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
    private static final String stdLogPrefix = "/var/spacewalk/systemlogs/tasko/";

    private Long id;
    private Integer orgId;
    private TaskoTemplate template;
    private String jobLabel;
    private Date startTime;
    private Date endTime;
    private String stdOutputPath = null;
    private String stdErrorPath = null;
    private String status;
    private Date created;
    private Date modified;

    public TaskoRun() {
    }

    public TaskoRun(Integer orgIdIn, TaskoTemplate templateIn, String jobLabelIn) {
        setOrgId(orgIdIn);
        setTemplate(templateIn);
        setJobLabel(jobLabelIn);
        File logDir = new File(getStdLogDirName(orgId));
        if (!logDir.isDirectory()) {
            if (!logDir.exists()) {
                logDir.mkdirs();
            }
        }
        saveStatus(STATUS_READY_TO_RUN);
    }

    public void start() {
        if (new File(getStdLogDirName(orgId)).isDirectory()) {
            setStdOutputPath(getStdOutputLog(orgId, template, this));
            setStdErrorPath(getStdErrorLog(orgId, template, this));
        }
        else {
            log.warn("Logging disabled. No directory " + stdLogPrefix);
        }
        setStartTime(new Date());
        saveStatus(STATUS_RUNNING);
    }

    public void finished(JobExecutionContext context) {
        setEndTime(new Date());
        String out = (String) context.getJobDetail().getJobDataMap().get("stdOutput");
        if (out != null) {
            saveLogToFile(getStdOutputPath(), out);
        }
        String err = (String) context.getJobDetail().getJobDataMap().get("stdError");
        if (err != null) {
            saveLogToFile(getStdErrorPath(), err);
        }
        saveStatus(STATUS_FINISHED);
    }

    public void execute(JobExecutionContext context)
        throws JobExecutionException {
            start();
            Class jobClass = null;
            Job job = null;
            try {
                jobClass = Class.forName(template.getTask().getTaskClass());
                job = (Job) jobClass.newInstance();
            }
            catch (ClassNotFoundException cnfe) {
                log.warn("Internal task error.");
                saveToStdError(cnfe.toString());
                saveStatus(STATUS_FAILED);
                return;
            }
            catch (InstantiationException ie) {
                log.warn("Internal task error.");
                saveToStdError(ie.toString());
                saveStatus(STATUS_FAILED);
                return;
            }
            catch (IllegalAccessException iae) {
                log.warn("Internal task error.");
                saveToStdError(iae.toString());
                saveStatus(STATUS_FAILED);
                return;
            }

            job.execute(context);
            finished(context);
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

    private void saveStatus(String statusIn) {
        setStatus(statusIn);
        TaskoFactory.save(this);
    }

    public static String getStdOutputLog(Integer orgId, TaskoTemplate templ, TaskoRun run) {
        return getStdLogDirName(orgId) + getStdLogFileName(templ, run) + "_out";
    }

    public static String getStdErrorLog(Integer orgId, TaskoTemplate templ, TaskoRun run) {
        return getStdLogDirName(orgId) + getStdLogFileName(templ, run) + "_err";
    }

    private static String getStdLogDirName(Integer orgId) {
        String dirName = stdLogPrefix;
        if (orgId == null) {
            dirName += "sat";
        }
        else {
            dirName += "org" + orgId;
        }
        dirName += "/";
        return dirName;
    }

    private static String getStdLogFileName(TaskoTemplate templ, TaskoRun run) {
        return templ.getBunch().getName() + "_" + templ.getTask().getName()
            + "_" + run.getId();
    }

    private void saveLogToFile(String fileName, String log) {
        try {
            BufferedWriter out = new BufferedWriter(new FileWriter(fileName));
            out.write(log);
            out.close();
        } catch (IOException e) {
        }
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

    /**
     * @return Returns the jobLabel.
     */
    public String getJobLabel() {
        return jobLabel;
    }

    /**
     * @param jobLabel The jobLabel to set.
     */
    public void setJobLabel(String jobLabel) {
        this.jobLabel = jobLabel;
    }
}
