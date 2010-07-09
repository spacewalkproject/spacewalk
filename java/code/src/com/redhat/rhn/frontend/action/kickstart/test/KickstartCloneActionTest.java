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

import com.redhat.rhn.domain.kickstart.KickstartData;
import com.redhat.rhn.frontend.action.kickstart.BaseKickstartEditAction;
import com.redhat.rhn.frontend.struts.FormActionContstants;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartCloneActionTest
 * @version $Rev: 1 $
 */
public class KickstartCloneActionTest extends BaseKickstartEditTestCase {

    public void testExecute() throws Exception {
        setRequestPathInfo("/kickstart/KickstartClone");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
    }

    public void testExecuteSubmit() throws Exception {
        addRequestParameter(BaseKickstartEditAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(FormActionContstants.LABEL,
                "KickstartCloneActionTestLabel" + TestUtils.randomString());
        setRequestPathInfo("/kickstart/KickstartClone");
        actionPerform();
        verifyActionMessage("kickstart.clone.success");
        KickstartData cloned = (KickstartData)
            request.getAttribute(RequestContext.KICKSTART);
        assertNotNull(cloned);
        assertNotSame(ksdata.getId(), cloned.getId());
        String expectedForward = "/kickstart/KickstartDetailsEdit.do?" +
            RequestContext.KICKSTART_ID + "=" + cloned.getId();
        assertEquals(expectedForward, getActualForward());
        setRequestPathInfo(getActualForward());
        addRequestParameter(BaseKickstartEditAction.SUBMITTED,
                Boolean.FALSE.toString());
        actionPerform();

    }


}

