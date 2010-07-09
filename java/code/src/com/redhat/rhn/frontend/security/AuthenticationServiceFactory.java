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

import com.redhat.rhn.frontend.servlets.PxtSessionDelegate;
import com.redhat.rhn.frontend.servlets.PxtSessionDelegateFactory;

import org.apache.log4j.Logger;

/**
 *
 * AuthenticationServiceFactory is factory for creating AuthenticationService objects.
 * This class is designed so that different factory implementations as well as different
 * AuthenticationService implementations can easily be plugged in.
 *
 * @see AuthenticationService
 * @version $Rev$
 */
public class AuthenticationServiceFactory {


    private static AuthenticationServiceFactory instance;

    private static final Logger LOG = Logger.getLogger(AuthenticationServiceFactory.class);

    private PxtAuthenticationService pxtAuthService;

    protected AuthenticationServiceFactory() {
    }

    /**
     *
     * @return An <code>AuthenticationServiceFactory</code> object.
     */
    public static AuthenticationServiceFactory getInstance() {
        if (instance == null) {
            instance = new AuthenticationServiceFactory();
        }

        return instance;
    }

    /**
     * Returns an AuthenticationService object. The implementation uses PXT authentication.
     *
     * @return An {@link AuthenticationService} object.
     *
     * @throws AuthenticationServiceInitializationException if an error occurs initializing
     * the AuthenticationService instance.
     */
    public AuthenticationService getAuthenticationService() {
        return getPxtService();
    }

    private PxtSessionDelegate getPxtSessionDelegate() {
        PxtSessionDelegateFactory factory = PxtSessionDelegateFactory.getInstance();

        return factory.newPxtSessionDelegate();
    }

    protected AuthenticationService getPxtService() {
        if (pxtAuthService == null) {
            LOG.debug("Creating a new " + PxtAuthenticationService.class.getName() +
                    " instance.");

            pxtAuthService = new PxtAuthenticationService();
            pxtAuthService.setPxtSessionDelegate(getPxtSessionDelegate());
        }

        LOG.debug("Returning a " + PxtAuthenticationService.class.getName() +
                " to provide authentication services.");

        return pxtAuthService;
    }
}
