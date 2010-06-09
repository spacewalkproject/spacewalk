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
import com.redhat.rhn.domain.server.ServerFactory;
import com.redhat.rhn.domain.server.VirtualInstanceFactory;

import java.util.LinkedList;
import java.util.List;


/**
 * VirtualizationEntitlementsService
 * @version $Rev$
 */
public class VirtualizationEntitlementsManager {
    private static final VirtualizationEntitlementsManager INSTANCE = 
                                    new VirtualizationEntitlementsManager();
    /**
     * Initializes the manager.
     */
    private VirtualizationEntitlementsManager() {
    }

    /**
     * @return an instance
     */
    public static VirtualizationEntitlementsManager getInstance() {
        return INSTANCE;
    }
    
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
    public List findGuestUnlimitedHostsByOrg(Org org) {
        return ServerFactory.findVirtPlatformHostsByOrg(org);
    }
    
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
    public List findGuestLimitedHostsByOrg(Org org) {
        return ServerFactory.findVirtHostsExceedingGuestLimitByOrg(org);
    }
    
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
    public List findGuestsWithoutHostsByOrg(Org org) {
       List guestsWithoutHosts = new LinkedList();
       guestsWithoutHosts.addAll(VirtualInstanceFactory.getInstance().
                                           findGuestsWithNonVirtHostByOrg(org));
       guestsWithoutHosts.addAll(VirtualInstanceFactory.getInstance().
                                               findGuestsWithoutAHostByOrg(org));
       
       return guestsWithoutHosts;
    }    
    
}
