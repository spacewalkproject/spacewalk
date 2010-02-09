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

import com.redhat.rhn.common.db.datasource.DataResult;
import com.redhat.rhn.domain.common.CommonFactory;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.domain.common.test.FileListTest;
import com.redhat.rhn.domain.rhnset.RhnSet;
import com.redhat.rhn.domain.rhnset.RhnSetElement;
import com.redhat.rhn.domain.user.User;
import com.redhat.rhn.frontend.action.systems.provisioning.PreservationListConfirmDeleteAction;
import com.redhat.rhn.frontend.struts.RequestContext;
import com.redhat.rhn.manager.rhnset.RhnSetDecl;
import com.redhat.rhn.manager.rhnset.RhnSetManager;
import com.redhat.rhn.testing.ActionHelper;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.RhnMockHttpServletRequest;

import org.apache.struts.action.Action;

import java.util.Iterator;



/**
 * PreservationListConfirmDeleteActionTest
 * @version 
 */
public class PreservationListConfirmDeleteActionTest extends RhnBaseTestCase {
    private Action action = null;
    
    public void setUp() {
        action = new PreservationListConfirmDeleteAction();
    }
    
    public void testExecute() throws Exception {
        String rhnsetLabel = "file_lists";
        ActionHelper ah = new ActionHelper();
        ah.setUpAction(action);

        // we use the user created by the Helper
        User user = ah.getUser();
        
        RhnSet set = RhnSetDecl.FILE_LISTS.get(user);
        
        // we give the set some FileLists 
        for (int i = 0; i < 5; i++) {
            FileList fl = FileListTest.createTestFileList(
                                      ah.getUser().getOrg());
            CommonFactory.saveFileList(fl);
            set.addElement(fl.getId());
        }
        
        RhnSetManager.store(set);
        ah.setupClampListBounds();
        ah.getRequest().setupAddParameter("newset", (String)null);
        ah.getRequest().setupAddParameter("returnvisit", (String) null);
        ah.getRequest().setupAddParameter("submitted", "false");
        ah.executeAction();
       
        RhnMockHttpServletRequest request = ah.getRequest();
        
        RequestContext requestContext = new RequestContext(request);
        
        user = requestContext.getLoggedInUser();
        set = (RhnSet) request.getAttribute("set");
        
        DataResult dr = (DataResult) request.getAttribute("pageList");
        assertNotNull(dr);
        assertTrue(dr.size() > 0);
        assertNotNull(set);
        assertTrue(!set.isEmpty());
        assertEquals(rhnsetLabel, set.getLabel());
        
        // clean up
        Iterator i = set.getElements().iterator();
        while (i.hasNext()) {
            RhnSetElement elem = (RhnSetElement) i.next();
            FileList fl = CommonFactory.lookupFileList(elem.getElement(), 
                                                            user.getOrg());
            CommonFactory.removeFileList(fl);
        }
    }
}
