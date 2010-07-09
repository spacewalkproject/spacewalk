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

import org.apache.commons.lang.builder.CompareToBuilder;


/**
 * EntitlementDto
 * @version $Rev$
 */
public class EntitlementDto implements Comparable {

    private Entitlement entitlement;
    private Long availbleEntitlements;

    /**
     * Constructor
     * @param entIn to set
     * @param availEnts to set
     */
    public EntitlementDto(Entitlement entIn, Long availEnts) {
        this.entitlement = entIn;
        this.availbleEntitlements = availEnts;
    }

    /**
     * @return Returns the availbleEntitlements.
     */
    public Long getAvailbleEntitlements() {
        return availbleEntitlements;
    }

    /**
     * @param availbleEntitlementsIn The availbleEntitlements to set.
     */
    public void setAvailbleEntitlements(Long availbleEntitlementsIn) {
        this.availbleEntitlements = availbleEntitlementsIn;
    }

    /**
     * @return Returns the entitlement.
     */
    public Entitlement getEntitlement() {
        return entitlement;
    }

    /**
     * @param entitlementIn The entitlement to set.
     */
    public void setEntitlement(Entitlement entitlementIn) {
        this.entitlement = entitlementIn;
    }

    /**
     * {@inheritDoc}
     */
    public int compareTo(final Object other) {
        EntitlementDto castOther = (EntitlementDto) other;
        return new CompareToBuilder()
                .append(entitlement, castOther.entitlement).toComparison();
    }

}
