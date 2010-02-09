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
package com.redhat.rhn.domain.action.kickstart.test;


import com.redhat.rhn.domain.action.Action;
import com.redhat.rhn.domain.action.ActionFactory;
import com.redhat.rhn.domain.action.kickstart.KickstartAction;
import com.redhat.rhn.domain.action.kickstart.KickstartActionDetails;
import com.redhat.rhn.domain.action.kickstart.KickstartInitiateAction;
import com.redhat.rhn.domain.action.kickstart.KickstartScheduleSyncAction;
import com.redhat.rhn.domain.action.test.ActionFactoryTest;
import com.redhat.rhn.domain.common.FileList;
import com.redhat.rhn.testing.RhnBaseTestCase;
import com.redhat.rhn.testing.TestUtils;
import com.redhat.rhn.testing.UserTestUtils;

import java.util.Date;

/**
 * KickstartActionTest
 * @version $Rev$
 */
public class KickstartActionTest extends RhnBaseTestCase {

    /**
     * Test fetching a KickstartAction 
     * @throws Exception
     */
    public void testLookupKickstartAction() throws Exception {
        Action newA = ActionFactoryTest.createAction(UserTestUtils.createUser("testUser", 
            UserTestUtils.createOrg("testOrg")), ActionFactory.TYPE_KICKSTART_INITIATE);
        Long id = newA.getId();
        Action a = ActionFactory.lookupById(id);

        assertNotNull(a);
        assertTrue(a instanceof KickstartInitiateAction);
        KickstartAction k = (KickstartAction) a;
        assertNotNull(k.getKickstartActionDetails().getStaticDevice());
        assertNotNull(k.getEarliestAction());
    }
    
    public void testKickstartInitiateAction() throws Exception {

        Action newA = ActionFactoryTest
                          .createAction(UserTestUtils.createUser("testUser", 
                                        UserTestUtils.createOrg("testOrg")),
                                        ActionFactory.TYPE_KICKSTART_INITIATE);
        Long id = newA.getId();
        String appendTestString = "Append Test String";
        
        KickstartInitiateAction k = (KickstartInitiateAction) 
                                    ActionFactory.lookupById(id);
        KickstartActionDetails ksad = k.getKickstartActionDetails();
        ksad.setAppendString(appendTestString);
        ActionFactory.save(k);
        
        KickstartInitiateAction k2 = (KickstartInitiateAction) 
                                     ActionFactory.lookupById(id);
        KickstartActionDetails ksad2 = k2.getKickstartActionDetails();
        assertEquals(ksad2.getAppendString(), appendTestString);
        
        FileList f = new FileList();
        f.setLabel("TestingKSAction" + TestUtils.randomString());
        f.setOrg(k.getOrg());
        f.setCreated(new Date());
        f.setModified(new Date());
        TestUtils.saveAndFlush(f);
        
        ksad.addFileList(f);
        TestUtils.saveAndFlush(ksad);
        assertNotNull(ksad.getFileLists());
        assertEquals(ksad.getFileLists().size(), 1);        
        assertNotNull(k.getEarliestAction());
        
    }
    
    public void testKickstartScheduleSyncAction() throws Exception {

        Action newA = ActionFactoryTest
                        .createAction(UserTestUtils.createUser("testUser", 
                                      UserTestUtils.createOrg("testOrg")),
                                      ActionFactory.TYPE_KICKSTART_SCHEDULE_SYNC);
        Long id = newA.getId();
        String appendTestString = "Append Test String";
        
        KickstartScheduleSyncAction k = (KickstartScheduleSyncAction) 
                                        ActionFactory.lookupById(id);
        KickstartActionDetails ksad = k.getKickstartActionDetails();
        ksad.setAppendString(appendTestString);
        ActionFactory.save(k);
        
        KickstartScheduleSyncAction k2 = (KickstartScheduleSyncAction) 
                                         ActionFactory.lookupById(id);
        KickstartActionDetails ksad2 = k2.getKickstartActionDetails();
        assertEquals(ksad2.getAppendString(), appendTestString);
        
        FileList f = new FileList();
        f.setLabel("TestingKSAction" + TestUtils.randomString());
        f.setOrg(k.getOrg());
        f.setCreated(new Date());
        f.setModified(new Date());
        TestUtils.saveAndFlush(f);
        
        ksad.addFileList(f);
        assertNotNull(ksad.getFileLists());
        assertEquals(ksad.getFileLists().size(), 1);        
      
    }
}
