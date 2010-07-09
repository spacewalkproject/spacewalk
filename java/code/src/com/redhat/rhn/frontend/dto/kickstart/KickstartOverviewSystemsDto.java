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
package com.redhat.rhn.frontend.dto.kickstart;

import com.redhat.rhn.domain.server.Server;
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.frontend.dto.BaseDto;

import java.sql.Timestamp;

/**
 * KickstartOverviewSystemsDto
 * @version $Rev$
 */
public class KickstartOverviewSystemsDto extends BaseDto {
    private String label;
    private String description;
    private Timestamp lastModified;
    private Long oldServerId;
    private Long newServerId;
    private String elapsedTimeAfterModify;
    private String clientIp;

    /**
     * @return the client IP of the kickstarting system.
     */
    public String getClientIp() {
        return clientIp;
    }

    /**
     * @param clientIpIn The client IP to set.
     */
    public void setClientIp(String clientIpIn) {
        this.clientIp = clientIpIn;
    }

    /**
     * @return Returns the system's status description.
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param descriptionIn The descriptionIn to set.
     */
    public void setDescription(String descriptionIn) {
        this.description = descriptionIn;
    }

    /**
     * @return Returns the date this system was
     * last modified.
     */
    public Timestamp getLastModified() {
        return lastModified;
    }

    /**
     * @param lastModifiedIn The lastModifiedIn to set.
     */
    public void setLastModified(Timestamp lastModifiedIn) {
        this.lastModified = lastModifiedIn;
    }

    /**
     * @param time The time to set. This is how many minutes,
     * hours, days and weeks ago since lastModified
     */
    public void setElapsedTimeAfterModify(String time) {
        this.elapsedTimeAfterModify = time;
    }

    /**
     * @return Returns the floor of elaspsed time since
     * lastModified
     */
    public String getElapsedTimeAfterModify() {
        return elapsedTimeAfterModify;
    }

    /**
     * @return Returns the label
     */
    public String getLabel() {
        return label;
    }

    /**
     * @param labelIn to set
     */
    public void setLabel(String labelIn) {
        this.label = labelIn;
    }

    /**
     * @param idIn The idIn to set
     */
    public void setOldServerId(Long idIn) {
        this.oldServerId = idIn;
    }

    /**
     * @return Returns old server id
     */
    public Long getOldServerId() {
        return oldServerId;
    }

    /**
     * @return Returns new server id
     * if it exist otherwise old server id.
     */
    public Long getServerId() {
        if (!getIsBareMetal()) {
            return getNewServerId() == null ? getOldServerId() : getNewServerId();
        }
        else {
            return null;    //this should never happen
        }
    }

    /**
     *
     * @return Server Name
     */
    public String getServerName() {
        Server s = ServerFactory.lookupById(new Long(getServerId().longValue()));
        return s.getName();
    }

    /**
     * @return Returns new server id
     */
    public Long getNewServerId() {
        return newServerId;
    }

    /**
     * @param idIn The idIn to set
     */
    public void setNewServerId(Long idIn) {
        this.newServerId = idIn;
    }

    /**
     * @return whether or not the current system is a bare metal
     */
    public boolean getIsBareMetal() {
        return (getOldServerId() == null && getNewServerId() == null);
    }

    /**
     * unimplemented method
     * @return Returns the id.
     */
    public Long getId() {
        // no-op
        return null;
    }
}
