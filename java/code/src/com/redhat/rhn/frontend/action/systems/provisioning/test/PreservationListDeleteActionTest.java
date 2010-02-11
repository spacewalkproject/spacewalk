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
import com.redhat.rhn.frontend.action.systems.provisioning.PreservationListDeleteAction;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;

import org.apache.struts.Globals;
import org.apache.struts.action.Action;
import org.apache.struts.action.ActionForward;

import java.util.LinkedList;
import java.util.List;

/**
 * ProbeSuitesRemoveActionTest
 * @version 
 */
public class PreservationListDeleteActionTest extends RhnBaseTestCase {
    private Action action = null;
    
    public void setUp() throws Exception {
        super.setUp();
        action = new PreservationListDeleteAction();
    }
    
    /**
     * Test to make sure we delete the FileLists.
     * @throws Exception if test fails
     */
    public void testOperateOnSelectedSet() throws Exception {
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);
        ah.setupClampListBounds();
        ah.getRequest().setRequestURL("");
        ah.getRequest().setupAddParameter("newset", (String)null);
        ah.getRequest().setupAddParameter("items_on_page", (String)null);
        List ids = new LinkedList();
        
        // give list some FileLists
        for (int i = 0; i < 5; i++) {
            FileList fl = FileListTest.createTestFileList(
                                                   ah.getUser().getOrg());
            CommonFactory.saveFileList(fl);
            ids.add(fl.getId().toString());
        }
        
        ah.getRequest().setupAddParameter("items_selected",
                                         (String[]) ids.toArray(new String[0]));
        
        ActionForward testforward = ah.executeAction("operateOnSelectedSet");
        assertEquals("path?lower=10", testforward.getPath());
        assertNotNull(ah.getRequest().getSession().getAttribute(Globals.MESSAGE_KEY));
        assertNull(CommonFactory.lookupFileList(new Long(ids.get(0).toString()),
                                                         ah.getUser().getOrg()));
    }
}
