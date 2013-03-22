/**
 * Copyright (c) 2013 Red Hat, Inc.
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
 * CrashSystemsDto
 * @version $Rev$
 */
public class CrashSystemsDto extends BaseDto {

    private Long id;
    private Long serverId;
    private String serverName;
    private Long crashId;
    private Long crashCount;
    private String crashComponent;
    private Date lastReport;

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
     * @return Returns the crashId.
     */
    public Long getCrashId() {
        return crashId;
    }

    /**
     * @param crashIdIn The crashId to set.
     */
    public void setCrashId(Long crashIdIn) {
        crashId = crashIdIn;
    }

    /**
     * @return Returns the crashCount.
     */
    public Long getCrashCount() {
        return crashCount;
    }

    /**
     * @param crashCountIn The crashCount to set.
     */
    public void setCrashCount(Long crashCountIn) {
        crashCount = crashCountIn;
    }

    /**
     * @return Returns the crashComponent.
     */
    public String getCrashComponent() {
        return crashComponent;
    }

    /**
     * @param crashComponentIn The crashComponent to set.
     */
    public void setCrashComponent(String crashComponentIn) {
        crashComponent = crashComponentIn;
    }

    /**
     * @return Returns the lastReport.
     */
    public Date getLastReport() {
        return lastReport;
    }

    /**
     * @param lastReportIn The lastReport to set.
     */
    public void setLastReport(Date lastReportIn) {
        lastReport = lastReportIn;
    }
}
