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

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.hibernate.Hibernate;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.sql.Blob;
import java.util.Date;
import java.util.Map;

/**
 * a schedule represents a concrete bunch, that is scheduled with specified parameters,
 * in specified time period with some periodicity
 * TaskoSchedule
 * @version $Rev$
 */
public class TaskoSchedule {

    private Long id;
    private String jobLabel;
    private TaskoBunch bunch;
    private Integer orgId;
    private Date activeFrom;
    private Date activeTill;
    private String cronExpr;
    private byte[] data;
    private Date created;
    private Date modified;


    /**
     * default constructor required by hibernate
     */
    public TaskoSchedule() {
    }

    /**
     * constructor
     * schedule is always associated with organization, bunch, job name, job parameter,
     * time period when active and cron expression, how often is shall get scheduled
     * @param orgIdIn organization id
     * @param bunchIn bunch id
     * @param jobLabelIn job name
     * @param dataIn job parameter
     * @param activeFromIn scheduled from
     * @param activeTillIn scheduled till
     * @param cronExprIn cron expression
     */
    public TaskoSchedule(Integer orgIdIn, TaskoBunch bunchIn, String jobLabelIn,
            Map dataIn, Date activeFromIn, Date activeTillIn, String cronExprIn) {
        setOrgId(orgIdIn);
        setBunch(bunchIn);
        setJobLabel(jobLabelIn);
        data = serializeMap(dataIn);
        setCronExpr(cronExprIn);
        if (activeFromIn == null) {
            setActiveFrom(new Date());
        }
        else {
            setActiveFrom(activeFromIn);
        }
        if (cronExprIn.isEmpty()) {
            // set activeFrom for single runs
            setActiveTill(getActiveFrom());
        }
        if (activeTillIn != null) {
            setActiveTill(activeTillIn);
        }
    }

    /**
     * unschedule this particular schedule
     */
    public void unschedule() {
        setActiveTill(new Date());
    }

    private byte[] serializeMap(Map dataMap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        if (null != dataMap) {
            ObjectOutputStream out;
            try {
                out = new ObjectOutputStream(baos);
                out.writeObject(dataMap);
                out.flush();
            }
            catch (IOException e) {
                return null;
            }
        }
        return baos.toByteArray();
    }

    private Map getDataMapFromBlob(Blob blob) {
        Object obj = null;

        try {
            if (blob != null) {
                InputStream binaryInput = blob.getBinaryStream();

                if (null != binaryInput) {
                    ObjectInputStream in = new ObjectInputStream(binaryInput);
                    obj = in.readObject();
                    in.close();
                }
            }
        }
        catch (Exception e) {
            // return null;
        }
        return (Map) obj;
    }

    /**
     * set job parameters
     * @param dataMap job paramters
     */
    public void setDataMap(Map dataMap) {
        data = serializeMap(dataMap);
    }

    /**
     * get job parameters
     * @return job paramters
     */
    public Map getDataMap() {
        return getDataMapFromBlob(getData());
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
        id = idIn;
    }

    /**
     * @return Returns the jobLabel.
     */
    public String getJobLabel() {
        return jobLabel;
    }

    /**
     * @param jobLabelIn The jobLabel to set.
     */
    public void setJobLabel(String jobLabelIn) {
        jobLabel = jobLabelIn;
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
        bunch = bunchIn;
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
        orgId = orgIdIn;
    }

    /**
     * @return Returns the activeFrom.
     */
    public Date getActiveFrom() {
        return activeFrom;
    }

    /**
     * @param activeFromIn The activeFrom to set.
     */
    public void setActiveFrom(Date activeFromIn) {
        activeFrom = activeFromIn;
    }

    /**
     * @return Returns the activeTill.
     */
    public Date getActiveTill() {
        return activeTill;
    }

    /**
     * @param activeTillIn The activeTill to set.
     */
    public void setActiveTill(Date activeTillIn) {
        activeTill = activeTillIn;
    }

    /**
     * @return Returns the data.
     */
    public Blob getData() {
        return Hibernate.createBlob(data);
    }

    /**
     * @param dataBlobIn The params to set.
     */
    public void setData(Blob dataBlobIn) {
        data = HibernateFactory.blobToByteArray(dataBlobIn);
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
        created = createdIn;
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
        modified = modifiedIn;
    }

    /**
     * @return Returns the cronExpr.
     */
    public String getCronExpr() {
        return cronExpr;
    }

    /**
     * @param cronExprIn The cronExpr to set.
     */
    public void setCronExpr(String cronExprIn) {
        cronExpr = cronExprIn;
    }
}
