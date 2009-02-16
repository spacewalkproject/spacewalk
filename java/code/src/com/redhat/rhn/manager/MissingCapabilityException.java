/**
 * Copyright (c) 2009 Red Hat, Inc.
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
package com.redhat.rhn.manager;

import com.redhat.rhn.common.RhnRuntimeException;
import com.redhat.rhn.domain.server.Server;

import java.util.List;

/**
 * MissingCapabilityException
 * @version $Rev$
 */
public class MissingCapabilityException extends RhnRuntimeException {
    
    private List<Server> servers;
    private String  capability;
    /**
     * 
     */
    public MissingCapabilityException() {
        super();
    }

    /**
     * @param msg An error message
     */
    public MissingCapabilityException(String msg) {
        super(msg);
    }

    /**
     * @param t The Throwable to wrap
     */
    public MissingCapabilityException(Throwable t) {
        super(t);
    }

    /**
     * @param msg An error message
     * @param t The Throwable to wrap
     */
    public MissingCapabilityException(String msg, Throwable t) {
        super(msg, t);
    }
    
    /**
     * Constructor for exception on missing capability on a bunch of servers.
     * @param missingCapability the missing capability. 
     * @param incapableServers the servers missing the capaibility 
     */
    public MissingCapabilityException(String missingCapability,
                                    List<Server> incapableServers) {
        
        this(makeMessage(missingCapability, incapableServers));
        servers = incapableServers;
        capability = missingCapability;
    }
    
    private static String makeMessage(String missingCapability,
                            List<Server> incapableServers) {
        return "Missing Client Capability -> " +  missingCapability +
        " for the server [" + incapableServers + "]. The server" +
        " will be unable to deploy config files " +
          "until this capability is provided.";
    }

    
    /**
     * @return the list of servers missing the given capability
     *          or null if none exist.
     */
    public List<Server> getServers() {
        return servers;
    }

    
    /**
     * @return the missing capability
     */
    public String getCapability() {
        return capability;
    }

}
