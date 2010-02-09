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
package com.redhat.rhn.frontend.action.kickstart.test;

import com.redhat.rhn.domain.kickstart.KickstartScript;
import com.redhat.rhn.frontend.action.kickstart.KickstartScriptCreateAction;
import com.redhat.rhn.frontend.action.kickstart.KickstartScriptDeleteAction;
import com.redhat.rhn.frontend.struts.RequestContext;

/**
 * KickstartScriptDeleteActionTest
 * @version $Rev: 1 $
 */
public class KickstartScriptDeleteActionTest extends BaseKickstartEditTestCase {
    
    public void testExecute() throws Exception {
        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        assertEquals(5, ksdata.getScripts().size());
        addRequestParameter(RequestContext.KICKSTART_SCRIPT_ID, kss.getId().toString());
        addRequestParameter(KickstartScriptDeleteAction.SUBMITTED, 
                Boolean.FALSE.toString());
        setRequestPathInfo("/kickstart/KickstartScriptDelete");
        actionPerform();
        assertEquals(5, ksdata.getScripts().size());
        assertNotNull(request.getAttribute(KickstartScriptDeleteAction.KICKSTART_SCRIPT));
    }
    
    
    public void testExecuteSubmit() throws Exception {
        KickstartScript kss = (KickstartScript) ksdata.getScripts().iterator().next();
        assertEquals(5, ksdata.getScripts().size());
        addRequestParameter(RequestContext.KICKSTART_SCRIPT_ID, kss.getId().toString());
        addRequestParameter(KickstartScriptCreateAction.SUBMITTED, 
                Boolean.TRUE.toString());
        setRequestPathInfo("/kickstart/KickstartScriptDelete");
        actionPerform();
        assertEquals(4, ksdata.getScripts().size());
    }
}

