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
package com.redhat.rhn.frontend.xmlrpc.kickstart.keys;

import com.redhat.rhn.FaultException;
import com.redhat.rhn.common.localization.LocalizationService;

/**
 * @author Jason Dobies
 * @version $Revision$
 */
public class KickstartKeyDeleteException extends FaultException {

    /**
     * Creates a <code>KickstartKeyDeleteException</code> with no underlying cause. 
     */
    public KickstartKeyDeleteException() {
        super(2755, "kickstartKeyDelete",
            LocalizationService.getInstance().getMessage("api.kickstart.keys.delete"));
    }

    /**
     * Creates a new <code>KickstartKeyDeleteException</code> to wrap the given exception.
     * 
     * @param cause cause of the delete failure
     */
    public KickstartKeyDeleteException(Throwable cause) {
        super(2755, "kickstartKeyDelete",
            LocalizationService.getInstance().getMessage("api.kickstart.keys.delete"),
                cause);        
    }
}
