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

import java.util.Date;

/**
 * FilePreservationDto
 * @version $Rev$
 */
public class FilePreservationDto extends BaseDto {
    private Long id;
    private Long org_id;
    private String label;
    private Date created;
    private Date modified;

    /**
     * @return Returns the FileList id.
     */
    public Long getId() {
        return id;
    }

    /**
     * @return Returns the date FileList was created.
     */
    public Date getCreated() {
        return created;
    }

    /**
     * @param cdateIn The cdateIn to set.
     */
    public void setCreated(Date cdateIn) {
        this.created = cdateIn;
    }

    /**
     * @return Returns the FileList label.
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn The labelIn to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @return Returns the date the FileList was modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     * @param mdateIn The mdateIn to set.
     */
    public void setModified(Date mdateIn) {
        this.modified = mdateIn;
    }

    /**
     * @return Returns The FileList org_id.
     */
    public Long getOrgId() {
        return org_id;
    }

    /**
     * @param orgIn The orgIn to set.
     */
    public void setOrgId(Long orgIn) {
        this.org_id = orgIn;
    }

    /**
     * @param idIn The idIn to set.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

}
