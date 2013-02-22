/**
 * Copyright (c) 2012--2013 Red Hat, Inc.
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

package com.redhat.rhn.domain.server;

import com.redhat.rhn.domain.BaseDomainHelper;

import java.util.Date;

/**
 * Represents the number of total and unique crashes on a particular server.
 * @version $Rev$
 */
public class CrashCount extends BaseDomainHelper {

    private Long id;
    private Server server;
    private long uniqueCrashCount;
    private long totalCrashCount;
    private Date lastReport;

    /**
     * Represents application crash information.
     */
    public CrashCount() {
        super();
    }

    /**
     * Returns the database id of the crashes object.
     * @return Returns the id.
     */
    public Long getId() {
        return id;
    }

    /**
     * Sets the database id of the crashes object.
     * @param idIn The id to set.
     */
    public void setId(Long idIn) {
        id = idIn;
    }

    /**
     * The parent server.
     * @return Returns the server.
     */
    public Server getServer() {
        return server;
    }

    /**
     * Sets the parent server.
     * @param serverIn The server to set.
     */
    public void setServer(Server serverIn) {
        server = serverIn;
    }

    /**
     * Returns the number of unique application crashes.
     * @return the number of unique application crashes.
     */
    public long getUniqueCrashCount() {
        return uniqueCrashCount;
    }

    /**
     * Sets the number of unique application crashes.
     * @param count The number of unique crashes.
     */
    public void setUniqueCrashCount(long count) {
        uniqueCrashCount = count;
    }

    /**
     * Returns the total number of application crashes.
     * @return the total number of application crashes.
     */
    public long getTotalCrashCount() {
        return totalCrashCount;
    }

    /**
     * Sets the total number of application crashes.
     * @param count The total number of crashes.
     */
    public void setTotalCrashCount(long count) {
        totalCrashCount = count;
    }

    /**
     * Returns the date last of last crash report.
     * @return the date last of last crash report.
     */
    public Date getLastReport() {
        return lastReport;
    }

    /**
     * Sets the date of last crash report.
     * @param lastReportIn the date of last crash report.
     */
    public void setLastReport(Date lastReportIn) {
        lastReport = lastReportIn;
    }
}
