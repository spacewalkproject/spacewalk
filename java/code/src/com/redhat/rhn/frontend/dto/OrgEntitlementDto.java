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

import com.redhat.rhn.domain.entitlement.Entitlement;
import com.redhat.rhn.domain.org.Org;
import com.redhat.rhn.domain.org.OrgFactory;
import com.redhat.rhn.manager.entitlement.EntitlementManager;


/**
 * OrgEntitlementDto
 * @version $Rev$
 */
public class OrgEntitlementDto extends EntitlementDto {

    private Org org;
    private Entitlement ent;
    /**
     * Constructor ..
     * @param entIn to transfer
     * @param orgIn who we are viewing
     */
    public OrgEntitlementDto(Entitlement entIn, Org orgIn) {
        super(entIn, null);
        this.org = orgIn;
        ent = entIn;
        Long availEnts = EntitlementManager.getAvailableEntitlements(
                entIn, orgIn);
        this.setAvailbleEntitlements(availEnts);

    }

    /**
     *
     * @return max members for this entitlement
     */
    public Long getMaxEntitlements() {
        Long count = EntitlementManager.getMaxEntitlements(this.getEntitlement(), org);
        if (count == null) {
            return new Long(0);
        }
        else {
            return count;
        }
    }

    /**
     * Get the count of the number of used slots.
     * @return Long count, null if unlimited
     */
    public Long getCurrentEntitlements() {
        Long count = EntitlementManager.getUsedEntitlements(this.getEntitlement(), org);
        if (count == null) {
            return new Long(0);
        }
        else {
            return count;
        }
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Long getAvailbleEntitlements() {
        Long count = super.getAvailbleEntitlements();
        if (count == null) {
            return new Long(0);
        }
        else {
            return count;
        }
    }

    /**
     *
     * @return Long total of the available Entitlements in the default Org
     */
    public Long getSatelliteTotal() {
        Org defaultOrg = OrgFactory.getSatelliteOrg();
        return EntitlementManager.
            getAvailableEntitlements(this.getEntitlement(), defaultOrg);
    }

    /**
     *
     * @return upper range for which a org can get entitlements
     * (org1 max - org1 consumed + org max)
     */
    public Long getUpperRange() {
        Long defaultMax = EntitlementManager.getMaxEntitlements(this.getEntitlement(),
                                             OrgFactory.getSatelliteOrg());
        Long defaultCur = EntitlementManager.getUsedEntitlements(this.getEntitlement(),
                                             OrgFactory.getSatelliteOrg());
        Long upper = getMaxEntitlements() + (defaultMax - defaultCur);
        return upper;
    }


    /**
     * @return the ent
     */
    public Entitlement getEntitlement() {
        return ent;
    }

    /**
     * Returns the org information.
     * @return the associated org
     */
    public Org getOrg() {
        return org;
    }
}
