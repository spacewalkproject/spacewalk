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
package com.redhat.rhn.domain.action.script;

import com.redhat.rhn.common.hibernate.HibernateFactory;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.sql.Blob;
import java.util.Date;

/**
 * ScriptResult
 * @version $Rev$
 */
public class ScriptResult implements Serializable {

    private Long serverId;
    private Long actionScriptId;
    private Date startDate;
    private Date stopDate;
    private Long returnCode;
    private Blob outputBlob;
    
    private ScriptActionDetails parentScriptActionDetails;
    
    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }
    
    /**
     * @param s The serverId to set.
     */
    public void setServerId(Long s) {
        this.serverId = s;
    }
    
    /**
     * @return Returns the actionScriptId.
     */
    public Long getActionScriptId() {
        return actionScriptId;
    }
    
    /**
     * @param a The actionScriptId to set.
     */
    public void setActionScriptId(Long a) {
        this.actionScriptId = a;
    }
    
    /**
     * @return Returns the startDate.
     */
    public Date getStartDate() {
        return startDate;
    }
    
    /**
     * @param s The startDate to set.
     */
    public void setStartDate(Date s) {
        this.startDate = s;
    }
    
    /**
     * @return Returns the stopDate.
     */
    public Date getStopDate() {
        return stopDate;
    }
    
    /**
     * @param s The stopDate to set.
     */
    public void setStopDate(Date s) {
        this.stopDate = s;
    }
    
    /**
     * @return Returns the returnCode.
     */
    public Long getReturnCode() {
        return returnCode;
    }
    
    /**
     * @param r The returnCode to set.
     */
    public void setReturnCode(Long r) {
        this.returnCode = r;
    }

    /**
     * Get the parent of this object.
     * 
     * @return Returns the parentScriptActionDetails.
     */
    public ScriptActionDetails getParentScriptActionDetails() {
        return parentScriptActionDetails;
    }
    
    /**
     * Set the parent of this object.
     * 
     * @param parentScriptActionDetailsIn The parentScriptActionDetails to set.
     */
    public void setParentScriptActionDetails(
            ScriptActionDetails parentScriptActionDetailsIn) {
        this.parentScriptActionDetails = parentScriptActionDetailsIn;
    }
    
    /**
     * {@inheritDoc}
     */
    public boolean equals(Object obj) {
        if (obj == null || !(obj instanceof ScriptResult)) {
            return false;
        }
       
        ScriptResult r = (ScriptResult) obj;
        
        return new EqualsBuilder().append(this.getActionScriptId(), r.getActionScriptId())
                                  .append(this.getServerId(), r.getServerId())
                                  .append(this.getStartDate(), r.getStartDate())
                                  .append(this.getStopDate(), r.getStopDate())
                                  .append(this.getReturnCode(), r.getReturnCode())
                                  .isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getActionScriptId())
                                    .append(getServerId())
                                    .append(getStartDate())
                                    .append(getStopDate())
                                    .append(getReturnCode())
                                    .toHashCode();
    }
    
    /**
     * Get the output.
     * 
     * @return Returns the output.
     */
    public byte[] getOutput() {
        return HibernateFactory.blobToByteArray(outputBlob);
    }

    /**
     * Let Hibernate get the output blob. (used only by Hibernate) 
     * @return Returns the script.
     */
    private Blob getOutputBlob() {
        return outputBlob;
    }

    /**
     * Let Hibernate set the output blob contents. (used only by Hibernate) 
     * @param outputBlob The script to set.
     */
    private void setOutputBlob(Blob outputBlobIn) {
        this.outputBlob = outputBlobIn;
    }

    /**
     * Get the String version of the Script contents
     * @return String version of the Script contents
     */
    public String getOutputContents() {
        return HibernateFactory.getByteArrayContents(getOutput());
    }
    
}
