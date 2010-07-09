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
 * Invalid Access Value Exception
 *
 * @version $Rev$
 */
public class InvalidAccessValueException extends FaultException  {

    /**
     * Constructor
     * @param value The access value that was invalid
     */
    public InvalidAccessValueException(String value) {
        super(1064, "Invalid Access Value" , LocalizationService.getInstance().
                getMessage("api.channel.access.invalidaccessvalue", new Object [] {value}));
    }

    /**
     * Constructor
     * @param value The access value that was invalid
     * @param cause the cause
     */
    public InvalidAccessValueException(String value, Throwable cause) {
        super(1064, "Invalid Access Value" , LocalizationService.getInstance().
                getMessage("api.channel.access.invalidaccessvalue", new Object [] {value}),
                cause);
    }
}
