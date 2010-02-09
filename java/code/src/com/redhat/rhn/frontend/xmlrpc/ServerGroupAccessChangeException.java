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

package com.redhat.rhn.frontend.xmlrpc;

import com.redhat.rhn.FaultException;

/**
 * Server Group Access Change Exception - This exception may be thrown when the user has
 * is attempting to remove server group access permissions from a Satellite or
 * Organization administrator.
 *
 * @version $Rev$
 */
public class ServerGroupAccessChangeException extends FaultException  {

    /**
     * Constructor
     * @param logins the logins that the access change was attempted for
     */
    public ServerGroupAccessChangeException(String logins) {
        super(2202, "ServerGroupAccess", "api.systemgroup.accessChangeDenied",
            new Object[] {logins});
    }
}
