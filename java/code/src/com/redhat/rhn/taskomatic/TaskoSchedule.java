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

import org.hibernate.Hibernate;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.sql.Blob;
import java.sql.SQLException;
import java.util.Date;
import java.util.Map;


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

    public TaskoSchedule() {
    }

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

    private byte[] toByteArray(Blob fromImageBlob) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
          return toByteArrayImpl(fromImageBlob, baos);
        }
        catch (Exception e) {
            // return null
        }
        return null;
      }

      private byte[] toByteArrayImpl(Blob fromImageBlob,
          ByteArrayOutputStream baos) throws SQLException, IOException {
        byte[] buf = new byte[4000];
        int dataSize;
        InputStream is = fromImageBlob.getBinaryStream();

        try {
          while ((dataSize = is.read(buf)) != -1) {
            baos.write(buf, 0, dataSize);
          }
        }
        finally {
          if (is != null) {
            is.close();
          }
        }
        return baos.toByteArray();
      }

    public void setDataMap(Map dataMap) {
        data = serializeMap(dataMap);
    }

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
        // data = dataBlobIn.getBytes(0, (int) dataBlobIn.length() - 1);
        data = toByteArray(dataBlobIn);
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
