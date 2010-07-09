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

import com.redhat.rhn.common.localization.LocalizationService;

import java.util.Date;

/**
 * ServerActionDto - represents an action for a single server
 * @version $Rev$
 */
public class ServerActionDto extends BaseDto {

    private Long id;
    private Long serverId;
    private String serverName;
    private String status;
    private Long scheduledById;
    private String scheduledByName;
    private Date earliest;

    private Integer fileCount;


    /**
     * @return Returns the fileCount.
     */
    public Integer getFileCount() {
        return fileCount;
    }


    /**
     * @param fileCountIn The fileCount to set.
     */
    public void setFileCount(Integer fileCountIn) {
        fileCount = fileCountIn;
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
     * @return Returns the scheduledById.
     */
    public Long getScheduledById() {
        return scheduledById;
    }

    /**
     * @param scheduledByIdIn The scheduledById to set.
     */
    public void setScheduledById(Long scheduledByIdIn) {
        scheduledById = scheduledByIdIn;
    }

    /**
     * @return Returns the scheduledByName.
     */
    public String getScheduledByName() {
        return scheduledByName;
    }

    /**
     * @param scheduledByNameIn The scheduledByName to set.
     */
    public void setScheduledByName(String scheduledByNameIn) {
        scheduledByName = scheduledByNameIn;
    }

    /**
     * @return Returns the serverId.
     */
    public Long getServerId() {
        return serverId;
    }

    /**
     * @param serverIdIn The serverId to set.
     */
    public void setServerId(Long serverIdIn) {
        serverId = serverIdIn;
    }

    /**
     * @return Returns the serverName.
     */
    public String getServerName() {
        return serverName;
    }

    /**
     * @param serverNameIn The serverName to set.
     */
    public void setServerName(String serverNameIn) {
        serverName = serverNameIn;
    }

    /**
     * Returns a localized status.
     * @return Returns the localized status.
     */
    public String getStatus() {
        if (status == null) {
            return null;
        }
        return LocalizationService.getInstance().getMessage(status);
    }

    /**
     * @param statusIn The status to set.
     */
    public void setStatus(String statusIn) {
        status = statusIn;
    }



    /**
     * @return Returns the earliest.
     */
    public Date getEarliest() {
        return earliest;
    }



    /**
     * @param earliestIn The earliest to set.
     */
    public void setEarliest(Date earliestIn) {
        earliest = earliestIn;
    }

    /**
     * @return Returns a localized String displaying the date.
     */
    public String getEarliestDisplay() {
        return LocalizationService.getInstance().formatDate(earliest);
    }

}
