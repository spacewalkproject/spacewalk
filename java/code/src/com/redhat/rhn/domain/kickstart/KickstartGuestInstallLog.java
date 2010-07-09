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

import java.util.Date;

/**
 * KickstartGuestInstallLog - Class representation of the table
 * rhnVirtualInstanceInstallLog.
 * @version $Rev: 1 $
 */
public class KickstartGuestInstallLog {

    private Long id;
    private String logMessage;
    private Long sessionId;
    private Date created;
    private Date modified;

    /**
     * Returns the id.
     * @return The id.
     */
    public Long getId() {
        return this.id;
    }

    /**
     * Sets the id for this object.
     * @param idIn The id for this object.
     */
    public void setId(Long idIn) {
        this.id = idIn;
    }

    /**
     * Returns the log message.
     * @return The log message.
     */
    public String getLogMessage() {
        return this.logMessage;
    }

    /**
     * Sets the log message.
     * @param logMessageIn The log message to set.
     */
    public void setLogMessage(String logMessageIn) {
        this.logMessage = logMessageIn;
    }

    /**
     * Returns the kickstart session id.
     * @return The kickstart session id.
     */
    public Long getSessionId() {
        return this.sessionId;
    }

    /**
     * Sets the kickstart session id.
     * @param sessionIdIn The kickstart session id.
     */
    public void setSessionId(Long sessionIdIn) {
        this.sessionId = sessionIdIn;
    }

    /**
     * Returns the creation date.
     * @return The creation date.
     */
    public Date getCreated() {
        return this.created;
    }

    /**
     * Sets the creation date.
     * @param createdIn The creation date to set.
    */
    public void setCreated(Date createdIn) {
        this.created = createdIn;
    }

    /**
     * Returns the modified date.
     * @return The modified date.
    */
    public Date getModified() {
        return this.modified;
    }

    /**
     * Sets the modified date.
     * @param modifiedIn The modified date.
    */
    public void setModified(Date modifiedIn) {
        this.modified = modifiedIn;
    }

}
