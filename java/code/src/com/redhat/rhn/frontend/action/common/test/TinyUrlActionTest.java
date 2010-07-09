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
package com.redhat.rhn.frontend.action.common.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.TinyUrl;
import com.redhat.rhn.frontend.action.common.TinyUrlAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;

import java.util.Date;

import junit.framework.AssertionFailedError;

/**
 * TinyUrlActionTest
 * @version $Rev$
 */
public class TinyUrlActionTest extends RhnMockStrutsTestCase {

    public void testTinyUrl() throws Exception {
        setRequestPathInfo("/ty/TinyUrl");
        TinyUrl url = CommonFactory.createTinyUrl(
                "/rhn/kickstart/ks-rhel-i386-as-4-u2", new Date());
        CommonFactory.saveTinyUrl(url);
        addRequestParameter(TinyUrlAction.TY_TOKEN, url.getToken());
        actionPerform();
        assertEquals("/kickstart/DownloadFile.do", getActualForward());
        assertNotNull(request.getAttribute("ksurl"));
    }

    public void testEmptyTinyUrl() throws Exception {
        setRequestPathInfo("/ty/TinyUrl");
        try {
            actionPerform();
            fail("We should have gotten a 404.");
        }
        catch (AssertionFailedError afe) {
            // NOOP
        }
    }
}
