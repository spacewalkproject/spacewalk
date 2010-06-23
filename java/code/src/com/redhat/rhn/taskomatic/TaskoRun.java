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

import org.apache.log4j.Logger;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
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
    private static final String STD_LOG_PREFIX = "/var/spacewalk/systemlogs/tasko/";

    private Long id;
    private Integer orgId;
    private TaskoTemplate template;
    private Long scheduleId;
    private Date startTime;
    private Date endTime;
    private String stdOutputPath = null;
    private String stdErrorPath = null;
    private String status;
    private Date created;
    private Date modified;

    public TaskoRun() {
    }

    public TaskoRun(Integer orgIdIn, TaskoTemplate templateIn, Long scheduleIdIn) {
        setOrgId(orgIdIn);
        setTemplate(templateIn);
        setScheduleId(scheduleIdIn);
        File logDir = new File(getStdLogDirName(orgId));
        if (!logDir.isDirectory()) {
            if (!logDir.exists()) {
                logDir.mkdirs();
            }
        }
        saveStatus(STATUS_READY_TO_RUN);
    }

    public void start() {
        setStartTime(new Date());
        saveStatus(STATUS_RUNNING);
    }

    public void finished(JobExecutionContext context) {
        setEndTime(new Date());
        String out = (String) context.getJobDetail().getJobDataMap().get("stdOutput");
        if (new File(getStdLogDirName(orgId)).isDirectory()) {
            if ((out != null) && (!out.isEmpty())) {
                setStdOutputPath(getStdOutputLog(orgId, template, this));
                saveLogToFile(getStdOutputPath(), out);
            }
            else {
                setStdOutputPath("");
            }
            String err = (String) context.getJobDetail().getJobDataMap().get("stdError");
            if ((err != null) && (!err.isEmpty())) {
                setStdErrorPath(getStdErrorLog(orgId, template, this));
                saveLogToFile(getStdErrorPath(), err);
            }
            else {
                setStdErrorPath("");
            }
        }
        else {
            log.warn("Logging disabled. No directory " + getStdLogDirName(orgId));
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
            }
            catch (IOException io) {
                log.error("Cannot save traceback to " + stdErrorPath);
            }
        }
    }

    private void saveStatus(String statusIn) {
        setStatus(statusIn);
        TaskoFactory.save(this);
    }

    public String getTailOfStdOutput(Long nBytes) {
        return getTailOfFile(getStdOutputPath(), nBytes);
    }

    public String getTailOfStdError(Long nBytes) {
        return getTailOfFile(getStdErrorPath(), nBytes);
    }

    private String getTailOfFile(String fileName, Long nBytes) {
        RandomAccessFile file;
        try {
            file = new RandomAccessFile(fileName, "r");
            file.seek(file.length() - nBytes);
            String tail = file.readLine();
            file.close();
            return tail;
        }
        catch (FileNotFoundException e) {
            return "";
        }
        catch (IOException e) {
            return "";
        }
    }

    public static String getStdOutputLog(Integer orgId, TaskoTemplate templ, TaskoRun run) {
        return getStdLogDirName(orgId) + getStdLogFileName(templ, run) + "_out";
    }

    public static String getStdErrorLog(Integer orgId, TaskoTemplate templ, TaskoRun run) {
        return getStdLogDirName(orgId) + getStdLogFileName(templ, run) + "_err";
    }

    private static String getStdLogDirName(Integer orgId) {
        String dirName = STD_LOG_PREFIX;
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
        return templ.getBunch().getName() + "_" + templ.getTask().getName() +
            "_" + run.getId();
    }

    private void saveLogToFile(String fileName, String logContent) {
        try {
            BufferedWriter out = new BufferedWriter(new FileWriter(fileName));
            out.write(logContent);
            out.close();
        }
        catch (IOException e) {
            log.error("Unable to store log file to " + fileName);
        }
    }

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
     * @param startTimeIn The startTime to set.
     */
    public void setStartTime(Date startTimeIn) {
        this.startTime = startTimeIn;
    }


    /**
     * @return Returns the endTime.
     */
    public Date getEndTime() {
        return endTime;
    }


    /**
     * @param endTimeIn The endTime to set.
     */
    public void setEndTime(Date endTimeIn) {
        this.endTime = endTimeIn;
    }


    /**
     * @return Returns the stdOutputPath.
     */
    public String getStdOutputPath() {
        return stdOutputPath;
    }


    /**
     * @param stdOutputPathIn The stdOutputPath to set.
     */
    public void setStdOutputPath(String stdOutputPathIn) {
        this.stdOutputPath = stdOutputPathIn;
    }


    /**
     * @return Returns the stdErrorPath.
     */
    public String getStdErrorPath() {
        return stdErrorPath;
    }


    /**
     * @param stdErrorPathIn The stdErrorPath to set.
     */
    public void setStdErrorPath(String stdErrorPathIn) {
        this.stdErrorPath = stdErrorPathIn;
    }


    /**
     * @return Returns the status.
     */
    public String getStatus() {
        return status;
    }


    /**
     * @param statusIn The status to set.
     */
    public void setStatus(String statusIn) {
        this.status = statusIn;
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
     * @return Returns the orgId.
     */
    public Integer getOrgId() {
        return orgId;
    }


    /**
     * @param orgIdIn The orgId to set.
     */
    public void setOrgId(Integer orgIdIn) {
        this.orgId = orgIdIn;
    }

    /**
     * @return Returns the jobLabel.
     */
    public Long getScheduleId() {
        return scheduleId;
    }

    /**
     * @param jobLabelIn The jobLabel to set.
     */
    public void setScheduleId(Long scheduleIdIn) {
        this.scheduleId = scheduleIdIn;
    }
}
