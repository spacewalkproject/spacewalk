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
package com.redhat.rhn.frontend.action.systems.provisioning.kickstart.test;

import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * SessionStatusActionTest
 * @version $Rev: 1 $
 */
public class SessionStatusActionTest extends BaseSessionTestCase {
    
    public void testExecute() throws Exception {
        setRequestPathInfo("/systems/details/kickstart/SessionStatus");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.SYSTEM));
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
        assertNotNull(request.getAttribute(RequestContext.KICKSTART_SESSION));
        assertNotNull(request.getAttribute(RequestContext.KICKSTART_STATE_DESC));
    }

}

