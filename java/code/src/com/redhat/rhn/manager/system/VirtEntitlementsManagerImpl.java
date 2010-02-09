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
 * VirtEntitlementsManagerImpl
 * 
 * @version $Rev$
 */
public class VirtEntitlementsManagerImpl implements VirtualizationEntitlementsManager {
    
    private VirtualInstanceFactory virtualInstanceDAO;
    
    /**
     * Initializes the manager.
     */
    public VirtEntitlementsManagerImpl() {
        virtualInstanceDAO = new VirtualInstanceFactory();
    }

    /**
     * {@inheritDoc}
     */
    public List findGuestUnlimitedHostsByOrg(Org org) {
        return ServerFactory.findVirtPlatformHostsByOrg(org);
    }
    
    /**
     * {@inheritDoc}
     */
    public List findGuestLimitedHostsByOrg(Org org) {
        return ServerFactory.findVirtHostsExceedingGuestLimitByOrg(org);
    }
    
    /**
     * {@inheritDoc}
     */
    public List findGuestsWithoutHostsByOrg(Org org) {
       List guestsWithoutHosts = new LinkedList();
       
       guestsWithoutHosts.addAll(virtualInstanceDAO.findGuestsWithNonVirtHostByOrg(org));
       guestsWithoutHosts.addAll(virtualInstanceDAO.findGuestsWithoutAHostByOrg(org));
       
       return guestsWithoutHosts;
    }

}
