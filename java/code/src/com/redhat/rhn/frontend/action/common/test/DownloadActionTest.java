/**
 * Copyright (c) 2008 Red Hat, Inc.
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

import com.redhat.rhn.testing.RhnMockStrutsTestCase;

/**
 * TinyUrlActionTest
 * @version $Rev$
 */
public class DownloadActionTest extends RhnMockStrutsTestCase {
    
    public void testKsDownload() throws Exception {
        setRequestPathInfo("/common/DownloadFile");
        // /ks/dist/f9-x86_64-distro/images/boot.iso
        addRequestParameter("url", "/ks/dist/f9-x86_64-distro/images/boot.iso");
        actionPerform();
        assertEquals("/kickstart/DownloadFile.do", getActualForward());
        assertNotNull(request.getAttribute("ksurl"));
        assertNotNull(request.getAttribute("params"));
    }

}
