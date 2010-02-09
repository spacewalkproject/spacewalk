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

import com.redhat.rhn.domain.user.User;

import java.util.Date;

/**
 * CustomDataKey
 * @version $Rev$
 */
public class CustomDataKeyOverview extends BaseDto {

    private Long id;
    private String label;
    private String description;
    private User creator;
    private Long serverCount;
    private Date lastModified;




    /**
     * @return Returns the lastModified.
     */
    public Date getLastModified() {
        return lastModified;
    }


    /**
     * @param lastModifiedIn The lastModified to set.
     */
    public void setLastModified(Date lastModifiedIn) {
        this.lastModified = lastModifiedIn;
    }

    /**
     * @return Returns the systemCount.
     */
    public Long getServerCount() {
        return serverCount;
    }

    /**
     * @param systemCountIn The systemCount to set.
     */
    public void setServerCount(Long systemCountIn) {
        this.serverCount = systemCountIn;
    }
    /**
     * @return Returns the creator.
     */
    public User getCreator() {
        return creator;
    }
    /**
     * @param creatorIn The creator to set.
     */
    public void setCreator(User creatorIn) {
        this.creator = creatorIn;
    }
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }
    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
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
     * @return Returns the label.
     */
    public String getLabel() {
        return label;
    }
    /**
     * @param labelIn The label to set.
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }
    /**
     * @return Returns the lastModifier.
     */


}
