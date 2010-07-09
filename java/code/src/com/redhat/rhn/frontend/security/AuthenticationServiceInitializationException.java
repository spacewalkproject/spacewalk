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
package com.redhat.rhn.frontend.security;

import com.redhat.rhn.common.RhnRuntimeException;


/**
 * Throw to indicate that a problem occurred while initializing an AuthenticationService
 * object. When this exception is throw, the AuthenticationService object may not be in a
 * usable state.
 *
 * @version $Rev$
 */
public class AuthenticationServiceInitializationException extends RhnRuntimeException {

    /**
     *
     */
    public AuthenticationServiceInitializationException() {
    }

    /**
     * @param msg The detail message
     */
    public AuthenticationServiceInitializationException(String msg) {
        super(msg);
    }

    /**
     * @param cause The casue
     */
    public AuthenticationServiceInitializationException(Throwable cause) {
        super(cause);
    }

    /**
     * @param msg The detail message
     * @param cause The cause
     */
    public AuthenticationServiceInitializationException(String msg, Throwable cause) {
        super(msg, cause);
    }

}
