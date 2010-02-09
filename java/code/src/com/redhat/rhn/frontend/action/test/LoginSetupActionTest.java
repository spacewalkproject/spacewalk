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
package com.redhat.rhn.frontend.action.test;

import com.redhat.rhn.frontend.action.LoginSetupAction;
import com.redhat.rhn.manager.satellite.test.CertificateManagerTest;
import com.redhat.rhn.testing.RhnMockDynaActionForm;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import com.mockobjects.servlet.MockHttpSession;

import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

/**
 * LoginSetupActionTest
 * @version $Rev$
 */
public class LoginSetupActionTest extends RhnMockStrutsTestCase {

    /**
     * {@inheritDoc}
     */
    public void setUp() throws Exception {
        super.setUp();
        setRequestPathInfo("/Login");
    }
    
    public void testExpirationMessage() throws Exception {
        
        CertificateManagerTest.expireSatelliteCertificate();
        actionPerform();
        verifyActionMessage("satellite.expired");
        assertTrue(request.getAttribute(LoginSetupAction.HAS_EXPIRED).equals(Boolean.TRUE));
    }
    
    public void testGracePeriodMessage() throws Exception {
        
        CertificateManagerTest.activateGracePeriod();
        actionPerform();
        verifyActionMessage("satellite.graceperiod");
    }
    
    public void testUrlBounce() {
        LoginSetupAction action = new LoginSetupAction();

        // setup stuff for Struts
        ActionMapping mapping = new ActionMapping();
        mapping.addForwardConfig(new ActionForward("default", "path", false));
        RhnMockDynaActionForm form = new RhnMockDynaActionForm("loginForm");
        RhnMockHttpServletRequest req = new RhnMockHttpServletRequest();
        RhnMockHttpServletResponse resp = new RhnMockHttpServletResponse();
        req.setSession(new MockHttpSession());
        req.setupServerName("mymachine.rhndev.redhat.com");
        req.addAttribute("url_bounce", "/rhn/UserDetails.do?sid=1");
        
        // ok run it
        ActionForward rc = action.execute(mapping, form, req, resp);

        // verify
        String bounce = (String) form.get("url_bounce");
        
        assertNotNull(bounce);
        assertEquals(bounce, "/rhn/UserDetails.do?sid=1");
        assertNotNull(rc);
        assertEquals("default", rc.getName());
    }
}
