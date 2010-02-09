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
package com.redhat.rhn.frontend.servlets.test;

import com.redhat.rhn.common.conf.Config;
import com.redhat.rhn.common.conf.ConfigDefaults;
import com.redhat.rhn.frontend.servlets.EnvironmentFilter;

import org.apache.struts.Globals;

/**
 * SessionFilterTest
 * @version $Rev: 64451 $
 */
public class EnvironmentFilterTest extends BaseFilterTst {
    
    public void setUp() {
        super.setUp();
        this.request.setRequestURL("http://rhn.webdev.redhat.com/rhn/Login.do");
    }

    public void testNonSSLUrls() throws Exception {

        EnvironmentFilter filter = new EnvironmentFilter();
        request.setupAddParameter("message", "some.key.to.localize");
        request.setupAddParameter("messagep1", "param value");
        request.setupAddParameter("messagep2", "param value");
        request.setupAddParameter("messagep3", "param value");
        filter.init(null);
        
        Config c = Config.get();
        Boolean origValue = new Boolean(ConfigDefaults.get().isSSLAvailable());
        c.setBoolean(ConfigDefaults.SSL_AVAILABLE, Boolean.TRUE.toString());
        try {
            filter.doFilter(request, response, chain);
        }
        finally {
            // Revert back
            c.setBoolean(ConfigDefaults.SSL_AVAILABLE, origValue.toString());
        }
        // Check that we got the expected redirect.
        String expectedRedir = "https://mymachine.rhndev.redhat.com/rhn/Login.do";
        assertEquals(expectedRedir, response.getRedirect());
        
        request.setupGetRequestURI("/rhn/kickstart/DownloadFile");
        response.clearRedirect();
        request.setupAddParameter("message", "some.key.to.localize");
        request.setupAddParameter("messagep1", "param value");
        request.setupAddParameter("messagep2", "param value");
        request.setupAddParameter("messagep3", "param value");
        filter.doFilter(request, response, chain);
        assertNull(response.getRedirect());
        assertFalse(expectedRedir.equals(response.getRedirect()));

        request.setupGetRequestURI("/rhn/rpc/api");
        response.clearRedirect();
        filter.doFilter(request, response, chain);
        assertNull(response.getRedirect());
    }
    
    public void testAddAMessage() throws Exception {
        Config c = Config.get();
        boolean origValue = ConfigDefaults.get().isSSLAvailable();
        EnvironmentFilter filter = new EnvironmentFilter();
        filter.init(null);
        request.setupAddParameter("message", "some.key.to.localize");
        request.setupAddParameter("messagep1", "param value");
        request.setupAddParameter("messagep2", "param value");
        request.setupAddParameter("messagep3", "param value");
        c.setBoolean(ConfigDefaults.SSL_AVAILABLE, Boolean.FALSE.toString());
        try {
            filter.doFilter(request, response, chain);
        }
        finally {
            c.setBoolean(ConfigDefaults.SSL_AVAILABLE, String.valueOf(origValue));    
        }
        
        assertNotNull(request.getAttribute(Globals.MESSAGE_KEY));
        assertNotNull(session.getAttribute(Globals.MESSAGE_KEY));
    }
}
