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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.util.StringUtil;

import java.util.Date;

/**
 * ConfigRevisionDto - Basic data about a config revision from rhnConfigRevision
 * and rhnConfigContent
 * @version $Rev$
 */
public class ConfigRevisionDto extends BaseDto {
    private Long id;
    private Integer revisionNumber;
    private Date created;
    private Date modified;
    private Long fileSize;

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
     * @return Returns the revisionNumber.
     */
    public Integer getRevisionNumber() {
        return revisionNumber;
    }

    /**
     * @param revisionNumberIn The revisionNumber to set.
     */
    public void setRevisionNumber(Integer revisionNumberIn) {
        revisionNumber = revisionNumberIn;
    }

    /**
     * @return Returns the size.
     */
    public Long getFileSize() {
        return fileSize;
    }

    /**
     * @param fileSizeIn The fileSize to set.
     */
    public void setFileSize(Long fileSizeIn) {
        fileSize = fileSizeIn;
    }

    /**
     * @return A localized display of the file size of this revision
     */
    public String getSizeDisplay() {
        return StringUtil.displayFileSize(fileSize.longValue());
    }

    /**
     * @return A localized display of the time this revision was created relative
     *         to now.  Using friendly time display.
     */
    public String getCreatedDisplay() {
        return StringUtil.categorizeTime(created.getTime(), StringUtil.WEEKS_UNITS);
    }

}
