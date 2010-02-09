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
package com.redhat.rhn.frontend.action.systems.provisioning.test;

import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.common.test.FileListTest;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * PreservationListDeleteSingleTest
 * @version $Rev$
 */
public class PreservationListDeleteSingleTest extends RhnMockStrutsTestCase {

    public void testForwardToDelete() throws Exception {
        UserTestUtils.addProvisioning(user.getOrg());
        setRequestPathInfo(
                "/systems/provisioning/preservation/PreservationListDeleteSingle");
        FileList list = FileListTest.createTestFileList(user.getOrg());
        CommonFactory.saveFileList(list);
        TestUtils.flushAndEvict(list);
        addRequestParameter(RequestContext.FILE_LIST_ID, list.getId().toString());
        actionPerform();
        String expected = "/systems/provisioning/preservation/" +
                "PreservationListDeleteSubmit.do?setupdated=t" +
                "rue&items_selected=" + list.getId() + "&dispatch=Delete+File+List";
        verifyForwardPath(expected);
    }
}
