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
import com.redhat.rhn.domain.server.Server;

/**
 * Organization Not Trusted Exception
 *
 * @version $Rev$
 */
public class OrgNotInTrustException extends FaultException  {

    /**
     * Constructor
     * @param server The server not defined in trust.
     */
    public OrgNotInTrustException(Server server) {
        super(2854, "Organization Not In Trust" , LocalizationService.getInstance().
                getMessage("api.org.sysnotintrust", server.getId().toString(),
                        server.getOrg().getId().toString()));
    }

    /**
     * Constructor
     * @param server The server not defined in trust.
     * @param cause the cause
     */
    public OrgNotInTrustException(Server server, Throwable cause) {
        super(2854, "Organization Not In Trust" , LocalizationService.getInstance().
                getMessage("api.org.sysnotintrust", server.getId().toString(),
                        server.getOrg().getId().toString()), cause);
    }

    /**
     * Constructor
     * @param value The org id not defined in trust.
     */
    public OrgNotInTrustException(Integer value) {
        super(2854, "Organization Not In Trust" , LocalizationService.getInstance().
                getMessage("api.org.notintrust", new Object [] {value}));
    }

    /**
     * Constructor
     * @param value The org id not defined in trust.
     * @param cause the cause
     */
    public OrgNotInTrustException(Integer value, Throwable cause) {
        super(2854, "Organization Not In Trust" , LocalizationService.getInstance().
                getMessage("api.org.notintrust", new Object [] {value}), 
                cause);
    }

}
