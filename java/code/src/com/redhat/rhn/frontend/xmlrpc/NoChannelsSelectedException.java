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
 * Invalid Package Exception
 *
 * @version $Rev$
 */
public class NoChannelsSelectedException extends FaultException  {

    /**
     * Constructor
     */
    public NoChannelsSelectedException() {
        super(2603, "No Channels Selected" , LocalizationService.getInstance().
                getMessage("api.errata.nochannelsselected", new Object [] {}));
    }

    /**
     * Constructor
     * @param advisory The advisory to be created
     * @param cause the cause
     */
    public NoChannelsSelectedException(String advisory, Throwable cause) {
        super(2603, "No Channels Selected" , LocalizationService.getInstance().
                getMessage("api.errata.nochannelsselected", 
                new Object [] {advisory}), cause);
    }
    
}
