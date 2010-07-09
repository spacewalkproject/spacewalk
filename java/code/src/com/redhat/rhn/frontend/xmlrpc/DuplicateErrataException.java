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
public class DuplicateErrataException extends FaultException  {

    /**
     * Constructor
     * @param advisory The advisory that was request
     */
    public DuplicateErrataException(String advisory) {
        super(2601, "Errata already exists" + advisory, LocalizationService.getInstance().
                getMessage("api.errata.duplicateerrata", new Object [] {advisory}));
    }

    /**
     * Constructor
     * @param advisory The advisory that was requested
     * @param cause the cause
     */
    public DuplicateErrataException(String advisory, Throwable cause) {
        super(2601, "Errata already exists" , LocalizationService.getInstance().
                getMessage("api.errata.duplicateerrata", new Object [] {advisory}), cause);
    }

}
