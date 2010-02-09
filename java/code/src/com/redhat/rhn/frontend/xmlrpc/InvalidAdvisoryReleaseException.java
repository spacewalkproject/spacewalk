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
import com.redhat.rhn.manager.errata.ErrataManager;

/**
 * Invalid Advisory Release Exception
 *
 * @version $Rev$
 */
public class InvalidAdvisoryReleaseException extends FaultException  {

    /**
     * Constructor
     * @param value The arch that was request
     */
    public InvalidAdvisoryReleaseException(long value) {
        super(1070, "Invalid Advisory Release" , LocalizationService.getInstance().
            getMessage("api.errata.invalidadvisoryrelease",
                new Object [] {value, ErrataManager.MAX_ADVISORY_RELEASE}));
    }

    /**
     * Constructor
     * @param value The arch that was requested
     * @param cause the cause
     */
    public InvalidAdvisoryReleaseException(long value, Throwable cause) {
        super(1070, "Invalid Advisory Release" , LocalizationService.getInstance().
            getMessage("api.errata.invalidadvisoryrelease",
               new Object [] {value, ErrataManager.MAX_ADVISORY_RELEASE}), cause);
    }

}
