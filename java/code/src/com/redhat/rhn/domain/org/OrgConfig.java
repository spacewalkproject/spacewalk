/**
 * Copyright (c) 2013--2014 Red Hat, Inc.
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

package com.redhat.rhn.domain.org;

import com.redhat.rhn.domain.BaseDomainHelper;
import org.apache.log4j.Logger;

/**
 * Class OrgConfig that reflects the DB representation of rhnOrgConfiguration DB table:
 * rhnOrgConfiguration
 */
public class OrgConfig extends BaseDomainHelper {

    protected static Logger log = Logger.getLogger(OrgConfig.class);

    private Long orgId;
    private boolean stagingContentEnabled;
    private boolean crashReportingEnabled;
    private boolean crashfileUploadEnabled;
    private Long crashFileSizelimit;
    private boolean scapfileUploadEnabled;
    private Long scapFileSizelimit;
    private Long scapRetentionPeriodDays;

    /**
     * Gets the current value of org_id
     * @return Returns the value of org_id
     */
    public Long getOrgId() {
        return orgId;
    }

    /**
     * Sets the value of org_id to new value
     * @param orgIdIn New value for orgId
     */
    protected void setOrgId(Long orgIdIn) {
        orgId = orgIdIn;
    }

    /**
     * @return Returns the stageContentEnabled.
     */
    public boolean isStagingContentEnabled() {
        return stagingContentEnabled;
    }

    /**
     * @param stageContentEnabledIn The stageContentEnabled to set.
     */
    public void setStagingContentEnabled(boolean stageContentEnabledIn) {
        stagingContentEnabled = stageContentEnabledIn;
    }

    /**
     * @return Returns the crashReportingEnabled flag.
     */
    public boolean isCrashReportingEnabled() {
        return crashReportingEnabled;
    }

    /**
     * @param crashReportingEnabledIn The crashReportingEnabled to set.
     */
    public void setCrashReportingEnabled(boolean crashReportingEnabledIn) {
        crashReportingEnabled = crashReportingEnabledIn;
    }

    /**
     * @return Returns the crashfileUploadEnabled flag.
     */
    public boolean isCrashfileUploadEnabled() {
        return crashfileUploadEnabled;
    }

    /**
     * @param crashfileUploadEnabledIn The crashfileUploadEnabled to set.
     */
    public void setCrashfileUploadEnabled(boolean crashfileUploadEnabledIn) {
        crashfileUploadEnabled = crashfileUploadEnabledIn;
    }

    /**
     * Get the org-wide crash file size limit.
     * @return Returns the org-wide crash file size limit.
     */
    public Long getCrashFileSizelimit() {
        return crashFileSizelimit;
    }

    /**
     * Set the org-wide crash file size limit.
     * @param sizeLimitIn The org-wide crash file size limit to set.
     */
    public void setCrashFileSizelimit(Long sizeLimitIn) {
        crashFileSizelimit = sizeLimitIn;
    }

    /**
     * @return Returns the scapfileUploadEnabled flag.
     */
    public boolean isScapfileUploadEnabled() {
        return scapfileUploadEnabled;
    }

    /**
     * @param scapfileUploadEnabledIn The scapfileUploadEnabled to set.
     */
    public void setScapfileUploadEnabled(boolean scapfileUploadEnabledIn) {
        scapfileUploadEnabled = scapfileUploadEnabledIn;
    }

    /**
     * Get the org-wide SCAP file size limit.
     * @return Returns the org-wide scap file size limit.
     */
    public Long getScapFileSizelimit() {
        return scapFileSizelimit;
    }

    /**
     * Set the org-wide SCAP file size limit.
     * @param sizeLimitIn The org-wide SCAP file size limit to set.
     */
    public void setScapFileSizelimit(Long sizeLimitIn) {
        scapFileSizelimit = sizeLimitIn;
    }

    /**
     * Get the org-wide period (in days) after which it is possible to remove SCAP scan.
     * @return Returns the org-wide SCAP retention period.
     */
    public Long getScapRetentionPeriodDays() {
        return scapRetentionPeriodDays;
    }

    /**
     * Set the org-wide SCAP period (in days) after which it is possible to remove SCAP
     * scan.
     * @param scapRetentionPeriodDaysIn The org-wide SCAP retention period.
     */
    public void setScapRetentionPeriodDays(Long scapRetentionPeriodDaysIn) {
        scapRetentionPeriodDays = scapRetentionPeriodDaysIn;
    }
}
