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

package com.redhat.rhn.domain.org;

import com.redhat.rhn.common.util.StringUtil;
import com.redhat.rhn.domain.BaseDomainHelper;

/**
 * OrgQuota - java representation of the rhnOrgQuota table
 * @version $Rev$
 */
public class OrgQuota extends BaseDomainHelper {

    private Long orgId;
    private Long total;
    private Long bonus;
    private Long used;

    private Org org;

    /** Set the Org (parent) on this object
    * @param orgIn the Org we want to set as the parent of this object.
    */
    public void setOrg(Org orgIn) {
        this.org = orgIn;
    }

    /** Get the Org (parent) from this object
    * @return Org associated with this quota
    */
    public Org getOrg() {
        return this.org;
    }

    /**
     * Getter for orgId
     * @return Long to get
    */
    public Long getOrgId() {
        return this.orgId;
    }

    /**
     * Setter for orgId
     * @param orgIdIn to set
    */
    public void setOrgId(Long orgIdIn) {
        this.orgId = orgIdIn;
    }

    /**
     * Getter for total
     * @return Long to get
    */
    public Long getTotal() {
        return this.total;
    }

    /**
     * Setter for total
     * @param totalIn to set
    */
    public void setTotal(Long totalIn) {
        this.total = totalIn;
    }

    /**
     * Getter for bonus
     * @return Long to get
    */
    public Long getBonus() {
        return this.bonus;
    }

    /**
     * Setter for bonus
     * @param bonusIn to set
    */
    public void setBonus(Long bonusIn) {
        this.bonus = bonusIn;
    }

    /**
     * Getter for used
     * @return Long to get
    */
    public Long getUsed() {
        return this.used;
    }

    /**
     * Setter for used
     * @param usedIn to set
    */
    public void setUsed(Long usedIn) {
        this.used = usedIn;
    }

    /**
     * Getter for the available org quota.
     * This is total + bonus - used.
     * @return The available quota for an org.
     */
    public Long getAvailable() {
        long lgTotal = getTotal().longValue();
        long lgBonus = getBonus().longValue();
        long lgUsed = getUsed().longValue();
        return new Long(lgTotal + lgBonus - lgUsed);
    }

    /**
     * Gives a display for the available quota.
     * This is total + bonus - used.
     * @return A display string for the available org quota.
     */
    public String getAvailableDisplay() {
        return StringUtil.displayFileSize(getAvailable().longValue());
    }

}
