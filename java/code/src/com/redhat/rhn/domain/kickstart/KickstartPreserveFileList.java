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
package com.redhat.rhn.domain.kickstart;

import com.redhat.rhn.domain.common.FileList;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;
import java.util.Date;

/**
 * kickstartpreservefilelist - Class representation of the table 
 * rhnkickstartpreservefilelist.
 * @version $Rev: 1 $
 */
public class KickstartPreserveFileList implements Serializable {

    private KickstartData ksdata;
    private FileList fileList;
    private Date created;
    private Date modified;
    /** 
     * Getter for ksdata
     * @return KickstartData to get
    */
    public KickstartData getksdata() {
        return this.ksdata;
    }

    /** 
     * Setter for ksdata
     * @param ksdataIn to set
    */
    public void setKsdata(KickstartData ksdataIn) {
        this.ksdata = ksdataIn;
    }

    /** 
     * Getter for fileList 
     * @return Long to get
    */
    public FileList getFileList() {
        return this.fileList;
    }

    /** 
     * Setter for fileList 
     * @param fileListIn to set
    */
    public void setFileList(FileList fileListIn) {
        this.fileList = fileListIn;
    }

    /** 
     * Getter for created 
     * @return Date to get
    */
    public Date getCreated() {
        return this.created;
    }

    /** 
     * Setter for created 
     * @param createdIn to set
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /** 
     * Getter for modified 
     * @return Date to get
    */
    public Date getModified() {
        return this.modified;
    }

    /** 
     * Setter for modified 
     * @param modifiedIn to set
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (!(other instanceof KickstartPreserveFileList)) {
            return false;
        }
        KickstartPreserveFileList castOther = (KickstartPreserveFileList) other;
        return new EqualsBuilder().append(ksdata, castOther.ksdata)
                                  .append(fileList, castOther.fileList)
                                  .isEquals();
    }

    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(ksdata)
                                    .append(fileList)
                                    .toHashCode();
    }

}
