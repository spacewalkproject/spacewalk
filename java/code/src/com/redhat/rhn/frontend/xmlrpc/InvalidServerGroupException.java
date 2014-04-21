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
import com.redhat.rhn.common.localization.LocalizationService;

/**
 * Invalid Server Group
 *
 * @version $Rev$
 */
public class InvalidServerGroupException extends FaultException  {

    /**
     * Constructor
     */
    public InvalidServerGroupException() {
        super(2200, "invalidServerGroup" , "Invalid server group");
    }

    /**
     * Constructor
     * @param name the name of the server group that is invalid
     */
    public InvalidServerGroupException(String name) {
        super(2200, "invalidServerGroup", LocalizationService.getInstance().getMessage(
                "api.externalgroup.nosuchservergroup", new Object[] { name }));
    }

    /**
     * Constructor
     * @param cause the cause
     */
    public InvalidServerGroupException(Throwable cause) {
        super(2200 , "invalidserverGroup" , "Invalid server group" , cause);
    }

}
