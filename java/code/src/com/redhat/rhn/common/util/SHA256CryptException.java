/**
 * Copyright (c) 2014 Red Hat, Inc.
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

package com.redhat.rhn.common.util;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * A RuntimeException indicating a fatal failure trying to use the SHA256Crypt utitlity
 */
public class SHA256CryptException extends RhnRuntimeException  {
    /**
     * SHA256CryptException
     * @param message exception message
     */
    public SHA256CryptException(String message) {
        super(message);
    }

    /**
     * SHA256CryptException
     * @param message exception message
     * @param cause the cause
     */
    public SHA256CryptException(String message, Throwable cause) {
        super(message, cause);
    }
}
