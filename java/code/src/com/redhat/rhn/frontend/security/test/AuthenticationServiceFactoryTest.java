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
package com.redhat.rhn.frontend.security.test;

import com.redhat.rhn.frontend.security.AuthenticationService;
import com.redhat.rhn.frontend.security.AuthenticationServiceFactory;
import com.redhat.rhn.frontend.security.PxtAuthenticationService;

import junit.framework.TestCase;

/**
 *
 * AuthenticationServiceFactoryTest
 * @version $Rev$
 */
public class AuthenticationServiceFactoryTest extends TestCase {

    private class AuthenticationServiceFactoryStub extends AuthenticationServiceFactory {

        private boolean satellite = true;

        public boolean isSatellite() {
            return satellite;
        }

        public void setSatellite(boolean isSatellite) {
            satellite = isSatellite;
        }


    }

    private AuthenticationServiceFactoryStub factory;

    protected void setUp() throws Exception {
        factory = new AuthenticationServiceFactoryStub();
    }

    public final void testGetInstance() {
        assertNotNull(AuthenticationServiceFactory.getInstance());
    }

    public final void testGetAuthenticationServiceWhenInSatelliteMode() {
        factory.setSatellite(true);

        AuthenticationService service = factory.getAuthenticationService();

        assertTrue(service instanceof PxtAuthenticationService);
    }

}
