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

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * An AuthenticationService is a service that encapsulates authentication logic in coarse-
 * grained operations. Note that this service does not handle logins.
 *
 * @version $Rev$
 */
public interface AuthenticationService {

    /**
     * Validate whatever credentials are associated with the request. For hosted, this will
     * be the sso cookie, and for satellite, this will be the pxt cookie. If validation
     * fails, implementors should throw an AuthenticationException. Note that if an
     * implementation does not support/implement this operation, an AuthenticationException
     * should be thrown, and not an UnsupportedOperationException.
     *
     * @param request The current request
     *
     * @param response The current response
     *
     * @return True is validation succeeds, false otherwise.
     *
     * @throws ServletException If an unrecoverable error occurs
     */
    boolean validate(HttpServletRequest request, HttpServletResponse response)
        throws ServletException;

    /**
     * Redirects the request to whatever resource handles logins. This method is typically
     * invoked after a call to {@link #validate(HttpServletRequest, HttpServletResponse)}
     * fails. Note that the redirect may be client-side or server-side, and it may be to an
     * external or an internal resource.
     *
     * @param request the request
     * @param response the response
     * @throws ServletException If an unrecoverable error occurs
     */
    void redirectToLogin(HttpServletRequest request, HttpServletResponse response)
        throws ServletException;

    /**
     * Invalidates login credentials associated with the given request.
     *
     * @param request The current request
     * @param response The current response
     * @throws ServletException If an unrecoverable error occurs
     */
    void invalidate(HttpServletRequest request, HttpServletResponse response)
        throws ServletException;
}
