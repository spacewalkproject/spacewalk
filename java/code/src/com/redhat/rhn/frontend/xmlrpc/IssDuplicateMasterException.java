/**
 * Copyright (c) 2013 Red Hat, Inc.
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
 * ISS Master we're trying to create already exists
 *
 * @version $Rev$
 */
public class IssDuplicateMasterException extends FaultException {

    private static final long serialVersionUID = -272385595779582534L;

    /**
     * Tried to create a master when one already exists w/a given label
     * @param label label we tried to use
     */
    public IssDuplicateMasterException(String label) {
        super(3000, "duplicateMaster", LocalizationService.getInstance().
                getMessage("api.iss.duplicatemaster", label));
    }

}
