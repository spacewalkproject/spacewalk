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
package com.redhat.rhn.frontend.dto;

import com.redhat.rhn.common.localization.LocalizationService;

import org.apache.commons.lang.builder.ToStringBuilder;

import java.util.Date;


/**
 * OperationsDto
 * @version $Rev$
 */
public class OperationDetailsDto {
    private Long id;
    private String description;
    private String status;
    private Date started;
    private Date modified;
    private long serverCount;

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
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn The description to set.
     */
    public void setDescription(String descriptionIn) {
        description = descriptionIn;
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
        status = statusIn;
    }

    /**
     * @return Returns the started.
     */
    public Date getStarted() {
        return started;
    }

    /**
     *
     * @return the i18n formatted string for started date
     */
    public String getStartedDateString() {
        return LocalizationService.getInstance().formatDate(getStarted());
    }

    /**
     * @param startedIn The started to set.
     */
    public void setStarted(Date startedIn) {
        started = startedIn;
    }

    /**
     * @return Returns the modified.
     */
    public Date getModified() {
        return modified;
    }

    /**
     *
     * @return the i18n formatted string for modified date
     */
    public String getModifiedDateString() {
        return LocalizationService.getInstance().formatDate(getModified());
    }

    /**
     * @param modifiedIn The modified to set.
     */
    public void setModified(Date modifiedIn) {
        modified = modifiedIn;
    }

    /**
     * @return Returns the serverCount.
     */
    public long getServerCount() {
        return serverCount;
    }

    /**
     * @param serverCountIn The serverCount to set.
     */
    public void setServerCount(long serverCountIn) {
        serverCount = serverCountIn;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public String toString() {
        return ToStringBuilder.reflectionToString(this);
    }
}
