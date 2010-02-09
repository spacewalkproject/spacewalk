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
import com.redhat.rhn.frontend.action.systems.provisioning.BasePreservationListEditAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.frontend.struts.RhnAction;
import com.redhat.rhn.testing.RhnMockStrutsTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

/**
 * PreservationListEditActionTest
 * @version $Rev: 1 $
 */
public class PreservationListEditActionTest extends RhnMockStrutsTestCase {
        
    public void testEditExecute() throws Exception {
        UserTestUtils.addProvisioning(user.getOrg());
        FileList list = FileListTest.createTestFileList(user.getOrg());
        CommonFactory.saveFileList(list);
        TestUtils.flushAndEvict(list);
        String testLabel = "some new label" + TestUtils.randomString();
        addRequestParameter(BasePreservationListEditAction.LABEL, testLabel);
        addRequestParameter(RhnAction.SUBMITTED, Boolean.TRUE.toString());
        addRequestParameter(RequestContext.FILE_LIST_ID, list.getId().toString());
        setRequestPathInfo("/systems/provisioning/preservation/PreservationListEdit");
        actionPerform();
        String[] msgs = {"preservation.key.success"};
        verifyActionMessages(msgs);
        FileList lchanged = CommonFactory.lookupFileList(list.getId(), user.getOrg());
        assertEquals(testLabel, lchanged.getLabel());
        assertNotNull(getRequest().
                getAttribute(BasePreservationListEditAction.FILE_LIST));
    }
        
    public void testCreateSubmit() throws Exception {
        UserTestUtils.addProvisioning(user.getOrg());
        executeCreate(Boolean.TRUE);
        String[] msgs = {"preservation.key.success"};
        verifyActionMessages(msgs);
    }

    public void testCreateSetup() throws Exception {
        executeCreate(Boolean.FALSE);
    }

    private void executeCreate(Boolean submit) throws Exception {
        String testLabel = "some new label" + TestUtils.randomString();
        setRequestPathInfo("/systems/provisioning/preservation/PreservationListCreate");
        addRequestParameter(RhnAction.SUBMITTED, submit.toString());
        addRequestParameter(BasePreservationListEditAction.LABEL, testLabel);
        addRequestParameter(BasePreservationListEditAction.FILES_STRING, "1\n\2\n\3");
        actionPerform();
        if (submit.booleanValue()) {
            FileList fl = (FileList) getRequest().
                getAttribute(BasePreservationListEditAction.FILE_LIST);
            assertNotNull(fl);
            assertEquals(testLabel, fl.getLabel());
        }
    }
    
    
    
}

