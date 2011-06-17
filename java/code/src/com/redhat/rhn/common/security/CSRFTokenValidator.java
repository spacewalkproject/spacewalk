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

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * This is a utility class containing static methods for handling creation and
 * validation of security tokens used for preventing from CSRF attacks.
 */
public final class CSRFTokenValidator {

    private static String tokenKey = "csrf_token";
    private static String defaultAlgorithm = "SHA1PRNG";

    /* utility class, no public constructor  */
    private CSRFTokenValidator() {
    }

    /**
     * Create a new CSRF token using the given algorithm, throws a runtime
     * exception in case of an algorithm is used that is not available.
     *
     * @param alg
     * @return token as a String
     * @throws CSRFTokenException
     */
    private static String createNewToken(String alg) throws CSRFTokenException {
        String tokenValue = null;
        try {
            tokenValue = String.valueOf(SecureRandom.getInstance(alg).nextLong());
        }
        catch (NoSuchAlgorithmException e) {
            throw new CSRFTokenException(e.getMessage(), e);
        }
        return tokenValue;
    }

    /**
     * Return the CSRF token from the given session, create a new token if
     * there is currently none associated with this session.
     *
     * @param session HttpSession to retrieve the token from
     * @return token Security token retrieved from the session
     */
    public static String getToken(HttpSession session) {
        String tokenValue = (String) session.getAttribute(tokenKey);
        if (tokenValue == null) {
            // Create new token if necessary
            tokenValue = createNewToken(defaultAlgorithm);
            session.setAttribute(tokenKey, tokenValue);
        }
        return tokenValue;
    }

    /**
     * Validate a given request within its own session, throws a runtime
     * exception leading to internal server error in case of failure.
     *
     * @param request HTTPServletRequest to validate the token for
     * @throws CSRFTokenException In case the validation failed
     */
    public static void validate(HttpServletRequest request) throws CSRFTokenException {
        HttpSession session = request.getSession();

        if (session.getAttribute(tokenKey) == null) {
            throw new CSRFTokenException("Session does not contain a CSRF security token");
        }

        if (request.getParameter(tokenKey) == null) {
            throw new CSRFTokenException("Request does not contain a CSRF security token");
        }

        if (!session.getAttribute(tokenKey).equals(request.getParameter(tokenKey))) {
            throw new CSRFTokenException("Validation of CSRF security token failed");
        }
    }
}
