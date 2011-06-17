/**
 * Copyright (c) 2011 Novell
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
package com.redhat.rhn.common.security;

import com.redhat.rhn.common.RhnRuntimeException;

/**
 * RuntimeException to indicate failure during validation of CSRF tokens.
 */
public class CSRFTokenException extends RhnRuntimeException  {

    /** Serial Version UID */
    private static final long serialVersionUID = -913505868082953593L;

    /**
     * Constructor
     *
     * @param message exception message
     */
    public CSRFTokenException(String message) {
        super(message);
    }

    /**
     * Constructor
     *
     * @param message exception message
     * @param cause exception cause
     */
    public CSRFTokenException(String message, Throwable cause) {
        super(message, cause);
    }
}
