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

import com.redhat.rhn.domain.session.WebSession;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;
import com.redhat.rhn.testing.RhnMockHttpServletResponse;
import com.redhat.rhn.testing.RhnMockHttpSession;

import com.mockobjects.servlet.MockFilterChain;
import com.mockobjects.servlet.MockHttpSession;

/**
 * AuthFilterTest
 * @version $Rev: 59372 $
 */
public abstract class BaseFilterTst extends RhnBaseTestCase {

    protected RhnMockHttpServletRequest request;
    protected MockHttpSession session;
    protected RhnMockHttpServletResponse response;
    protected MockFilterChain chain;

    public void setUp() {
        request = new RhnMockHttpServletRequest();
        session = new RhnMockHttpSession();

        RequestContext requestContext = new RequestContext(request);

        request.setupServerName("mymachine.rhndev.redhat.com");
        request.setSession(session);
        request.setupGetRequestURI("http://localhost:8080");
        WebSession s = requestContext.getWebSession();
        request.addCookie(requestContext.createWebSessionCookie(s.getId(), 10));
        response = new RhnMockHttpServletResponse();
        chain = new MockFilterChain();
    }

}

