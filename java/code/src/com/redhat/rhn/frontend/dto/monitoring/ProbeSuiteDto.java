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
package com.redhat.rhn.frontend.dto.monitoring;

import com.redhat.rhn.frontend.dto.BaseDto;

/**
 * DTO for a com.redhat.rhn.domain.monitoring.suite.ProbeSuite.
 * Populated by this query:
 * 
 * SELECT csouter.recid suite_id, csouter.suite_name suite_name, 
 *   csouter.description description,
 *   (SELECT count(DISTINCT cp.host_id) system_count
 *   FROM RHN_CHECK_SUITES cs, RHN_CHECK_SUITE_PROBE csp, 
 *        RHN_SERVICE_PROBE_ORIGINS spo, RHN_CHECK_PROBE cp
 *   WHERE cs.recid = csp.check_suite_id AND
 *         csp.probe_id = spo.origin_probe_id AND
 *         spo.service_probe_id = cp.probe_id
 *         AND cs.recid = csouter.recid) system_count
 *  FROM rhn_check_suites csouter
 *  WHERE csouter.customer_id = :org_id
 * @version $Rev: 50942 $
 */
public class ProbeSuiteDto extends BaseDto {
    
    private Long suiteId;
    private String suiteName;
    private String description;
    private Long systemCount;
    private Long accessCount;
    
    /**
     * {@inheritDoc}
     */
    public Long getId() {
        return suiteId;
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
     * @return Returns the suiteName.
     */
    public String getSuiteName() {
        return suiteName;
    }

    
    /**
     * @param suiteNameIn The suiteName to set.
     */
    public void setSuiteName(String suiteNameIn) {
        this.suiteName = suiteNameIn;
    }

    
    /**
     * @return Returns the systemCount.
     */
    public Long getSystemCount() {
        return systemCount;
    }

    
    /**
     * @param systemCountIn The systemCount to set.
     */
    public void setSystemCount(Long systemCountIn) {
        this.systemCount = systemCountIn;
    }


    
    /**
     * @return Returns the suiteId.
     */
    public Long getSuiteId() {
        return suiteId;
    }
    
    /**
     * @param suiteIdIn The suiteId to set.
     */
    public void setSuiteId(Long suiteIdIn) {
        this.suiteId = suiteIdIn;
    }    
    
    /**
     * @return Returns the accessCount.
     */
    public Long getAccessCount() {
        return accessCount;
    }

    
    /**
     * @param accessCount0 The accessCount to set.
     */
    public void setAccessCount(Long accessCount0) {
        this.accessCount = accessCount0;
    }

    /**
     * {@inheritDoc}
     */
    public boolean isSelectable() {
        return getAccessCount().equals(getSystemCount());
    }
}
