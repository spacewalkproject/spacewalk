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
    private Org org;
    private boolean stagingContentEnabled;
    private Long crashFileSizelimit;

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
}
