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
package com.redhat.rhn.manager.system;

import com.redhat.rhn.domain.org.Org;

import java.util.List;


/**
 * VirtualizationEntitlementsService
 * @version $Rev$
 */
public interface VirtualizationEntitlementsManager {
    
    /**
     * Queries an org for host systems, having the 'Unlimited Virtualization' entitlement, 
     * and the guest count for each host.
     * 
     * @param org The org to search in
     * 
     * @return A set of HostAndGuestView objects
     * 
     * @see com.redhat.rhn.domain.server.HostAndGuestCountView
     */
    List findGuestUnlimitedHostsByOrg(Org org);
    
    /**
     * Queries an org for host systems, having the 'Limited Virtualization' entitlement that
     * have exceeded their guest limit. The guest count for each host is also fetched.
     * 
     * @param org The org to search in
     * 
     * @return A set of HostAndGuestView objects
     * 
     * @see com.redhat.rhn.domain.server.HostAndGuestCountView
     */
    List findGuestLimitedHostsByOrg(Org org);
    
    /**
     * Queries an org for guest systems whose hosts either do not have any virtualization
     * entitlements or are not registered with RHN.
     * 
     * @param org The org to search in
     * 
     * @return A set of GuestAndNonVirtHostView objects
     * 
     * @see com.redhat.rhn.domain.server.GuestAndNonVirtHostView
     */
    List findGuestsWithoutHostsByOrg(Org org);
    
}
