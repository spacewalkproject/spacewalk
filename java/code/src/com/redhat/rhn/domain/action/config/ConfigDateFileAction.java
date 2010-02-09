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
package com.redhat.rhn.domain.action.config;

import com.redhat.rhn.domain.action.ActionChild;

import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;

import java.io.Serializable;

/**
 * ConfigDateFileAction - Class representation of the table rhnActionConfigDateFile.
 * 
 * @version $Rev$
 */
public class ConfigDateFileAction extends ActionChild implements Serializable {

    private String fileName;
    private String fileType;

    /** 
     * Getter for fileName 
     * @return String to get
    */
    public String getFileName() {
        return this.fileName;
    }

    /** 
     * Setter for fileName 
     * @param fileNameIn to set
    */
    public void setFileName(String fileNameIn) {
        this.fileName = fileNameIn;
    }

    /** 
     * Getter for fileType 
     * @return String to get
    */
    public String getFileType() {
        return this.fileType;
    }

    /** 
     * Setter for fileType 
     * @param fileTypeIn to set
    */
    public void setFileType(String fileTypeIn) {
        this.fileType = fileTypeIn;
    }

    /**
     * {@inheritDoc}
     */
    public boolean equals(final Object other) {
        if (other == null || !(other instanceof ConfigDateFileAction)) {
            return false;
        }
        ConfigDateFileAction castOther = (ConfigDateFileAction)other;
        return new EqualsBuilder().append(getParentAction(), castOther.getParentAction())
                                  .append(fileName, castOther.getFileName()).isEquals();
    }
    
    /**
     * {@inheritDoc}
     */
    public int hashCode() {
        return new HashCodeBuilder().append(getParentAction().getId()).append(fileName)
                .toHashCode();
    }

}
