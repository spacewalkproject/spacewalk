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
import com.redhat.rhn.frontend.action.kickstart.KickstartLocaleEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.TestUtils;

/**
 * KickstartDetailsEditTest
 * @version $Rev$
 */
public class KickstartLocaleEditTest extends BaseKickstartEditTestCase {
    
    public void testSetupExecute() throws Exception {
        setRequestPathInfo("/kickstart/LocaleEdit");
        actionPerform();
        assertNotNull(request.getAttribute(RequestContext.KICKSTART));
    }

    public void testSubmitStandard() throws Exception {
        addDispatchCall(KickstartLocaleEditAction.UPDATE_METHOD);
        setRequestPathInfo("/kickstart/LocaleEdit");
        addRequestParameter(KickstartLocaleEditAction.SUBMITTED,
                            Boolean.TRUE.toString());
        addRequestParameter(KickstartLocaleEditAction.TIMEZONE,
                            "America/New_York");
        addRequestParameter(KickstartLocaleEditAction.USE_UTC,
                            Boolean.FALSE.toString());
        actionPerform();

        TestUtils.saveAndFlush(this.ksdata);
        this.ksdata = (KickstartData) TestUtils.reload(this.ksdata);

        assertEquals("America/New_York", this.ksdata.getTimezone());
        assertFalse(this.ksdata.isUsingUtc().booleanValue());
    }   

    public void testSubmitAgain() throws Exception {
        addDispatchCall(KickstartLocaleEditAction.UPDATE_METHOD);
        setRequestPathInfo("/kickstart/LocaleEdit");
        addRequestParameter(KickstartLocaleEditAction.SUBMITTED,
                            Boolean.TRUE.toString());
        addRequestParameter(KickstartLocaleEditAction.TIMEZONE,
                            "Asia/Qatar");
        addRequestParameter(KickstartLocaleEditAction.USE_UTC,
                            Boolean.TRUE.toString());
        actionPerform();

        TestUtils.saveAndFlush(this.ksdata);
        this.ksdata = (KickstartData) TestUtils.reload(this.ksdata);

        assertEquals("Asia/Qatar", this.ksdata.getTimezone());
        assertTrue(this.ksdata.isUsingUtc().booleanValue());
    }   

}

