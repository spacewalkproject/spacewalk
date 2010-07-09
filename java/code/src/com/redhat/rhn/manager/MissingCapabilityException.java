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
package com.redhat.rhn.manager;

import com.redhat.rhn.common.RhnRuntimeException;
import com.redhat.rhn.domain.server.Server;

/**
 * MissingCapabilityException
 * @version $Rev$
 */
public class MissingCapabilityException extends RhnRuntimeException {

    /**
     * Comment for <code>serialVersionUID</code>
     */
    private static final long serialVersionUID = 1569955542059271165L;
    private Server server;
    private String  capability;

    /**
     * Constructor for exception on missing capability on a bunch of servers.
     * @param missingCapability the missing capability.
     * @param incapableServer the server missing the capaibility
     */
    public MissingCapabilityException(String missingCapability,
                                    Server incapableServer) {


        server = incapableServer;
        capability = missingCapability;
    }


    /**
     * @return the servers missing the given capability
     *          or null if none exist.
     */
    public Server getServer() {
        return server;
    }


    /**
     * @return the missing capability
     */
    public String getCapability() {
        return capability;
    }

}
