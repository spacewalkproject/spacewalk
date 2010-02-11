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
package com.redhat.rhn.frontend.integration.test;

import com.redhat.rhn.common.security.SessionSwap;
import com.redhat.rhn.frontend.integration.IntegrationService;
import com.redhat.rhn.testing.BaseTestCaseWithUser;
import com.redhat.rhn.testing.TestUtils;

import java.util.Map;

/**
 * @author mmccune
 * 
 */
public class IntegrationServiceTest extends BaseTestCaseWithUser {

    public void testAuth() throws Exception {
        String login = "test-login-iservice";
        Map tokens = (Map) TestUtils.getPrivateField(IntegrationService.get(), 
            "randomTokenStore");
        tokens.clear();
        assertNotNull(IntegrationService.get().
                getAuthToken(login));
        tokens = (Map) TestUtils.getPrivateField(IntegrationService.get(), 
            "randomTokenStore");
        assertNotNull(tokens);
        // Here we do re-implement the guts of what IntegrationService is doing
        // but there really is no other way since we don't want to really expose
        // the methodology of 'how' we are hashing/passing the values to the
        // callers of this API since its not important to a user.
        String hashedRandom = (String) tokens.get(login);
        String encodedRandom = SessionSwap.encodeData(hashedRandom);
        assertTrue(IntegrationService.get().checkRandomToken(login, 
                encodedRandom));
        
        // Check that a subsequent check of the token is still valid
        assertNotNull(IntegrationService.get().getAuthToken(login));
    }

}
