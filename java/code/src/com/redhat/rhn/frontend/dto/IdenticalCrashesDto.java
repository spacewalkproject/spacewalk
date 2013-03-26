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
 * IdenticalCrashesDto
 * @version $Rev$
 */
public class IdenticalCrashesDto extends BaseDto {

    private Long id;
    private String uuid;
    private String component;
    private long totalCrashCount;
    private long systemCount;
    private Date lastCrashReport;

    /**
     * Returns id
     * @return Returns id
     */
    public Long getId() {
        return id;
    }

    /**
     * Set the id
     * @param idIn The id to set
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * Returns the database uuid.
     * @return Returns the uuid.
     */
    public String getUuid() {
        return uuid;
    }

    /**
     * Sets the uuid.
     * @param uuidIn The id to set.
     */
    public void setUuid(String uuidIn) {
        uuid = uuidIn;
    }

    /**
     * Returns the component.
     * @return Returns the component.
     */
    public String getComponent() {
        return component;
    }

    /**
     * Sets the component.
     * @param componentIn The id to set.
     */
    public void setComponent(String componentIn) {
        component = componentIn;
    }

    /**
     * Returns total number of crashes.
     * @return total number of crashes.
     */
    public long getTotalCrashCount() {
        return totalCrashCount;
    }

    /**
     * Sets total number of crashes.
     * @param countIn Total number crashes.
     */
    public void setTotalCrashCount(long countIn) {
        totalCrashCount = countIn;
    }

    /**
     * Returns number of systems.
     * @return number of systems.
     */
    public long getSystemCount() {
        return systemCount;
    }

    /**
     * Sets the number of systems
     * @param countIn The number of systems
     */
    public void setSystemCount(long countIn) {
        systemCount = countIn;
    }

    /**
     * Returns the date last of last crash report.
     * @return the date last of last crash report.
     */
    public Date getLastCrashReport() {
        return lastCrashReport;
    }

    /**
     * Sets the date of last crash report.
     * @param lastCrashReportIn the date of last crash report.
     */
    public void setLastCrashReport(Date lastCrashReportIn) {
        lastCrashReport = lastCrashReportIn;
    }
}
